// pages/WeatherPage.ets
import { WeatherUtils } from '../utils/WeatherUtils';
import { WeatherCard } from '../components/WeatherCard';
import router from '@ohos.router';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

// ========== 数据类型定义 ==========

interface WeatherInfo {
  city: string;
  temperature: number;
  weather: string;
  humidity: number;
  windSpeed: number;
  windDirection: number;
  aqi: number;
  pressure: number;
  visibility: number;
  uvIndex: number;
  sunrise: string;
  sunset: string;
  forecast: DailyForecast[];
  hourlyForecast: HourlyForecast[];
}

interface DailyForecast {
  day: string;
  weather: string;
  high: number;
  low: number;
}

interface HourlyForecast {
  time: string;
  temp: number;
  weather: string;
}

interface ComfortLevel {
  temp: number;
  label: string;
  color: string;
}

@Component
export struct WeatherPage {
  private readonly comfortLevels: ComfortLevel[] = [
    { temp: -10, label: '严寒', color: '#4FC3F7' } as ComfortLevel,
    { temp: 0, label: '寒冷', color: '#81D4FA' } as ComfortLevel,
    { temp: 10, label: '凉爽', color: '#4CAF50' } as ComfortLevel,
    { temp: 20, label: '舒适', color: '#66BB6A' } as ComfortLevel,
    { temp: 28, label: '炎热', color: '#FF9800' } as ComfortLevel,
    { temp: 35, label: '酷热', color: '#F44336' } as ComfortLevel
  ];
  @State weatherData: WeatherInfo = {
    city: '北京',
    temperature: 26,
    weather: '晴',
    humidity: 65,
    windSpeed: 12,
    windDirection: 180,
    aqi: 45,
    pressure: 1013,
    visibility: 10,
    uvIndex: 5,
    sunrise: '06:30',
    sunset: '18:45',
    forecast: [
      {
        day: '今天',
        weather: '晴',
        high: 28,
        low: 18
      },
      {
        day: '明天',
        weather: '多云',
        high: 26,
        low: 17
      },
      {
        day: '后天',
        weather: '小雨',
        high: 22,
        low: 15
      }
    ],
    hourlyForecast: [
      { time: '现在', temp: 26, weather: '晴' },
      { time: '14:00', temp: 27, weather: '晴' },
      { time: '15:00', temp: 28, weather: '晴' },
      { time: '16:00', temp: 27, weather: '晴' },
      { time: '17:00', temp: 26, weather: '晴' }
    ]
  };
  @State showWeatherDetail: boolean = false;
  @State isLoading: boolean = true;
  @State refreshLoading: boolean = false;
  @State currentLocation: string = '当前位置';
  @State lastUpdateTime: string = '';

  // 移除温度单位相关状态
  // @StorageLink('temperature_unit') currentTemperatureUnit: string = 'celsius';

