
// components/WeatherCard.ets
import { WeatherUtils } from '../utils/WeatherUtils';
import { AppStorageV2 } from '@kit.ArkUI';

interface TemperatureUnitsType {
  CELSIUS: string;
  FAHRENHEIT: string;
}

@Component
export struct WeatherCard {
  // 基础天气信息
  private city: string = '北京';
  private temperature: number = 26;
  private weather: string = '晴';
  private humidity: number = 65;
  private windSpeed: number = 12;
  private windDirection: number = 180; // 风向角度（0-360）
  // 扩展信息
  private aqi: number = 45; // 空气质量指数
  private pressure: number = 1013; // 气压（hPa）
  private visibilityDistance: number = 10; // 能见度（km）
  private uvIndex: number = 5; // 紫外线指数
  // 时间信息
  private updateTime: string = '刚刚更新';
  private sunrise: string = '06:30';
  private sunset: string = '18:45';
  // 交互功能
  private onDetailClick: () => void = () => {
  };
  // 温度单位常量
  private readonly temperatureUnits: TemperatureUnitsType = {
    CELSIUS: 'celsius',
    FAHRENHEIT: 'fahrenheit'
  };
  // 响应式温度单位
  @StorageLink('temperature_unit') currentTemperatureUnit: string = this.temperatureUnits.CELSIUS;

  aboutToAppear() {
    this.updateTime = this.getCurrentTime();
  }

