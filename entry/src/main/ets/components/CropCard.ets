// entry/src/main/ets/components/CropCard.ets
import { Crop } from '../model/DataModel';

@Component
export struct CropCard {
  @Link crop: Crop;
  @State private isExpanded: boolean = false;

  build() {
    Column({ space: 8 }) {
      // 基础信息行
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.crop.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2C3E50')
          Text(`生长阶段: ${this.crop.growthStage}`)
            .fontSize(14)
            .fontColor('#7F8C8D')
        }
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text(`${this.crop.soilMoisture}%`)
            .fontSize(14)
            .fontColor(this.getMoistureColor())
          Text(`${this.crop.temperature}°C`)
            .fontSize(14)
            .fontColor(this.getTemperatureColor())
        }
      }
      .width('100%')

      // 可展开的详细信息
      if (this.isExpanded) {
        Column({ space: 8 }) {
          Divider().color('#ECF0F1').strokeWidth(1)
          Row() {
            Text('播种日期:')
              .fontSize(12)
              .fontColor('#7F8C8D')
              .layoutWeight(1)
            Text(this.crop.plantDate)
              .fontSize(12)
              .fontColor('#2C3E50')
          }
          Row() {
            Text('最后浇水:')
              .fontSize(12)
              .fontColor('#7F8C8D')
              .layoutWeight(1)
            Text(this.crop.lastWatering || '未记录')
              .fontSize(12)
              .fontColor('#2C3E50')
          }
          Button('标记浇水', { type: ButtonType.Normal })
            .width('100%')
            .margin({ top: 8 })
            .onClick(() => this.waterCrop())
        }
      }
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 2, color: '#000000', offsetX: 0, offsetY: 1 })
    .onClick(() => {
      this.isExpanded = !this.isExpanded;
    })
  }

  private waterCrop(): void {
    this.crop.lastWatering = new Date().toLocaleString();
    this.crop.soilMoisture = Math.min(100, this.crop.soilMoisture + 20);
  }

  private getMoistureColor(): ResourceColor {
    if (this.crop.soilMoisture < 30) return Color.Red;
    if (this.crop.soilMoisture < 60) return Color.Orange;
    return Color.Green;
  }

  private getTemperatureColor(): ResourceColor {
    if (this.crop.temperature < 15) return Color.Blue;
    if (this.crop.temperature > 35) return Color.Red;
    return Color.Green;
  }
}