  aboutToAppear() {
    this.loadWeatherData();
    this.lastUpdateTime = this.getCurrentTime();
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        this.BuildHeader()

        if (this.isLoading) {
          this.BuildLoadingState()
        } else {
          Scroll() {
            Column() {
              // 天气卡片
              WeatherCard({
                city: this.weatherData.city,
                temperature: this.weatherData.temperature,
                weather: this.weatherData.weather,
                humidity: this.weatherData.humidity,
                windSpeed: this.weatherData.windSpeed,
                windDirection: this.weatherData.windDirection,
                aqi: this.weatherData.aqi,
                pressure: this.weatherData.pressure,
                visibilityDistance: this.weatherData.visibility,
                uvIndex: this.weatherData.uvIndex,
                sunrise: this.weatherData.sunrise,
                sunset: this.weatherData.sunset,
                onDetailClick: this.onWeatherDetailClick.bind(this)
              })
                .margin({ bottom: 16 })

              // 小时预报
              this.BuildHourlyForecast()

              // 多日预报
              this.BuildDailyForecast()

              // 环境指标
              this.BuildEnvironmentMetrics()

              // 农业建议
              this.BuildFarmAdvice()

              // 舒适度指示器
              this.BuildComfortIndicator()
            }
            .padding(16)
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8FBF8')

      if (this.refreshLoading) {
        this.BuildRefreshOverlay()
      }
    }
  }

  // ========== 页面组件构建方法 ==========

  @Builder
  BuildHeader() {
    Column() {
      Row() {
        Column() {
          Text('天气')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2D4D2D')

          Text(this.currentLocation)
            .fontSize(12)
            .fontColor('#668866')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 操作按钮
        Row() {
          // 刷新按钮
          Image($r('app.media.ic_refresh'))
            .width(24)
            .height(24)
            .margin({ right: 16 })
            .onClick(() => {
              this.refreshWeatherData();
            })

          // 设置按钮
          Image($r('app.media.ic_settings'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.navigateToSettings();
            })
        }
      }
      .width('100%')

      // 最后更新时间
      Text(`最后更新: ${this.lastUpdateTime}`)
        .fontSize(10)
        .fontColor('#999999')
        .alignSelf(ItemAlign.Start)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 12,
      bottom: 12
    })
    .backgroundColor('#E8F5E8')
  }

  // 删除温度单位选择器方法
  // @Builder
  // BuildUnitSelector() {
  //   // 此方法已完全移除
  // }

  @Builder
  BuildHourlyForecast() {
    Column() {
      Row() {
        Text('小时预报')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D4D2D')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Blank()

        Text('24小时 ›')
          .fontSize(12)
          .fontColor('#2E8B57')
          .onClick(() => {
            this.viewDetailedHourlyForecast();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Scroll() {
        Row() {
          ForEach(this.weatherData.hourlyForecast, (hour: HourlyForecast, index: number) => {
            this.BuildHourlyForecastItem(hour, index)
          })
        }
        .padding({ right: 16 })
      }
      .scrollBar(BarState.Off)
      .height(100)
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

  @Builder
  BuildHourlyForecastItem(hour: HourlyForecast, index: number) {
    Column() {
      Text(hour.time)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      Text(WeatherUtils.getWeatherIcon(hour.weather))
        .fontSize(20)
        .margin({ bottom: 8 })

      // 使用固定的摄氏度显示，移除温度单位转换
      Text(`${hour.temp}°C`)
        .fontSize(14)
        .fontColor('#2D4D2D')
        .fontWeight(FontWeight.Medium)
    }
    .width(60)
    .margin({ right: index < this.weatherData.hourlyForecast.length - 1 ? 12 : 0 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BuildDailyForecast() {
    Column() {
      Text('天气预报')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      ForEach(this.weatherData.forecast, (forecast: DailyForecast, index: number) => {
        this.BuildDailyForecastItem(forecast, index)
      })
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

  @Builder
  BuildDailyForecastItem(forecast: DailyForecast, index: number) {
    Column() {
      Row() {
        Text(forecast.day)
          .fontSize(16)
          .fontColor('#2D4D2D')
          .width(60)

        Text(WeatherUtils.getWeatherIcon(forecast.weather))
          .fontSize(20)
          .width(40)

        Text(forecast.weather)
          .fontSize(14)
          .fontColor('#666666')
          .layoutWeight(1)

        // 使用固定的摄氏度显示
        Text(`${forecast.low}°C-${forecast.high}°C`)
          .fontSize(14)
          .fontColor('#2D4D2D')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      if (index < this.weatherData.forecast.length - 1) {
        Divider()
          .strokeWidth(1)
          .color('#F0F0F0')
      }
    }
    .width('100%')
  }

  @Builder
  BuildEnvironmentMetrics() {
    Column() {
      Text('环境指标')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Grid() {
        GridItem() {
          this.BuildMetricCard('空气质量', this.getAQIDescription(), this.getAQIColor(), '🌬️',
            `${this.weatherData.aqi}`)
        }

        GridItem() {
          this.BuildMetricCard('湿度', `${this.weatherData.humidity}%`, '#2196F3', '💧', '')
        }

        GridItem() {
          this.BuildMetricCard('气压', `${this.weatherData.pressure}hPa`, '#9C27B0', '📊', '')
        }

        GridItem() {
          this.BuildMetricCard('能见度', `${this.weatherData.visibility}km`, '#607D8B', '👁️', '')
        }

        GridItem() {
          this.BuildMetricCard('紫外线', this.getUVIndexDescription(), this.getUVIndexColor(), '☀️',
            `${this.weatherData.uvIndex}`)
        }

        GridItem() {
          this.BuildMetricCard('风速', `${this.weatherData.windSpeed}km/h`, '#00BCD4', '💨',
            this.getWindDirectionText(this.weatherData.windDirection))
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(120)
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

  @Builder
  BuildMetricCard(title: string, value: string, color: string, icon: string, subtitle: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(16)
          .margin({ right: 8 })

        Text(title)
          .fontSize(14)
          .fontColor('#666666')
      }
      .alignSelf(ItemAlign.Start)
      .margin({ bottom: 8 })

      Text(value)
        .fontSize(16)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)

      if (subtitle) {
        Text(subtitle)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height(80)
    .padding(12)
    .backgroundColor('#FAFAFA')
    .borderRadius(12)
  }

  @Builder
  BuildFarmAdvice() {
    Column() {
      Text('农业建议')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      Text(this.getFarmAdviceText())
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Start)
        .lineHeight(20)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#E8F5E8')
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }

  @Builder
  BuildComfortIndicator() {
    Column() {
      Text('体感舒适度')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
      Row() {
        Column() {
          Text(WeatherUtils.getComfortLevel(this.weatherData.temperature))
            .fontSize(16)
            .fontColor(WeatherUtils.getComfortColor(this.weatherData.temperature))
            .fontWeight(FontWeight.Medium)

          Text('当前体感')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text(`${this.weatherData.temperature}°C`)
            .fontSize(16)
            .fontColor('#2D4D2D')
            .fontWeight(FontWeight.Medium)

          Text('实际温度')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding({ bottom: 16 })

      // 舒适度进度条
      this.BuildComfortScale()
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
  }

  @Builder
  BuildComfortScale() {
    Column() {
      // 温度刻度
      Row() {
        ForEach(this.comfortLevels, (level: ComfortLevel, index: number) => {
          Column() {
            Text(`${level.temp}°C`)
              .fontSize(10)
              .fontColor('#999999')

            Blank()

            Circle()
              .width(8)
              .height(8)
              .fill(level.color)
          }
          .height(40)
          .layoutWeight(1)
        })
      }
      .width('100%')

      // 当前温度指示器
      Row() {
        Blank()
          .layoutWeight(this.calculateWeight(this.weatherData.temperature, -10, 35))
        Column() {
          Image($r('app.media.startIcon'))
            .width(16)
            .height(16)

          Text(`${this.weatherData.temperature}°C`)
            .fontSize(12)
            .fontColor('#2D4D2D')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)

        Blank()
          .layoutWeight(1 - this.calculateWeight(this.weatherData.temperature, -10, 35))
      }
      .width('100%')
      .margin({ top: 8 })
    }
  }

  @Builder
  BuildLoadingState() {
    Column() {
      Progress({ value: 0 })
        .width(40)
        .height(40)
        .color('#2E8B57')
        .margin({ bottom: 16 })

      Text('加载天气数据中...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  BuildRefreshOverlay() {
    Column() {
      Progress({ value: 0 })
        .width(40)
        .height(40)
        .color('#2E8B57')

      Text('更新中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(248, 251, 248, 0.8)')
  }

  // ========== 业务逻辑方法 ==========

  // 删除温度单位设置方法
  // private setTemperatureUnit(unit: string): void {
  //   // 此方法已移除
  // }

  // 删除温度格式化方法（使用固定摄氏度）
  // private getFormattedTemperature(temp: number): string {
  //   // 此方法已移除
  // }

  // 加载天气数据
  async loadWeatherData() {
    this.isLoading = true;

    try {
      // 模拟API调用延迟
      await new Promise<void>(resolve => setTimeout(resolve, 1000));

      this.isLoading = false;
      this.lastUpdateTime = this.getCurrentTime();
      hilog.info(0x0000, 'WeatherPage', '天气数据加载成功');
    } catch (error) {
      hilog.error(0x0000, 'WeatherPage', `加载天气数据失败: ${JSON.stringify(error)}`);
      this.showToast('加载天气数据失败');
      this.isLoading = false;
    }
  }

  // 刷新天气数据
  async refreshWeatherData() {
    this.refreshLoading = true;

    try {
      // 模拟刷新延迟
      await new Promise<void>(resolve => setTimeout(resolve, 1500));

      this.refreshLoading = false;
      this.lastUpdateTime = this.getCurrentTime();
      this.showToast('天气数据已更新');
      hilog.info(0x0000, 'WeatherPage', '天气数据刷新成功');
    } catch (error) {
      hilog.error(0x0000, 'WeatherPage', `刷新天气数据失败: ${JSON.stringify(error)}`);
      this.showToast('刷新失败，请重试');
      this.refreshLoading = false;
    }
  }

  // 天气详情点击处理
  private onWeatherDetailClick(): void {
    hilog.info(0x0000, 'WeatherPage', '点击天气详情按钮');

    router.pushUrl({
      url: 'pages/WeatherDetailPage',
      params: {
        city: this.weatherData.city,
        temperature: this.weatherData.temperature.toString(),
        weather: this.weatherData.weather,
        humidity: this.weatherData.humidity.toString(),
        windSpeed: this.weatherData.windSpeed.toString(),
        aqi: this.weatherData.aqi.toString(),
        forecast: JSON.stringify(this.weatherData.forecast)
      }
    }).then(() => {
      hilog.info(0x0000, 'WeatherPage', '跳转到天气详情页面成功');
    }).catch((error: Error) => {
      hilog.error(0x0000, 'WeatherPage', `跳转失败: ${JSON.stringify(error)}`);
      this.showToast('无法打开详情页面');
    });
  }

  // 查看详细小时预报
  private viewDetailedHourlyForecast(): void {
    hilog.info(0x0000, 'WeatherPage', '查看详细小时预报');
    this.showToast('小时预报功能开发中');
  }

  // 导航到设置页面
  private navigateToSettings(): void {
    hilog.info(0x0000, 'WeatherPage', '导航到设置页面');
    router.pushUrl({
      url: 'pages/SettingsPage'
    }).then(() => {
      hilog.info(0x0000, 'WeatherPage', '跳转到设置页面成功');
    }).catch((error: Error) => {
      hilog.error(0x0000, 'WeatherPage', `跳转失败: ${JSON.stringify(error)}`);
    });
  }

  // ========== 工具方法 ==========

  private getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }

  private getAQIDescription(): string {
    if (this.weatherData.aqi <= 50) {
      return '优';
    }
    if (this.weatherData.aqi <= 100) {
      return '良';
    }
    if (this.weatherData.aqi <= 150) {
      return '轻度污染';
    }
    if (this.weatherData.aqi <= 200) {
      return '中度污染';
    }
    if (this.weatherData.aqi <= 300) {
      return '重度污染';
    }
    return '严重污染';
  }

  private getAQIColor(): string {
    if (this.weatherData.aqi <= 50) {
      return '#4CAF50';
    }
    if (this.weatherData.aqi <= 100) {
      return '#8BC34A';
    }
    if (this.weatherData.aqi <= 150) {
      return '#FFC107';
    }
    if (this.weatherData.aqi <= 200) {
      return '#FF9800';
    }
    if (this.weatherData.aqi <= 300) {
      return '#F44336';
    }
    return '#9C27B0';
  }

  private getWindDirectionText(degrees: number): string {
    const directions = ['北风', '东北风', '东风', '东南风', '南风', '西南风', '西风', '西北风'];
    const index = Math.round((degrees % 360) / 45) % 8;
    return directions[index];
  }

  private getUVIndexDescription(): string {
    if (this.weatherData.uvIndex <= 2) {
      return '弱';
    }
    if (this.weatherData.uvIndex <= 5) {
      return '中等';
    }
    if (this.weatherData.uvIndex <= 7) {
      return '强';
    }
    if (this.weatherData.uvIndex <= 10) {
      return '很强';
    }
    return '极强';
  }

  private getUVIndexColor(): string {
    if (this.weatherData.uvIndex <= 2) {
      return '#4CAF50';
    }
    if (this.weatherData.uvIndex <= 5) {
      return '#FFC107';
    }
    if (this.weatherData.uvIndex <= 7) {
      return '#FF9800';
    }
    if (this.weatherData.uvIndex <= 10) {
      return '#F44336';
    }
    return '#9C27B0';
  }

  private getFarmAdviceText(): string {
    return WeatherUtils.getFarmAdvice(this.weatherData.weather, this.weatherData.temperature,
      this.weatherData.humidity);
  }

  private calculateWeight(value: number, min: number, max: number): number {
    const normalized = (value - min) / (max - min);
    return Math.max(0, Math.min(1, normalized));
  }

  private showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}