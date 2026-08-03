import { RemoteI18n } from '../../i18n/RemoteI18n';
import { CARD, INK, LINE, MUTED } from './Theme';
import { ModelServiceSettingsPanel } from './ModelServiceSettingsPanel';
import { DefaultAccountAvatar } from './DefaultAccountAvatar';

const SETTINGS_SHEET_BG: string = '#F4F4F7';
const SETTINGS_ROW_VALUE: string = '#8F8F94';

@Component
export struct SettingsSheet {
  @Prop generalChatApiUrl: string = '';
  @Prop generalChatModelName: string = '';
  @Prop hasGeneralChatApiKey: boolean = false;
  @Prop accountUsername: string = '';
  @Prop authenticatedUserId: string = '';
  @Prop deviceId: string = '';
  onClose: () => void = () => {};
  onOpenAccount: () => void = () => {};
  onSaveGeneralChatConfig: (
    apiUrl: string,
    apiKey: string,
    modelName: string,
    clearApiKey: boolean
  ) => Promise<string> = async (
    _apiUrl: string,
    _apiKey: string,
    _modelName: string,
    _clearApiKey: boolean
  ) => '';
  onTestGeneralChatConfig: (
    apiUrl: string,
    apiKey: string,
    modelName: string,
    clearApiKey: boolean
  ) => Promise<string> = async (
    _apiUrl: string,
    _apiKey: string,
    _modelName: string,
    _clearApiKey: boolean
  ) => '';
  @State showModelService: boolean = false;
  @State savedGeneralChatApiUrl: string = '';
  @State savedGeneralChatModelName: string = '';
  @State savedGeneralChatHasApiKey: boolean = false;

  aboutToAppear(): void {
    this.showModelService = false;
    this.syncGeneralChatConfig(this.generalChatApiUrl, this.generalChatModelName, this.hasGeneralChatApiKey);
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Scroll() {
        Column({ space: 0 }) {
          Text(RemoteI18n.t('settings.title'))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
            .width('100%')
            .margin({ bottom: 30 })

          this.AccountEntry()

          this.SectionTitle(RemoteI18n.t('settings.modelService.section'))
          this.ModelServiceCard()

          this.SectionTitle(RemoteI18n.t('settings.about.section'))
          this.AboutCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 64, bottom: 34 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

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

      if (this.showModelService) {
        this.ModelServicePanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(SETTINGS_SHEET_BG)
    .borderRadius({ topLeft: 34, topRight: 34 })
  }

  @Builder
  AccountEntry() {
    Row({ space: 12 }) {
      DefaultAccountAvatar({ avatarSize: 34 })
      Column({ space: 2 }) {
        Text(RemoteI18n.t('remote.settings.profile'))
          .fontSize(16).fontWeight(FontWeight.Medium).fontColor(INK)
        Text(this.accountUsername || RemoteI18n.t('remote.settings.accountNotSignedIn'))
          .fontSize(13).fontColor(SETTINGS_ROW_VALUE)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Image($r('app.media.settings_chevron_right'))
        .width(10).height(14).objectFit(ImageFit.Contain).opacity(0.52)
    }
    .width('100%').height(64).padding({ left: 18, right: 18 })
    .backgroundColor(CARD).borderRadius(8).margin({ bottom: 24 })
    .onClick(() => this.onOpenAccount())
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor(MUTED)
      .width('100%')
      .margin({ left: 12, bottom: 8 })
  }

  @Builder
  ModelServiceCard() {
    Column() {
      this.SettingsRow(
        $r('app.media.settings_apps_grid'),
        RemoteI18n.t('settings.modelService.title'),
        this.modelServiceStatus(),
        true,
        () => {
          this.showModelService = true;
        }
      )
    }
    .width('100%')
    .padding({ top: 5, bottom: 5 })
    .backgroundColor(CARD)
    .borderRadius(8)
    .margin({ bottom: 24 })
  }

  @Builder
  AboutCard() {
    Column() {
      this.StaticRow(RemoteI18n.t('settings.about.product'), 'BitFun HarmonyOS')
      Text('')
        .width('84%')
        .height(1)
        .backgroundColor(LINE)
      this.StaticRow(RemoteI18n.t('settings.about.version'), '1.0.0')
    }
    .width('100%')
    .padding({ top: 5, bottom: 5 })
    .backgroundColor(CARD)
    .borderRadius(8)
  }

  @Builder
  StaticRow(title: string, value: string) {
    Row({ space: 16 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Blank()
      Text(value)
        .fontSize(15)
        .fontColor(SETTINGS_ROW_VALUE)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(52)
    .padding({ left: 18, right: 18 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  SettingsRow(icon: Resource, title: string, value: string, showChevron: boolean, action: () => void) {
    Row({ space: 16 }) {
      Image(icon)
        .width(23)
        .height(23)
        .objectFit(ImageFit.Contain)
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Blank()
      Text(value)
        .fontSize(15)
        .fontColor(SETTINGS_ROW_VALUE)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 130 })
      if (showChevron) {
        Image($r('app.media.settings_chevron_right'))
          .width(10)
          .height(14)
          .objectFit(ImageFit.Contain)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 18, right: 18 })
    .alignItems(VerticalAlign.Center)
    .onClick(action)
  }

  @Builder
  ModelServicePanel() {
    ModelServiceSettingsPanel({
      apiUrl: this.savedGeneralChatApiUrl,
      modelName: this.savedGeneralChatModelName,
      hasApiKey: this.savedGeneralChatHasApiKey,
      onClose: () => {
        this.showModelService = false;
      },
      onSaved: (
        apiUrl: string,
        modelName: string,
        hasApiKey: boolean
      ) => {
        this.syncGeneralChatConfig(apiUrl, modelName, hasApiKey);
      },
      onTest: (
        apiUrl: string,
        apiKey: string,
        modelName: string,
        clearApiKey: boolean
      ) => {
        return this.onTestGeneralChatConfig(apiUrl, apiKey, modelName, clearApiKey);
      },
      onSave: (
        apiUrl: string,
        apiKey: string,
        modelName: string,
        clearApiKey: boolean
      ) => {
        return this.onSaveGeneralChatConfig(apiUrl, apiKey, modelName, clearApiKey);
      }
    })
  }

  private modelServiceStatus(): string {
    return this.savedGeneralChatApiUrl.length > 0 &&
      this.savedGeneralChatModelName.length > 0 && this.savedGeneralChatHasApiKey ?
      RemoteI18n.t('settings.modelService.configured') :
      RemoteI18n.t('settings.modelService.notConfigured');
  }

  private syncGeneralChatConfig(apiUrl: string, modelName: string, hasApiKey: boolean): void {
    this.savedGeneralChatApiUrl = apiUrl;
    this.savedGeneralChatModelName = modelName;
    this.savedGeneralChatHasApiKey = hasApiKey;
  }
}
