import { KeyboardAvoidMode } from '@kit.ArkUI';
import { RecentWorkspaceEntry } from '../../model/RemoteModels';
import { RemoteI18n } from '../../i18n/RemoteI18n';
import { CloudAccountDevice } from '../../services/CloudAccountClient';
import { RemoteCreateSessionState } from '../state/RemoteCreateSessionState';
import { ACCENT, CARD, INK, LINE, MUTED, PAGE_BG, SOFT, SUBTLE } from './Theme';

@ComponentV2
export struct RemoteCreateSessionView {
  @Param state: RemoteCreateSessionState = new RemoteCreateSessionState();
  @Event onBack: () => void = () => {};
  @Event onToggleDeviceMenu: () => void = () => {};
  @Event onToggleWorkspaceMenu: () => void = () => {};
  @Event onSelectDevice: (device: CloudAccountDevice) => void = (_device: CloudAccountDevice) => {};
  @Event onSelectWorkspace: (workspace?: RecentWorkspaceEntry) => void = (_workspace?: RecentWorkspaceEntry) => {};
  @Event onDraftChange: (value: string) => void = (_value: string) => {};
  @Event onSend: () => void = () => {};
  private previousKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;

  aboutToAppear(): void {
    this.previousKeyboardAvoidMode = this.getUIContext().getKeyboardAvoidMode();
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
    setTimeout(() => this.keepComposerFocused(), 180);
  }

  aboutToDisappear(): void {
    this.getUIContext().setKeyboardAvoidMode(this.previousKeyboardAvoidMode);
  }

  build() {
    Column() {
      Column() {
        Row() {
          Button() {
            Image($r('app.media.remote_ref_back'))
              .width(16)
              .height(25)
              .objectFit(ImageFit.Contain)
          }
          .width(48)
          .height(48)
          .padding(0)
          .type(ButtonType.Circle)
          .backgroundColor(CARD)
          .borderRadius(24)
          .shadow({ radius: 16, color: '#10000000', offsetY: 7 })
          .onClick(() => this.onBack())
        }
        .width('100%')
        .height(78)
        .padding({ left: 18, top: 14 })
        .alignItems(VerticalAlign.Top)
        Column()
          .width('100%')
          .layoutWeight(1)
          .onClick(() => {
            this.state.closeMenu();
            this.keepComposerFocused();
          })
      }
      .width('100%')
      .layoutWeight(1)
      this.ContextControls()
      this.Composer()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BG)
  }

  @Builder
  ContextControls() {
    Column({ space: 2 }) {
      this.ContextRow(
        'device',
        this.state.selectedDeviceName || RemoteI18n.t('remote.create.noDevice'),
        this.state.isLoadingDevices,
        () => this.onToggleDeviceMenu()
      )
      this.ContextRow(
        'workspace',
        this.state.selectedWorkspaceName || RemoteI18n.t('remote.create.chat'),
        this.state.isLoadingWorkspaces,
        () => this.onToggleWorkspaceMenu()
      )
    }
    .width('100%')
    .padding({ left: 28, right: 28, bottom: 4 })
  }

  @Builder
  ContextRow(kind: string, title: string, loading: boolean, onClick: () => void) {
    Row({ space: 13 }) {
      Image(kind === 'device' ? $r('app.media.remote_create_device') :
        (this.state.selectedWorkspacePath.length > 0 ? $r('app.media.remote_create_folder') : $r('app.media.remote_create_chat')))
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)
        .opacity(loading ? 0.42 : 1)
      Text(loading ? RemoteI18n.t('common.loading') : title)
        .constraintSize({ maxWidth: '74%' })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(loading ? MUTED : INK)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Image($r('app.media.remote_create_switch'))
        .width(22)
        .height(30)
        .objectFit(ImageFit.Contain)
        .opacity(loading ? 0.42 : 1)
      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .height(48)
    .padding({ left: 8, right: 10 })
    .borderRadius(12)
    .bindPopup(this.state.openMenu === (kind === 'device' ? 'devices' : 'workspaces'), {
      builder: () => {
        if (kind === 'device') {
          this.DeviceMenu()
        } else {
          this.WorkspaceMenu()
        }
      },
      placement: Placement.Top,
      popupColor: '#00000000',
      enableArrow: false,
      autoCancel: true,
      mask: false,
      targetSpace: 8,
      onStateChange: (event) => {
        if (!event.isVisible) {
          this.state.closeMenu();
        }
      }
    })
    .onClick(() => {
      onClick();
      this.keepComposerFocused();
    })
  }

  @Builder
  DeviceMenu() {
    Column() {
      if (this.state.devices.length === 0 && this.state.isLoadingDevices) {
        this.MenuMessage(RemoteI18n.t('common.loading'))
      } else if (this.state.devices.length === 0) {
        this.MenuMessage(RemoteI18n.t('remote.create.noOnlineDevice'))
      } else {
        ForEach(this.state.devices, (device: CloudAccountDevice) => {
          this.DeviceMenuRow(device)
        }, (device: CloudAccountDevice) => device.deviceId)
      }
    }
    .width(340)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(CARD)
    .borderRadius(24)
    .border({ width: 1, color: LINE })
    .shadow({ radius: 26, color: '#1A000000', offsetY: 10 })
  }

