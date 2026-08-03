import display from '@ohos.display';
import mediaQuery from '@ohos.mediaquery';
import { RemoteI18n } from '../../i18n/RemoteI18n';
import { RemotePermissionMode, RemoteSession } from '../../model/RemoteModels';
import { CloudAccountDevice } from '../../services/CloudAccountClient';
import { AppShell } from './AppShell';
import { AppSidebar } from './AppSidebar';
import { ConnectView } from './ConnectView';
import { ConversationIntent } from './ConversationIntent';
import { ConversationSourceSwitcher } from './ConversationSourceSwitcher';
import { ConversationViewHost } from './ConversationViewHost';
import { RemoteControlSettingsSheet } from './RemoteControlSettingsSheet';
import { RemoteCreateSessionView } from './RemoteCreateSessionView';
import { RemoteHomeView } from './RemoteHomeView';
import { RemoteSessionList } from './RemoteSessionList';
import { SettingsSheet } from './SettingsSheet';
import { CARD, GREEN, INK, LINE, MUTED, PAGE_BG, RED } from './Theme';
import { AppRoute, ConversationSource } from '../navigation/AppRouteContract';
import { AppShellState } from '../state/AppShellState';
import {
  ConversationLayoutCrease,
  ConversationLayoutPolicy
} from '../state/ConversationLayoutPolicy';
import { GeneralChatPageState } from '../state/GeneralChatPageState';
import { RemotePageState } from '../state/RemotePageState';
import { RemoteCreateSessionState } from '../state/RemoteCreateSessionState';
import { ConversationViewState } from '../state/ConversationViewState';

const WIDE_DETAIL_CONTENT_MAX_WIDTH: number = 920;

function safeFoldStatus(): display.FoldStatus {
  try {
    return display.getFoldStatus();
  } catch (_err) {
    return display.FoldStatus.FOLD_STATUS_UNKNOWN;
  }
}

export class AppRootPresentationActions {
  readonly onNavigationBack: (route: AppRoute) => boolean;
  readonly onConversationIntent: (route: AppRoute, intent: ConversationIntent) => void;
  readonly onCloseSidebar: () => void;
  readonly onWideConversationSource: (source: ConversationSource) => void;
  readonly onRemoteHome: RemoteHomePresentationActions;
  readonly onRemoteCreate: RemoteCreatePresentationActions;
  readonly onSidebar: SidebarPresentationActions;
  readonly onSettings: SettingsPresentationActions;
  readonly onConnect: ConnectPresentationActions;
  readonly generalStatus: () => string;

  constructor(
    onNavigationBack: (route: AppRoute) => boolean,
    onConversationIntent: (route: AppRoute, intent: ConversationIntent) => void,
    onCloseSidebar: () => void,
    onWideConversationSource: (source: ConversationSource) => void,
    onRemoteHome: RemoteHomePresentationActions,
    onRemoteCreate: RemoteCreatePresentationActions,
    onSidebar: SidebarPresentationActions,
    onSettings: SettingsPresentationActions,
    onConnect: ConnectPresentationActions,
    generalStatus: () => string
  ) {
    this.onNavigationBack = onNavigationBack;
    this.onConversationIntent = onConversationIntent;
    this.onCloseSidebar = onCloseSidebar;
    this.onWideConversationSource = onWideConversationSource;
    this.onRemoteHome = onRemoteHome;
    this.onRemoteCreate = onRemoteCreate;
    this.onSidebar = onSidebar;
    this.onSettings = onSettings;
    this.onConnect = onConnect;
    this.generalStatus = generalStatus;
  }
}

export class RemoteCreatePresentationActions {
  readonly back: () => void;
  readonly toggleDevices: () => void;
  readonly toggleWorkspaces: () => void;
  readonly selectDevice: (device: CloudAccountDevice) => void;
  readonly selectWorkspace: (path: string) => void;
  readonly draftChanged: (value: string) => void;
  readonly send: () => void;

  constructor(
    back: () => void,
    toggleDevices: () => void,
    toggleWorkspaces: () => void,
    selectDevice: (device: CloudAccountDevice) => void,
    selectWorkspace: (path: string) => void,
    draftChanged: (value: string) => void,
    send: () => void
  ) {
    this.back = back;
    this.toggleDevices = toggleDevices;
    this.toggleWorkspaces = toggleWorkspaces;
    this.selectDevice = selectDevice;
    this.selectWorkspace = selectWorkspace;
    this.draftChanged = draftChanged;
    this.send = send;
  }
}

