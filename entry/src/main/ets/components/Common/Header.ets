// 顶部标题栏组件
@Component
export struct Header {
  @Prop title: string = '智慧农场助手';
  @Prop showBack: boolean = false;
  @Prop onBackClick?: () => void;

  build() {
    Row() {
      if (this.showBack) {
        Text('‹')
          .fontSize(20)
          .fontColor('#2E8B57')
          .margin({ right: 12 })
          .onClick(() => {
            if (this.onBackClick) {
              this.onBackClick();
            }
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .layoutWeight(1)

      Text(this.getCurrentTime())
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  private getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }
}