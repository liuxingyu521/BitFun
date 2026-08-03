import { configAPI } from '@/infrastructure/api/service-api/ConfigAPI';
import { createLogger } from '@/shared/utils/logger';
import {
  builtinAppearanceCatalog,
  getBuiltinAppearance,
  getSystemAppearanceId,
} from '../builtins/catalog';
import { composeAppearancePackage } from '../builtins/composeAppearancePackage';
import type { AppearancePackageParser } from '../schema/AppearancePackageParser';
import {
  noopAppearanceSyncPort,
  type AppearanceCommittedEvent,
  type AppearanceSyncPort,
} from '../sync/AppearanceSync';
import {
  SYSTEM_APPEARANCE_ID,
  type AppearanceCatalogEntry,
  type AppearancePackage,
  type AppearanceSelectionId,
  type AppearanceServiceSnapshot,
  type AppearanceStorage,
  type ResolvedAppearance,
  type StoredAppearanceAsset,
  type StoredAppearancePackage,
} from '../types';
import type { AppearanceRuntime } from './AppearanceRuntime';

const log = createLogger('AppearanceService');
const APPEARANCE_SELECTION_CONFIG_PATH = 'appearance.selection';
const MAX_SEEN_SYNC_EVENTS = 256;

interface AppearanceSource {
  pkg: AppearancePackage;
  assets: StoredAppearancePackage['assets'];
  importedAt?: string;
}

interface ApplySelectionOptions {
  persist: boolean;
  publish: boolean;
  initializeRuntime?: boolean;
  force?: boolean;
}

declare global {
  // Injected by the desktop webview initialization script before the frontend
  // bundle runs. Both values are single-use startup hints.
  var __BITFUN_BOOTSTRAP_APPEARANCE_ID__: string | undefined;
  var __BITFUN_BOOTSTRAP_APPEARANCE_SELECTION__: string | undefined;
}

function consumeBootstrapAppearance(): {
  resolvedId?: string;
  selection?: AppearanceSelectionId;
} {
  const resolvedId = globalThis.__BITFUN_BOOTSTRAP_APPEARANCE_ID__;
  const selection = globalThis.__BITFUN_BOOTSTRAP_APPEARANCE_SELECTION__;
  delete globalThis.__BITFUN_BOOTSTRAP_APPEARANCE_ID__;
  delete globalThis.__BITFUN_BOOTSTRAP_APPEARANCE_SELECTION__;
  return {
    resolvedId: typeof resolvedId === 'string' && resolvedId.trim() ? resolvedId.trim() : undefined,
    selection: typeof selection === 'string' && selection.trim() ? selection.trim() : undefined,
  };
}

