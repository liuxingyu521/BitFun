import { RemoteSession } from '../../model/RemoteModels';
import { RemoteI18n } from '../../i18n/RemoteI18n';
import { RemoteActionsSheet } from './RemoteActionsSheet';
import { RemoteBottomBar } from './RemoteBottomBar';
import { RemoteHeader } from './RemoteHeader';
import { RemoteSessionList } from './RemoteSessionList';
import { RemoteSessionLoadingView } from './RemoteSessionLoadingView';
import { RemotePageState } from '../state/RemotePageState';
import { ACCENT, CARD, INK, MUTED, PAGE_BG } from './Theme';

@ComponentV2
export struct RemoteHomeView {
  @Param pageState: RemotePageState = new RemotePageState();
  @Param isBusy: boolean = false;
  @Param selectedSessionId: string = '';
  @Event onOpenSidebar: () => void = () => {};
  @Event onConnectWorkspace: () => void = () => {};
  @Event onAddConnection: () => void = () => {};
  @Event onOpenRemoteSettings: () => void = () => {};
  @Event onRefresh: () => void = () => {};
  @Event onShowWorkspaces: () => void = () => {};
  @Event onShowAssistants: () => void = () => {};
  @Event onSelectWorkspace: (path: string) => void = (_path: string) => {};
  @Event onSelectAssistant: (path: string) => void = (_path: string) => {};
  @Event onCancelWorkspacePicker: () => void = () => {};
  @Event onCancelAssistantPicker: () => void = () => {};
  @Event onSessionQueryChange: (value: string) => void = (_value: string) => {};
  @Event onSearchSessions: () => void = () => {};
  @Event onLoadMoreSessions: () => void = () => {};
  @Event onReconnect: () => void = () => {};
  @Event onDisconnect: () => void = () => {};
  @Event onClearPairing: () => void = () => {};
  @Event onCreate: (agentType: string) => void = (_agentType: string) => {};
  @Event onCreateAssistantSession: () => void = () => {};
  @Event onCreateInWorkspace: (path: string, agentType: string) => void = (_path: string, _agentType: string) => {};
  @Event onOpenSession: (session: RemoteSession) => void = (_session: RemoteSession) => {};
  @Event onDeleteSession: (session: RemoteSession) => void = (_session: RemoteSession) => {};
  @Local showRemoteActions: boolean = false;
  @Local sortMode: string = 'project';

