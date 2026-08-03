import { describe, it, expect } from '@ohos/hypium';
import { RemoteI18n } from '../main/ets/i18n/RemoteI18n';
import { ChatSessionController, ChatSessionSnapshot } from '../main/ets/services/ChatSessionController';
import { ChatComposerPolicy } from '../main/ets/services/ChatComposerPolicy';
import { ChatTimelineItem, ChatTimelineProjector } from '../main/ets/services/ChatTimelineProjector';
import { ChatTimelineStore } from '../main/ets/services/ChatTimelineStore';
import { ConversationEvent } from '../main/ets/services/ConversationEvent';
import { AsyncLifecycleGate } from '../main/ets/services/AsyncLifecycleGate';
import { Encoding } from '../main/ets/services/Encoding';
import {
  GeneralChatDraftStore,
  GeneralChatLocalStore,
  GeneralChatSendResult,
  GeneralChatStreamCallbacks,
  GeneralChatStreamObserver
} from '../main/ets/services/general-chat/GeneralChatPort';
import { GeneralChatApiClient } from '../main/ets/services/general-chat/GeneralChatApiClient';
import { GeneralChatBootstrapController } from '../main/ets/services/general-chat/GeneralChatBootstrapController';
import { GeneralChatCommandClient, GeneralChatCommandController } from '../main/ets/services/general-chat/GeneralChatCommandController';
import {
  GeneralChatConfigSnapshot,
  GeneralChatConfigStore,
  GeneralChatConfigValidator
} from '../main/ets/services/general-chat/GeneralChatConfigStore';
import { GeneralChatDraftController, GeneralChatDraftScheduler } from '../main/ets/services/general-chat/GeneralChatDraftController';
import { GeneralChatDraftLifecycleController } from '../main/ets/services/general-chat/GeneralChatDraftLifecycleController';
import { GeneralChatEventMapper } from '../main/ets/services/general-chat/GeneralChatEventMapper';
import { GeneralChatExportFormatter } from '../main/ets/services/general-chat/GeneralChatExportFormatter';
import {
  GeneralChatHttpHeaders,
  GeneralChatHttpMethod,
  GeneralChatHttpResponse,
  GeneralChatHttpTransport,
  GeneralChatTokenProvider
} from '../main/ets/services/general-chat/GeneralChatHttpTransport';
import { GeneralChatRepository } from '../main/ets/services/general-chat/GeneralChatRepository';
import {
  GeneralChatServiceState,
  GeneralChatServiceStatus
} from '../main/ets/services/general-chat/GeneralChatServiceState';
import { GeneralChatStreamCoordinator } from '../main/ets/services/general-chat/GeneralChatStreamCoordinator';
import { GeneralChatStreamLifecycleController } from '../main/ets/services/general-chat/GeneralChatStreamLifecycleController';
import {
  ModelProviderGeneralChatAdapter,
  ModelProviderMessage,
  ModelProviderProtocol
} from '../main/ets/services/general-chat/ModelProviderGeneralChatAdapter';
import { ModelProviderSseParser } from '../main/ets/services/general-chat/ModelProviderSseParser';
import { MockGeneralChatAdapter } from '../main/ets/services/general-chat/MockGeneralChatAdapter';
import { MarkdownParser } from '../main/ets/services/MarkdownParser';
import { RemoteCommandFactory } from '../main/ets/services/RemoteCommandFactory';
import { RemoteCrypto, RemoteCryptoCipher } from '../main/ets/services/RemoteCrypto';
import { RemoteDescriptorParser } from '../main/ets/services/RemoteDescriptorParser';
import { RemoteActivityLifecycleController } from '../main/ets/services/RemoteActivityLifecycleController';
import { RemoteChatCommandClient, RemoteChatCommandController } from '../main/ets/services/RemoteChatCommandController';
import { RemoteChatPollingLifecycleController } from '../main/ets/services/RemoteChatPollingLifecycleController';
import {
  RemoteFileDownloadClient,
  RemoteFileDownloadController,
  RemoteFileDownloadScheduler
} from '../main/ets/services/RemoteFileDownloadController';
import { RemoteHeartbeatController, RemoteHeartbeatScheduler } from '../main/ets/services/RemoteHeartbeatController';
import {
  RemoteModelClient,
  RemoteModelController,
  RemoteModelPreferenceStore
} from '../main/ets/services/RemoteModelController';
import { RemotePairingPolicy } from '../main/ets/services/RemotePairingPolicy';
import { RemoteResponseMapper } from '../main/ets/services/RemoteResponseMapper';
import { RemoteSessionClient, RemoteSessionController } from '../main/ets/services/RemoteSessionController';
import { RemoteSessionManager } from '../main/ets/services/RemoteSessionManager';
import { RemoteWorkspaceCoordinator } from '../main/ets/services/RemoteWorkspaceCoordinator';
import { RemoteWorkspaceDataSource } from '../main/ets/services/RemoteWorkspaceRepository';
import { RemoteToolActionClient, RemoteToolActionController } from '../main/ets/services/RemoteToolActionController';
import { RemoteUiState } from '../main/ets/services/RemoteUiState';
import {
  VoiceInputLifecycleCallbacks,
  VoiceInputLifecycleController,
  VoiceInputRouteSnapshot
} from '../main/ets/services/VoiceInputLifecycleController';
import { VoiceInputCallbacks, VoiceInputService } from '../main/ets/services/VoiceInputService';
import { AppShellState } from '../main/ets/pages/state/AppShellState';
import { GeneralChatPageState } from '../main/ets/pages/state/GeneralChatPageState';
import { RemotePageState } from '../main/ets/pages/state/RemotePageState';
import { ConversationViewState } from '../main/ets/pages/state/ConversationViewState';
import {
  ConversationLayoutCrease,
  ConversationLayoutPolicy
} from '../main/ets/pages/state/ConversationLayoutPolicy';
import {
  GENERAL_CHAT_COMPOSER_CAPABILITIES,
  REMOTE_CHAT_COMPOSER_CAPABILITIES
} from '../main/ets/pages/components/ChatComposerCapabilities';
import { ChatSurface } from '../main/ets/pages/components/ChatSurface';
import { ConversationViewContract } from '../main/ets/pages/components/ConversationViewContract';
import {
  AppNavigationBackAction,
  AppNavigationPathSpec,
  AppRoute,
  AppRouteContract,
  ConversationSource
} from '../main/ets/pages/navigation/AppRouteContract';
import { TimeFormat } from '../main/ets/services/TimeFormat';
import { X25519 } from '../main/ets/services/X25519';
import {
  ChatMessage,
  FileInfo,
  ImageAttachment,
  PollSessionResult,
  RecentWorkspaceEntry,
  AssistantEntry,
  CreateSessionOptions,
  RemoteImageContext,
  RemoteQuestionAnswerPayload,
  RemoteModelCatalog,
  ReadFileResult,
  RemoteSession,
  SelectedImageAttachment,
  SessionListResult,
  SessionMessagesResult,
  SessionSummary,
  WorkspaceInfo
} from '../main/ets/model/RemoteModels';