  build() {
    Column() {
      // 标题栏和操作按钮
      this.BuildHeader()

      // 主要天气信息区域
      this.BuildMainWeatherInfo()

      // 环境参数网格
      this.BuildEnvironmentGrid()

      // 底部信息栏
      this.BuildFooter()
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.getCardBackgroundColor())
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  BuildHeader() {
    Row() {
      Column() {
        Text('天气信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextColor('primary'))

        Text(this.getLastUpdateText())
          .fontSize(10)
          .fontColor(this.getTextColor('secondary'))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 操作按钮
      Row() {
        // 刷新按钮
        Text('🔄')
          .fontSize(16)
          .fontColor(this.getTextColor('secondary'))
          .padding(8)
          .backgroundColor(this.getButtonBackgroundColor())
          .borderRadius(20)
          .onClick(() => {
            this.onRefreshClick();
          })

        // 详情按钮
        Text('详情 ›')
          .fontSize(12)
          .fontColor('#2E8B57')
          .fontWeight(FontWeight.Medium)
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .backgroundColor(this.getButtonBackgroundColor())
          .borderRadius(12)
          .margin({ left: 8 })
          .onClick(() => {
            this.onDetailClick();
          })
      }
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  BuildMainWeatherInfo() {
    Row() {
      // 左侧：天气图标和温度
      Column() {
        // 天气图标
        Text(WeatherUtils.getWeatherIcon(this.weather))
          .fontSize(48)
          .margin({ bottom: 8 })

        // 温度显示
        Row() {
          Text(this.getFormattedTemperature(this.temperature))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTextColor('primary'))

          // 舒适度标签
          Text(this.getComfortLevel())
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getComfortColor())
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .borderRadius(10)
            .margin({ left: 8 })
        }
        .alignItems(VerticalAlign.Center)

        // 天气描述
        Text(this.weather)
          .fontSize(16)
          .fontColor(this.getTextColor('primary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 24 })

      // 右侧：详细天气信息
      Column() {
        // 城市名称
        Text(this.city)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTextColor('primary'))
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        // 主要参数
        Column({ space: 8 }) {
          this.BuildInfoItem('💧', `湿度 ${this.humidity}%`, '')
          this.BuildInfoItem('💨', `风速 ${this.windSpeed} km/h`, this.getWindDirectionText())
          this.BuildInfoItem('🌡️', `体感 ${this.getFeelsLikeTemperature()}`, '')
          this.BuildInfoItem('🌅', `日出 ${this.sunrise}`, `日落 ${this.sunset}`)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: 20 })
  }

  @Builder
  BuildInfoItem(icon: string, primaryText: string, secondaryText: string) {
    Row() {
      Text(icon)
        .fontSize(14)
        .width(20)

      Column() {
        Text(primaryText)
          .fontSize(12)
          .fontColor(this.getTextColor('primary'))
          .alignSelf(ItemAlign.Start)

        if (secondaryText) {
          Text(secondaryText)
            .fontSize(10)
            .fontColor(this.getTextColor('secondary'))
            .alignSelf(ItemAlign.Start)
            .margin({ top: 1 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 8 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  BuildEnvironmentGrid() {
    Grid() {
      GridItem() {
        this.BuildGridItem('空气质量', this.getAQIText(), this.getAQIColor(), '🌬️')
      }

      GridItem() {
        this.BuildGridItem('气压', `${this.pressure} hPa`, '#666666', '📊')
      }

      GridItem() {
        this.BuildGridItem('能见度', `${this.visibilityDistance} km`, '#666666', '👁️')
      }

      GridItem() {
        this.BuildGridItem('紫外线', this.getUVIndexText(), this.getUVIndexColor(), '☀️')
      }
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(12)
    .rowsGap(12)
    .width('100%')
    .height(120)
    .margin({ bottom: 16 })
  }

  @Builder
  BuildGridItem(label: string, value: string, color: string, icon: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(12)
          .margin({ right: 4 })

        Text(label)
          .fontSize(10)
          .fontColor(this.getTextColor('secondary'))
      }

      Text(value)
        .fontSize(14)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getGridItemBackgroundColor())
    .borderRadius(8)
    .padding(8)
  }

  @Builder
  BuildFooter() {
    Row() {
      Text(`数据更新时间: ${this.updateTime}`)
        .fontSize(10)
        .fontColor(this.getTextColor('secondary'))

      Blank()
      // 温度单位指示
      Text(`单位: ${this.getUnitDisplayName()}`)
        .fontSize(10)
        .fontColor(this.getTextColor('secondary'))
    }
    .width('100%')
  }

  // ========== 工具方法 ==========

  private getFormattedTemperature(temp: number): string {
    if (this.currentTemperatureUnit === this.temperatureUnits.FAHRENHEIT) {
      const fahrenheit = (temp * 9 / 5) + 32;
      return `${Math.round(fahrenheit)}°F`;
    }
    return `${Math.round(temp)}°C`;
  }

  private getUnitDisplayName(): string {
    return this.currentTemperatureUnit === this.temperatureUnits.CELSIUS ? '摄氏度' : '华氏度';
  }

  private getFeelsLikeTemperature(): string {
    // 简化的体感温度计算（实际应用中可以根据湿度、风速等计算）
    const feelsLike = this.temperature + (this.humidity > 80 ? 2 : 0) + (this.windSpeed > 20 ? -1 : 0);
    return this.getFormattedTemperature(feelsLike);
  }

  private getComfortLevel(): string {
    return WeatherUtils.getComfortLevel(this.temperature);
  }

  private getComfortColor(): string {
    return WeatherUtils.getComfortColor(this.temperature);
  }
  private getWindDirectionText(): string {
    return WeatherUtils.getWindDirectionFromDegrees(this.windDirection);
  }

  private getAQIText(): string {
    return WeatherUtils.getAQIDescription(this.aqi);
  }

  private getAQIColor(): string {
    return WeatherUtils.getAQIColor(this.aqi);
  }

  private getUVIndexText(): string {
    if (this.uvIndex <= 2) {
      return '弱';
    }
    if (this.uvIndex <= 5) {
      return '中等';
    }
    if (this.uvIndex <= 7) {
      return '强';
    }
    if (this.uvIndex <= 10) {
      return '很强';
    }
    return '极强';
  }

  private getUVIndexColor(): string {
    if (this.uvIndex <= 2) {
      return '#4CAF50';
    } // 绿色
    if (this.uvIndex <= 5) {
      return '#FFC107';
    } // 黄色
    if (this.uvIndex <= 7) {
      return '#FF9800';
    } // 橙色
    if (this.uvIndex <= 10) {
      return '#F44336';
    } // 红色
    return '#9C27B0'; // 紫色
  }

  private getCardBackgroundColor(): string {
    // 根据天气类型返回不同的背景色
    const isDaytime = this.isDaytime();
    const baseColor = WeatherUtils.getWeatherBackground(this.weather);

    if (!isDaytime) {
      // 夜间模式稍微加深颜色
      return this.adjustColorBrightness(baseColor, -0.1);
    }
    return baseColor;
  }

  private getTextColor(type: 'primary' | 'secondary'): string {
    const baseColor = this.isBrightBackground() ? '#2D4D2D' : '#FFFFFF';
    return type === 'primary' ? baseColor : this.adjustColorBrightness(baseColor, 0.3);
  }

  private getButtonBackgroundColor(): string {
    return this.isBrightBackground() ? 'rgba(255,255,255,0.8)' : 'rgba(255,255,255,0.2)';
  }

  private getGridItemBackgroundColor(): string {
    return this.isBrightBackground() ? 'rgba(255,255,255,0.6)' : 'rgba(255,255,255,0.1)';
  }

  private isBrightBackground(): boolean {
    const background = this.getCardBackgroundColor();
    // 简单判断颜色亮度（简化版）
    return !background.includes('2D4D2D') && !background.includes('1A237E');
  }

  private adjustColorBrightness(color: string, factor: number): string {
    // 简化的颜色亮度调整（实际应用中可以使用更精确的颜色处理）
    if (color.startsWith('#')) {
      return color; // 保持原色
    }
    return factor > 0 ? this.lightenColor(color) : this.darkenColor(color);
  }

  private lightenColor(color: string): string {
    // 简化处理，实际应该解析颜色值
    if (color === '#E8F5E8') {
      return '#F0F9F0';
    }
    if (color === '#FFF9C4') {
      return '#FFFDE7';
    }
    if (color === '#E3F2FD') {
      return '#E1F5FE';
    }
    return color;
  }

  private darkenColor(color: string): string {
    // 简化处理
    if (color === '#E8F5E8') {
      return '#D0EBD0';
    }
    if (color === '#FFF9C4') {
      return '#FFF59D';
    }
    if (color === '#E3F2FD') {
      return '#BBDEFB';
    }
    return color;
  }

  private isDaytime(): boolean {
    const now = new Date();
    const currentTime = now.getHours() * 60 + now.getMinutes();
    const sunriseTime = this.timeToMinutes(this.sunrise);
    const sunsetTime = this.timeToMinutes(this.sunset);

    return currentTime >= sunriseTime && currentTime < sunsetTime;
  }

  private timeToMinutes(timeStr: string): number {
    const parts = timeStr.split(':').map(Number);
    const hours = parts[0];
    const minutes = parts[1];
    return hours * 60 + minutes;
  }

  private getCurrentTime(): string {
    return WeatherUtils.formatTime(Date.now());
  }

  private getLastUpdateText(): string {
    const now = new Date();
    const updateTime = new Date(this.updateTime);
    const diffMinutes = Math.floor((now.getTime() - updateTime.getTime()) / (1000 * 60));

    if (diffMinutes < 1) {
      return '刚刚更新';
    }
    if (diffMinutes < 60) {
      return `${diffMinutes}分钟前更新`;
    }
    if (diffMinutes < 1440) {
      return `${Math.floor(diffMinutes / 60)}小时前更新`;
    }
    return '一天前更新';
  }

  private onRefreshClick(): void {
    // 刷新天气数据
    this.updateTime = this.getCurrentTime();
    console.log('刷新天气数据');

    // 这里可以触发数据刷新逻辑
    // this.refreshWeatherData();
  }
}

// 组件使用示例
/*
WeatherCard({
  city: '北京',
  temperature: 26,
  weather: '晴',
  humidity: 65,
  windSpeed: 12,
  aqi: 45,
  pressure: 1013,
  visibilityDistance: 10,
  uvIndex: 5,
  sunrise: '06:30',
  sunset: '18:45',
  onDetailClick: () => {
    // 处理详情点击
  }
})
*/