export class RemoteHomePresentationActions {
  readonly openSidebar: () => void; readonly connectWorkspace: () => void;
  readonly addConnection: () => void; readonly openSettings: () => void;
  readonly refresh: () => void; readonly showWorkspaces: () => void; readonly showAssistants: () => void;
  readonly selectWorkspace: (path: string) => void; readonly selectAssistant: (path: string) => void;
  readonly cancelWorkspace: () => void; readonly cancelAssistant: () => void;
  readonly queryChanged: (query: string) => void; readonly search: () => void; readonly loadMore: () => void;
  readonly reconnect: () => void; readonly disconnect: () => void; readonly clearPairing: () => void;
  readonly create: (agentType: string) => void; readonly createAssistant: () => void;
  readonly createInWorkspace: (path: string, agentType: string) => void; readonly openSession: (session: RemoteSession) => void;
  readonly deleteSession: (session: RemoteSession) => void;

  constructor(
    openSidebar: () => void, connectWorkspace: () => void, addConnection: () => void, openSettings: () => void,
    refresh: () => void, showWorkspaces: () => void, showAssistants: () => void,
    selectWorkspace: (path: string) => void, selectAssistant: (path: string) => void,
    cancelWorkspace: () => void, cancelAssistant: () => void, queryChanged: (query: string) => void,
    search: () => void, loadMore: () => void, reconnect: () => void, disconnect: () => void,
    clearPairing: () => void, create: (agentType: string) => void, createAssistant: () => void,
    createInWorkspace: (path: string, agentType: string) => void, openSession: (session: RemoteSession) => void,
    deleteSession: (session: RemoteSession) => void
  ) {
    this.openSidebar = openSidebar; this.connectWorkspace = connectWorkspace; this.addConnection = addConnection;
    this.openSettings = openSettings; this.refresh = refresh; this.showWorkspaces = showWorkspaces;
    this.showAssistants = showAssistants; this.selectWorkspace = selectWorkspace; this.selectAssistant = selectAssistant;
    this.cancelWorkspace = cancelWorkspace; this.cancelAssistant = cancelAssistant; this.queryChanged = queryChanged;
    this.search = search; this.loadMore = loadMore; this.reconnect = reconnect; this.disconnect = disconnect;
    this.clearPairing = clearPairing; this.create = create; this.createAssistant = createAssistant;
    this.createInWorkspace = createInWorkspace; this.openSession = openSession; this.deleteSession = deleteSession;
  }
}

export class SidebarPresentationActions {
  readonly close: () => void; readonly newChat: () => void; readonly enterCode: () => void;
  readonly settings: () => void; readonly openAccount: () => void;
  readonly openSession: (session: RemoteSession) => void;
  readonly archive: (session: RemoteSession, archived: boolean) => void;
  readonly exportSession: (session: RemoteSession) => void; readonly deleteSession: (session: RemoteSession) => void;
  constructor(
    close: () => void, newChat: () => void, enterCode: () => void, settings: () => void, openAccount: () => void,
    openSession: (session: RemoteSession) => void, archive: (session: RemoteSession, archived: boolean) => void,
    exportSession: (session: RemoteSession) => void, deleteSession: (session: RemoteSession) => void
  ) {
    this.close = close; this.newChat = newChat; this.enterCode = enterCode; this.settings = settings;
    this.openAccount = openAccount;
    this.openSession = openSession; this.archive = archive; this.exportSession = exportSession; this.deleteSession = deleteSession;
  }
}

export class SettingsPresentationActions {
  readonly close: () => void; readonly addConnection: () => void; readonly disconnect: () => void;
  readonly reconnect: () => void;
  readonly openAccount: () => void;
  readonly cloudLogin: (relayUrl: string, username: string, password: string) => Promise<string>;
  readonly cloudSync: () => Promise<string>;
  readonly cloudLogout: () => Promise<void>;
  readonly cloudListDevices: () => Promise<CloudAccountDevice[]>;
  readonly getPermissionMode: () => Promise<RemotePermissionMode>;
  readonly setPermissionMode: (mode: RemotePermissionMode) => Promise<RemotePermissionMode>;
  readonly testGeneral: (url: string, key: string, model: string, clear: boolean) => Promise<string>;
  readonly saveGeneral: (url: string, key: string, model: string, clear: boolean) => Promise<string>;
  constructor(
    close: () => void, addConnection: () => void, disconnect: () => void, reconnect: () => void,
    openAccount: () => void,
    cloudLogin: (relayUrl: string, username: string, password: string) => Promise<string>,
    cloudSync: () => Promise<string>, cloudLogout: () => Promise<void>,
    cloudListDevices: () => Promise<CloudAccountDevice[]>,
    getPermissionMode: () => Promise<RemotePermissionMode>,
    setPermissionMode: (mode: RemotePermissionMode) => Promise<RemotePermissionMode>,
    testGeneral: (url: string, key: string, model: string, clear: boolean) => Promise<string>,
    saveGeneral: (url: string, key: string, model: string, clear: boolean) => Promise<string>
  ) {
    this.close = close; this.addConnection = addConnection; this.disconnect = disconnect;
    this.reconnect = reconnect; this.openAccount = openAccount; this.cloudLogin = cloudLogin; this.cloudSync = cloudSync;
    this.cloudLogout = cloudLogout; this.cloudListDevices = cloudListDevices;
    this.getPermissionMode = getPermissionMode; this.setPermissionMode = setPermissionMode;
    this.testGeneral = testGeneral;
    this.saveGeneral = saveGeneral;
  }
}

