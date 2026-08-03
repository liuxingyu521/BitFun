import { useSyncExternalStore } from 'react';
import { appearanceService } from '../index';

const getPreviewAsset = (id: string) => appearanceService.getPreviewAsset(id);

export function useAppearance() {
  const snapshot = useSyncExternalStore(
    listener => appearanceService.subscribe(listener),
    () => appearanceService.getSnapshot(),
    () => appearanceService.getSnapshot(),
  );
  return {
    ...snapshot,
    select: (id: string) => appearanceService.select(id),
    getPackage: (id: string) => appearanceService.getPackage(id),
    getPreviewAsset,
    importPackage: (source: ArrayBuffer) => appearanceService.importPackage(source),
    exportPackage: (id: string) => appearanceService.exportPackage(id),
    activate: (id: string) => appearanceService.activate(id),
    deactivate: () => appearanceService.deactivate(),
    deletePackage: (id: string) => appearanceService.deletePackage(id),
  };
}
