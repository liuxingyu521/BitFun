import { RecentWorkspaceEntry, RemoteSession } from '../../model/RemoteModels';
import { RemoteI18n } from '../../i18n/RemoteI18n';
import { TimeFormat } from '../../services/TimeFormat';
import { CARD, INK, MUTED, RED } from './Theme';

@ComponentV2
export struct RemoteSessionList {
  @Param sessions: RemoteSession[] = [];
  @Param query: string = '';
  @Param sortMode: string = 'project';
  @Param hasMoreSessions: boolean = false;
  @Param isBusy: boolean = false;
  @Param selectedSessionId: string = '';
  @Param workspaceName: string = '';
  @Param workspacePath: string = '';
  @Param workspaceKind: string = 'normal';
  @Param recentWorkspaces: RecentWorkspaceEntry[] = [];
  @Event onCreate: () => void = () => {};
  @Event onOpenSession: (session: RemoteSession) => void = (_session: RemoteSession) => {};
  @Event onDeleteSession: (session: RemoteSession) => void = (_session: RemoteSession) => {};
  @Event onLoadMore: () => void = () => {};
  @Event onCreateAssistantSession: () => void = () => {};
  @Event onCreateInWorkspace: (path: string, agentType: string) => void = (_path: string, _agentType: string) => {};
  @Event onSelectWorkspace: (path: string) => void = (_path: string) => {};
  @Local collapsedWorkspacePaths: string[] = [];
  @Local projectVisibleSteps: string[] = [];
  @Local visibleProjectCount: number = 3;
  @Local chatsCollapsed: boolean = false;
  @Local chatVisibleCount: number = 3;
  @Local todayCollapsed: boolean = false;
  @Local yesterdayCollapsed: boolean = false;
  @Local earlierCollapsed: boolean = false;
  @Local createMenuPath: string = '';

