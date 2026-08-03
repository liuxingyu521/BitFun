const AVATAR_BACKGROUND: string = '#ECEEF1';
const AVATAR_FOREGROUND: string = '#626268';

@Component
export struct DefaultAccountAvatar {
  @Prop avatarSize: number = 34;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      SymbolGlyph($r('sys.symbol.person'))
        .fontSize(this.avatarSize * 0.52)
        .fontColor([AVATAR_FOREGROUND])
    }
    .width(this.avatarSize)
    .height(this.avatarSize)
    .backgroundColor(AVATAR_BACKGROUND)
    .borderRadius(this.avatarSize / 2)
  }
}
