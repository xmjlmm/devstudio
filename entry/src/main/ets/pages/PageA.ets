import router from '@ohos.router';

@Component
struct ChildComponent {
  @Prop countProp: number;
  @Link countLink: number;
  @State localCount: number = 0;

  build() {
    Column({ space: 15 }) {
      Text('子组件状态显示')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Column({ space: 8 }) {
        Text(`接收的Prop: ${this.countProp}`)
          .fontSize(14)
          .fontColor('#666666')

        Text(`接收的Link: ${this.countLink}`)
          .fontSize(14)
          .fontColor('#666666')

        Text(`本地状态: ${this.localCount}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#F8F9FA')
      .borderRadius(8)

      Column({ space: 10 }) {
        Button('点击"增加countLink"')
          .onClick(() => {
            this.countLink += 1;
          })
          .width('100%')
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')

        Button('修改本地状态')
          .onClick(() => {
            this.localCount += 1;
          })
          .width('100%')
          .backgroundColor('#28A745')
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E9ECEF', radius: 12 })
  }
}

@Entry
@Component
struct PageA {
  @State countState: number = 0;
  @StorageLink('darkTheme') isDarkTheme: boolean = false;

  build() {
    Column({ space: 20 }) {
      Text('状态管理演示')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')
        .margin({ bottom: 10 })

      Text(`父组件Count: ${this.countState}`)
        .fontSize(18)
        .fontColor(this.isDarkTheme ? '#FFFFFF' : '#333333')
        .margin({ bottom: 20 })

      ChildComponent({
        countProp: this.countState,
        countLink: $countState
      })

      Column({ space: 10 }) {
        Button('点击"增加countState"')
          .onClick(() => {
            this.countState += 1;
          })
          .width('90%')
          .backgroundColor('#FF6B81')
          .fontColor('#FFFFFF')

        Button('跳转到设置页面')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/PageB'
            });
          })
          .width('90%')
          .backgroundColor('#6F42C1')
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.isDarkTheme?'#1A1A1A':'#F5F5F5')
    .justifyContent(FlexAlign.Start)
  }
}