  @Builder
  DeviceMenuRow(device: CloudAccountDevice) {
    Row({ space: 12 }) {
      this.SelectionMark(device.deviceId === this.state.selectedDeviceId)
      Image($r('app.media.remote_create_device'))
        .width(27)
        .height(27)
        .objectFit(ImageFit.Contain)
      Text(device.deviceName)
        .layoutWeight(1)
        .fontSize(16)
        .fontColor(INK)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 18, top: 8, bottom: 8 })
    .onClick(() => {
      this.onSelectDevice(device);
      this.keepComposerFocused();
    })
  }

  @Builder
  WorkspaceMenu() {
    Column() {
      Row({ space: 12 }) {
        this.SelectionMark(this.state.selectedWorkspacePath.length === 0)
        Image($r('app.media.remote_create_chat'))
          .width(27)
          .height(27)
          .objectFit(ImageFit.Contain)
        Text(RemoteI18n.t('remote.create.chat'))
          .layoutWeight(1)
          .fontSize(16)
          .fontColor(INK)
      }
      .width('100%')
      .height(58)
      .padding({ left: 16, right: 18 })
      .onClick(() => {
        this.onSelectWorkspace(undefined);
        this.keepComposerFocused();
      })

      Divider().color(LINE).margin({ left: 58, right: 18 })

      if (this.state.workspaces.length === 0 && this.state.isLoadingWorkspaces) {
        this.MenuMessage(RemoteI18n.t('common.loading'))
      } else if (this.state.workspaces.length === 0) {
        this.MenuMessage(RemoteI18n.t('home.noRecentWorkspaces'))
      } else {
        Scroll() {
          Column() {
            ForEach(this.state.workspaces, (workspace: RecentWorkspaceEntry) => {
              this.WorkspaceMenuRow(workspace)
            }, (workspace: RecentWorkspaceEntry) => workspace.path)
          }
        }
        .width('100%')
        .constraintSize({ maxHeight: 190 })
        .scrollBar(BarState.Off)
      }
    }
    .width(340)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(CARD)
    .borderRadius(24)
    .border({ width: 1, color: LINE })
    .shadow({ radius: 26, color: '#1A000000', offsetY: 10 })
  }

  @Builder
  WorkspaceMenuRow(workspace: RecentWorkspaceEntry) {
    Row({ space: 12 }) {
      this.SelectionMark(workspace.path === this.state.selectedWorkspacePath)
      Image($r('app.media.remote_create_folder'))
        .width(27)
        .height(27)
        .objectFit(ImageFit.Contain)
      Column({ space: 2 }) {
        Text(workspace.name)
          .width('100%')
          .fontSize(16)
          .fontColor(INK)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(workspace.path)
          .width('100%')
          .fontSize(11)
          .fontColor(MUTED)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 18 })
    .onClick(() => {
      this.onSelectWorkspace(workspace);
      this.keepComposerFocused();
    })
  }

  @Builder
  SelectionMark(selected: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      if (selected) {
        Image($r('app.media.remote_actions_check'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
      }
    }
    .width(20)
    .height(24)
  }

  @Builder
  MenuMessage(message: string) {
    Text(message)
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 18 })
      .fontSize(13)
      .fontColor(MUTED)
  }

  @Builder
  Composer() {
    Column({ space: 6 }) {
      if (this.state.errorText.length > 0) {
        Text(this.state.errorText)
          .width('100%')
          .padding({ left: 12, right: 12 })
          .fontSize(12)
          .fontColor('#C63E3E')
          .maxLines(2)
      }
      Row({ space: 8 }) {
        TextArea({ placeholder: RemoteI18n.t('remote.create.placeholder'), text: this.state.draft })
          .id('remote-create-composer')
          .layoutWeight(1)
          .height(56)
          .fontSize(16)
          .fontColor(INK)
          .placeholderColor(SUBTLE)
          .backgroundColor('#00000000')
          .padding({ left: 6, right: 4, top: 8, bottom: 8 })
          .defaultFocus(true)
          .maxLines(3)
          .onChange((value: string, previewText?: PreviewText) => {
            if (previewText && previewText.value.length > 0) {
              return;
            }
            this.onDraftChange(value);
          })
        Button() {
          Image($r('app.media.gpt_composer_send'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain)
            .opacity(this.canSend() ? 1 : 0.36)
        }
        .width(42)
        .height(42)
        .padding(0)
        .type(ButtonType.Circle)
        .backgroundColor('#00000000')
        .enabled(this.canSend())
        .onClick(() => this.onSend())
      }
      .width('100%')
      .height(66)
      .padding({ left: 12, right: 7, top: 5, bottom: 5 })
      .backgroundColor(CARD)
      .borderRadius(25)
      .border({ width: 1, color: SOFT })
      .shadow({ radius: 22, color: '#18000000', offsetY: 7 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 14 })
  }

  private canSend(): boolean {
    return this.state.draft.trim().length > 0 && this.state.selectedDeviceId.length > 0 &&
      !this.state.isSubmitting;
  }

  private keepComposerFocused(): void {
    setTimeout(() => focusControl.requestFocus('remote-create-composer'), 30);
  }
}
