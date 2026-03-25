import { FarmDatabase } from '../database/FarmDatabase';
import { StorageUtils } from '../utils/StorageUtils';
import { WeatherUtils } from '../utils/WeatherUtils';
import { DateUtils } from '../utils/DateUtils';
import { ProductType, ProductStatus, RecordType, WeatherType, EnumUtils } from '../model/Enums';
import { FarmProduct, GrowthRecord, WeatherInfo } from '../model/DataModels';

@Component
export struct HomePage {
  @State farmData: FarmData = new FarmData();
  @State weatherInfo: WeatherInfo = new WeatherInfo();
  @State recentActivities: Activity[] = [];
  @State isLoading: boolean = true;
  @State userName: string = '农场管理员';
  @State currentTime: string = DateUtils.formatTime(new Date());

  // 组件生命周期 - 组件即将出现时调用
  aboutToAppear(): void {
    console.info('HomePage aboutToAppear');
    this.loadAllData();

    // 设置定时器更新当前时间
    setInterval(() => {
      this.currentTime = DateUtils.formatTime(new Date());
    }, 60000);
  }

  // 组件生命周期 - 组件即将销毁时调用
  aboutToDisappear(): void {
    console.info('HomePage aboutToDisappear');
    // 清理定时器等资源
  }

  // 页面显示时调用
  onPageShow(): void {
    console.info('HomePage onPageShow');
    // 页面显示时刷新数据
    this.loadAllData();
  }

  // 页面隐藏时调用
  onPageHide(): void {
    console.info('HomePage onPageHide');
  }

