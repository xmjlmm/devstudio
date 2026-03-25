// entry/src/main/ets/components/StatCard.ets

@Component
export struct StatCard {
  title: string = '';
  value: string = '';
  color: string = '#3498DB';

  build() {
    Column({ space: 8 }) {
      Text(this.value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
      Text(this.title)
        .fontSize(12)
        .fontColor('#7F8C8D')
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 2, color: '#000000', offsetX: 0, offsetY: 1 })
    .width(120)
    .height(80)
  }
}