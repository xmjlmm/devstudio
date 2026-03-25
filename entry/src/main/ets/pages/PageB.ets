import router from '@ohos.router';

@Entry
@Component
struct PageB {
  // 双向绑定持久化存储
  @StorageLink('darkTheme') isDarkTheme: boolean = false;
  // 单向绑定持久化存储
  @StorageProp('darkTheme') themeProp: boolean = false;

  build() {
    Column({ space: 20 }) {
      // 页面标题
      Text('主题设置页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')
        .margin({ bottom: 10 })

      // 主题设置卡片
      Column({ space: 15 }) {
        Text('当前主题模式')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')

        Text(this.isDarkTheme ? '深色主题' : '浅色主题')
          .fontSize(16)
          .fontColor(this.isDarkTheme ? '#CCCCCC' : '#666666')

        // 主题切换开关
        Row({ space: 10 }) {
          Text('浅色')
            .fontSize(14)
            .fontColor(this.isDarkTheme ? '#999999' : '#007DFF')

          Toggle({ type: ToggleType.Switch,
            isOn: this.isDarkTheme })
            .onChange((value: boolean) => {
              this.isDarkTheme = value;
              console.info('主题已切换: ' + (value ? '深色' : '浅色'));
            })
            .width(40)
            .height(20)

          Text('深色')
            .fontSize(14)
            .fontColor(this.isDarkTheme ? '#007DFF' : '#999999')
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 5 })
      }
      .width('90%')
      .padding(20)
      .backgroundColor(this.isDarkTheme ? '#2D2D2D' : '#FFFFFF')
      .borderRadius(12)
      .shadow(this.isDarkTheme ? {radius: 0}:{ radius: 8, color: '#00000010' })

      // 装饰器说明区域
      Column({ space: 12 }) {
        Text('装饰器特性说明')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkTheme ? '#FFFFFF' : '#000000')
          .margin({ bottom: 5 })

        this.buildDecoratorItem('@StorageLink', '双向绑定，修改会持久化并全局同步')
        this.buildDecoratorItem('@StorageProp', '单向绑定，仅读取持久化数据')
        this.buildDecoratorItem('@State', '组件内部状态，不持久化')
        this.buildDecoratorItem('@Prop', '父→子单向传递')
        this.buildDecoratorItem('@Link', '父子组件双向同步')
      }
      .width('90%')
      .padding(15)
      .backgroundColor(this.isDarkTheme ? '#2D2D2D' : '#FFFFFF')
      .borderRadius(12)

      // 操作按钮
      Button('返回主页面')
        .onClick(() => {
          router.back();
        })
        .width('80%')
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.isDarkTheme ? '#1A1A1A' : '#F5F5F5')
  }

  // 构建装饰器说明项
  @Builder
  buildDecoratorItem(name: string, description: string) {
    Row({ space: 10 }) {
      Text(name)
        .fontSize(12)
        .fontColor('#007DFF')
        .fontWeight(FontWeight.Bold)
        .width('30%')

      Text(description)
        .fontSize(12)
        .fontColor(this.isDarkTheme ? '#CCCCCC' : '#666666')
        .width('70%')
    }
    .width('100%')
    .padding({ top: 5, bottom: 5 })
  }

  aboutToAppear() {
    console.info('页面B已加载，当前主题: ' + (this.isDarkTheme ? '深色' : '浅色'));
    console.info('@StorageProp读取的主题值: ' + this.themeProp);
  }
}