  build() {
    Stack() {
      Column() {
        RemoteHeader({
          desktopName: this.pageState.desktopName,
          connectionState: this.pageState.connectionState,
          isLoading: this.pageState.isLoadingHome,
          onOpenSidebar: () => {
            this.onOpenSidebar();
          },
          onOpenActions: () => {
            this.openRemoteActions();
          }
        })
        if (this.isInitialLoading()) {
          RemoteSessionLoadingView()
          RemoteBottomBar({
            query: this.pageState.sessionQuery,
            isBusy: true,
            onQueryChange: (value: string) => {
              this.onSessionQueryChange(value);
            },
            onSearch: () => {
              this.onSearchSessions();
            },
            onCreate: () => {
              this.onCreateAssistantSession();
            }
          })
        } else if (this.canUseRemote()) {
          RemoteSessionList({
            sessions: this.pageState.visibleSessions(),
            query: this.pageState.sessionQuery,
            sortMode: this.sortMode,
            workspaceName: this.pageState.workspaceName,
            workspacePath: this.pageState.workspacePath,
            workspaceKind: this.pageState.workspaceKind,
            recentWorkspaces: this.pageState.recentWorkspaces,
            hasMoreSessions: this.pageState.hasMoreSessions,
            isBusy: this.isBusy || this.pageState.isLoadingSessions,
            onCreate: () => {
              this.onCreate('code');
            },
            onCreateAssistantSession: () => {
              this.onCreateAssistantSession();
            },
            onCreateInWorkspace: (path: string, agentType: string) => {
              this.onCreateInWorkspace(path, agentType);
            },
            onSelectWorkspace: (path: string) => {
              this.onSelectWorkspace(path);
            },
            onOpenSession: (session: RemoteSession) => {
              this.onOpenSession(session);
            },
            onDeleteSession: (session: RemoteSession) => {
              this.onDeleteSession(session);
            },
            selectedSessionId: this.selectedSessionId,
            onLoadMore: () => {
              this.onLoadMoreSessions();
            }
          })
          RemoteBottomBar({
            query: this.pageState.sessionQuery,
            isBusy: this.isBusy,
            onQueryChange: (value: string) => {
              this.onSessionQueryChange(value);
            },
            onSearch: () => {
              this.onSearchSessions();
            },
            onCreate: () => {
              this.onCreateAssistantSession();
            }
          })
        } else {
          this.DisconnectedState()
        }
      }
      if (this.showRemoteActions) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Text('')
            .width('100%')
            .height('100%')
            .backgroundColor('#06000000')
            .onClick(() => {
              this.dismissRemoteActions();
            })
          Column() {
            this.RemoteActionsLayer()
          }
            .width(330)
            .height(390)
            .margin({ top: 4, right: 4 })
            .transition(TransitionEffect.translate({ x: 18, y: -12 })
              .combine(TransitionEffect.opacity(0))
              .animation({ duration: 220, curve: Curve.EaseOut }))
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 0, bottom: 16 })
    .backgroundColor(PAGE_BG)
  }

  @Builder
  RemoteActionsLayer() {
    RemoteActionsSheet({
      desktopName: this.pageState.desktopName,
      workspaceName: this.pageState.workspaceName,
      workspacePath: this.pageState.workspacePath,
      assistantId: this.pageState.assistantId,
      connectionState: this.pageState.connectionState,
      isBusy: this.isBusy,
      sortMode: this.sortMode,
      recentWorkspaces: this.pageState.recentWorkspaces,
      assistants: this.pageState.assistants,
      showWorkspacePicker: this.pageState.showWorkspacePicker,
      showAssistantPicker: this.pageState.showAssistantPicker,
      onClose: () => {
        this.closeRemoteActions();
      },
      onDismiss: () => {
        this.dismissRemoteActions();
      },
      onRefresh: () => {
        this.onRefresh();
      },
      onShowWorkspaces: () => {
        this.onShowWorkspaces();
      },
      onShowAssistants: () => {
        this.onShowAssistants();
      },
      onSelectWorkspace: (path: string) => {
        this.onSelectWorkspace(path);
      },
      onSelectAssistant: (path: string) => {
        this.onSelectAssistant(path);
      },
      onCancelWorkspacePicker: () => {
        this.onCancelWorkspacePicker();
      },
      onCancelAssistantPicker: () => {
        this.onCancelAssistantPicker();
      },
      onReconnect: () => {
        this.onReconnect();
      },
      onDisconnect: () => {
        this.onDisconnect();
      },
      onClearPairing: () => {
        this.onClearPairing();
      },
      onSortModeChange: (mode: string) => {
        this.sortMode = mode;
      },
      onAddConnection: () => {
        this.onAddConnection();
      },
      onOpenSettings: () => {
        this.onOpenRemoteSettings();
      }
    })
  }

  @Builder
  DisconnectedState() {
    Column({ space: 10 }) {
      this.LargeDesktopGlyph()
      Text(RemoteI18n.t('remote.connectTitle'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
        .margin({ top: 8 })
      Text(RemoteI18n.t('remote.connectText'))
        .fontSize(14)
        .lineHeight(21)
        .fontColor(MUTED)
        .textAlign(TextAlign.Center)
        .constraintSize({ maxWidth: 280 })
      Button(RemoteI18n.t('connect.connect'))
        .width(148)
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(CARD)
        .backgroundColor(ACCENT)
        .borderRadius(25)
        .margin({ top: 14 })
        .onClick(() => {
          this.onConnectWorkspace();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: 72 })
  }

  @Builder
  LargeDesktopGlyph() {
    Stack() {
      Text('')
        .width(46)
        .height(34)
        .borderRadius(6)
        .border({ width: 2, color: INK })
        .position({ x: 9, y: 4 })
      Text('')
        .width(18)
        .height(2)
        .backgroundColor(INK)
        .position({ x: 23, y: 44 })
      Text('')
        .width(34)
        .height(2)
        .backgroundColor(INK)
        .position({ x: 15, y: 51 })
    }
    .width(64)
    .height(58)
  }

  private closeRemoteActions(): void {
    this.onCancelWorkspacePicker();
    this.onCancelAssistantPicker();
    this.dismissRemoteActions();
  }

  private openRemoteActions(): void {
    this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseOut }, () => {
      this.showRemoteActions = true;
    });
  }

  private dismissRemoteActions(): void {
    this.getUIContext().animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
      this.showRemoteActions = false;
    });
  }

  private canUseRemote(): boolean {
    return this.pageState.connectionState === 'connected';
  }

  private isConnecting(): boolean {
    return this.pageState.connectionState === 'parsing' ||
      this.pageState.connectionState === 'pairing' ||
      this.pageState.connectionState === 'reconnecting';
  }

  private isInitialLoading(): boolean {
    return this.pageState.isLoadingHome || this.isConnecting();
  }

}
