// entry/src/main/ets/pages/Index.ets
import router from '@ohos.router';
import { Crop, WeatherData } from '../model/DataModel';
import { RdbManager } from '../model/RdbManager';
import { WeatherCard } from '../components/WeatherCard';
import { StatCard } from '../components/StatCard';
import { CropCard } from '../components/CropCard';
import { Logger } from '../utils/Logger';
import { DateUtils } from '../utils/DateUtils';

@Entry
@Component
struct Index {
  @State cropList: Crop[] = [];
  @State weatherData: WeatherData = new WeatherData();
  @State pendingTaskCount: number = 0;
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadInitialData();
  }

  async loadInitialData() {
    try {
      this.isLoading = true;
      await this.loadCropsData();
      await this.loadTasksData();
      await this.loadWeatherData();
      Logger.info('首页数据加载完成');
    } catch (error) {
      Logger.error('数据加载失败', error);
    } finally {
      this.isLoading = false;
    }
  }

  async loadCropsData() {
    this.cropList = await RdbManager.queryAllCrops();
  }

  async loadTasksData() {
    this.pendingTaskCount = await RdbManager.queryPendingTaskCount();
  }

  async loadWeatherData() {
    await new Promise(resolve => setTimeout(resolve, 500));
    this.weatherData = {
      temperature: 25,
      humidity: 65,
      condition: '晴朗',
      windSpeed: 3.2,
      timestamp: DateUtils.getCurrentTime(),
      location: '智慧农场'
    };
  }

  build() {
    Column({ space: 0 }) {
      // 顶部标题栏
      this.buildHeader()

      // 内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 天气卡片
          WeatherCard({ weatherData: $weatherData })

          // 统计卡片行
          this.buildStatsRow()

          // 作物列表区域
          this.buildCropListSection()
        }
        .padding(16)
      }
      .layoutWeight(1)

      // 加载指示器
      if (this.isLoading) {
        this.buildLoadingIndicator()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  @Builder
  buildHeader() {
    Row() {
      Text('智慧农场助手')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2C3E50')

      Blank()

      Button('设置', { type: ButtonType.Normal })
        .fontSize(12)
        .onClick(() => {
          router.pushUrl({ url: 'pages/Settings' }, router.RouterMode.Single);
        })
    }
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#000000', offsetX: 0, offsetY: 1 })
  }

  @Builder
  buildStatsRow() {
    Row({ space: 12 }) {
      StatCard({
        title: '作物总数',
        value: this.cropList.length.toString(),
        color: '#27AE60'
      })

      StatCard({
        title: '待办任务',
        value: this.pendingTaskCount.toString(),
        color: '#E74C3C'
      })

      StatCard({
        title: '健康作物',
        value: this.getHealthyCropsCount().toString(),
        color: '#3498DB'
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildCropListSection() {
    Column({ space: 12 }) {
      // 标题栏
      Row() {
        Text('我的作物')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')

        Blank()

        Text('管理')
          .fontSize(14)
          .fontColor('#3498DB')
          .onClick(() => {
            router.pushUrl({ url: 'pages/CropManage' }, router.RouterMode.Standard);
          })
      }
      .width('100%')

      // 作物列表
      if (this.cropList.length === 0) {
        this.buildEmptyState()
      } else {
        Column() {
          ForEach(this.cropList.slice(0, 3), (crop: Crop, index: number) => {
            CropCard({ crop: $crop })
              .margin({ bottom: 8 })
          })
        }
      }
    }
  }

  @Builder
  buildEmptyState() {
    Column({ space: 16 }) {
      Text('🌱')
        .fontSize(48)

      Text('暂无作物数据')
        .fontSize(16)
        .fontColor('#95A5A6')

      Button('添加作物', { type: ButtonType.Capsule })
        .onClick(() => {
          router.pushUrl({ url: 'pages/CropManage' }, router.RouterMode.Standard);
        })
    }
    .width('100%')
    .padding(40)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildLoadingIndicator() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)

      Text('加载中...')
        .fontSize(14)
        .margin({ top: 8 })
        .fontColor('#7F8C8D')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .opacity(0.9)
  }

  private getHealthyCropsCount(): number {
    return this.cropList.filter(crop => crop.healthStatus === 'healthy').length;
  }
}