import {
  ToolInputFixture,
  CryptoImageFixture,
  CryptoCommandFixture,
  CryptoSimpleCommandFixture,
  GeneralChatRecordedRequest,
  FakeRemoteWorkspaceDataSource,
  FakeRemoteCryptoCipher,
  hexToBytes,
  bytesToHex,
  fixedRandomBytes,
  expectCommandJson,
  connectedPeers,
  chatMessage,
  remoteSession,
  selectedImage,
  remoteModelCatalog,
  activeChatMessage,
  chatMessageWithImage,
  imageAttachment,
  pollResult,
  delay,
  FakePollSessionManager,
  BlockingPollSessionManager,
  FakeGeneralChatLocalStore,
  FailingGeneralChatAdapter,
  PartialFailingGeneralChatAdapter,
  FakeGeneralChatTokenProvider,
  FakeGeneralChatHttpTransport,
  FakeRemoteHeartbeatScheduler,
  FakeGeneralChatDraftScheduler,
  FakeVoiceInputLifecycleService,
  FakeRemoteFileDownloadScheduler,
  FakeRemoteFileDownloadClient,
  FakeRemoteFileSaver,
  RemoteDownloadStatusRecord,
  FakeRemoteToolActionClient,
  FakeRemoteModelClient,
  FakeRemoteModelPreferenceStore,
  RemoteModelProjectionRecord,
  FakeRemoteSessionClient,
  RemoteSessionProjectionRecord,
  FakeRemoteChatCommandClient,
  RemoteChatMessagesProjectionRecord,
  FakeGeneralChatCommandClient,
  FakeGeneralChatConfigStore
} from './LocalTestFixtures';