function importedCatalogEntry(value: {
  id: string;
  name: string;
  author?: string;
  description?: string;
  version: string;
  mode: 'light' | 'dark';
  importedAt: string;
}): AppearanceCatalogEntry {
  return { ...value, source: 'imported' };
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function appearanceCatalogsEqual(
  left: readonly AppearanceCatalogEntry[],
  right: readonly AppearanceCatalogEntry[],
): boolean {
  if (left.length !== right.length) return false;
  return left.every((entry, index) => {
    const candidate = right[index];
    return entry.id === candidate.id
      && entry.name === candidate.name
      && entry.author === candidate.author
      && entry.description === candidate.description
      && entry.version === candidate.version
      && entry.mode === candidate.mode
      && entry.source === candidate.source
      && entry.importedAt === candidate.importedAt;
  });
}

function createEventId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID();
  }
  return `${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

export class AppearanceService {
  private snapshot: AppearanceServiceSnapshot = {
    initialized: false,
    status: 'initializing',
    selectedAppearanceId: SYSTEM_APPEARANCE_ID,
    resolvedAppearanceId: null,
    appearances: builtinAppearanceCatalog,
    current: null,
  };
  private listeners = new Set<(snapshot: AppearanceServiceSnapshot) => void>();
  private initializePromise: Promise<void> | null = null;
  private mutationQueue: Promise<void> = Promise.resolve();
  private systemMedia: MediaQueryList | null = null;
  private syncUnsubscribe: (() => void) | null = null;
  private reconciliationQueued = false;
  private activeSource: AppearanceSource | null = null;
  private persistedSelectionId: AppearanceSelectionId | null = null;
  private readonly sourceId = createEventId();
  private readonly seenSyncEvents = new Set<string>();

  private readonly handleSystemAppearanceChange = () => {
    void this.initialize()
      .then(() => this.enqueueMutation(async () => {
        if (this.snapshot.selectedAppearanceId !== SYSTEM_APPEARANCE_ID) return;
        await this.applySelectionTransaction(SYSTEM_APPEARANCE_ID, {
          persist: false,
          publish: false,
          force: true,
        });
      }))
      .catch(error => {
        log.error('Failed to follow system appearance', { error });
      });
  };
  private readonly handleWindowFocus = () => this.scheduleReconciliation();
  private readonly handleVisibilityChange = () => {
    if (typeof document === 'undefined' || document.visibilityState === 'visible') {
      this.scheduleReconciliation();
    }
  };

  constructor(
    private readonly runtime: AppearanceRuntime,
    private readonly parser: AppearancePackageParser,
    private readonly storage: AppearanceStorage,
    private readonly syncPort: AppearanceSyncPort = noopAppearanceSyncPort,
  ) {}

  initialize(): Promise<void> {
    if (this.initializePromise) return this.initializePromise;
    this.initializePromise = this.initializeInternal();
    return this.initializePromise;
  }

  getSnapshot(): AppearanceServiceSnapshot {
    return this.snapshot;
  }

  getPackage(id: string): Promise<AppearancePackage | null> {
    const builtin = getBuiltinAppearance(id);
    if (builtin) return Promise.resolve(builtin);
    return this.storage.get(id).then(stored => stored?.manifest ?? null);
  }

  async getPreviewAsset(id: string): Promise<StoredAppearanceAsset | null> {
    const stored = await this.storage.get(id);
    if (!stored) return null;
    const explicitId = stored.manifest.preview?.assetId;
    const fallbackId = explicitId
      ?? (stored.assets.preview?.mimeType.startsWith('image/') ? 'preview' : undefined)
      ?? (stored.assets.background?.mimeType.startsWith('image/') ? 'background' : undefined)
      ?? Object.keys(stored.assets).find(assetId => stored.assets[assetId].mimeType.startsWith('image/'));
    return fallbackId ? stored.assets[fallbackId] ?? null : null;
  }

  subscribe(listener: (snapshot: AppearanceServiceSnapshot) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  async select(id: AppearanceSelectionId): Promise<void> {
    await this.initialize();
    await this.enqueueMutation(() => this.applySelectionTransaction(id, {
      persist: true,
      publish: true,
    }));
  }

  async importPackage(source: ArrayBuffer): Promise<AppearanceCatalogEntry> {
    await this.initialize();
    const stored = await this.parser.parse(source);
    if (getBuiltinAppearance(stored.manifest.id)) {
      throw new Error(`Imported appearance cannot replace a builtin appearance: ${stored.manifest.id}`);
    }
    const composed = composeAppearancePackage(stored.manifest);
    this.runtime.preflight(composed, stored.assets);

    return this.enqueueMutation(async () => {
      const id = stored.manifest.id;
      const previousStored = await this.storage.get(id);
      const previousSnapshot = this.snapshot;
      const previousSource = this.activeSource;
      const active = previousSnapshot.selectedAppearanceId === id;
      let applied: ResolvedAppearance | null = null;
      let storageCommitted = false;
      this.setApplying(active ? id : undefined);

      try {
        if (active) applied = await this.runtime.applyPackage(composed, stored.assets);
        await this.storage.put(stored);
        storageCommitted = true;
        const appearances = await this.loadCatalog();
        if (active && applied) {
          this.activeSource = { pkg: composed, assets: stored.assets, importedAt: stored.importedAt };
        }
        this.setSnapshot({
          ...previousSnapshot,
          status: 'ready',
          pendingSelectionId: undefined,
          lastError: undefined,
          appearances,
          ...(applied ? { current: applied, resolvedAppearanceId: id } : {}),
        });
        const imported = appearances.find(item => item.id === id);
        if (!imported) throw new Error(`Imported appearance catalog entry is missing: ${id}`);
        await this.publish({
          kind: 'package-upserted',
          eventId: createEventId(),
          sourceId: this.sourceId,
          packageId: id,
          version: stored.manifest.version,
        });
        return imported;
      } catch (error) {
        const compensationErrors: string[] = [];
        if (storageCommitted) {
          try {
            await this.restoreStoredPackage(id, previousStored);
          } catch (restoreError) {
            compensationErrors.push(`storage rollback failed: ${errorMessage(restoreError)}`);
          }
        }
        let restoredCurrent = previousSnapshot.current;
        let restoredResolvedAppearanceId = previousSnapshot.resolvedAppearanceId;
        if (active) {
          try {
            restoredCurrent = await this.restoreRuntime(previousSource, previousSnapshot.current);
            this.activeSource = previousSource;
          } catch (restoreError) {
            compensationErrors.push(`runtime rollback failed: ${errorMessage(restoreError)}`);
            const runtimeSnapshot = this.runtime.getSnapshot();
            restoredCurrent = runtimeSnapshot;
            restoredResolvedAppearanceId = runtimeSnapshot?.id ?? null;
            this.activeSource = runtimeSnapshot?.id === id
              ? { pkg: composed, assets: stored.assets, importedAt: stored.importedAt }
              : previousSource;
          }
        } else {
          this.activeSource = previousSource;
        }
        this.setSnapshot({
          ...previousSnapshot,
          status: compensationErrors.length > 0 ? 'degraded' : 'ready',
          pendingSelectionId: undefined,
          lastError: [errorMessage(error), ...compensationErrors].join('; '),
          current: restoredCurrent,
          resolvedAppearanceId: restoredResolvedAppearanceId,
        });
        throw error;
      }
    });
  }

  async exportPackage(id: string): Promise<ArrayBuffer> {
    const stored = await this.storage.get(id);
    if (!stored) throw new Error(`Imported appearance package not found: ${id}`);
    return stored.archive.slice(0);
  }

  activate(id: string): Promise<void> {
    return this.select(id);
  }

  deactivate(): Promise<void> {
    return this.select(SYSTEM_APPEARANCE_ID);
  }

  async deletePackage(id: string): Promise<void> {
    await this.initialize();
    await this.enqueueMutation(async () => {
      if (getBuiltinAppearance(id)) throw new Error(`Builtin appearance cannot be deleted: ${id}`);
      const previousStored = await this.storage.get(id);
      const previousSnapshot = this.snapshot;
      const wasActive = previousSnapshot.selectedAppearanceId === id;
      let storageCommitted = false;
      try {
        await this.storage.delete(id);
        storageCommitted = true;
        const appearances = await this.loadCatalog();
        if (wasActive) {
          await this.applySelectionTransaction(SYSTEM_APPEARANCE_ID, {
            persist: true,
            publish: false,
          });
        }
        this.setSnapshot({ ...this.snapshot, appearances });
      } catch (error) {
        const compensationErrors: string[] = [];
        const selectionCompensationDegraded = this.snapshot.status === 'degraded';
        if (storageCommitted && previousStored) {
          try {
            await this.storage.put(previousStored);
          } catch (restoreError) {
            compensationErrors.push(`storage rollback failed: ${errorMessage(restoreError)}`);
          }
        }
        if (selectionCompensationDegraded) {
          compensationErrors.push('selection rollback did not fully restore persisted state');
        }
        const currentSnapshot = this.runtime.getSnapshot();
        const selectedAppearanceId = currentSnapshot?.id === getSystemAppearanceId()
          ? SYSTEM_APPEARANCE_ID
          : previousSnapshot.selectedAppearanceId;
        this.setSnapshot({
          ...previousSnapshot,
          status: compensationErrors.length > 0 ? 'degraded' : 'ready',
          pendingSelectionId: undefined,
          lastError: [errorMessage(error), ...compensationErrors].join('; '),
          selectedAppearanceId,
          current: currentSnapshot ?? previousSnapshot.current,
          resolvedAppearanceId: currentSnapshot?.id ?? previousSnapshot.resolvedAppearanceId,
        });
        throw error;
      }
      if (wasActive) await this.publishSelection(SYSTEM_APPEARANCE_ID);
      await this.publish({
        kind: 'package-deleted',
        eventId: createEventId(),
        sourceId: this.sourceId,
        packageId: id,
      });
    });
  }

  async dispose(): Promise<void> {
    this.detachSystemListener();
    this.detachReconciliationListeners();
    this.syncUnsubscribe?.();
    this.syncUnsubscribe = null;
    this.syncPort.dispose?.();
    await this.runtime.dispose();
    this.activeSource = null;
  }

  private async initializeInternal(): Promise<void> {
    this.attachSyncListener();
    this.setSnapshot({ ...this.snapshot, appearances: await this.loadCatalog() });
    const bootstrap = consumeBootstrapAppearance();
    const configuredSelection = bootstrap.selection
      ?? await configAPI.getConfig(APPEARANCE_SELECTION_CONFIG_PATH, { skipRetryOnNotFound: true });
    const selected = typeof configuredSelection === 'string' && configuredSelection.trim()
      ? configuredSelection.trim()
      : SYSTEM_APPEARANCE_ID;
    this.persistedSelectionId = selected;
    try {
      await this.applySelectionTransaction(selected, {
        persist: false,
        publish: false,
        initializeRuntime: true,
        force: true,
      });
      if (bootstrap.resolvedId && bootstrap.resolvedId !== this.snapshot.resolvedAppearanceId) {
        log.debug('Desktop bootstrap appearance differed from the initialized runtime appearance', {
          bootstrapAppearanceId: bootstrap.resolvedId,
          runtimeAppearanceId: this.snapshot.resolvedAppearanceId,
        });
      }
    } catch (error) {
      log.error('Configured appearance activation failed', { appearanceId: selected, error });
      await this.applySelectionTransaction(SYSTEM_APPEARANCE_ID, {
        persist: false,
        publish: false,
        initializeRuntime: true,
        force: true,
      });
      this.setSnapshot({
        ...this.snapshot,
        status: 'degraded',
        lastError: errorMessage(error),
      });
    }
    this.attachSystemListener();
    this.attachReconciliationListeners();
  }

  private async applySelectionTransaction(
    selected: AppearanceSelectionId,
    options: ApplySelectionOptions,
  ): Promise<void> {
    const resolvedId = selected === SYSTEM_APPEARANCE_ID ? getSystemAppearanceId() : selected;
    const unchanged = this.snapshot.initialized
      && this.snapshot.selectedAppearanceId === selected
      && this.snapshot.resolvedAppearanceId === resolvedId
      && (!options.persist || this.persistedSelectionId === selected);
    if (unchanged && !options.force) return;

    const resolved = await this.resolvePackage(resolvedId);
    if (!resolved) throw new Error(`Appearance package not found: ${resolvedId}`);
    this.runtime.preflight(resolved.pkg, resolved.assets);

    const previousSnapshot = this.snapshot;
    const previousSource = this.activeSource;
    const previousPersistedSelectionId = this.persistedSelectionId;
    this.setApplying(selected);
    let runtimeApplied = false;
    let persistenceAttempted = false;
    try {
      const current = options.initializeRuntime
        ? await this.runtime.initialize(resolved.pkg, resolved.assets)
        : await this.runtime.applyPackage(resolved.pkg, resolved.assets);
      runtimeApplied = true;
      if (options.persist) {
        persistenceAttempted = true;
        await configAPI.setConfig(APPEARANCE_SELECTION_CONFIG_PATH, selected);
        this.persistedSelectionId = selected;
      }
      this.activeSource = resolved;
      this.setSnapshot({
        ...previousSnapshot,
        initialized: true,
        status: 'ready',
        pendingSelectionId: undefined,
        lastError: undefined,
        selectedAppearanceId: selected,
        resolvedAppearanceId: resolvedId,
        current,
      });
      if (options.publish) await this.publishSelection(selected);
    } catch (error) {
      const compensationErrors: string[] = [];
      if (persistenceAttempted && previousPersistedSelectionId !== null) {
        try {
          await configAPI.setConfig(APPEARANCE_SELECTION_CONFIG_PATH, previousPersistedSelectionId);
          this.persistedSelectionId = previousPersistedSelectionId;
        } catch (rollbackError) {
          compensationErrors.push(`selection rollback failed: ${errorMessage(rollbackError)}`);
        }
      }
      let restoredCurrent = previousSnapshot.current;
      if (runtimeApplied) {
        try {
          restoredCurrent = await this.restoreRuntime(previousSource, previousSnapshot.current);
        } catch (rollbackError) {
          compensationErrors.push(`runtime rollback failed: ${errorMessage(rollbackError)}`);
          const runtimeSnapshot = this.runtime.getSnapshot();
          this.activeSource = runtimeSnapshot?.id === resolvedId ? resolved : previousSource;
          this.setSnapshot({
            ...previousSnapshot,
            initialized: true,
            status: 'degraded',
            pendingSelectionId: undefined,
            lastError: [errorMessage(error), ...compensationErrors].join('; '),
            selectedAppearanceId: runtimeSnapshot?.id === resolvedId
              ? selected
              : previousSnapshot.selectedAppearanceId,
            resolvedAppearanceId: runtimeSnapshot?.id ?? null,
            current: runtimeSnapshot,
          });
          throw error;
        }
      }
      this.activeSource = previousSource;
      this.setSnapshot({
        ...previousSnapshot,
        status: compensationErrors.length > 0
          ? 'degraded'
          : previousSnapshot.initialized ? 'ready' : 'initializing',
        pendingSelectionId: undefined,
        lastError: [errorMessage(error), ...compensationErrors].join('; '),
        current: restoredCurrent,
      });
      throw error;
    }
  }

  private async restoreRuntime(
    source: AppearanceSource | null,
    fallback: ResolvedAppearance | null,
  ): Promise<ResolvedAppearance | null> {
    if (!source) return fallback;
    return this.runtime.applyPackage(source.pkg, source.assets);
  }

  private async restoreStoredPackage(
    id: string,
    previous: StoredAppearancePackage | null,
  ): Promise<void> {
    try {
      if (previous) await this.storage.put(previous);
      else await this.storage.delete(id);
    } catch (error) {
      log.error('Failed to restore appearance package storage', { appearanceId: id, error });
      throw error;
    }
  }

  private async resolvePackage(id: string): Promise<AppearanceSource | null> {
    const builtin = getBuiltinAppearance(id);
    if (builtin) return { pkg: builtin, assets: {} };
    const stored = await this.storage.get(id);
    return stored ? {
      pkg: composeAppearancePackage(stored.manifest),
      assets: stored.assets,
      importedAt: stored.importedAt,
    } : null;
  }

  private async loadCatalog(): Promise<readonly AppearanceCatalogEntry[]> {
    const imported = (await this.storage.listCatalog()).map(importedCatalogEntry);
    return [...builtinAppearanceCatalog, ...imported];
  }

  private attachSystemListener(): void {
    if (this.systemMedia || typeof window === 'undefined' || typeof window.matchMedia !== 'function') return;
    this.systemMedia = window.matchMedia('(prefers-color-scheme: dark)');
    this.systemMedia.addEventListener('change', this.handleSystemAppearanceChange);
  }

  private detachSystemListener(): void {
    this.systemMedia?.removeEventListener('change', this.handleSystemAppearanceChange);
    this.systemMedia = null;
  }

  private attachReconciliationListeners(): void {
    if (typeof window !== 'undefined' && typeof window.addEventListener === 'function') {
      window.addEventListener('focus', this.handleWindowFocus);
    }
    if (typeof document !== 'undefined' && typeof document.addEventListener === 'function') {
      document.addEventListener('visibilitychange', this.handleVisibilityChange);
    }
  }

  private detachReconciliationListeners(): void {
    if (typeof window !== 'undefined' && typeof window.removeEventListener === 'function') {
      window.removeEventListener('focus', this.handleWindowFocus);
    }
    if (typeof document !== 'undefined' && typeof document.removeEventListener === 'function') {
      document.removeEventListener('visibilitychange', this.handleVisibilityChange);
    }
  }

  private scheduleReconciliation(): void {
    if (this.reconciliationQueued) return;
    this.reconciliationQueued = true;
    void this.initialize()
      .then(() => this.enqueueMutation(() => this.reconcileExternalState()))
      .catch(error => {
        log.error('Failed to reconcile appearance state', { error });
        this.setSnapshot({
          ...this.snapshot,
          status: 'degraded',
          pendingSelectionId: undefined,
          lastError: errorMessage(error),
        });
      })
      .finally(() => {
        this.reconciliationQueued = false;
      });
  }

  private async reconcileExternalState(): Promise<void> {
    const configuredSelection = await configAPI.getConfig(
      APPEARANCE_SELECTION_CONFIG_PATH,
      { skipRetryOnNotFound: true },
    );
    const selected = typeof configuredSelection === 'string' && configuredSelection.trim()
      ? configuredSelection.trim()
      : SYSTEM_APPEARANCE_ID;
    const appearances = await this.loadCatalog();
    this.persistedSelectionId = selected;
    if (!appearanceCatalogsEqual(this.snapshot.appearances, appearances)) {
      this.setSnapshot({ ...this.snapshot, appearances });
    }

    const resolvedId = selected === SYSTEM_APPEARANCE_ID ? getSystemAppearanceId() : selected;
    const importedSelection = !getBuiltinAppearance(resolvedId);
    const importedEntry = importedSelection
      ? appearances.find(entry => entry.id === resolvedId && entry.source === 'imported')
      : undefined;
    const activeSource = this.activeSource;
    const importedSourceChanged = importedSelection && (
      !importedEntry
      || !activeSource
      || activeSource.pkg.id !== resolvedId
      || activeSource.pkg.version !== importedEntry.version
      || activeSource.importedAt !== importedEntry.importedAt
    );
    const needsApply = this.snapshot.selectedAppearanceId !== selected
      || this.snapshot.resolvedAppearanceId !== resolvedId
      || importedSourceChanged;
    if (!needsApply) return;

    try {
      await this.applySelectionTransaction(selected, {
        persist: false,
        publish: false,
        force: true,
      });
    } catch (error) {
      await this.applySelectionTransaction(SYSTEM_APPEARANCE_ID, {
        persist: false,
        publish: false,
        force: true,
      });
      this.setSnapshot({
        ...this.snapshot,
        status: 'degraded',
        lastError: errorMessage(error),
      });
    }
  }

  private attachSyncListener(): void {
    if (this.syncUnsubscribe) return;
    this.syncUnsubscribe = this.syncPort.subscribe(event => {
      if (event.sourceId === this.sourceId || this.seenSyncEvents.has(event.eventId)) return;
      this.rememberSyncEvent(event.eventId);
      void this.initialize()
        .then(() => this.enqueueMutation(() => this.applySyncEvent(event)))
        .catch(error => {
          log.error('Failed to synchronize appearance mutation', { event, error });
          this.setSnapshot({
            ...this.snapshot,
            status: 'degraded',
            pendingSelectionId: undefined,
            lastError: errorMessage(error),
          });
        });
    });
  }

  private async applySyncEvent(event: AppearanceCommittedEvent): Promise<void> {
    if (event.kind === 'selection-changed') {
      this.persistedSelectionId = event.selectionId;
      await this.applySelectionTransaction(event.selectionId, {
        persist: false,
        publish: false,
        force: true,
      });
      return;
    }

    const appearances = await this.loadCatalog();
    this.setSnapshot({ ...this.snapshot, appearances });
    if (event.kind === 'package-upserted') {
      if (this.snapshot.selectedAppearanceId === event.packageId) {
        await this.applySelectionTransaction(event.packageId, {
          persist: false,
          publish: false,
          force: true,
        });
      }
      return;
    }

    if (this.snapshot.selectedAppearanceId === event.packageId) {
      await this.applySelectionTransaction(SYSTEM_APPEARANCE_ID, {
        persist: false,
        publish: false,
        force: true,
      });
    }
  }

  private async publishSelection(selectionId: AppearanceSelectionId): Promise<void> {
    await this.publish({
      kind: 'selection-changed',
      eventId: createEventId(),
      sourceId: this.sourceId,
      selectionId,
    });
  }

  private async publish(event: AppearanceCommittedEvent): Promise<void> {
    try {
      await this.syncPort.publish(event);
    } catch (error) {
      log.warn('Failed to publish appearance mutation', { event, error });
    }
  }

  private rememberSyncEvent(eventId: string): void {
    this.seenSyncEvents.add(eventId);
    if (this.seenSyncEvents.size <= MAX_SEEN_SYNC_EVENTS) return;
    const oldest = this.seenSyncEvents.values().next().value as string | undefined;
    if (oldest) this.seenSyncEvents.delete(oldest);
  }

  private enqueueMutation<T>(operation: () => Promise<T>): Promise<T> {
    const result = this.mutationQueue.then(operation, operation);
    this.mutationQueue = result.then(() => undefined, () => undefined);
    return result;
  }

  private setApplying(pendingSelectionId?: AppearanceSelectionId): void {
    this.setSnapshot({
      ...this.snapshot,
      status: 'applying',
      pendingSelectionId,
      lastError: undefined,
    });
  }

  private setSnapshot(snapshot: AppearanceServiceSnapshot): void {
    this.snapshot = Object.freeze({
      ...snapshot,
      appearances: Object.freeze([...snapshot.appearances]),
    });
    this.listeners.forEach(listener => listener(this.snapshot));
  }
}
