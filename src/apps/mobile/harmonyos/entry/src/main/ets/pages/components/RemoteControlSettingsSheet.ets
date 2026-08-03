import { RemoteI18n } from '../../i18n/RemoteI18n';
import { CARD, GREEN, INK, LINE, MUTED } from './Theme';
import { CloudAccountDevice } from '../../services/CloudAccountClient';
import { RemotePermissionMode } from '../../model/RemoteModels';
import { DefaultAccountAvatar } from './DefaultAccountAvatar';
import { BitFunAccountLoginPage } from './BitFunAccountLoginPage';

const REMOTE_SETTINGS_BG: string = '#F4F4F7';
const REMOTE_SETTINGS_BLUE: string = '#0A84FF';

@Component
export struct RemoteControlSettingsSheet {
  @Prop desktopName: string = '';
  @Prop desktopId: string = '';
  @Prop userId: string = '';
  @Prop accountUsername: string = '';
  @Prop @Watch('handleAccountUserChanged') accountUserId: string = '';
  @Prop deviceId: string = '';
  @Prop controlTargetType: string = 'none';
  @Prop controlTargetDeviceId: string = '';
  @Prop connectionState: string = 'idle';
  @Prop statusText: string = '';
  @Prop isBusy: boolean = false;
  @Prop openAccountOnAppear: boolean = false;
  onClose: () => void = () => {};
  onOpenAccount: () => void = () => {};
  onAddConnection: () => void = () => {};
  cloudLogin: (relayUrl: string, username: string, password: string) => Promise<string> = async (_relayUrl: string, _username: string, _password: string): Promise<string> => '';
  cloudSync: () => Promise<string> = async (): Promise<string> => '0';
  cloudLogout: () => Promise<void> = async (): Promise<void> => {};
  cloudListDevices: () => Promise<CloudAccountDevice[]> = async (): Promise<CloudAccountDevice[]> => [];
  getPermissionMode: () => Promise<RemotePermissionMode> = async (): Promise<RemotePermissionMode> => 'ask';
  setPermissionMode: (mode: RemotePermissionMode) => Promise<RemotePermissionMode> =
    async (mode: RemotePermissionMode): Promise<RemotePermissionMode> => mode;
  onDisconnect: () => void = () => {};
  onReconnect: () => void = () => {};
  @State showProfile: boolean = false;
  @State showLogin: boolean = false;
  @State cloudSyncBusy: boolean = false;
  @State cloudSyncStatus: string = '';
  @State accountDevices: CloudAccountDevice[] = [];
  @State accountDevicesBusy: boolean = false;
  @State accountDevicesError: string = '';
  @State permissionMode: RemotePermissionMode = 'ask';
  @State permissionModeBusy: boolean = false;
  @State permissionModeLoaded: boolean = false;
  @State permissionModeError: string = '';
  @State confirmFullAccess: boolean = false;
  @State logoutBusy: boolean = false;