  // 加载所有数据
  async loadAllData(): Promise<void> {
    this.isLoading = true;

    try {
      // 并行加载所有数据以提高性能
      await Promise.all([
        this.loadFarmData(),
        this.loadWeatherData(),
        this.loadRecentActivities(),
        this.loadUserSettings()
      ]);
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 加载农场数据
  async loadFarmData(): Promise<void> {
    try {
      const allProducts = await FarmDatabase.getAllProducts();
      const growingCount = allProducts.filter(p => p.status === ProductStatus.GROWING).length;

      this.farmData = {
        name: await StorageUtils.getString('farm_name', '阳光农场'),
        description: '专注于有机农业种植',
        totalProducts: allProducts.length,
        growingCount: growingCount,
        todayTasks: await this.calculateTodayTasks(),
        onlineDevices: await StorageUtils.getNumber('online_devices', 12)
      };
    } catch (error) {
      console.error('Failed to load farm data:', error);
    }
  }

  // 加载天气数据
  async loadWeatherData(): Promise<void> {
    try {
      // 这里可以从API获取，目前使用模拟数据
      this.weatherInfo = {
        city: await StorageUtils.getString('farm_city', '北京'),
        temperature: 26,
        weather: '晴',
        humidity: 65,
        windSpeed: 12,
        updateTime: new Date().toISOString(),
        forecast: [
          {
            date: DateUtils.formatDate(new Date()),
            weather: '晴',
            maxTemp: 28,
            minTemp: 18
          },
          {
            date: DateUtils.formatDate(new Date(Date.now() + 86400000)),
            weather: '多云',
            maxTemp: 26,
            minTemp: 17
          },
          {
            date: DateUtils.formatDate(new Date(Date.now() + 172800000)),
            weather: '小雨',
            maxTemp: 22,
            minTemp: 15
          }
        ]
      };
    } catch (error) {
      console.error('Failed to load weather data:', error);
    }
  }

  // 加载最近活动
  async loadRecentActivities(): Promise<void> {
    try {
      // 这里可以从数据库获取，目前使用模拟数据
      this.recentActivities = [
        {
          id: 1,
          type: RecordType.WATERING,
          title: '西红柿自动浇水完成',
          time: '10:30',
          status: '已完成',
          icon: '💧',
          color: '#2196F3',
          statusColor: '#4CAF50',
          statusBgColor: '#E8F5E8'
        },
        {
          id: 2,
          type: RecordType.OBSERVATION,
          title: '黄瓜进入开花期',
          time: '09:15',
          status: '进行中',
          icon: '🌱',
          color: '#4CAF50',
          statusColor: '#FFA500',
          statusBgColor: '#FFF5E6'
        },
        {
          id: 3,
          type: RecordType.HARVESTING,
          title: '新批次草莓上架',
          time: '昨天',
          status: '已上架',
          icon: '📦',
          color: '#FF6B6B',
          statusColor: '#2196F3',
          statusBgColor: '#E3F2FD'
        }
      ];
    } catch (error) {
      console.error('Failed to load activities:', error);
    }
  }

  // 加载用户设置
  async loadUserSettings(): Promise<void> {
    try {
      this.userName = await StorageUtils.getString('user_name', '农场管理员');
    } catch (error) {
      console.error('Failed to load user settings:', error);
    }
  }

  // 计算今日任务
  async calculateTodayTasks(): Promise<number> {
    try {
      // 简化实现，实际应根据作物状态计算
      return 3;
    } catch (error) {
      console.error('Failed to calculate tasks:', error);
      return 0;
    }
  }

  build() {
    Column() {
      // 顶部状态栏
      this.BuildStatusBar()

      if (this.isLoading) {
        this.BuildLoadingIndicator()
      } else {
        Scroll() {
          Column() {
            // 农场信息卡片
            this.BuildFarmOverview()

            // 天气信息卡片
            this.BuildWeatherCard()

            // 数据统计网格
            this.BuildStatsGrid()

            // 最近活动
            this.BuildRecentActivities()

            // 快捷操作
            this.BuildQuickActions()
          }
          .padding(16)
        }
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FBF8')
  }

  // 构建顶部状态栏
  @Builder
  BuildStatusBar() {
    Row() {
      Column() {
        Text(this.currentTime)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2D4D2D')

        Text('您好，' + this.userName)
          .fontSize(12)
          .fontColor('#668866')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 天气简讯
      Row() {
        Text(WeatherUtils.getWeatherIcon(this.weatherInfo.weather))
          .fontSize(16)
          .margin({ right: 5 })
        Text(`${this.weatherInfo.temperature}°C ${this.weatherInfo.weather}`)
          .fontSize(12)
          .fontColor('#668866')
      }
      .padding({
        left: 8,
        right: 8,
        top: 6,
        bottom: 6
      })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
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

  // 构建加载指示器
  @Builder
  BuildLoadingIndicator() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#2E8B57')
        .margin({ bottom: 16 })

      Text('加载中...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 构建农场概览
  @Builder
  BuildFarmOverview() {
    Column() {
      Row() {
        Text('🌾')
          .fontSize(24)
          .margin({ right: 12 })

        Column() {
          Text(this.farmData.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2D4D2D')

          Text(this.farmData.description)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('运营中')
            .fontSize(10)
            .fontColor('#4CAF50')
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .backgroundColor('#E8F5E8')
            .borderRadius(6)

          Text('今日在线')
            .fontSize(10)
            .fontColor('#888888')
            .margin({ top: 4 })
        }
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }

  // 构建天气卡片
  @Builder
  BuildWeatherCard() {
    Column() {
      Row() {
        Text('🌤️')
          .fontSize(20)
          .margin({ right: 12 })

        Column() {
          Text(`${this.weatherInfo.temperature}°C ${this.weatherInfo.weather}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D4D2D')

          Text(`湿度 ${this.weatherInfo.humidity}% | 风速 ${this.weatherInfo.windSpeed}km/h`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('适宜')
          .fontSize(10)
          .fontColor('#4CAF50')
          .padding({
            left: 6,
            right: 6,
            top: 3,
            bottom: 3
          })
          .backgroundColor('#E8F5E8')
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#E8F5E8')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  // 构建数据统计网格
  @Builder
  BuildStatsGrid() {
    Column() {
      Text('数据概览')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      GridRow() {
        GridCol({ span: 6 }) {
          this.BuildStatItem('📦', this.farmData.totalProducts.toString(), '在售产品', '#FF6B6B')
        }

        GridCol({ span: 6 }) {
          this.BuildStatItem('🌱', this.farmData.growingCount.toString(), '生长中', '#4CAF50')
        }

        GridCol({ span: 6 }) {
          this.BuildStatItem('✅', this.farmData.todayTasks.toString(), '今日任务', '#FFA500')
        }

        GridCol({ span: 6 }) {
          this.BuildStatItem('🔧', this.farmData.onlineDevices.toString(), '设备在线', '#2196F3')
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }

  // 构建统计项
  @Builder
  BuildStatItem(icon: string, value: string, label: string, color: ResourceColor) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(16)
          .margin({ right: 6 })

        Text(value)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }

      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .margin(4)
  }

  // 构建最近活动
  @Builder
  BuildRecentActivities() {
    Column() {
      Row() {
        Text('最新动态')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D4D2D')

        Blank()

        Text('查看全部')
          .fontSize(12)
          .fontColor('#2E8B57')
          .onClick(() => {
            console.log('查看全部活动');
            // 这里可以跳转到活动记录页面
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        ForEach(this.recentActivities, (activity: Activity, index: number) => {
          this.BuildActivityItem(activity, index)
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }

  // 构建活动项
  @Builder
  BuildActivityItem(activity: Activity, index: number) {
    Row() {
      Text(activity.icon)
        .fontSize(16)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
        .backgroundColor(activity.color)
        .fontColor('#FFFFFF')
        .borderRadius(12)
        .margin({ right: 12 })

      Column() {
        Text(activity.title)
          .fontSize(14)
          .fontColor('#2D4D2D')
          .alignSelf(ItemAlign.Start)

        Text(activity.time)
          .fontSize(11)
          .fontColor('#888888')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(activity.status)
        .fontSize(10)
        .fontColor(activity.statusColor)
        .padding({
          left: 6,
          right: 6,
          top: 2,
          bottom: 2
        })
        .backgroundColor(activity.statusBgColor)
        .borderRadius(4)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })

    if (index < this.recentActivities.length - 1) {
      Divider()
        .strokeWidth(1)
        .color('#F0F0F0')
        .margin({ top: 8, bottom: 8 })
    }
  }

  // 构建快捷操作
  @Builder
  BuildQuickActions() {
    Column() {
      Text('快捷功能')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Row() {
        this.BuildActionButton('📋', '产品管理', '#2E8B57')
        this.BuildActionButton('📊', '生长记录', '#FFA500')
        this.BuildActionButton('💧', '智能灌溉', '#2196F3')
        this.BuildActionButton('🌤️', '天气详情', '#9C27B0')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 构建操作按钮
  @Builder
  BuildActionButton(icon: string, label: string, color: ResourceColor) {
    Column() {
      Text(icon)
        .fontSize(20)
        .padding(12)
        .backgroundColor(color + '1A') // 添加透明度
        .fontColor(color)
        .borderRadius(10)

      Text(label)
        .fontSize(11)
        .fontColor('#2D4D2D')
        .margin({ top: 6 })
    }
    .onClick(() => {
      console.info(`点击: ${label}`);
      this.handleActionClick(label);
    })
  }

  // 处理操作点击
  private handleActionClick(action: string): void {
    switch (action) {
      case '产品管理':
        console.log('导航到产品管理页面');
        // router.pushUrl({ url: 'pages/ProductPage' });
        break;
      case '生长记录':
        console.log('导航到生长记录页面');
        // router.pushUrl({ url: 'pages/RecordPage' });
        break;
      case '智能灌溉':
        console.log('启动智能灌溉');
        this.startIrrigation();
        break;
      case '天气详情':
        console.log('查看天气详情');
        // router.pushUrl({ url: 'pages/WeatherPage' });
        break;
    }
  }

  // 启动灌溉系统
  private startIrrigation(): void {
    console.log('启动智能灌溉系统');
    // 这里可以调用灌溉设备的API
  }
}

// 本地数据类型
class FarmData {
  name: string = '';
  description: string = '';
  totalProducts: number = 0;
  growingCount: number = 0;
  todayTasks: number = 0;
  onlineDevices: number = 0;
}

class Activity {
  id: number = 0;
  type: RecordType = RecordType.OTHER;
  title: string = '';
  time: string = '';
  status: string = '';
  icon: string = '';
  color: string = '';
  statusColor: string = '';
  statusBgColor: string = '';
}