import router from '@ohos.router';

// 子组件定义 - 必须放在父组件之前
@Component
struct ChildComponent {
  @Prop countProp: number;        // 单向绑定
  @Link countLink: number;        // 双向绑定
  @State localCount: number = 0;  // 子组件内部状态

  build() {
    Column({ space: 15 }) {
      Text('子组件状态显示')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      // 状态显示区域
      Column({ space: 8 }) {
        Text(`接收的Prop: ${this.countProp}`)
          .fontSize(14)
        Text(`接收的Link: ${this.countLink}`)
          .fontSize(14)
        Text(`本地状态: ${this.localCount}`)
          .fontSize(14)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#F8F9FA')
      .borderRadius(8)

      // 操作按钮区域
      Column({ space: 10 }) {
        Button('修改Link（双向同步）')
          .onClick(() => {
            this.countLink += 1; // 双向绑定，会同步到父组件
          })
          .width('100%')
          .backgroundColor('#007DFF')

        Button('修改本地状态')
          .onClick(() => {
            this.localCount += 1; // 仅修改子组件内部状态
          })
          .width('100%')
          .backgroundColor('#28A745')
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(15)
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
      Text('状态管理演示 - 主页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')

      Text(`父组件Count: ${this.countState}`)
        .fontSize(18)
        .fontColor(this.isDarkTheme ? '#E0E0E0' : '#666666')

      // 使用子组件 - 修正语法
      ChildComponent({
        countProp: this.countState,
        countLink: $countState
      })

      Button('父组件: Count + 1')
        .onClick(() => {
          this.countState += 1;
        })
        .width('80%')
        .backgroundColor('#FF6B81')

      Button('跳转到设置页面')
        .onClick(() => {
          router.pushUrl({ url: 'pages/PageB' });
        })
        .width('80%')
        .backgroundColor('#6F42C1')
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.isDarkTheme ? '#1A1A1A' : '#F5F5F5')
  }
}