export class ConnectPresentationActions {
  readonly back: () => void; readonly connect: (password?: string) => void; readonly clearPairing: () => void;
  readonly urlChanged: (url: string) => void; readonly userChanged: (user: string) => void;
  readonly detected: (url: string) => boolean; readonly inputVisible: (visible: boolean) => void;
  readonly paste: () => void; readonly scan: () => void;
  readonly cloudListDevices: () => Promise<CloudAccountDevice[]>;
  readonly cloudSelectDevice: (device: CloudAccountDevice) => Promise<void>;
  constructor(
    back: () => void, connect: (password?: string) => void, clearPairing: () => void,
    urlChanged: (url: string) => void, userChanged: (user: string) => void,
    detected: (url: string) => boolean, inputVisible: (visible: boolean) => void,
    paste: () => void, scan: () => void, cloudListDevices: () => Promise<CloudAccountDevice[]>,
    cloudSelectDevice: (device: CloudAccountDevice) => Promise<void>
  ) {
    this.back = back; this.connect = connect; this.clearPairing = clearPairing;
    this.urlChanged = urlChanged; this.userChanged = userChanged; this.detected = detected;
    this.inputVisible = inputVisible; this.paste = paste; this.scan = scan;
    this.cloudListDevices = cloudListDevices; this.cloudSelectDevice = cloudSelectDevice;
  }
}

