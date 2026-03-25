@Component
export struct FarmCard {
  private farmName: string = '阳光农场';
  private farmType: string = '有机种植';
  private status: string = '运营中';
  private temperature: number = 26;
  private humidity: number = 65;
  private productCount: number = 15;
  private growingCount: number = 8;
  private onCardClick: () => void = () => {
  };

  build() {
    Column() {
      // 农场基本信息行
      Row() {
        // 农场图标和名称
        Column() {
          Text('🌾')
            .fontSize(24)
            .margin({ bottom: 8 })

          Text(this.farmName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2D4D2D')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 运营状态
        Column() {
          Text(this.status)
            .fontSize(12)
            .fontColor('#4CAF50')
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .backgroundColor('#E8F5E8')
            .borderRadius(6)

          Text(this.farmType)
            .fontSize(10)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.End)
      }

      Divider()
        .strokeWidth(1)
        .color('#E8E8E8')
        .margin({ top: 12, bottom: 12 })

      // 环境数据
      Row() {
        Column() {
          Text('🌡️')
            .fontSize(16)
            .margin({ bottom: 4 })
          Text(`${this.temperature}°C`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D4D2D')
          Text('温度')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column() {
          Text('💧')
            .fontSize(16)
            .margin({ bottom: 4 })
          Text(`${this.humidity}%`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D4D2D')
          Text('湿度')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column() {
          Text('📦')
            .fontSize(16)
            .margin({ bottom: 4 })
          Text(this.productCount.toString())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D4D2D')
          Text('在售')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column() {
          Text('🌱')
            .fontSize(16)
            .margin({ bottom: 4 })
          Text(this.growingCount.toString())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D4D2D')
          Text('生长中')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)
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
    .onClick(() => {
      this.onCardClick();
    })
  }
}