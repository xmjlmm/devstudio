// entry/src/main/ets/components/WeatherCard.ets
import { WeatherData } from '../model/DataModel';

@Component
export struct WeatherCard {
  @Link weatherData: WeatherData;
  @State isRefreshing: boolean = false;

  build() {
    Column({ space: 12 }) {
      // 标题和刷新按钮
      Row() {
        Text('天气信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C3E50')
        Blank()
        Button('刷新', { type: ButtonType.Normal })
          .fontSize(12)
          .onClick(() => this.refreshWeather())
      }
      .width('100%')

      // 天气内容
      Row({ space: 20 }) {
        Column({ space: 4 }) {
          Text(`${this.weatherData.temperature}°C`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E74C3C')
          Text(this.weatherData.condition)
            .fontSize(14)
            .fontColor('#7F8C8D')
        }

        Column({ space: 4 }) {
          Text(`湿度: ${this.weatherData.humidity}%`)
            .fontSize(12)
            .fontColor('#7F8C8D')
          Text(`风速: ${this.weatherData.windSpeed}m/s`)
            .fontSize(12)
            .fontColor('#7F8C8D')
        }
      }
      .width('100%')
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 2, color: '#000000', offsetX: 0, offsetY: 1 })
  }

  private refreshWeather(): void {
    this.isRefreshing = true;
    // 模拟天气数据刷新
    setTimeout(() => {
      this.weatherData.temperature = 20 + Math.floor(Math.random() * 15);
      this.weatherData.humidity = 40 + Math.floor(Math.random() * 40);
      this.weatherData.windSpeed = 1 + Math.floor(Math.random() * 10);
      this.isRefreshing = false;
    }, 1000);
  }
}