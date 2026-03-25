// 底部导航栏组件
@Component
export struct TabBar {
  @Prop currentTab: number = 0;
  @Prop onTabChange: (index: number) => void = () => {};

  private tabItems: TabItem[] = [
    { title: '首页', icon: '🏠' },
    { title: '产品', icon: '📦' },
    { title: '记录', icon: '📝' },
    { title: '天气', icon: '🌤️' },
    { title: '设置', icon: '⚙️' }
  ];

  build() {
    Row() {
      ForEach(this.tabItems, (item: TabItem, index: number) => {
        this.BuildTabItem(item, index)
      })
    }
    .width('100%')
    .height(60)
    .padding({ left: 10, right: 10 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: -2 })
  }

  @Builder
  BuildTabItem(item: TabItem, index: number) {
    Column() {
      Text(item.icon)
        .fontSize(20)
        .margin({ bottom: 4 })

      Text(item.title)
        .fontSize(11)
        .fontColor(this.currentTab === index ? '#2E8B57' : '#666666')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .layoutWeight(1)
    .padding(8)
    .backgroundColor(this.currentTab === index ? '#F0F9F4' : 'transparent')
    .borderRadius(8)
    .onClick(() => {
      this.onTabChange(index);
    })
  }
}

interface TabItem {
  title: string;
  icon: string;
}