  aboutToAppear(): void {
    this.showProfile = this.openAccountOnAppear && this.isAccountAuthenticated();
    this.showLogin = this.openAccountOnAppear && !this.isAccountAuthenticated();
    if (this.isAccountAuthenticated()) {
      this.refreshAccountDevices();
    }
    if (this.canManagePermissions()) {
      this.refreshPermissionMode();
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      if (this.showLogin || (this.showProfile && !this.isAccountAuthenticated())) {
        this.LoginPage()
      } else if (this.showProfile) {
        this.ProfilePage()
      } else {
        this.RemoteControlPage()
      }
      if (!this.showLogin && !this.showProfile) {
        this.CloseButton()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(REMOTE_SETTINGS_BG)
    .borderRadius(this.openAccountOnAppear ? 0 : { topLeft: 34, topRight: 34 })
  }

  @Builder
  private RemoteControlPage() {
    Scroll() {
      Column({ space: 0 }) {
        Text(RemoteI18n.t('remote.settings.title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
          .width('100%')
          .height(56)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 30 })

        this.ProfileEntry()

        this.ConnectionSectionHeader()
        this.CurrentControlCard()
        this.OtherConnectionSection()
        this.PermissionSectionHeader()
        this.PermissionModeCard()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 20, bottom: 42 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private ProfileEntry() {
    Row({ space: 12 }) {
      DefaultAccountAvatar({ avatarSize: 34 })
      Text(this.isAccountAuthenticated() ? RemoteI18n.t('remote.settings.profile') :
        RemoteI18n.t('sidebar.signInBitFunAccount'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
        .layoutWeight(1)
      Image($r('app.media.settings_chevron_right'))
        .width(10)
        .height(14)
        .objectFit(ImageFit.Contain)
        .opacity(0.52)
    }
    .width('100%')
    .height(64)
    .padding({ left: 18, right: 18 })
    .backgroundColor(CARD)
    .borderRadius(28)
    .margin({ bottom: 28 })
    .onClick(() => {
      if (this.isAccountAuthenticated()) {
        this.showProfile = true;
      } else {
        this.onOpenAccount();
      }
    })
  }

  @Builder
  private ConnectionSectionHeader() {
    Row() {
      Text(RemoteI18n.t('remote.settings.currentControl'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#929298')
    }
    .width('100%')
    .height(42)
    .padding({ left: 18, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private CurrentControlCard() {
    Column() {
      Row({ space: 14 }) {
        Image($r('app.media.remote_ref_device'))
          .width(28)
          .height(24)
          .objectFit(ImageFit.Contain)
          .opacity(0.58)
        Column({ space: 2 }) {
          Text(RemoteI18n.t('remote.settings.desktopProduct'))
            .fontSize(14)
            .fontColor('#929298')
          Text(this.connectionTitle())
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(INK)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.connectionDetail())
            .fontSize(14)
            .fontColor('#929298')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        this.ConnectionAction()
      }
      .width('100%')
      .height(92)
      .padding({ left: 18, right: 18 })
      .alignItems(VerticalAlign.Center)

      Divider()
        .strokeWidth(1)
        .color(LINE)
        .margin({ left: 18, right: 18 })

      Row({ space: 10 }) {
        Image($r('app.media.remote_actions_link'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .opacity(0.58)
        Text(RemoteI18n.t('remote.settings.connectionSource'))
          .fontSize(14)
          .fontColor('#929298')
        Blank()
        Text(this.connectionSourceLabel())
          .fontSize(13)
          .fontColor(REMOTE_SETTINGS_BLUE)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#EDF5FF')
          .borderRadius(12)
      }
      .width('100%')
      .height(52)
      .padding({ left: 18, right: 18 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(CARD)
    .borderRadius(28)
  }

  @Builder
  private ConnectionAction() {
    if (this.isConnectedOrConnecting()) {
      Text(RemoteI18n.t('remote.settings.disconnect'))
        .fontSize(14)
        .fontColor(REMOTE_SETTINGS_BLUE)
        .padding({ left: 10, right: 10, top: 7, bottom: 7 })
        .backgroundColor('#EDF5FF')
        .borderRadius(14)
        .onClick(() => this.onDisconnect())
    } else if (this.hasConnectionProjection()) {
      Text(RemoteI18n.t('remote.settings.reconnect'))
        .fontSize(14)
        .fontColor(REMOTE_SETTINGS_BLUE)
        .padding({ left: 10, right: 10, top: 7, bottom: 7 })
        .backgroundColor('#EDF5FF')
        .borderRadius(14)
        .onClick(() => this.onReconnect())
    }
  }

  @Builder
  private OtherConnectionSection() {
    Column({ space: 10 }) {
      Text(RemoteI18n.t('remote.settings.otherConnectionMethods'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#929298')
        .width('100%')
        .height(42)
        .padding({ left: 18, right: 16 })
      Row({ space: 12 }) {
        Image($r('app.media.remote_actions_link'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
          .opacity(0.62)
        Column({ space: 2 }) {
          Text(RemoteI18n.t('remote.settings.qrConnect'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(INK)
          Text(RemoteI18n.t('remote.settings.qrConnectBody'))
            .fontSize(13)
            .fontColor('#929298')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        Image($r('app.media.settings_chevron_right'))
          .width(10)
          .height(14)
          .objectFit(ImageFit.Contain)
          .opacity(0.52)
      }
      .width('100%')
      .height(78)
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor(CARD)
      .borderRadius(24)
      .onClick(() => this.onAddConnection())
    }
    .width('100%')
    .margin({ top: 16, bottom: 8 })
  }

  @Builder
  private PermissionSectionHeader() {
    Row() {
      Text(RemoteI18n.t('remote.permissions.title'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#929298')
      Blank()
      if (this.canManagePermissions()) {
        Text(RemoteI18n.t('common.refresh'))
          .fontSize(14)
          .fontColor(this.permissionModeBusy ? MUTED : REMOTE_SETTINGS_BLUE)
          .onClick(() => this.refreshPermissionMode())
      }
    }
    .width('100%')
    .height(54)
    .padding({ left: 18, right: 16, top: 12 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private PermissionModeCard() {
    Column() {
      Text(RemoteI18n.t('remote.permissions.scope'))
        .width('100%')
        .fontSize(13)
        .lineHeight(19)
        .fontColor(MUTED)
        .padding({ left: 18, right: 18, top: 16, bottom: 8 })

      this.PermissionModeRow(
        'ask',
        RemoteI18n.t('remote.permissions.ask'),
        RemoteI18n.t('remote.permissions.askDescription')
      )
      Divider().strokeWidth(1).color(LINE).margin({ left: 18, right: 18 })
      this.PermissionModeRow(
        'auto',
        RemoteI18n.t('remote.permissions.auto'),
        RemoteI18n.t('remote.permissions.autoDescription')
      )
      Divider().strokeWidth(1).color(LINE).margin({ left: 18, right: 18 })
      this.PermissionModeRow(
        'full_access',
        RemoteI18n.t('remote.permissions.fullAccess'),
        RemoteI18n.t('remote.permissions.fullAccessDescription')
      )

      Text(this.permissionStatusText())
        .width('100%')
        .height(28)
        .fontSize(12)
        .fontColor(this.permissionModeError.length > 0 ? '#D04A3A' : MUTED)
        .padding({ left: 18, right: 18, top: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.confirmFullAccess) {
        this.FullAccessConfirmation()
      }
    }
    .width('100%')
    .backgroundColor(CARD)
    .borderRadius(28)
  }

  @Builder
  private PermissionModeRow(mode: RemotePermissionMode, label: string, description: string) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.permissionModeLoaded && this.permissionMode === mode) {
          Image($r('app.media.remote_actions_check'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
        }
      }
      .width(22)
      .height(24)
      Column({ space: 3 }) {
        Text(label)
          .width('100%')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(INK)
        Text(description)
          .width('100%')
          .fontSize(12)
          .lineHeight(17)
          .fontColor(MUTED)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(72)
    .padding({ left: 18, right: 18 })
    .opacity(this.canChangePermissionMode() ? 1 : 0.54)
    .onClick(() => this.selectPermissionMode(mode))
  }

  @Builder
  private FullAccessConfirmation() {
    Column({ space: 10 }) {
      Text(RemoteI18n.t('remote.permissions.fullAccessWarningTitle'))
        .width('100%')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#B9382D')
      Text(RemoteI18n.t('remote.permissions.fullAccessWarningBody'))
        .width('100%')
        .fontSize(13)
        .lineHeight(19)
        .fontColor(INK)
      Row({ space: 10 }) {
        Button(RemoteI18n.t('remote.permissions.cancel'))
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontColor(INK)
          .backgroundColor('#F0EFEC')
          .borderRadius(21)
          .onClick(() => { this.confirmFullAccess = false; })
        Button(RemoteI18n.t('remote.permissions.confirmFullAccess'))
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontColor(CARD)
          .backgroundColor('#C63E3E')
          .borderRadius(21)
          .onClick(() => this.applyPermissionMode('full_access'))
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 16 })
    .backgroundColor('#FFF3F1')
    .border({ width: 1, color: '#F0B3AA' })
    .borderRadius(18)
    .margin({ left: 12, right: 12, bottom: 14 })
  }

  @Builder
  private LoginPage() {
    BitFunAccountLoginPage({
      cloudLogin: this.cloudLogin,
      onBack: (): void => this.leaveAccountPage(),
      onLoginSuccess: (): void => {
        this.showLogin = false;
        this.showProfile = true;
        this.refreshAccountDevices(true);
      }
    })
  }

  @Builder
  private ProfilePage() {
    Scroll() {
      Column({ space: 0 }) {
        Row() {
          Button() {
            Image($r('app.media.remote_ref_back'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Contain)
          }
            .width(44)
            .height(44)
            .padding(0)
            .type(ButtonType.Circle)
            .backgroundColor(CARD)
            .onClick(() => {
              this.leaveAccountPage();
            })
          Text(RemoteI18n.t('remote.settings.profile'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(44)
        }
        .width('100%')
        .height(56)
        .margin({ bottom: 30 })

        Column({ space: 10 }) {
          DefaultAccountAvatar({ avatarSize: 70 })
          Text(this.profileName())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
            .width('88%')
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.profileIdentifier())
            .fontSize(14)
            .fontColor(MUTED)
            .width('88%')
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding({ top: 24, bottom: 24 })
        .backgroundColor(CARD)
        .borderRadius(28)
        .margin({ bottom: 24 })

        this.AccountStatusCard()

        this.DeviceManagementCard()

        Text(RemoteI18n.t('remote.settings.profileDetails'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#929298')
          .width('100%')
          .margin({ left: 18, bottom: 8 })

        Column() {
          this.ProfileDetailRow(RemoteI18n.t('remote.settings.userId'), this.profileIdentifier())
          Divider().strokeWidth(1).color(LINE).margin({ left: 18, right: 18 })
          this.ProfileDetailRow(RemoteI18n.t('remote.settings.deviceId'), this.deviceId || '-')
        }
        .width('100%')
        .backgroundColor(CARD)
        .borderRadius(28)

        if (this.isAccountAuthenticated()) {
          this.LogoutAction()
        }
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 20, bottom: 42 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  private AccountStatusCard() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Text(RemoteI18n.t('remote.settings.account'))
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
        Blank()
        Text(this.isAccountAuthenticated() ? RemoteI18n.t('remote.settings.accountSignedIn') :
          RemoteI18n.t('remote.settings.accountNotSignedIn'))
          .fontSize(14)
          .fontColor(this.isAccountAuthenticated() ? GREEN : MUTED)
      }
      .width('100%')

      Text(RemoteI18n.f('remote.settings.accountSignedInBody', this.accountUsername || this.accountUserId))
        .fontSize(14)
        .lineHeight(20)
        .fontColor(MUTED)
        .width('100%')

      Button(RemoteI18n.t('remote.settings.accountSync'))
        .height(42)
        .width('100%')
        .fontSize(15)
        .fontColor(REMOTE_SETTINGS_BLUE)
        .backgroundColor('#E8F2FF')
        .borderRadius(21)
        .enabled(!this.cloudSyncBusy)
        .onClick(async () => {
          this.cloudSyncBusy = true;
          this.cloudSyncStatus = '';
          try {
            const count = await this.cloudSync();
            this.cloudSyncStatus = RemoteI18n.f('remote.settings.accountSyncSuccess', count);
          } catch (err) {
            this.cloudSyncStatus = err instanceof Error ? err.message : RemoteI18n.t('remote.settings.accountSyncFailed');
          } finally {
            this.cloudSyncBusy = false;
          }
        })
      if (this.cloudSyncStatus.length > 0) {
        Text(this.cloudSyncStatus).fontSize(13).fontColor(MUTED).width('100%')
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(CARD)
    .borderRadius(24)
    .margin({ bottom: 24 })
  }

  @Builder
  private LogoutAction() {
    Row({ space: 14 }) {
      Image($r('app.media.settings_logout_arrow'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(this.logoutBusy ? RemoteI18n.t('remote.settings.accountLoggingOut') :
        RemoteI18n.t('remote.settings.accountLogout'))
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E11D17')
    }
    .width('100%')
    .height(62)
    .padding({ left: 20, right: 20 })
    .backgroundColor(CARD)
    .borderRadius(24)
    .margin({ top: 30, bottom: 8 })
    .opacity(this.logoutBusy ? 0.55 : 1)
    .enabled(!this.logoutBusy)
    .onClick(async () => {
      this.logoutBusy = true;
      try {
        await this.cloudLogout();
        this.cloudSyncStatus = '';
        this.showProfile = false;
        this.showLogin = true;
      } finally {
        this.logoutBusy = false;
      }
    })
  }

  @Builder
  private DeviceManagementCard() {
    Column({ space: 8 }) {
      Row() {
        Text(RemoteI18n.t('remote.settings.deviceManagement'))
          .fontSize(17).fontWeight(FontWeight.Bold).fontColor(INK)
        Blank()
        Text(this.accountDevicesBusy ? RemoteI18n.t('remote.settings.deviceLoading') :
          RemoteI18n.t('remote.settings.deviceRefresh'))
          .fontSize(13).fontColor(this.accountDevicesBusy ? MUTED : REMOTE_SETTINGS_BLUE)
          .onClick(async () => {
            await this.refreshAccountDevices();
          })
      }.width('100%')
      if (!this.isAccountAuthenticated()) {
        Text(RemoteI18n.t('remote.settings.deviceLoginRequired'))
          .fontSize(13).lineHeight(18).fontColor(MUTED).width('100%')
      } else if (this.accountDevicesBusy && this.accountDevices.length === 0) {
        Text(RemoteI18n.t('remote.settings.deviceLoading'))
          .fontSize(13).fontColor(MUTED).width('100%')
      } else if (this.desktopDevices().length === 0) {
        Text(this.accountDevicesError || RemoteI18n.t('remote.settings.deviceEmpty'))
          .fontSize(13).lineHeight(18).fontColor(MUTED).width('100%')
      } else {
        ForEach(this.desktopDevices(), (device: CloudAccountDevice) => {
          this.AccountDeviceRow(device)
        }, (device: CloudAccountDevice): string =>
          `${device.deviceId}:${device.online ? 'online' : 'offline'}:${device.lastSeenAt || 0}:${device.deviceName}`)
      }
    }
    .width('100%').padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor(CARD).borderRadius(24).margin({ bottom: 24 })
  }

  @Builder
  private AccountDeviceRow(device: CloudAccountDevice) {
    Row({ space: 12 }) {
      Image($r('app.media.remote_ref_device'))
        .width(24).height(22).objectFit(ImageFit.Contain).opacity(0.58)
      Column({ space: 2 }) {
        Text(device.deviceName || device.deviceId)
          .fontSize(15).fontWeight(FontWeight.Medium).fontColor(INK)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.deviceStatus(device))
          .fontSize(13).fontColor(device.online ? GREEN : MUTED)
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .width('100%').height(54).alignItems(VerticalAlign.Center)
    .opacity(device.online ? 1 : 0.68)
  }

  private async refreshAccountDevices(allowPendingLogin: boolean = false): Promise<void> {
    if ((!this.isAccountAuthenticated() && !allowPendingLogin) || this.accountDevicesBusy) return;
    this.accountDevicesBusy = true;
    this.accountDevicesError = '';
    try {
      this.accountDevices = await this.cloudListDevices();
    } catch (err) {
      this.accountDevicesError = err instanceof Error ? err.message : RemoteI18n.t('remote.settings.deviceLoadFailed');
    } finally {
      this.accountDevicesBusy = false;
    }
  }

  private desktopDevices(): CloudAccountDevice[] {
    return this.accountDevices.filter((device: CloudAccountDevice): boolean =>
      device.deviceId !== this.deviceId && device.deviceName !== 'HarmonyOS Phone');
  }

  private deviceStatus(device: CloudAccountDevice): string {
    if (device.deviceId === this.deviceId) return RemoteI18n.t('remote.settings.deviceCurrent');
    const presence = device.online ? RemoteI18n.t('remote.settings.deviceOnline') :
      RemoteI18n.t('remote.settings.deviceOffline');
    if (device.deviceId === this.controlTargetDeviceId && this.connectionState === 'connected') {
      return `${RemoteI18n.t('remote.settings.deviceControlling')} · ${presence}`;
    }
    if (device.deviceId === this.controlTargetDeviceId) {
      return `${RemoteI18n.t('connect.deviceLastUsed')} · ${presence}`;
    }
    return presence;
  }

  @Builder
  private ProfileDetailRow(label: string, value: string) {
    Row({ space: 16 }) {
      Text(label)
        .fontSize(16)
        .fontColor(INK)
      Blank()
      Text(value)
        .fontSize(14)
        .fontColor(MUTED)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 190 })
    }
    .width('100%')
    .height(58)
    .padding({ left: 18, right: 18 })
  }

  @Builder
  private CloseButton() {
    Button() {
      Image($r('app.media.settings_close_x'))
        .width(28)
        .height(28)
        .objectFit(ImageFit.Contain)
    }
    .width(50)
    .height(50)
    .padding(0)
    .type(ButtonType.Circle)
    .backgroundColor(CARD)
    .shadow({ radius: 16, color: '#10000000', offsetY: 7 })
    .margin({ top: 22, right: 18 })
    .onClick(() => {
      this.onClose();
    })
  }

  private isConnectedOrConnecting(): boolean {
    return this.connectionState === 'connected' || this.connectionState === 'reconnecting' ||
      this.connectionState === 'pairing' || this.connectionState === 'parsing';
  }

  private canManagePermissions(): boolean {
    return this.connectionState === 'connected';
  }

  private canChangePermissionMode(): boolean {
    return this.canManagePermissions() && !this.permissionModeBusy;
  }

  private async refreshPermissionMode(): Promise<void> {
    if (!this.canManagePermissions() || this.permissionModeBusy) {
      return;
    }
    this.permissionModeBusy = true;
    this.permissionModeError = '';
    try {
      this.permissionMode = await this.getPermissionMode();
      this.permissionModeLoaded = true;
    } catch (err) {
      this.permissionModeError = err instanceof Error ? err.message :
        RemoteI18n.t('remote.permissions.loadFailed');
    } finally {
      this.permissionModeBusy = false;
    }
  }

  private selectPermissionMode(mode: RemotePermissionMode): void {
    if (!this.canChangePermissionMode() ||
      (this.permissionModeLoaded && this.permissionMode === mode)) {
      return;
    }
    if (mode === 'full_access') {
      this.confirmFullAccess = true;
      return;
    }
    this.confirmFullAccess = false;
    this.applyPermissionMode(mode);
  }

  private async applyPermissionMode(mode: RemotePermissionMode): Promise<void> {
    if (!this.canChangePermissionMode()) {
      return;
    }
    this.permissionModeBusy = true;
    this.permissionModeError = '';
    try {
      this.permissionMode = await this.setPermissionMode(mode);
      this.permissionModeLoaded = true;
      this.confirmFullAccess = false;
    } catch (err) {
      this.permissionModeError = err instanceof Error ? err.message :
        RemoteI18n.t('remote.permissions.saveFailed');
    } finally {
      this.permissionModeBusy = false;
    }
  }

  private permissionStatusText(): string {
    if (!this.canManagePermissions()) {
      return RemoteI18n.t('remote.permissions.connectionRequired');
    }
    if (this.permissionModeBusy) {
      return RemoteI18n.t('remote.permissions.loading');
    }
    return this.permissionModeError;
  }

  private connectionTitle(): string {
    return this.desktopName || this.desktopId || RemoteI18n.t('remote.settings.noDesktop');
  }

  private connectionSourceLabel(): string {
    if (this.controlTargetType === 'account_device') {
      return RemoteI18n.t('remote.settings.accountDevice');
    }
    if (this.controlTargetType === 'room') {
      return RemoteI18n.t('remote.settings.qrPairing');
    }
    return RemoteI18n.t('remote.settings.noConnectionSource');
  }

  private hasConnectionProjection(): boolean {
    return this.controlTargetType !== 'none' || this.desktopId.trim().length > 0;
  }

  private connectionDetail(): string {
    if (this.connectionState === 'connected') {
      return RemoteI18n.t('connection.connected');
    }
    if (this.connectionState === 'reconnecting') {
      return RemoteI18n.t('connection.reconnecting');
    }
    return this.statusText || RemoteI18n.t('connection.disconnected');
  }

  private profileName(): string {
    return this.accountUsername || RemoteI18n.t('remote.settings.bitfunUser');
  }

  private profileIdentifier(): string {
    return this.accountUserId || this.userId || this.deviceId || '-';
  }

  private isAccountAuthenticated(): boolean {
    return this.accountUserId.trim().length > 0;
  }

  private handleAccountUserChanged(): void {
    if (this.isAccountAuthenticated() && this.accountDevices.length === 0) {
      this.refreshAccountDevices();
    }
  }

  private leaveAccountPage(): void {
    if (this.openAccountOnAppear) {
      this.onClose();
      return;
    }
    this.showLogin = false;
    this.showProfile = false;
  }
}