export default function remoteControllersUnitTest() {
  describe('RemoteFileDownloadController', () => {
    it('owns remote file download progress and delayed downloading marker cleanup', 0, async () => {
      const client = new FakeRemoteFileDownloadClient();
      const scheduler = new FakeRemoteFileDownloadScheduler();
      const fileSaver = new FakeRemoteFileSaver();
      const status = new RemoteDownloadStatusRecord();
      const busyEvents: boolean[] = [];
      let statusText = '';
      const controller = new RemoteFileDownloadController(
        client,
        (downloadingFilePath: string, downloadedFilePath: string, fileDownloadStatus: string) => {
          status.downloadingFilePath = downloadingFilePath;
          status.downloadedFilePath = downloadedFilePath;
          status.fileDownloadStatus = fileDownloadStatus;
        },
        () => {
          status.downloadingFilePath = '';
        },
        (nextStatusText: string) => {
          statusText = nextStatusText;
        },
        (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        100,
        scheduler,
        fileSaver
      );

      await controller.download('/workspace/BitFun/README.md', 'session-1', false, true);

      expect(client.infoRequests[0]).assertEqual('/workspace/BitFun/README.md|session-1');
      expect(client.readRequests[0]).assertEqual('/workspace/BitFun/README.md|session-1');
      expect(fileSaver.savedNames[0]).assertEqual('README.md');
      expect(status.downloadedFilePath).assertEqual('/workspace/BitFun/README.md');
      expect(status.fileDownloadStatus.indexOf('README.md') >= 0).assertTrue();
      expect(statusText).assertEqual(status.fileDownloadStatus);
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
      expect(controller.isClearPending()).assertTrue();
      expect(scheduler.delays.get(1)).assertEqual(100);

      scheduler.tick(1);
      expect(status.downloadingFilePath).assertEqual('');
      expect(status.downloadedFilePath).assertEqual('/workspace/BitFun/README.md');
    });

    it('skips unavailable downloads before touching the client', 0, async () => {
      const client = new FakeRemoteFileDownloadClient();
      const scheduler = new FakeRemoteFileDownloadScheduler();
      const status = new RemoteDownloadStatusRecord();
      const controller = new RemoteFileDownloadController(
        client,
        (downloadingFilePath: string, downloadedFilePath: string, fileDownloadStatus: string) => {
          status.downloadingFilePath = downloadingFilePath;
          status.downloadedFilePath = downloadedFilePath;
          status.fileDownloadStatus = fileDownloadStatus;
        },
        () => {
          status.downloadingFilePath = '';
        },
        (_statusText: string) => {},
        (_isBusy: boolean) => {},
        100,
        scheduler
      );

      await controller.download('', 'session-1', false, true);
      await controller.download('/workspace/BitFun/README.md', '', false, true);
      await controller.download('/workspace/BitFun/README.md', 'session-1', true, true);
      await controller.download('/workspace/BitFun/README.md', 'session-1', false, false);

      expect(client.infoRequests.length).assertEqual(0);
      expect(client.readRequests.length).assertEqual(0);
      expect(status.fileDownloadStatus).assertEqual('');
    });
  });

  describe('RemoteToolActionController', () => {
    it('owns remote tool action status, busy, and poll callbacks', 0, async () => {
      const client = new FakeRemoteToolActionClient();
      const busyEvents: boolean[] = [];
      const statuses: string[] = [];
      let pollCount = 0;
      const controller = new RemoteToolActionController(
        client,
        (statusText: string) => {
          statuses.push(statusText);
        },
        (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        () => {
          pollCount += 1;
        }
      );

      const updatedInput: ToolInputFixture = { safe: true };
      await controller.approve('tool-1', 'session-1', true, updatedInput);
      await controller.reject('tool-2', 'session-1', true);
      await controller.cancel('tool-3', 'session-1', true);
      await controller.answer('tool-4', 'session-1', true, { answer: 'yes', '0': 'yes' });

      expect(client.actions[0]).assertEqual('confirm:tool-1:{"safe":true}');
      expect(client.actions[1]).assertEqual('reject:tool-2:Rejected from HarmonyOS remote client');
      expect(client.actions[2]).assertEqual('cancel:tool-3:Cancelled from HarmonyOS remote client');
      expect(client.actions[3].indexOf('answer:tool-4:') === 0).assertTrue();
      expect(client.actions[3].indexOf('"answer":"yes"') >= 0).assertTrue();
      expect(client.actions[3].indexOf('"0":"yes"') >= 0).assertTrue();
      expect(pollCount).assertEqual(4);
      expect(busyEvents.length).assertEqual(8);
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
      expect(statuses.indexOf(RemoteI18n.t('status.approvingTool')) >= 0).assertTrue();
      expect(statuses.indexOf(RemoteI18n.t('status.toolApproved')) >= 0).assertTrue();
    });

    it('runs available tool actions and skips invalid route state', 0, async () => {
      const client = new FakeRemoteToolActionClient();
      const busyEvents: boolean[] = [];
      let pollCount = 0;
      const controller = new RemoteToolActionController(
        client,
        (_statusText: string) => {},
        (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        () => {
          pollCount += 1;
        }
      );

      await controller.approve('', 'session-1', true);
      await controller.approve('tool-1', '', true);
      await controller.approve('tool-1', 'session-1', true);
      await controller.approve('tool-1', 'session-1', false);

      expect(client.actions.length).assertEqual(1);
      expect(client.actions[0]).assertEqual('confirm:tool-1:{}');
      expect(busyEvents.length).assertEqual(2);
      expect(pollCount).assertEqual(1);
    });

    it('reports failed tool actions and clears busy without polling', 0, async () => {
      const client = new FakeRemoteToolActionClient();
      client.shouldFail = true;
      const busyEvents: boolean[] = [];
      const statuses: string[] = [];
      let pollCount = 0;
      const controller = new RemoteToolActionController(
        client,
        (statusText: string) => {
          statuses.push(statusText);
        },
        (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        () => {
          pollCount += 1;
        }
      );

      await controller.reject('tool-1', 'session-1', true);

      expect(client.actions.length).assertEqual(1);
      expect(pollCount).assertEqual(0);
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
      expect(statuses[statuses.length - 1].indexOf('Expected tool action failure') >= 0).assertTrue();
    });
  });

  describe('RemoteModelController', () => {
    it('loads model catalog and applies the saved preferred model when still current', 0, async () => {
      const client = new FakeRemoteModelClient();
      const preferences = new FakeRemoteModelPreferenceStore();
      const resets: RemoteModelProjectionRecord[] = [];
      const applied: RemoteModelProjectionRecord[] = [];
      const controller = new RemoteModelController(
        client,
        preferences,
        (modelCatalog: RemoteModelCatalog, selectedModelId: string, knownModelCatalogVersion: number) => {
          const record = new RemoteModelProjectionRecord();
          record.version = knownModelCatalogVersion;
          record.selectedModelId = selectedModelId;
          record.sessionModelId = modelCatalog.session_model_id || '';
          record.modelCount = modelCatalog.models.length;
          resets.push(record);
        },
        (modelCatalog: RemoteModelCatalog, selectedModelId: string, knownModelCatalogVersion: number) => {
          const record = new RemoteModelProjectionRecord();
          record.version = knownModelCatalogVersion;
          record.selectedModelId = selectedModelId;
          record.sessionModelId = modelCatalog.session_model_id || '';
          record.modelCount = modelCatalog.models.length;
          applied.push(record);
        },
        (_statusText: string) => {},
        (_isBusy: boolean) => {}
      );

      controller.setPreferredModelId('model-b');
      await controller.loadCatalog('session-1', true, (sessionId: string) => sessionId === 'session-1');

      expect(client.catalogRequests[0]).assertEqual('session-1');
      expect(resets.length).assertEqual(1);
      expect(resets[0].modelCount).assertEqual(0);
      expect(applied.length).assertEqual(1);
      expect(applied[0].version).assertEqual(2);
      expect(applied[0].selectedModelId).assertEqual('model-b');
      expect(applied[0].modelCount).assertEqual(2);
    });

    it('ignores stale catalog loads after clearing the visible projection', 0, async () => {
      const client = new FakeRemoteModelClient();
      const preferences = new FakeRemoteModelPreferenceStore();
      let resetCount = 0;
      let appliedCount = 0;
      const controller = new RemoteModelController(
        client,
        preferences,
        (_modelCatalog: RemoteModelCatalog, _selectedModelId: string, _knownModelCatalogVersion: number) => {
          resetCount += 1;
        },
        (_modelCatalog: RemoteModelCatalog, _selectedModelId: string, _knownModelCatalogVersion: number) => {
          appliedCount += 1;
        },
        (_statusText: string) => {},
        (_isBusy: boolean) => {}
      );

      await controller.loadCatalog('session-1', true, (_sessionId: string) => false);

      expect(client.catalogRequests.length).assertEqual(1);
      expect(resetCount).assertEqual(1);
      expect(appliedCount).assertEqual(0);
    });

    it('selects and persists a session model through the model client', 0, async () => {
      const client = new FakeRemoteModelClient();
      const preferences = new FakeRemoteModelPreferenceStore();
      const statuses: string[] = [];
      const busyEvents: boolean[] = [];
      const applied: RemoteModelProjectionRecord[] = [];
      const controller = new RemoteModelController(
        client,
        preferences,
        (_modelCatalog: RemoteModelCatalog, _selectedModelId: string, _knownModelCatalogVersion: number) => {},
        (modelCatalog: RemoteModelCatalog, selectedModelId: string, knownModelCatalogVersion: number) => {
          const record = new RemoteModelProjectionRecord();
          record.version = knownModelCatalogVersion;
          record.selectedModelId = selectedModelId;
          record.sessionModelId = modelCatalog.session_model_id || '';
          record.modelCount = modelCatalog.models.length;
          applied.push(record);
        },
        (statusText: string) => {
          statuses.push(statusText);
        },
        (isBusy: boolean) => {
          busyEvents.push(isBusy);
        }
      );

      controller.applyCatalog(remoteModelCatalog());
      await controller.selectModel('model-b', 'session-1', false, true);

      expect(client.modelSelections[0]).assertEqual('session-1:model-b');
      expect(preferences.savedModelIds[0]).assertEqual('model-b');
      expect(applied[applied.length - 1].selectedModelId).assertEqual('model-b');
      expect(applied[applied.length - 1].sessionModelId).assertEqual('model-b');
      expect(statuses[0]).assertEqual(RemoteI18n.t('status.switchingModel'));
      expect(statuses[1]).assertEqual(RemoteI18n.t('status.modelSwitched'));
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
    });

    it('skips model selection guards and reports selection failures', 0, async () => {
      const client = new FakeRemoteModelClient();
      const preferences = new FakeRemoteModelPreferenceStore();
      const statuses: string[] = [];
      const busyEvents: boolean[] = [];
      const controller = new RemoteModelController(
        client,
        preferences,
        (_modelCatalog: RemoteModelCatalog, _selectedModelId: string, _knownModelCatalogVersion: number) => {},
        (_modelCatalog: RemoteModelCatalog, _selectedModelId: string, _knownModelCatalogVersion: number) => {},
        (statusText: string) => {
          statuses.push(statusText);
        },
        (isBusy: boolean) => {
          busyEvents.push(isBusy);
        }
      );

      await controller.selectModel('', 'session-1', false, true);
      await controller.selectModel('model-a', '', false, true);
      await controller.selectModel('model-a', 'session-1', true, true);
      await controller.selectModel('model-a', 'session-1', false, false);
      expect(client.modelSelections.length).assertEqual(0);
      expect(busyEvents.length).assertEqual(0);

      client.shouldFailSelect = true;
      await controller.selectModel('model-a', 'session-1', false, true);
      expect(client.modelSelections.length).assertEqual(1);
      expect(preferences.savedModelIds.length).assertEqual(0);
      expect(statuses[statuses.length - 1].indexOf('Expected model selection failure') >= 0).assertTrue();
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
    });
  });

  describe('RemoteSessionController', () => {
    it('refreshes session list and restores connected projection', 0, async () => {
      const client = new FakeRemoteSessionClient();
      const projection = new RemoteSessionProjectionRecord();
      const statuses: string[] = [];
      const loadingEvents: boolean[] = [];
      let reconnectCount = 0;
      let connectedCount = 0;
      let heartbeatCount = 0;
      client.listResults = [{
        sessions: [remoteSession('session-1', 'Session 1'), remoteSession('session-2', 'Session 2')],
        hasMore: true
      }];
      const controller = new RemoteSessionController(client, 8, {
        onSessions: (sessions: RemoteSession[], hasMore: boolean) => {
          projection.sessions = sessions;
          projection.hasMore = hasMore;
        },
        onActiveSession: (_session: SessionSummary) => {},
        onStatusText: (statusText: string) => {
          statuses.push(statusText);
        },
        onBusy: (_isBusy: boolean) => {},
        onLoading: (isLoading: boolean) => {
          loadingEvents.push(isLoading);
        },
        onSessionError: (_errorText: string) => {},
        onReconnecting: () => {
          reconnectCount += 1;
        },
        onConnected: () => {
          connectedCount += 1;
        },
        onConnectionFailed: (_err: Object) => {},
        onStartHeartbeat: () => {
          heartbeatCount += 1;
        }
      });

      await controller.refresh('repo', 'code', true, false);

      expect(client.listRequests[0]).assertEqual('8:0:repo:code');
      expect(projection.sessions.length).assertEqual(2);
      expect(projection.hasMore).assertTrue();
      expect(loadingEvents[0]).assertTrue();
      expect(loadingEvents[1]).assertFalse();
      expect(reconnectCount).assertEqual(1);
      expect(connectedCount).assertEqual(1);
      expect(heartbeatCount).assertEqual(1);
      expect(statuses[0]).assertEqual(RemoteI18n.t('status.refreshSessions'));
      expect(statuses[statuses.length - 1]).assertEqual(RemoteI18n.t('connection.connected'));
    });

    it('loads more sessions from current offset and keeps existing duplicates stable', 0, async () => {
      const client = new FakeRemoteSessionClient();
      const projection = new RemoteSessionProjectionRecord();
      const busyEvents: boolean[] = [];
      client.listResults = [{
        sessions: [remoteSession('session-1', 'Updated 1'), remoteSession('session-2', 'Session 2')],
        hasMore: false
      }];
      const controller = new RemoteSessionController(client, 2, {
        onSessions: (sessions: RemoteSession[], hasMore: boolean) => {
          projection.sessions = sessions;
          projection.hasMore = hasMore;
        },
        onActiveSession: (_session: SessionSummary) => {},
        onStatusText: (_statusText: string) => {},
        onBusy: (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        onLoading: (_isLoading: boolean) => {},
        onSessionError: (_errorText: string) => {},
        onReconnecting: () => {},
        onConnected: () => {},
        onConnectionFailed: (_err: Object) => {},
        onStartHeartbeat: () => {}
      });
      controller.setSessions([remoteSession('session-1', 'Session 1')], true);

      await controller.loadMore('', 'all', false, true);

      expect(client.listRequests[0]).assertEqual('2:1::all');
      expect(projection.sessions.length).assertEqual(2);
      expect(projection.sessions[0].title).assertEqual('Session 1');
      expect(projection.sessions[1].id).assertEqual('session-2');
      expect(projection.hasMore).assertFalse();
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
    });

    it('creates and opens sessions through active-session callbacks', 0, async () => {
      const client = new FakeRemoteSessionClient();
      const activeSessions: SessionSummary[] = [];
      const openedSessions: SessionSummary[] = [];
      const controller = new RemoteSessionController(client, 8, {
        onSessions: (_sessions: RemoteSession[], _hasMore: boolean) => {},
        onActiveSession: (session: SessionSummary) => {
          activeSessions.push(session);
        },
        onStatusText: (_statusText: string) => {},
        onBusy: (_isBusy: boolean) => {},
        onLoading: (_isLoading: boolean) => {},
        onSessionError: (_errorText: string) => {},
        onReconnecting: () => {},
        onConnected: () => {},
        onConnectionFailed: (_err: Object) => {},
        onStartHeartbeat: () => {}
      });

      await controller.create('code', false, true, async (session: SessionSummary): Promise<void> => {
        openedSessions.push(session);
      });
      await controller.open(remoteSession('opened-session', 'Opened Session'), '/workspace', false, true,
        async (session: SessionSummary): Promise<void> => {
          openedSessions.push(session);
        });

      expect(client.createRequests[0]).assertEqual('code::');
      expect(activeSessions.length).assertEqual(2);
      expect(activeSessions[0].sessionId).assertEqual('created-session');
      expect(activeSessions[1].sessionId).assertEqual('opened-session');
      expect(activeSessions[1].workspacePath).assertEqual('/workspace');
      expect(openedSessions.length).assertEqual(2);
    });

    it('deletes active sessions and backfills list when more pages exist', 0, async () => {
      const client = new FakeRemoteSessionClient();
      const projection = new RemoteSessionProjectionRecord();
      let deletedActiveCount = 0;
      client.listResults = [{
        sessions: [remoteSession('session-3', 'Session 3')],
        hasMore: false
      }];
      const controller = new RemoteSessionController(client, 2, {
        onSessions: (sessions: RemoteSession[], hasMore: boolean) => {
          projection.sessions = sessions;
          projection.hasMore = hasMore;
        },
        onActiveSession: (_session: SessionSummary) => {},
        onStatusText: (_statusText: string) => {},
        onBusy: (_isBusy: boolean) => {},
        onLoading: (_isLoading: boolean) => {},
        onSessionError: (_errorText: string) => {},
        onReconnecting: () => {},
        onConnected: () => {},
        onConnectionFailed: (_err: Object) => {},
        onStartHeartbeat: () => {}
      });
      controller.setSessions([
        remoteSession('session-1', 'Session 1'),
        remoteSession('session-2', 'Session 2')
      ], true);

      await controller.delete(
        remoteSession('session-1', 'Session 1'),
        'session-1',
        false,
        true,
        '',
        'all',
        async (): Promise<void> => {
          deletedActiveCount += 1;
        }
      );

      expect(client.deleteRequests[0]).assertEqual('session-1');
      expect(client.listRequests[0]).assertEqual('2:1::all');
      expect(deletedActiveCount).assertEqual(1);
      expect(projection.sessions.length).assertEqual(2);
      expect(projection.sessions[0].id).assertEqual('session-2');
      expect(projection.sessions[1].id).assertEqual('session-3');
      expect(projection.hasMore).assertFalse();
    });
  });

  describe('RemoteChatCommandController', () => {
    it('loads active messages and ignores stale route projections', 0, async () => {
      const client = new FakeRemoteChatCommandClient();
      const projection = new RemoteChatMessagesProjectionRecord();
      const statuses: string[] = [];
      client.messageResults = [{
        messages: [chatMessage('message-1', 'assistant', 'Hello')],
        hasMore: false
      }, {
        messages: [chatMessage('message-2', 'assistant', 'Stale')],
        hasMore: false
      }];
      const controller = new RemoteChatCommandController(client, {
        onMessagesLoaded: (messages: ChatMessage[], hasMoreMessages: boolean) => {
          projection.messages = messages;
          projection.hasMoreMessages = hasMoreMessages;
        },
        onMessageCountKnown: (pollVersion: number, knownMessageCount: number) => {
          projection.pollVersion = pollVersion;
          projection.knownMessageCount = knownMessageCount;
        },
        onSendSucceeded: (_turnId: string, _pendingActiveId: string) => {},
        onSendFailed: (
          _rawText: string,
          _images: SelectedImageAttachment[],
          _localMessageId: string,
          _pendingActiveId: string
        ) => {},
        onActiveSession: (_session: SessionSummary) => {},
        onSessionTitleChanged: (_sessionId: string, _title: string) => {},
        onStatusText: (statusText: string) => {
          statuses.push(statusText);
        },
        onBusy: (_isBusy: boolean) => {},
        onPollRequested: () => {}
      });

      await controller.loadMessages('session-1', (_sessionId: string) => true);
      await controller.loadMessages('session-2', (_sessionId: string) => false);

      expect(client.messageRequests[0]).assertEqual('session-1');
      expect(client.messageRequests[1]).assertEqual('session-2');
      expect(projection.messages.length).assertEqual(1);
      expect(projection.messages[0].id).assertEqual('message-1');
      expect(projection.hasMoreMessages).assertFalse();
      expect(projection.pollVersion).assertEqual(0);
      expect(projection.knownMessageCount).assertEqual(1);
      expect(statuses[0]).assertEqual(RemoteI18n.t('status.loadMessages'));
      expect(statuses[1]).assertEqual(RemoteI18n.t('status.messagesSynced'));
    });

    it('loads older messages with busy and cursor callbacks', 0, async () => {
      const client = new FakeRemoteChatCommandClient();
      const projection = new RemoteChatMessagesProjectionRecord();
      const busyEvents: boolean[] = [];
      client.messageResults = [{
        messages: [
          chatMessage('message-1', 'user', 'Older'),
          chatMessage('message-2', 'assistant', 'Reply')
        ],
        hasMore: false
      }];
      const controller = new RemoteChatCommandController(client, {
        onMessagesLoaded: (messages: ChatMessage[], hasMoreMessages: boolean) => {
          projection.messages = messages;
          projection.hasMoreMessages = hasMoreMessages;
        },
        onMessageCountKnown: (pollVersion: number, knownMessageCount: number) => {
          projection.pollVersion = pollVersion;
          projection.knownMessageCount = knownMessageCount;
        },
        onSendSucceeded: (_turnId: string, _pendingActiveId: string) => {},
        onSendFailed: (
          _rawText: string,
          _images: SelectedImageAttachment[],
          _localMessageId: string,
          _pendingActiveId: string
        ) => {},
        onActiveSession: (_session: SessionSummary) => {},
        onSessionTitleChanged: (_sessionId: string, _title: string) => {},
        onStatusText: (_statusText: string) => {},
        onBusy: (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        onPollRequested: () => {}
      });

      await controller.loadOlderMessages('session-1', 7, true, false);

      expect(client.messageRequests[0]).assertEqual('session-1');
      expect(projection.messages.length).assertEqual(2);
      expect(projection.hasMoreMessages).assertFalse();
      expect(projection.pollVersion).assertEqual(7);
      expect(projection.knownMessageCount).assertEqual(2);
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
    });

    it('sends prepared remote messages and reports failed payloads', 0, async () => {
      const client = new FakeRemoteChatCommandClient();
      const succeeded: string[] = [];
      const failed: string[] = [];
      const busyEvents: boolean[] = [];
      const controller = new RemoteChatCommandController(client, {
        onMessagesLoaded: (_messages: ChatMessage[], _hasMoreMessages: boolean) => {},
        onMessageCountKnown: (_pollVersion: number, _knownMessageCount: number) => {},
        onSendSucceeded: (turnId: string, pendingActiveId: string) => {
          succeeded.push(`${turnId}:${pendingActiveId}`);
        },
        onSendFailed: (
          rawText: string,
          images: SelectedImageAttachment[],
          localMessageId: string,
          pendingActiveId: string
        ) => {
          failed.push(`${rawText}:${images.length}:${localMessageId}:${pendingActiveId}`);
        },
        onActiveSession: (_session: SessionSummary) => {},
        onSessionTitleChanged: (_sessionId: string, _title: string) => {},
        onStatusText: (_statusText: string) => {},
        onBusy: (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        onPollRequested: () => {}
      });

      await controller.sendPreparedMessage(
        'session-1',
        'Describe image',
        'code',
        'Describe image',
        [selectedImage('image-1')],
        [{
          id: 'image-1',
          data_url: 'data:image/png;base64,AA==',
          mime_type: 'image/png'
        }],
        'local-1',
        'pending-1',
        false,
        true
      );
      client.shouldFailSend = true;
      await controller.sendPreparedMessage(
        'session-1',
        'Retry text',
        'code',
        'Retry text',
        [],
        [],
        'local-2',
        'pending-2',
        false,
        true
      );

      expect(client.sendRequests[0]).assertEqual('images:session-1:Describe image:code:1');
      expect(client.sendRequests[1]).assertEqual('text:session-1:Retry text:code');
      expect(succeeded[0]).assertEqual('turn-1:pending-1');
      expect(failed[0]).assertEqual('Retry text:0:local-2:pending-2');
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
      expect(busyEvents[2]).assertTrue();
      expect(busyEvents[3]).assertFalse();
    });

    it('stops active tasks and reports guard states', 0, async () => {
      const client = new FakeRemoteChatCommandClient();
      const statuses: string[] = [];
      let pollCount = 0;
      const controller = new RemoteChatCommandController(client, {
        onMessagesLoaded: (_messages: ChatMessage[], _hasMoreMessages: boolean) => {},
        onMessageCountKnown: (_pollVersion: number, _knownMessageCount: number) => {},
        onSendSucceeded: (_turnId: string, _pendingActiveId: string) => {},
        onSendFailed: (
          _rawText: string,
          _images: SelectedImageAttachment[],
          _localMessageId: string,
          _pendingActiveId: string
        ) => {},
        onActiveSession: (_session: SessionSummary) => {},
        onSessionTitleChanged: (_sessionId: string, _title: string) => {},
        onStatusText: (statusText: string) => {
          statuses.push(statusText);
        },
        onBusy: (_isBusy: boolean) => {},
        onPollRequested: () => {
          pollCount += 1;
        }
      });

      await controller.stopTask('session-1', '', '', true);
      await controller.stopTask('session-1', 'active-turn', 'turn-1', true);

      expect(client.cancelRequests[0]).assertEqual('session-1:turn-1');
      expect(statuses[0]).assertEqual(RemoteI18n.t('status.noRunningTask'));
      expect(statuses[1]).assertEqual(RemoteI18n.t('status.stoppingTask'));
      expect(statuses[2]).assertEqual(RemoteI18n.t('status.stopRequested'));
      expect(pollCount).assertEqual(1);
    });

    it('renames active sessions and updates active/list projections', 0, async () => {
      const client = new FakeRemoteChatCommandClient();
      const activeSessions: SessionSummary[] = [];
      const titleUpdates: string[] = [];
      const busyEvents: boolean[] = [];
      const controller = new RemoteChatCommandController(client, {
        onMessagesLoaded: (_messages: ChatMessage[], _hasMoreMessages: boolean) => {},
        onMessageCountKnown: (_pollVersion: number, _knownMessageCount: number) => {},
        onSendSucceeded: (_turnId: string, _pendingActiveId: string) => {},
        onSendFailed: (
          _rawText: string,
          _images: SelectedImageAttachment[],
          _localMessageId: string,
          _pendingActiveId: string
        ) => {},
        onActiveSession: (session: SessionSummary) => {
          activeSessions.push(session);
        },
        onSessionTitleChanged: (sessionId: string, title: string) => {
          titleUpdates.push(`${sessionId}:${title}`);
        },
        onStatusText: (_statusText: string) => {},
        onBusy: (isBusy: boolean) => {
          busyEvents.push(isBusy);
        },
        onPollRequested: () => {}
      });

      await controller.renameActiveSession({
        sessionId: 'session-1',
        title: 'Old title',
        workspacePath: '/workspace',
        agentType: 'code',
        initialTurnId: 'turn-0'
      }, '  New title  ', false, true);

      expect(client.renameRequests[0]).assertEqual('session-1:New title');
      expect(activeSessions[0].title).assertEqual('New title');
      expect(activeSessions[0].initialTurnId || '').assertEqual('turn-0');
      expect(titleUpdates[0]).assertEqual('session-1:New title');
      expect(busyEvents[0]).assertTrue();
      expect(busyEvents[1]).assertFalse();
    });
  });

  describe('ChatComposerCapabilities', () => {
    it('keeps route-to-surface composer ownership explicit', 0, () => {
      expect(AppRouteContract.isGeneralComposerRoute(AppRoute.ChatHome)).assertTrue();
      expect(AppRouteContract.isGeneralComposerRoute(AppRoute.GeneralChat)).assertTrue();
      expect(AppRouteContract.isGeneralComposerRoute(AppRoute.RemoteHome)).assertFalse();
      expect(AppRouteContract.isGeneralComposerRoute(AppRoute.RemoteChat)).assertFalse();
    });

    it('keeps general chat independent from remote-only composer requirements', 0, () => {
      expect(GENERAL_CHAT_COMPOSER_CAPABILITIES.surface).assertEqual(ChatSurface.General);
      expect(GENERAL_CHAT_COMPOSER_CAPABILITIES.supportsAttachments).assertFalse();
      expect(GENERAL_CHAT_COMPOSER_CAPABILITIES.requiresRemoteConnection).assertFalse();
    });

    it('keeps remote composer attachments behind the remote connection', 0, () => {
      expect(REMOTE_CHAT_COMPOSER_CAPABILITIES.surface).assertEqual(ChatSurface.Remote);
      expect(REMOTE_CHAT_COMPOSER_CAPABILITIES.supportsAttachments).assertTrue();
      expect(REMOTE_CHAT_COMPOSER_CAPABILITIES.requiresRemoteConnection).assertTrue();
    });
  });

  describe('ConversationViewContract', () => {
    it('keeps empty ordinary chat on the unified conversation surface with suggestions', 0, () => {
      const emptyItems = ChatTimelineProjector.project([], [], RemoteUiState.emptyActiveTurn(), false);

      expect(ConversationViewContract.surfaceForRoute(false)).assertEqual(ChatSurface.General);
      expect(ConversationViewContract.shouldShowSuggestions(true, false, emptyItems)).assertTrue();
      expect(ConversationViewContract.visibleTimelineItems(emptyItems).length).assertEqual(0);
      expect(ConversationViewContract.hasRealTimelineItem(emptyItems)).assertFalse();
    });

    it('removes suggestions on the same page once ordinary chat has real content or is sending', 0, () => {
      const emptyItems = ChatTimelineProjector.project([], [], RemoteUiState.emptyActiveTurn(), false);
      const messageItems = ChatTimelineProjector.project([
        chatMessage('general-user-1', 'user', 'Write a short intro')
      ], [], RemoteUiState.emptyActiveTurn(), false);

      expect(ConversationViewContract.shouldShowSuggestions(true, true, emptyItems)).assertFalse();
      expect(ConversationViewContract.shouldShowSuggestions(true, false, messageItems)).assertFalse();
      expect(ConversationViewContract.visibleTimelineItems(messageItems).length).assertEqual(1);
      expect(ConversationViewContract.visibleTimelineItems(messageItems)[0].type).assertEqual('user_message');
      expect(ConversationViewContract.hasRealTimelineItem(messageItems)).assertTrue();
    });

    it('keeps remote empty conversations blank instead of rendering the old empty card', 0, () => {
      const emptyItems = ChatTimelineProjector.project([], [], RemoteUiState.emptyActiveTurn(), false);

      expect(ConversationViewContract.surfaceForRoute(true)).assertEqual(ChatSurface.Remote);
      expect(ConversationViewContract.shouldShowSuggestions(false, false, emptyItems)).assertFalse();
      expect(ConversationViewContract.visibleTimelineItems(emptyItems).length).assertEqual(0);
    });
  });

  describe('AppRouteContract', () => {
    it('defines stable route ids and session-carrying route params', 0, () => {
      const generalParam = AppRouteContract.routeParam('general-session-1');
      const remoteParam = AppRouteContract.routeParam('remote-session-1');

      expect(`${AppRoute.ChatHome}`).assertEqual('ChatHome');
      expect(`${AppRoute.GeneralChat}`).assertEqual('GeneralChat');
      expect(`${AppRoute.RemoteHome}`).assertEqual('RemoteHome');
      expect(`${AppRoute.RemoteChat}`).assertEqual('RemoteChat');
      expect(AppRouteContract.isSessionRoute(AppRoute.ChatHome)).assertFalse();
      expect(AppRouteContract.isSessionRoute(AppRoute.RemoteHome)).assertFalse();
      expect(AppRouteContract.isSessionRoute(AppRoute.GeneralChat)).assertTrue();
      expect(AppRouteContract.isSessionRoute(AppRoute.RemoteChat)).assertTrue();
      expect(generalParam.sessionId).assertEqual('general-session-1');
      expect(remoteParam.sessionId).assertEqual('remote-session-1');
    });

    it('derives current route from NavPathStack path names with ChatHome as root', 0, () => {
      expect(AppRouteContract.currentRoute([])).assertEqual(AppRoute.ChatHome);
      expect(AppRouteContract.currentRoute([AppRoute.RemoteHome])).assertEqual(AppRoute.RemoteHome);
      expect(AppRouteContract.currentRoute([
        AppRoute.RemoteHome,
        AppRoute.RemoteChat
      ])).assertEqual(AppRoute.RemoteChat);
      expect(AppRouteContract.currentRoute([
        AppRoute.GeneralChat
      ])).assertEqual(AppRoute.GeneralChat);
    });

    it('builds push path specs and suppresses duplicate current routes', 0, () => {
      const duplicate = AppRouteContract.pathSpec(AppRoute.RemoteHome, AppRoute.RemoteHome, '');
      const chatHomeDuplicate = AppRouteContract.pathSpec(AppRoute.ChatHome, AppRoute.ChatHome, 'general-session-1');
      const remoteChatSpec = AppRouteContract.pathSpec(
        AppRoute.RemoteHome,
        AppRoute.RemoteChat,
        'remote-session-1'
      ) as AppNavigationPathSpec;
      const generalChatSpec = AppRouteContract.pathSpec(
        AppRoute.ChatHome,
        AppRoute.GeneralChat,
        'general-session-1'
      ) as AppNavigationPathSpec;

      expect(duplicate === undefined).assertTrue();
      expect(chatHomeDuplicate === undefined).assertTrue();
      expect(remoteChatSpec.name).assertEqual(AppRoute.RemoteChat);
      expect(remoteChatSpec.hasSessionParam()).assertTrue();
      expect(remoteChatSpec.routeParam().sessionId).assertEqual('remote-session-1');
      expect(generalChatSpec.name).assertEqual(AppRoute.GeneralChat);
      expect(generalChatSpec.routeParam().sessionId).assertEqual('general-session-1');
    });

    it('classifies back actions without depending on ArkUI NavPathStack', 0, () => {
      expect(AppRouteContract.backAction(AppRoute.ChatHome, true))
        .assertEqual(AppNavigationBackAction.CloseSidebar);
      expect(AppRouteContract.backAction(AppRoute.GeneralChat, false))
        .assertEqual(AppNavigationBackAction.CloseActiveChat);
      expect(AppRouteContract.backAction(AppRoute.RemoteChat, false))
        .assertEqual(AppNavigationBackAction.CloseActiveChat);
      expect(AppRouteContract.backAction(AppRoute.RemoteHome, false))
        .assertEqual(AppNavigationBackAction.PopRemoteHome);
      expect(AppRouteContract.backAction(AppRoute.ChatHome, false))
        .assertEqual(AppNavigationBackAction.AllowSystem);
    });

    it('derives conversation sources and wide source destinations', 0, () => {
      expect(AppRouteContract.conversationSource(AppRoute.ChatHome)).assertEqual(ConversationSource.General);
      expect(AppRouteContract.conversationSource(AppRoute.GeneralChat)).assertEqual(ConversationSource.General);
      expect(AppRouteContract.conversationSource(AppRoute.RemoteHome)).assertEqual(ConversationSource.Remote);
      expect(AppRouteContract.conversationSource(AppRoute.RemoteChat)).assertEqual(ConversationSource.Remote);

      const general = AppRouteContract.routeForConversationSource(ConversationSource.General, true, 'remote-1');
      const remoteHome = AppRouteContract.routeForConversationSource(ConversationSource.Remote, false, 'remote-1');
      const connectedRemoteHome = AppRouteContract.routeForConversationSource(ConversationSource.Remote, true, '');
      const remoteChat = AppRouteContract.routeForConversationSource(ConversationSource.Remote, true, 'remote-1');
      expect(general.name).assertEqual(AppRoute.ChatHome);
      expect(general.hasSessionParam()).assertFalse();
      expect(remoteHome.name).assertEqual(AppRoute.RemoteHome);
      expect(remoteHome.hasSessionParam()).assertFalse();
      expect(connectedRemoteHome.name).assertEqual(AppRoute.RemoteHome);
      expect(connectedRemoteHome.hasSessionParam()).assertFalse();
      expect(remoteChat.name).assertEqual(AppRoute.RemoteChat);
      expect(remoteChat.routeParam().sessionId).assertEqual('remote-1');
    });
  });

  describe('ConversationLayoutPolicy', () => {
    it('keeps folded and narrow surfaces compact', 0, () => {
      expect(ConversationLayoutPolicy.useMasterDetail(480, false, false)).assertFalse();
      expect(ConversationLayoutPolicy.useMasterDetail(900, true, true)).assertFalse();
      expect(ConversationLayoutPolicy.useMasterDetail(900, false, true)).assertFalse();
    });

    it('uses master-detail for media-query or width-qualified surfaces', 0, () => {
      expect(ConversationLayoutPolicy.useMasterDetail(480, true, false)).assertTrue();
      expect(ConversationLayoutPolicy.useMasterDetail(
        ConversationLayoutPolicy.WIDE_LAYOUT_MIN_WIDTH,
        false,
        false
      )).assertTrue();
    });

    it('keeps the existing master width when no usable crease is available', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(860, []);
      const invalidCrease = ConversationLayoutPolicy.resolveWideGeometry(
        860,
        [new ConversationLayoutCrease(120, 10)]
      );
      expect(geometry.masterPaneWidth).assertEqual(ConversationLayoutPolicy.FALLBACK_MASTER_PANE_WIDTH);
      expect(geometry.masterDetailGap).assertEqual(0);
      expect(geometry.isExtraWide).assertFalse();
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(516);
      expect(invalidCrease.masterPaneWidth).assertEqual(ConversationLayoutPolicy.FALLBACK_MASTER_PANE_WIDTH);
    });

    it('returns no detail content band when the viewport cannot fit the fallback master', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(300, []);
      expect(geometry.masterPaneWidth).assertEqual(ConversationLayoutPolicy.FALLBACK_MASTER_PANE_WIDTH);
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(0);
    });

    it('aligns the master boundary with the first usable fold crease', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        820,
        [new ConversationLayoutCrease(382, 8)]
      );
      expect(geometry.masterPaneWidth).assertEqual(382);
      expect(geometry.masterDetailGap).assertEqual(8);
      expect(geometry.isExtraWide).assertFalse();
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(430);
    });

    it('accepts a zero-width crease without creating an empty detail segment', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        900,
        [new ConversationLayoutCrease(352, 0)]
      );
      expect(geometry.masterPaneWidth).assertEqual(352);
      expect(geometry.masterDetailGap).assertEqual(0);
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(548);
    });

    it('treats two creases as an extra-wide master-detail surface', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        1080,
        [new ConversationLayoutCrease(352, 8), new ConversationLayoutCrease(712, 8)]
      );
      expect(geometry.masterPaneWidth).assertEqual(352);
      expect(geometry.masterDetailGap).assertEqual(8);
      expect(geometry.isExtraWide).assertTrue();
      expect(geometry.detailContentOffset).assertEqual(360);
      expect(geometry.detailContentWidth).assertEqual(360);
    });

    it('selects the widest hinge-free detail band on asymmetric three-screen geometry', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        1080,
        [new ConversationLayoutCrease(352, 8), new ConversationLayoutCrease(800, 8)]
      );
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(440);
    });

    it('uses width as the extra-wide fallback when crease data is missing', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        ConversationLayoutPolicy.EXTRA_WIDE_MIN_WIDTH,
        []
      );
      expect(geometry.isExtraWide).assertTrue();
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(736);
    });

    it('ignores crease regions outside the application viewport', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        900,
        [
          new ConversationLayoutCrease(-12, 8),
          new ConversationLayoutCrease(420, -2),
          new ConversationLayoutCrease(910, 8)
        ]
      );
      expect(geometry.masterPaneWidth).assertEqual(ConversationLayoutPolicy.FALLBACK_MASTER_PANE_WIDTH);
      expect(geometry.detailContentOffset).assertEqual(0);
      expect(geometry.detailContentWidth).assertEqual(556);
    });

    it('rejects a crease that leaves too little detail space', 0, () => {
      const geometry = ConversationLayoutPolicy.resolveWideGeometry(
        900,
        [new ConversationLayoutCrease(600, 8)]
      );
      expect(geometry.masterPaneWidth).assertEqual(ConversationLayoutPolicy.FALLBACK_MASTER_PANE_WIDTH);
      expect(geometry.detailContentOffset).assertEqual(264);
      expect(geometry.detailContentWidth).assertEqual(292);
    });
  });

  describe('ChatSessionController', () => {
    it('ignores a poll response that completes after the controller stopped', 0, async () => {
      const manager = new BlockingPollSessionManager();
      const snapshots: ChatSessionSnapshot[] = [];
      const errors: Object[] = [];
      const controller = new ChatSessionController(manager, {
        onSnapshot: (snapshot: ChatSessionSnapshot) => {
          snapshots.push(snapshot);
        },
        onError: (error: Object) => {
          errors.push(error);
        },
        canPoll: (_sessionId: string) => true
      });

      controller.start('session-stale', {
        pollVersion: 0,
        knownMessageCount: 0,
        knownModelCatalogVersion: 0
      });
      await delay(20);
      controller.stop();
      manager.resolve(pollResult({
        version: 1,
        changed: true,
        sessionState: 'idle',
        title: 'Stale',
        newMessages: [chatMessage('stale-message', 'assistant', 'must not render')],
        totalMessageCount: 1
      }));
      await delay(20);

      expect(snapshots.length).assertEqual(0);
      expect(errors.length).assertEqual(0);
    });

    it('preserves active turn when unchanged poll omits active turn', 0, async () => {
      const manager = new FakePollSessionManager();
      const snapshots: ChatSessionSnapshot[] = [];
      manager.results = [pollResult({
        version: 1,
        changed: false,
        sessionState: 'running',
        title: 'Session',
        newMessages: [],
        totalMessageCount: 1
      })];
      const controller = new ChatSessionController(manager, {
        onSnapshot: (snapshot: ChatSessionSnapshot) => {
          snapshots.push(snapshot);
        },
        onError: (_error: Object) => {},
        canPoll: (_sessionId: string) => true
      });

      controller.start('session-1', {
        pollVersion: 1,
        knownMessageCount: 1,
        knownModelCatalogVersion: 0
      }, chatMessage('active-turn-1', 'assistant', 'Working', 'active'));
      await delay(20);
      controller.stop(false);

      expect(snapshots.length).assertEqual(1);
      expect(snapshots[0].changed).assertEqual(false);
      expect(snapshots[0].activeTurn ? snapshots[0].activeTurn.id : '').assertEqual('active-turn-1');
    });

    it('keeps completed active turn until final assistant message arrives', 0, async () => {
      const manager = new FakePollSessionManager();
      const snapshots: ChatSessionSnapshot[] = [];
      const controller = new ChatSessionController(manager, {
        onSnapshot: (snapshot: ChatSessionSnapshot) => {
          snapshots.push(snapshot);
        },
        onError: (_error: Object) => {},
        canPoll: (_sessionId: string) => true
      });

      manager.results = [pollResult({
        version: 2,
        changed: true,
        sessionState: 'idle',
        title: 'Session',
        newMessages: [],
        totalMessageCount: 1,
        activeTurn: chatMessage('active-turn-2', 'assistant', 'Final text', 'completed')
      })];
      controller.start('session-1', {
        pollVersion: 1,
        knownMessageCount: 1,
        knownModelCatalogVersion: 0
      }, chatMessage('active-turn-2', 'assistant', 'Final text', 'active'));
      await delay(20);

      manager.results = [pollResult({
        version: 3,
        changed: true,
        sessionState: 'idle',
        title: 'Session',
        newMessages: [],
        totalMessageCount: 1
      })];
      await controller.pollNow();

      manager.results = [pollResult({
        version: 4,
        changed: true,
        sessionState: 'idle',
        title: 'Session',
        newMessages: [
          chatMessage('assistant-final-1', 'assistant', 'Final text')
        ],
        totalMessageCount: 2
      })];
      await controller.pollNow();
      controller.stop(false);

      expect(snapshots.length).assertEqual(3);
      expect(snapshots[0].activeTurn ? snapshots[0].activeTurn.status : '').assertEqual('completed');
      expect(snapshots[1].activeTurn ? snapshots[1].activeTurn.id : '').assertEqual('active-turn-2');
      expect(snapshots[2].activeTurn ? snapshots[2].activeTurn.id : '').assertEqual('');
    });

    it('resyncs when a completed assistant message is updated during the settle window', 0, async () => {
      const manager = new FakePollSessionManager();
      const snapshots: ChatSessionSnapshot[] = [];
      const controller = new ChatSessionController(manager, {
        onSnapshot: (snapshot: ChatSessionSnapshot) => {
          snapshots.push(snapshot);
        },
        onError: (_error: Object) => {},
        canPoll: (_sessionId: string) => true
      });

      manager.results = [pollResult({
        version: 2,
        changed: true,
        sessionState: 'idle',
        title: 'Session',
        newMessages: [
          chatMessage('turn-1-assistant', 'assistant', '')
        ],
        totalMessageCount: 2
      })];
      controller.start('session-1', {
        pollVersion: 1,
        knownMessageCount: 1,
        knownModelCatalogVersion: 0
      }, chatMessage('active-turn-1', 'assistant', '', 'active'));
      await delay(20);

      manager.results = [pollResult({
        version: 3,
        changed: true,
        sessionState: 'idle',
        title: 'Session',
        newMessages: [],
        totalMessageCount: 2
      })];
      await controller.pollNow();
      controller.stop(false);

      expect(snapshots.length).assertEqual(2);
      expect(snapshots[0].shouldSyncAfterTurnEnded).assertEqual(true);
      expect(snapshots[1].newMessages.length).assertEqual(0);
      expect(snapshots[1].shouldSyncAfterTurnEnded).assertEqual(true);
    });
  });
}
