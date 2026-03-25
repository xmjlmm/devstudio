import { HomePage } from './HomePage';
import { ProductPage } from './ProductPage';
import { RecordPage } from './RecordPage';
import { WeatherPage } from './WeatherPage';
import { SettingsPage } from './SettingsPage';

@Entry
@Component
struct MainPage {
  @State currentTab: number = 0;
  @State userName: string = '农场管理员';
  // 页面标题配置
  private pageTitles: string[] = [
    '农场概览',
    '产品管理',
    '生长记录',
    '天气信息',
    '系统设置'
  ];
  // 页面图标配置
  private pageIcons: string[] = ['🏠', '📦', '📝', '🌤️', '⚙️'];

  build() {
    Column() {
      // 顶部标题栏
      this.BuildHeader()

      // 内容区域 - 根据当前标签显示不同页面
      this.BuildContentArea()

      // 底部导航栏
      this.BuildTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FBF8')
  }

  // 构建顶部标题栏
  @Builder
  BuildHeader() {
    Row() {
      Column() {
        Text('智慧农场助手')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D4D2D')

        Text(`您好，${this.userName}`)
          .fontSize(12)
          .fontColor('#668866')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 当前时间显示
      Text(this.getCurrentTime())
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 10,
      bottom: 10
    })
    .backgroundColor('#E8F5E8')
  }

  // 构建内容区域
  @Builder
  BuildContentArea() {
    Column() {
      // 根据当前标签显示对应页面
      if (this.currentTab === 0) {
        HomePage()
      } else if (this.currentTab === 1) {
        ProductPage()
      } else if (this.currentTab === 2) {
        RecordPage()
      } else if (this.currentTab === 3) {
        WeatherPage()
      } else {
        SettingsPage()
      }
    }
    .layoutWeight(1)
    .width('100%')
  }

  // 构建底部导航栏
  @Builder
  BuildTabBar() {
    Column() {
      Divider()
        .strokeWidth(1)
        .color('#E8E8E8')

      Row() {
        ForEach([0, 1, 2, 3, 4], (index: number) => {
          this.BuildTabItem(index)
        })
      }
      .width('100%')
      .height(60)
      .padding({ left: 10, right: 10 })
    }
    .backgroundColor('#FFFFFF')
  }

  // 构建导航项
  @Builder
  BuildTabItem(index: number) {
    Column() {
      Text(this.pageIcons[index])
        .fontSize(20)
        .margin({ bottom: 4 })

      Text(this.pageTitles[index])
        .fontSize(11)
        .fontColor(this.currentTab === index ? '#2E8B57' : '#666666')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .layoutWeight(1)
    .padding(8)
    .backgroundColor(this.currentTab === index ? '#F0F9F4' : 'transparent')
    .borderRadius(8)
    .onClick(() => {
      this.currentTab = index;
      console.log(`切换到: ${this.pageTitles[index]}`);
    })
  }

  // 获取当前时间
  private getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }
}