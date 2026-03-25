import router from '@ohos.router';

@Entry
@Component
struct PageB {
  @StorageLink('darkTheme') isDarkTheme: boolean = false;

  build() {
    Column({ space: 20 }) {
      Text('主题设置页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')

      Column({ space: 15 }) {
        Text('当前主题模式')
          .fontSize(18)
          .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')

        Text(this.isDarkTheme ? '深色主题' : '浅色主题')
          .fontSize(16)
          .fontColor(this.isDarkTheme ? '#CCCCCC' : '#666666')

        Toggle({ type: ToggleType.Switch, isOn: this.isDarkTheme })
          .onChange((value: boolean) => {
            this.isDarkTheme = value;
          })
      }
      .width('90%')
      .padding(20)
      .backgroundColor(this.isDarkTheme ? '#2D2D2D' : '#F0F0F0')
      .borderRadius(12)

      Button('返回主页面')
        .onClick(() => {
          router.back();
        })
        .width('80%')
        .backgroundColor('#007DFF')
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.isDarkTheme ? '#1A1A1A' : '#FAFAFA')
  }
}