  @Monitor('isBusy', 'workspacePath')
  onWorkspaceContextChanged(): void {
    this.createMenuPath = '';
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          if (this.sortMode === 'time') {
            this.TimeSection()
          } else if (this.sortMode === 'chat') {
            this.ChatSection()
            this.ProjectSection()
          } else {
            this.ProjectSection()
            this.ChatSection()
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private TimeSection() {
    Column() {
      if (this.sessionsByTime().length === 0) {
        this.EmptySessions()
      } else {
        if (this.sessionsForTimeBucket('today').length > 0) {
          this.TodayGroup()
        }
        if (this.sessionsForTimeBucket('yesterday').length > 0) {
          this.YesterdayGroup()
        }
        if (this.sessionsForTimeBucket('earlier').length > 0) {
          this.EarlierGroup()
        }
      }
    }
    .width('100%')
    .margin({ top: 14, bottom: 16 })
  }

  @Builder
  private TodayGroup() {
    Column() {
      this.TimeGroupHeader(RemoteI18n.t('remote.time.today'), this.todayCollapsed, () => {
        this.todayCollapsed = !this.todayCollapsed;
      })
      if (!this.todayCollapsed) {
        ForEach(this.sessionsForTimeBucket('today'), (item: RemoteSession) => {
          this.SessionRow(item)
        }, (item: RemoteSession) => item.id)
      }
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  private YesterdayGroup() {
    Column() {
      this.TimeGroupHeader(RemoteI18n.t('remote.time.yesterday'), this.yesterdayCollapsed, () => {
        this.yesterdayCollapsed = !this.yesterdayCollapsed;
      })
      if (!this.yesterdayCollapsed) {
        ForEach(this.sessionsForTimeBucket('yesterday'), (item: RemoteSession) => {
          this.SessionRow(item)
        }, (item: RemoteSession) => item.id)
      }
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  private EarlierGroup() {
    Column() {
      this.TimeGroupHeader(RemoteI18n.t('remote.time.earlier'), this.earlierCollapsed, () => {
        this.earlierCollapsed = !this.earlierCollapsed;
      })
      if (!this.earlierCollapsed) {
        ForEach(this.sessionsForTimeBucket('earlier'), (item: RemoteSession) => {
          this.SessionRow(item)
        }, (item: RemoteSession) => item.id)
      }
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  private TimeGroupHeader(title: string, collapsed: boolean, action: () => void) {
    Row({ space: 8 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
      if (collapsed) {
        Image($r('app.media.remote_ref_chevron_right'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .opacity(0.55)
      } else {
        Image($r('app.media.remote_ref_chevron_centered'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .opacity(0.55)
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .onClick(action)
  }

  @Builder
  private ProjectSection() {
    Column({ space: 4 }) {
      Row() {
        Row({ space: 8 }) {
          Text(RemoteI18n.t('sidebar.projects'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text(`${this.projectEntries().length}`)
            .fontSize(14)
            .fontColor(MUTED)
        }
        Blank()
      }
      .width('100%')
      .height(58)
      .alignItems(VerticalAlign.Center)
      ForEach(this.visibleProjectEntries(), (project: RecentWorkspaceEntry) => {
        Column({ space: 2 }) {
          Row({ space: 10 }) {
            Image($r('app.media.remote_ref_folder'))
              .width(30)
              .height(25)
              .objectFit(ImageFit.Contain)
            Text(project.name || this.basename(project.path))
              .fontSize(18)
              .fontColor(INK)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            if (this.isWorkspaceCollapsed(project.path)) {
              Image($r('app.media.remote_ref_chevron_right'))
                .width(18)
                .height(18)
                .objectFit(ImageFit.Contain)
            } else {
              Image($r('app.media.remote_ref_chevron_centered'))
                .width(18)
                .height(18)
                .objectFit(ImageFit.Contain)
            }
            if (project.path.length > 0) {
              Image($r('app.media.remote_ref_edit'))
                .width(25)
                .height(25)
                .objectFit(ImageFit.Contain)
                .opacity(0.52)
                .bindPopup(this.createMenuPath.length > 0 && this.createMenuPath === project.path, {
                  builder: () => {
                    this.ProjectCreateMenu(project.path)
                  },
                  placement: Placement.Top,
                  popupColor: '#00000000',
                  enableArrow: false,
                  autoCancel: true,
                  mask: false,
                  targetSpace: 6,
                  onStateChange: (event) => {
                    if (!event.isVisible) {
                      this.createMenuPath = '';
                    }
                  }
                })
                .onClick(() => {
                  this.createMenuPath = this.createMenuPath === project.path ? '' : project.path;
                })
            }
          }
          .width('100%')
          .height(50)
          .onClick(() => {
            this.toggleWorkspace(project.path);
          })
          if (!this.isWorkspaceCollapsed(project.path)) {
            this.projectPreview(project.path)
          }
        }
        .width('100%')
        .margin({ bottom: 8 })
      }, (project: RecentWorkspaceEntry): string => project.path)
      if (this.visibleProjectCount < this.projectEntries().length) {
        Text(RemoteI18n.f('remote.projects.showMore', String(this.nextProjectEntryBatchSize())))
          .fontSize(15)
          .fontColor(MUTED)
          .height(48)
          .width('100%')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.visibleProjectCount += 3;
          })
      }
    }
    .width('100%')
    .margin({ top: 18 })
  }

  @Builder
  private ProjectCreateMenu(path: string) {
    Column({ space: 2 }) {
      this.ProjectCreateMenuItem('Code', 'code', path)
      this.ProjectCreateMenuItem('Cowork', 'Cowork', path)
    }
    .width(150)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(CARD)
    .borderRadius(14)
    .border({ width: 1, color: '#18000000' })
    .shadow({ radius: 20, color: '#1A000000', offsetY: 8 })
  }

  @Builder
  private ProjectCreateMenuItem(label: string, agentType: string, path: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor(INK)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(42)
    .padding({ left: 18, right: 18 })
    .onClick(() => {
      this.createMenuPath = '';
      this.onCreateInWorkspace(path, agentType);
    })
  }

  @Builder
  private ChatSection() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Text(RemoteI18n.t('remote.chats'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          if (this.chatsCollapsed) {
            Image($r('app.media.remote_ref_chevron_right'))
              .width(18)
              .height(18)
              .objectFit(ImageFit.Contain)
          } else {
            Image($r('app.media.remote_ref_chevron_centered'))
              .width(18)
              .height(18)
              .objectFit(ImageFit.Contain)
          }
        }
        .onClick(() => {
          this.chatsCollapsed = !this.chatsCollapsed;
        })
        Blank()
        Image($r('app.media.remote_ref_edit'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Contain)
          .opacity(0.52)
          .onClick(() => {
            this.onCreateAssistantSession();
          })
      }
      .width('100%')
      .height(58)
      .alignItems(VerticalAlign.Center)
      if (this.visibleChatSessions().length === 0) {
        this.EmptySessions()
      } else if (!this.chatsCollapsed) {
        ForEach(this.visibleChatSessions().slice(0, this.chatVisibleCount), (item: RemoteSession) => {
          this.SessionRow(item)
        })
        if (this.chatVisibleCount < this.visibleChatSessions().length) {
          Text(RemoteI18n.f('remote.sessions.showMore', String(this.nextChatBatchSize())))
            .fontSize(15)
            .fontColor(MUTED)
            .height(48)
            .width('100%')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.chatVisibleCount += 3;
            })
        }
      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 16 })
  }

  @Builder
  private projectPreview(path: string) {
    ForEach(this.visibleProjectSessions(path), (item: RemoteSession) => {
      Row() {
        Text(item.title || RemoteI18n.t('sidebar.untitled'))
          .fontSize(16)
          .fontColor(INK)
          .fontWeight(this.selectedSessionId === item.id ? FontWeight.Medium : FontWeight.Regular)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .height(58)
      .padding({ left: 0, right: 8 })
      .backgroundColor(this.selectedSessionId === item.id ? '#F3F3F3' : '#00000000')
      .borderRadius(12)
      .onClick(() => {
        this.onOpenSession(item);
      })
    })
    if (this.projectVisibleCount(path) < this.projectSessions(path).length) {
      Text(RemoteI18n.f('remote.sessions.showMore', String(this.nextProjectBatchSize(path))))
        .fontSize(15)
        .fontColor(MUTED)
        .height(44)
        .width('100%')
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.projectVisibleSteps = this.projectVisibleSteps.concat([path]);
        })
    }
  }

  private projectEntries(): RecentWorkspaceEntry[] {
    const entries: RecentWorkspaceEntry[] = [];
    if ((this.workspacePath.length > 0 || this.workspaceName.length > 0) && !this.isAssistantWorkspace(this.workspacePath)) {
      entries.push({ path: this.workspacePath, name: this.workspaceName, lastOpened: '', workspaceKind: 'normal' });
    }
    this.recentWorkspaces.forEach((item: RecentWorkspaceEntry) => {
      if (item.path.length > 0 && !this.isAssistantWorkspace(item.path) &&
        !entries.some((entry: RecentWorkspaceEntry) => entry.path === item.path)) {
        entries.push(item);
      }
    });
    return entries;
  }

  private visibleProjectEntries(): RecentWorkspaceEntry[] {
    return this.projectEntries().slice(0, this.visibleProjectCount);
  }

  private nextProjectEntryBatchSize(): number {
    return Math.min(3, this.projectEntries().length - this.visibleProjectCount);
  }

  private basename(path: string): string {
    const parts = path.split('/');
    return parts.length > 0 ? parts[parts.length - 1] : path;
  }

  private visibleChatSessions(): RemoteSession[] {
    const query = this.query.trim().toLowerCase();
    return this.sessions.filter((item: RemoteSession) => {
      if (!this.isAssistantSession(item) || item.status === 'archived') {
        return false;
      }
      return query.length === 0 || item.title.toLowerCase().indexOf(query) >= 0;
    });
  }

  private sessionsByTime(): RemoteSession[] {
    const query = this.query.trim().toLowerCase();
    return this.sessions.filter((item: RemoteSession) => {
      if (item.status === 'archived') {
        return false;
      }
      return query.length === 0 || item.title.toLowerCase().indexOf(query) >= 0;
    }).slice().sort((left: RemoteSession, right: RemoteSession) => {
      return this.sessionTimestamp(right) - this.sessionTimestamp(left);
    });
  }

  private sessionsForTimeBucket(bucket: string): RemoteSession[] {
    return this.sessionsByTime().filter((item: RemoteSession) => {
      return this.timeBucket(item) === bucket;
    });
  }

  private timeBucket(item: RemoteSession): string {
    const timestamp = this.sessionTimestamp(item);
    if (timestamp <= 0) {
      return 'earlier';
    }
    const sessionDate = new Date(timestamp);
    const now = new Date();
    if (this.sameCalendarDay(sessionDate, now)) {
      return 'today';
    }
    const yesterday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1);
    return this.sameCalendarDay(sessionDate, yesterday) ? 'yesterday' : 'earlier';
  }

  private sessionTimestamp(item: RemoteSession): number {
    const updated = TimeFormat.timestampMs(item.updatedAt || '');
    if (!Number.isNaN(updated) && updated > 0) {
      return updated;
    }
    const created = TimeFormat.timestampMs(item.createdAt || '');
    return !Number.isNaN(created) && created > 0 ? created : 0;
  }

  private sameCalendarDay(left: Date, right: Date): boolean {
    return left.getFullYear() === right.getFullYear() &&
      left.getMonth() === right.getMonth() &&
      left.getDate() === right.getDate();
  }

  private projectSessions(path: string): RemoteSession[] {
    return this.sessions.filter((item: RemoteSession) => {
      return !this.isAssistantSession(item) && (item.workspacePath || this.workspacePath) === path;
    });
  }

  private visibleProjectSessions(path: string): RemoteSession[] {
    return this.projectSessions(path).slice(0, this.projectVisibleCount(path));
  }

  private projectVisibleCount(path: string): number {
    const additionalSteps = this.projectVisibleSteps.filter((item: string) => item === path).length;
    return 3 + additionalSteps * 3;
  }

  private nextProjectBatchSize(path: string): number {
    return Math.min(3, this.projectSessions(path).length - this.projectVisibleCount(path));
  }

  private nextChatBatchSize(): number {
    return Math.min(3, this.visibleChatSessions().length - this.chatVisibleCount);
  }

  private isAssistantSession(item: RemoteSession): boolean {
    const agentType = (item.agentType || '').toLowerCase();
    return agentType === 'claw' || agentType === 'assistant' || agentType === 'chat' ||
      this.isAssistantWorkspace(item.workspacePath || '');
  }

  private isAssistantWorkspace(path: string): boolean {
    if (path.length === 0) {
      return this.workspaceKind.toLowerCase() === 'assistant';
    }
    if (path === this.workspacePath && this.workspaceKind.toLowerCase() === 'assistant') {
      return true;
    }
    return this.recentWorkspaces.some((item: RecentWorkspaceEntry) => {
      return item.path === path && item.workspaceKind.toLowerCase() === 'assistant';
    });
  }


  private isWorkspaceCollapsed(path: string): boolean {
    return this.collapsedWorkspacePaths.indexOf(path) >= 0;
  }

  private toggleWorkspace(path: string): void {
    if (this.isWorkspaceCollapsed(path)) {
      this.collapsedWorkspacePaths = this.collapsedWorkspacePaths.filter((item: string) => item !== path);
    } else {
      this.collapsedWorkspacePaths = this.collapsedWorkspacePaths.concat([path]);
    }
  }

  @Builder
  private SessionRow(item: RemoteSession) {
    Row() {
      Text(item.title || RemoteI18n.t('sidebar.untitled'))
        .fontSize(18)
        .fontWeight(this.selectedSessionId === item.id ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(INK)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text('›')
        .fontSize(22)
        .fontColor('#00000000')
    }
    .width('100%')
    .height(58)
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.selectedSessionId === item.id ? '#F3F3F3' : '#00000000')
    .borderRadius(12)
    .onClick(() => {
      this.onOpenSession(item);
    })
  }

  @Builder
  private EmptySessions() {
    Column({ space: 8 }) {
      Text(this.isBusy ? RemoteI18n.t('home.emptyLoadingTitle') : RemoteI18n.t('remote.emptyTitle'))
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Text(this.isBusy ? RemoteI18n.t('home.emptyLoadingText') : RemoteI18n.t('remote.emptyText'))
        .fontSize(14)
        .lineHeight(21)
        .fontColor(MUTED)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 36, right: 36, bottom: 80 })
  }

  @Builder
  private DeleteReveal(item: RemoteSession) {
    Text(RemoteI18n.t('home.deleteSession'))
      .fontSize(13)
      .fontColor(CARD)
      .textAlign(TextAlign.Center)
      .width(92)
      .height(58)
      .backgroundColor(RED)
      .onClick(() => {
        this.onDeleteSession(item);
      })
  }

  private sessionSwipeAction(item: RemoteSession): SwipeActionOptions {
    if (this.isBusy || item.id.length === 0) {
      return {};
    }
    return {
      end: {
        builder: () => {
          this.DeleteReveal(item);
        },
        actionAreaDistance: 92,
        onAction: () => {
          this.onDeleteSession(item);
        }
      },
      edgeEffect: SwipeEdgeEffect.None
    };
  }
}