@ComponentV2
export struct AppRootPresentation {
  @Param shellState: AppShellState = new AppShellState();
  @Param navigationStack: NavPathStack = new NavPathStack();
  @Param remotePageState: RemotePageState = new RemotePageState();
  @Param remoteCreateState: RemoteCreateSessionState = new RemoteCreateSessionState();
  @Param generalPageState: GeneralChatPageState = new GeneralChatPageState();
  @Param deviceId: string = '';
  @Param currentRoute: AppRoute = AppRoute.ChatHome;
  @Local viewportWidth: number = 0;
  @Local wideLayoutMatched: boolean = false;
  @Local foldStatus: display.FoldStatus = safeFoldStatus();
  @Local wideMasterPaneWidth: number = ConversationLayoutPolicy.FALLBACK_MASTER_PANE_WIDTH;
  @Local wideMasterDetailGap: number = 0;
  @Local wideDetailContentOffset: number = 0;
  @Local wideDetailContentWidth: number = 0;
  @Local remoteWideSortMode: string = 'project';
  private wideQueryListener?: mediaQuery.MediaQueryListener;
  private foldStatusChanged: (status: display.FoldStatus) => void =
    (status: display.FoldStatus): void => {
      this.foldStatus = status;
      this.refreshWideGeometry();
    };
  private wideQueryChanged: (result: mediaQuery.MediaQueryResult) => void =
    (result: mediaQuery.MediaQueryResult): void => {
      this.wideLayoutMatched = result.matches;
    };
  @Param actions: AppRootPresentationActions = new AppRootPresentationActions(
    () => false, () => {}, () => {}, () => {},
    new RemoteHomePresentationActions(() => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {},
      () => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {},
      () => {}, () => {}, () => {}, () => {}, () => {}),
    new RemoteCreatePresentationActions(() => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}),
    new SidebarPresentationActions(() => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}, () => {}),
    new SettingsPresentationActions(() => {}, () => {}, () => {}, () => {}, () => {}, async (_relayUrl: string, _username: string, _password: string): Promise<string> => '', async (): Promise<string> => '', async (): Promise<void> => {}, async (): Promise<CloudAccountDevice[]> => [], async (): Promise<RemotePermissionMode> => 'ask', async (mode: RemotePermissionMode): Promise<RemotePermissionMode> => mode, async (_url: string, _key: string, _model: string, _clear: boolean): Promise<string> => '', async (_url: string, _key: string, _model: string, _clear: boolean): Promise<string> => ''),
    new ConnectPresentationActions(() => {}, () => {}, () => {}, () => {}, () => {}, () => false, () => {}, () => {},
      () => {}, async (): Promise<CloudAccountDevice[]> => [], async (_device: CloudAccountDevice): Promise<void> => {}),
    () => ''
  );

  aboutToAppear(): void {
    this.bindResponsiveQueries();
    this.bindFoldStatus();
  }

  aboutToDisappear(): void {
    this.unbindFoldStatus();
    this.unbindResponsiveQueries();
  }

  build() {
    Stack() {
      AppShell({ shellState: this.shellState, content: () => { this.NavigationContent(); },
        sidebar: () => { this.SidebarContent(); }, settings: () => { this.SettingsContent(); },
        connect: () => { this.ConnectContent(); }, onCloseSidebar: this.actions.onCloseSidebar })
    }.width('100%').height('100%')
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      this.viewportWidth = this.areaWidth(newArea.width);
      this.refreshWideGeometry();
    })
  }

  @Builder
  NavigationContent() {
    Navigation(this.navigationStack) { this.RouteContent(AppRoute.ChatHome) }
      .width('100%').height('100%').hideTitleBar(true).mode(NavigationMode.Stack)
      .navDestination(this.NavigationDestination)
  }

  @Builder
  NavigationDestination(name: string) {
    NavDestination() { this.RouteContent(name as AppRoute) }.hideTitleBar(true).backgroundColor(PAGE_BG)
      .onBackPressed(() => this.actions.onNavigationBack(name as AppRoute))
  }

  @Builder
  RouteContent(route: AppRoute) {
    if (this.isGeneralWideRoute(route) && this.isWideLayout()) {
      this.WideGeneralChatContent(route)
    } else if (route === AppRoute.RemoteChat && this.isWideLayout()) {
      this.WideRemoteChatContent()
    } else if (route === AppRoute.RemoteHome && this.isWideLayout()) {
      this.WideRemoteHomeContent()
    } else {
      this.RouteSurfaceContent(route, true, true)
    }
  }

  @Builder
  RouteSurfaceContent(route: AppRoute, showSidebarButton: boolean, showBackButton: boolean) {
    Column() {
      if (route === AppRoute.RemoteHome) {
        RemoteHomeView({ pageState: this.remotePageState, isBusy: this.remotePageState.isBusy,
          selectedSessionId: this.remotePageState.activeSession.sessionId,
          onOpenSidebar: this.actions.onRemoteHome.openSidebar,
          onConnectWorkspace: this.actions.onRemoteHome.connectWorkspace,
          onAddConnection: this.actions.onRemoteHome.addConnection,
          onOpenRemoteSettings: this.actions.onRemoteHome.openSettings,
          onRefresh: this.actions.onRemoteHome.refresh,
          onShowWorkspaces: this.actions.onRemoteHome.showWorkspaces,
          onShowAssistants: this.actions.onRemoteHome.showAssistants,
          onSelectWorkspace: this.actions.onRemoteHome.selectWorkspace,
          onSelectAssistant: this.actions.onRemoteHome.selectAssistant,
          onCancelWorkspacePicker: this.actions.onRemoteHome.cancelWorkspace,
          onCancelAssistantPicker: this.actions.onRemoteHome.cancelAssistant,
          onSessionQueryChange: this.actions.onRemoteHome.queryChanged,
          onSearchSessions: this.actions.onRemoteHome.search,
          onLoadMoreSessions: this.actions.onRemoteHome.loadMore,
          onReconnect: this.actions.onRemoteHome.reconnect,
          onDisconnect: this.actions.onRemoteHome.disconnect,
          onClearPairing: this.actions.onRemoteHome.clearPairing,
          onCreate: this.actions.onRemoteHome.create,
          onCreateAssistantSession: this.actions.onRemoteHome.createAssistant,
          onCreateInWorkspace: this.actions.onRemoteHome.createInWorkspace,
          onOpenSession: this.actions.onRemoteHome.openSession,
          onDeleteSession: this.actions.onRemoteHome.deleteSession })
      } else if (route === AppRoute.RemoteCreate) {
        RemoteCreateSessionView({
          state: this.remoteCreateState,
          onBack: this.actions.onRemoteCreate.back,
          onToggleDeviceMenu: this.actions.onRemoteCreate.toggleDevices,
          onToggleWorkspaceMenu: this.actions.onRemoteCreate.toggleWorkspaces,
          onSelectDevice: this.actions.onRemoteCreate.selectDevice,
          onSelectWorkspace: (workspace) => this.actions.onRemoteCreate.selectWorkspace(workspace?.path || ''),
          onDraftChange: this.actions.onRemoteCreate.draftChanged,
          onSend: this.actions.onRemoteCreate.send
        })
      } else {
        ConversationViewHost({
          viewState: ConversationViewState.project(route, this.remotePageState, this.generalPageState,
            this.actions.generalStatus()),
          showSidebarButton: showSidebarButton,
          showBackButton: showBackButton,
          onIntent: (intent: ConversationIntent) => this.actions.onConversationIntent(route, intent)
        })
      }
    }.width('100%').height('100%').backgroundColor(PAGE_BG)
  }

  @Builder
  WideGeneralChatContent(route: AppRoute) {
    Row() {
      Column() {
        AppSidebar({ sessions: this.generalPageState.recentSessions(), pinnedSessionId: this.generalPageState.pinnedSessionId(),
          selectedSessionId: this.generalPageState.activeSession.sessionId,
          connectionState: this.remotePageState.connectionState,
          accountUserId: this.remotePageState.accountUserId,
          activeSection: 'chat',
          showConversationSourceSwitcher: true,
          conversationSource: ConversationSource.General,
          onClose: this.actions.onSidebar.close,
          onNewChat: this.actions.onSidebar.newChat,
          onEnterCode: () => this.actions.onWideConversationSource(ConversationSource.Remote),
          onConversationSource: this.actions.onWideConversationSource,
          onOpenSettings: this.actions.onSidebar.settings, onOpenAccount: this.actions.onSidebar.openAccount,
          onOpenSession: this.actions.onSidebar.openSession,
          onArchiveSession: this.actions.onSidebar.archive, onExportSession: this.actions.onSidebar.exportSession,
          onDeleteSession: this.actions.onSidebar.deleteSession })
      }
      .width(this.wideMasterPaneWidth)
      .height('100%')
      .backgroundColor(PAGE_BG)
      .border({ width: { right: 1 }, color: LINE })

      this.WideMasterDetailGap()
      this.WideConversationDetail(route, true)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BG)
  }

  @Builder
  WideRemoteHomeContent() {
    Row() {
      this.RemoteMasterPane('')
      this.WideMasterDetailGap()

      Column() {
        this.RemoteFlowPlaceholder()
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(PAGE_BG)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BG)
  }

  @Builder
  RemoteMasterPane(selectedSessionId: string) {
    Column({ space: 12 }) {
      this.RemoteWidePaneHeader()
      ConversationSourceSwitcher({
        activeSource: ConversationSource.Remote,
        onSelectSource: this.actions.onWideConversationSource
      })
      if (this.canShowRemoteWideList()) {
        RemoteSessionList({
          sessions: this.remotePageState.visibleSessions(),
          query: this.remotePageState.sessionQuery,
          sortMode: this.remoteWideSortMode,
          workspaceName: this.remotePageState.workspaceName,
          workspacePath: this.remotePageState.workspacePath,
          workspaceKind: this.remotePageState.workspaceKind,
          recentWorkspaces: this.remotePageState.recentWorkspaces,
          hasMoreSessions: this.remotePageState.hasMoreSessions,
          isBusy: this.remotePageState.isBusy || this.remotePageState.isLoadingSessions,
          selectedSessionId: selectedSessionId,
          onCreate: () => {
            this.actions.onRemoteHome.create('code');
          },
          onCreateAssistantSession: () => {
            this.actions.onRemoteHome.createAssistant();
          },
          onCreateInWorkspace: (path: string, agentType: string) => {
            this.actions.onRemoteHome.createInWorkspace(path, agentType);
          },
          onSelectWorkspace: (path: string) => {
            this.actions.onRemoteHome.selectWorkspace(path);
          },
          onOpenSession: (session: RemoteSession) => {
            this.actions.onRemoteHome.openSession(session);
          },
          onDeleteSession: (session: RemoteSession) => {
            this.actions.onRemoteHome.deleteSession(session);
          },
          onLoadMore: () => {
            this.actions.onRemoteHome.loadMore();
          }
        })
        this.RemoteWideSearchBar()
      } else {
        this.RemoteWideDisconnected()
      }
    }
    .width(this.wideMasterPaneWidth)
    .height('100%')
    .padding({ left: 24, right: 18, top: 14, bottom: 12 })
    .backgroundColor(PAGE_BG)
    .border({ width: { right: 1 }, color: LINE })
  }

  @Builder
  RemoteWidePaneHeader() {
    Row({ space: 10 }) {
      Column({ space: 4 }) {
        Text(RemoteI18n.t('remote.title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 6 }) {
          this.RemoteWideStatusDot()
          Text(this.remoteWideStatusText())
            .fontSize(12)
            .fontColor(MUTED)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.remote_ref_more'))
          .width(22)
          .height(8)
          .objectFit(ImageFit.Contain)
      }
      .width(38)
      .height(38)
      .backgroundColor(CARD)
      .borderRadius(19)
      .border({ width: 1, color: LINE })
      .onClick(() => {
        this.actions.onRemoteHome.openSettings();
      })
    }
    .width('100%')
    .height(46)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  RemoteWideStatusDot() {
    Stack() {
      Text('')
    }
      .width(7)
      .height(7)
      .backgroundColor(this.remoteWideStatusColor())
      .borderRadius(4)
  }

  @Builder
  RemoteWideSearchBar() {
    Row({ space: 8 }) {
      Row({ space: 7 }) {
        Image($r('app.media.remote_ref_search_reference'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .opacity(0.58)
        TextInput({ placeholder: RemoteI18n.t('remote.searchChats'), text: this.remotePageState.sessionQuery })
          .height(38)
          .fontSize(14)
          .fontColor(INK)
          .placeholderColor(MUTED)
          .backgroundColor('#00000000')
          .padding({ left: 0, right: 0 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.actions.onRemoteHome.queryChanged(value);
          })
          .onSubmit(() => {
            this.actions.onRemoteHome.search();
          })
      }
      .height(42)
      .layoutWeight(1)
      .padding({ left: 12, right: 10 })
      .backgroundColor(CARD)
      .borderRadius(21)
      .border({ width: 1, color: LINE })

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.remote_ref_new_chat'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
      }
      .width(42)
      .height(42)
      .backgroundColor(INK)
      .borderRadius(21)
      .opacity(this.remotePageState.isBusy ? 0.45 : 1)
      .onClick(() => {
        if (!this.remotePageState.isBusy) {
          this.actions.onRemoteHome.createAssistant();
        }
      })
    }
    .width('100%')
    .height(46)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  RemoteWideDisconnected() {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.remote_ref_device'))
          .width(42)
          .height(42)
          .objectFit(ImageFit.Contain)
      }
      .width(74)
      .height(74)
      .backgroundColor(CARD)
      .borderRadius(24)
      .border({ width: 1, color: LINE })
      Text(RemoteI18n.t('remote.connectTitle'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
        .textAlign(TextAlign.Center)
      Text(RemoteI18n.t('remote.connectText'))
        .fontSize(13)
        .lineHeight(20)
        .fontColor(MUTED)
        .textAlign(TextAlign.Center)
      Button(RemoteI18n.t('connect.connect'))
        .width(136)
        .height(44)
        .fontSize(15)
        .fontColor(CARD)
        .backgroundColor(INK)
        .borderRadius(22)
        .onClick(() => {
          this.actions.onRemoteHome.connectWorkspace();
        })
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 20, right: 20, bottom: 48 })
  }

  @Builder
  WideRemoteChatContent() {
    Row() {
      this.RemoteMasterPane(this.remotePageState.activeSession.sessionId)
      this.WideMasterDetailGap()
      this.WideConversationDetail(AppRoute.RemoteChat, false)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BG)
  }

  @Builder
  WideConversationDetail(route: AppRoute, showBackButton: boolean) {
    Row() {
      if (this.wideDetailContentOffset > 0) {
        Blank().width(this.wideDetailContentOffset)
      }
      Row() {
        Column() {
          this.RouteSurfaceContent(route, false, showBackButton)
        }
        .width('100%')
        .height('100%')
        .constraintSize({ maxWidth: WIDE_DETAIL_CONTENT_MAX_WIDTH })
        .backgroundColor(PAGE_BG)
      }
      .width(this.wideDetailContentWidth > 0 ? this.wideDetailContentWidth : '100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      if (this.wideDetailContentOffset > 0) {
        Blank().layoutWeight(1)
      }
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(PAGE_BG)
  }

  @Builder
  WideMasterDetailGap() {
    if (this.wideMasterDetailGap > 0) {
      Row() {
      }
      .width(this.wideMasterDetailGap)
      .height('100%')
      .backgroundColor(LINE)
    }
  }

  @Builder
  RemoteFlowPlaceholder() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text(RemoteI18n.t('remote.chats'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text(this.remoteDesktopName())
            .fontSize(13)
            .fontColor(MUTED)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
      }
      .width('100%')
      .height(76)
      .padding({ left: 24, right: 24, top: 14, bottom: 12 })
      .border({ width: { bottom: 1 }, color: LINE })

      Column({ space: 8 }) {
        Text(this.remoteFlowPlaceholderTitle())
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
        Text(this.remoteWideStatusText())
          .fontSize(14)
          .fontColor(MUTED)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 24, right: 24, bottom: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BG)
  }

  private isWideLayout(): boolean {
    return ConversationLayoutPolicy.useMasterDetail(
      this.viewportWidth,
      this.wideLayoutMatched,
      this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED
    );
  }

  private isGeneralWideRoute(route: AppRoute): boolean {
    return route === AppRoute.ChatHome || route === AppRoute.GeneralChat;
  }

  private bindResponsiveQueries(): void {
    this.unbindResponsiveQueries();
    try {
      const appMediaQuery = this.getUIContext().getMediaQuery();
      this.wideQueryListener = appMediaQuery.matchMediaSync(
        `screen and (${ConversationLayoutPolicy.WIDE_LAYOUT_MIN_WIDTH} < width)`
      );
      this.wideLayoutMatched = this.wideQueryListener.matches;
      this.wideQueryListener.on('change', this.wideQueryChanged);
    } catch (_err) {
      this.wideLayoutMatched = this.viewportWidth >= ConversationLayoutPolicy.WIDE_LAYOUT_MIN_WIDTH;
      this.unbindResponsiveQueries();
    }
  }

  private bindFoldStatus(): void {
    this.unbindFoldStatus();
    try {
      this.foldStatus = display.getFoldStatus();
      this.refreshWideGeometry();
      display.on('foldStatusChange', this.foldStatusChanged);
    } catch (_err) {
      this.foldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;
      this.unbindFoldStatus();
    }
  }

  private unbindFoldStatus(): void {
    try {
      display.off('foldStatusChange', this.foldStatusChanged);
    } catch (_err) {
    }
  }

  private unbindResponsiveQueries(): void {
    if (this.wideQueryListener) {
      this.wideQueryListener.off('change', this.wideQueryChanged);
      this.wideQueryListener = undefined;
    }
  }

  private areaWidth(width: Object): number {
    const value = Number.parseFloat(`${width}`);
    return Number.isNaN(value) ? 0 : value;
  }

  private refreshWideGeometry(): void {
    const geometry = ConversationLayoutPolicy.resolveWideGeometry(
      this.viewportWidth,
      this.currentVerticalCreases()
    );
    this.wideMasterPaneWidth = geometry.masterPaneWidth;
    this.wideMasterDetailGap = geometry.masterDetailGap;
    this.wideDetailContentOffset = geometry.detailContentOffset;
    this.wideDetailContentWidth = geometry.detailContentWidth;
  }

  private currentVerticalCreases(): ConversationLayoutCrease[] {
    if (this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
      return [];
    }
    try {
      const region = display.getCurrentFoldCreaseRegion();
      return region.creaseRects
        .filter((rect: display.Rect): boolean => rect.height > rect.width)
        .map((rect: display.Rect): ConversationLayoutCrease => {
          return new ConversationLayoutCrease(
            this.getUIContext().px2vp(rect.left),
            this.getUIContext().px2vp(rect.width)
          );
        });
    } catch (_err) {
      return [];
    }
  }

  private canShowRemoteWideList(): boolean {
    return this.remotePageState.connectionState === 'connected' || this.remotePageState.visibleSessions().length > 0 ||
      this.remotePageState.isLoadingHome || this.remotePageState.isLoadingSessions;
  }

  private remoteWideStatusText(): string {
    if (this.remotePageState.statusText.length > 0) {
      return this.remotePageState.statusText;
    }
    return this.remoteDesktopName();
  }

  private remoteWideStatusColor(): string {
    if (this.remotePageState.connectionState === 'connected') {
      return GREEN;
    }
    if (this.remotePageState.connectionState === 'failed' || this.remotePageState.connectionState === 'disconnected') {
      return RED;
    }
    return MUTED;
  }

  private remoteDesktopName(): string {
    return this.remotePageState.desktopName.length > 0 ? this.remotePageState.desktopName :
      RemoteI18n.t('remote.settings.noDesktop');
  }

  private remoteFlowPlaceholderTitle(): string {
    return this.remotePageState.visibleSessions().length > 0 ? '选择会话' : RemoteI18n.t('remote.emptyTitle');
  }

  @Builder SidebarContent() {
    AppSidebar({ sessions: this.generalPageState.recentSessions(), pinnedSessionId: this.generalPageState.pinnedSessionId(),
      selectedSessionId: this.currentRoute === AppRoute.ChatHome || this.currentRoute === AppRoute.GeneralChat ?
        this.generalPageState.activeSession.sessionId : '', connectionState: this.remotePageState.connectionState,
      accountUserId: this.remotePageState.accountUserId,
      activeSection: this.currentRoute === AppRoute.RemoteHome || this.currentRoute === AppRoute.RemoteChat ? 'remote' : 'chat',
      onClose: this.actions.onSidebar.close,
      onNewChat: this.actions.onSidebar.newChat, onEnterCode: this.actions.onSidebar.enterCode,
      onOpenSettings: this.actions.onSidebar.settings, onOpenAccount: this.actions.onSidebar.openAccount,
      onOpenSession: this.actions.onSidebar.openSession,
      onArchiveSession: this.actions.onSidebar.archive, onExportSession: this.actions.onSidebar.exportSession,
      onDeleteSession: this.actions.onSidebar.deleteSession })
  }

  @Builder SettingsContent() {
    if (this.shellState.settingsMode === 'remote' || this.shellState.settingsMode === 'account') {
      RemoteControlSettingsSheet({ desktopName: this.remotePageState.desktopName, desktopId: this.remotePageState.desktopId,
        userId: this.remotePageState.userId, accountUsername: this.remotePageState.accountUsername,
        accountUserId: this.remotePageState.accountUserId, deviceId: this.deviceId,
        controlTargetType: this.remotePageState.controlTargetType,
        controlTargetDeviceId: this.remotePageState.controlTargetDeviceId,
        connectionState: this.remotePageState.connectionState, statusText: this.remotePageState.statusText,
        isBusy: this.remotePageState.isBusy, onClose: this.actions.onSettings.close,
        onOpenAccount: this.actions.onSettings.openAccount,
        onAddConnection: this.actions.onSettings.addConnection,
        cloudLogin: this.actions.onSettings.cloudLogin,
        cloudSync: this.actions.onSettings.cloudSync,
        cloudLogout: this.actions.onSettings.cloudLogout,
        cloudListDevices: this.actions.onSettings.cloudListDevices,
        getPermissionMode: this.actions.onSettings.getPermissionMode,
        setPermissionMode: this.actions.onSettings.setPermissionMode,
        openAccountOnAppear: this.shellState.settingsMode === 'account',
        onDisconnect: this.actions.onSettings.disconnect, onReconnect: this.actions.onSettings.reconnect })
    } else {
      SettingsSheet({ generalChatApiUrl: this.generalPageState.apiUrl, generalChatModelName: this.generalPageState.modelName,
        hasGeneralChatApiKey: this.generalPageState.hasApiKey,
        accountUsername: this.remotePageState.accountUsername,
        authenticatedUserId: this.remotePageState.accountUserId,
      deviceId: this.deviceId,
      onOpenAccount: this.actions.onSettings.openAccount,
      onTestGeneralChatConfig: this.actions.onSettings.testGeneral,
      onSaveGeneralChatConfig: this.actions.onSettings.saveGeneral,
      onClose: this.actions.onSettings.close })
    }
  }

  @Builder ConnectContent() {
    ConnectView({ remoteUrl: this.remotePageState.remoteUrl, userId: this.remotePageState.userId,
      showRemoteUrlInput: this.remotePageState.showRemoteUrlInput, statusText: this.remotePageState.statusText,
      connectionState: this.remotePageState.connectionState, connectionFailureKind: this.remotePageState.connectionFailureKind,
      isBusy: this.remotePageState.isBusy, isConnected: this.remotePageState.connectionState === 'connected',
      desktopName: this.remotePageState.desktopName, desktopId: this.remotePageState.desktopId, deviceId: this.deviceId,
      accountUserId: this.remotePageState.accountUserId,
      controlTargetDeviceId: this.remotePageState.controlTargetDeviceId,
      requiresAccountAuth: this.remotePageState.requiresAccountAuth, accountUsername: this.remotePageState.accountUsername,
      startWithScanner: true,
      onBack: this.actions.onConnect.back, onConnect: this.actions.onConnect.connect,
      onClearPairing: this.actions.onConnect.clearPairing, onRemoteUrlChange: this.actions.onConnect.urlChanged,
      onUserIdChange: this.actions.onConnect.userChanged, onRemoteUrlDetected: this.actions.onConnect.detected,
      onRemoteUrlInputVisibleChange: this.actions.onConnect.inputVisible,
      onPasteRemoteUrl: this.actions.onConnect.paste, onScanRemoteUrl: this.actions.onConnect.scan,
      cloudListDevices: this.actions.onConnect.cloudListDevices,
      cloudSelectDevice: this.actions.onConnect.cloudSelectDevice })
      .width('100%').height('100%')
  }
}
