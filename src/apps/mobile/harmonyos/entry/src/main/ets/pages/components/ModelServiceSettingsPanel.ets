import { RemoteI18n } from '../../i18n/RemoteI18n';
import { ACCENT, CARD, GREEN, INK, LINE, MUTED, RED, SOFT, SUBTLE } from './Theme';

@Component
export struct ModelServiceSettingsPanel {
  @Prop apiUrl: string = '';
  @Prop modelName: string = '';
  @Prop hasApiKey: boolean = false;
  onClose: () => void = () => {};
  onSaved: (apiUrl: string, modelName: string, hasApiKey: boolean) => void = () => {};
  onTest: (
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
  onSave: (
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
  @State draftApiUrl: string = '';
  @State draftApiKey: string = '';
  @State draftModelName: string = '';
  @State clearApiKey: boolean = false;
  @State isSaving: boolean = false;
  @State isTesting: boolean = false;
  @State feedbackText: string = '';
  @State feedbackIsError: boolean = false;

  aboutToAppear(): void {
    this.draftApiUrl = this.apiUrl;
    this.draftModelName = this.modelName;
    this.draftApiKey = '';
    this.clearApiKey = false;
    this.isTesting = false;
    this.feedbackText = '';
    this.feedbackIsError = false;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('')
        .width('100%')
        .height('100%')
        .backgroundColor('#33000000')
        .onClick(() => {
          if (!this.isSaving && !this.isTesting) {
            this.onClose();
          }
        })

      Column({ space: 0 }) {
        this.Header()
        Scroll() {
          Column({ space: 20 }) {
            this.ConfigField(
              RemoteI18n.t('settings.modelService.apiUrl'),
              RemoteI18n.t('settings.modelService.apiUrlPlaceholder'),
              'url'
            )
            this.ApiKeyField()
            this.ConfigField(
              RemoteI18n.t('settings.modelService.modelName'),
              RemoteI18n.t('settings.modelService.modelPlaceholder'),
              'model'
            )
            Row({ space: 12 }) {
              Button(this.isTesting ? RemoteI18n.t('common.loading') : RemoteI18n.t('settings.modelService.testConnection'))
                .layoutWeight(1)
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(INK)
                .backgroundColor(this.isTesting ? MUTED : SOFT)
                .borderRadius(25)
                .enabled(!this.isSaving && !this.isTesting && this.hasTestableApiKey())
                .onClick(() => {
                  this.testConnection();
                })
              Button(this.isSaving ? RemoteI18n.t('common.loading') : RemoteI18n.t('common.save'))
                .layoutWeight(1)
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(CARD)
                .backgroundColor(this.isSaving ? MUTED : ACCENT)
                .borderRadius(25)
                .enabled(!this.isSaving && !this.isTesting)
                .onClick(() => {
                  this.save();
                })
            }
            .width('100%')

            if (!this.hasTestableApiKey()) {
              Text(RemoteI18n.t('settings.modelService.testNeedsKey'))
                .fontSize(12)
                .lineHeight(18)
                .fontColor(SUBTLE)
                .width('100%')
            }

            if (this.feedbackText.length > 0) {
              Text(this.feedbackText)
                .fontSize(13)
                .lineHeight(19)
                .fontColor(this.feedbackIsError ? RED : GREEN)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: 22, right: 22, top: 18, bottom: 30 })
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('78%')
      .backgroundColor(CARD)
      .borderRadius({ topLeft: 28, topRight: 28 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Header() {
    Row() {
      Text(RemoteI18n.t('settings.modelService.title'))
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
      Blank()
      Button() {
        Image($r('app.media.settings_close_x'))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
      .width(42)
      .height(42)
      .padding(0)
      .type(ButtonType.Circle)
      .backgroundColor(SOFT)
      .onClick(() => {
        if (!this.isSaving && !this.isTesting) {
          this.onClose();
        }
      })
    }
    .width('100%')
    .height(66)
    .padding({ left: 22, right: 18 })
    .border({ width: { bottom: 1 }, color: LINE })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  ConfigField(label: string, placeholder: string, kind: string) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
        .width('100%')
      TextInput({
        placeholder,
        text: kind === 'url' ? this.draftApiUrl : this.draftModelName
      })
        .width('100%')
        .height(52)
        .fontSize(15)
        .fontColor(INK)
        .placeholderColor(SUBTLE)
        .backgroundColor(SOFT)
        .borderRadius(8)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          if (kind === 'url') {
            this.draftApiUrl = value;
          } else {
            this.draftModelName = value;
          }
          this.clearFeedback();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ApiKeyField() {
    Column({ space: 8 }) {
      Row() {
        Text(RemoteI18n.t('settings.modelService.apiKey'))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(INK)
        Blank()
        if (this.hasApiKey && !this.clearApiKey) {
          Text(RemoteI18n.t('settings.modelService.keySaved'))
            .fontSize(12)
            .fontColor(MUTED)
        }
      }
      .width('100%')
      TextInput({
        placeholder: this.apiKeyPlaceholder(),
        text: this.draftApiKey
      })
        .type(InputType.Password)
        .showPasswordIcon(true)
        .width('100%')
        .height(52)
        .fontSize(15)
        .fontColor(INK)
        .placeholderColor(SUBTLE)
        .backgroundColor(SOFT)
        .borderRadius(8)
        .padding({ left: 14, right: 10 })
        .onChange((value: string) => {
          this.draftApiKey = value;
          if (value.length > 0) {
            this.clearApiKey = false;
          }
          this.clearFeedback();
        })
      if (this.hasApiKey) {
        Text(this.clearApiKey ?
          RemoteI18n.t('settings.modelService.keepKey') :
          RemoteI18n.t('settings.modelService.clearKey'))
          .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.clearApiKey ? INK : RED)
        .width('100%')
        .onClick(() => {
          this.clearApiKey = !this.clearApiKey;
          this.draftApiKey = '';
          this.clearFeedback();
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private apiKeyPlaceholder(): string {
    return this.hasApiKey && !this.clearApiKey ?
      RemoteI18n.t('settings.modelService.apiKeyKeepPlaceholder') :
      RemoteI18n.t('settings.modelService.apiKeyPlaceholder');
  }

  private async save(): Promise<void> {
    if (this.isSaving || this.isTesting) {
      return;
    }
    this.isSaving = true;
    this.clearFeedback();
    const error = await this.onSave(
      this.draftApiUrl,
      this.draftApiKey,
      this.draftModelName,
      this.clearApiKey
    );
    this.isSaving = false;
    if (error.length > 0) {
      this.feedbackText = error;
      this.feedbackIsError = true;
      return;
    }
    this.onSaved(
      this.draftApiUrl.trim(),
      this.draftModelName.trim(),
      !this.clearApiKey && (this.draftApiKey.trim().length > 0 || this.hasApiKey)
    );
    this.onClose();
  }

  private async testConnection(): Promise<void> {
    if (this.isSaving || this.isTesting || !this.hasTestableApiKey()) {
      return;
    }
    this.isTesting = true;
    this.clearFeedback();
    const error = await this.onTest(
      this.draftApiUrl,
      this.draftApiKey,
      this.draftModelName,
      this.clearApiKey
    );
    this.isTesting = false;
    if (error.length > 0) {
      this.feedbackText = error;
      this.feedbackIsError = true;
      return;
    }
    this.feedbackText = RemoteI18n.t('settings.modelService.testSuccess');
    this.feedbackIsError = false;
  }

  private hasTestableApiKey(): boolean {
    return this.draftApiKey.trim().length > 0 || (this.hasApiKey && !this.clearApiKey);
  }

  private clearFeedback(): void {
    this.feedbackText = '';
    this.feedbackIsError = false;
  }
}
