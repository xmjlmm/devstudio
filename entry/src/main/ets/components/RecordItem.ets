@Component
export struct RecordItem {
  // 使用@Prop装饰器使属性可外部传递
  @Prop recordType: string = '浇水';
  @Prop cropName: string = '西红柿';
  @Prop recordDate: string = '2024-01-20';
  @Prop notes: string = '完成自动浇水，土壤湿度适宜';
  @Prop images: string[] = [];
  @Prop temperature: number = 26;
  @Prop humidity: number = 65;
  @Prop onItemClick: () => void = () => {};
  @Prop onEditClick: () => void = () => {};

  build() {
    Column() {
      // 记录头部
      Row() {
        // 类型图标
        Column() {
          Text(this.getRecordIcon())
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .width(32)
        .height(32)
        .backgroundColor(this.getTypeColor())
        .borderRadius(6)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        // 主要信息
        Column() {
          Text(this.recordType)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2D4D2D')
            .alignSelf(ItemAlign.Start)

          Text(this.cropName)
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 时间和操作
        Column() {
          Text(this.formatDate(this.recordDate))
            .fontSize(10)
            .fontColor('#999999')
            .alignSelf(ItemAlign.End)

          Button('编辑')
            .fontSize(10)
            .fontColor('#2E8B57')
            .backgroundColor('transparent')
            .borderWidth(0)
            .onClick(() => {
              this.onEditClick();
            })
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // 记录内容
      if (this.notes) {
        Text(this.notes)
          .fontSize(12)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
          .alignSelf(ItemAlign.Start)
      }

      // 环境数据和图片预览
      Row() {
        // 环境数据
        if (this.temperature > 0 || this.humidity > 0) {
          Row() {
            if (this.temperature > 0) {
              Text(`🌡️ ${this.temperature}°C`)
                .fontSize(10)
                .fontColor('#666666')
                .margin({ right: 12 })
            }

            if (this.humidity > 0) {
              Text(`💧 ${this.humidity}%`)
                .fontSize(10)
                .fontColor('#666666')
            }
          }
          .layoutWeight(1)
        }

        // 图片预览
        if (this.images.length > 0) {
          this.BuildImagePreview()
        }
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 2,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => {
      this.onItemClick();
    })
  }

  @Builder
  BuildImagePreview() {
    Row() {
      Text('🖼️')
        .fontSize(12)
        .margin({ right: 6 })

      Text(`${this.images.length}张图片`)
        .fontSize(10)
        .fontColor('#666666')
    }
    .alignSelf(ItemAlign.End)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('#F5F5F5')
    .borderRadius(4)
  }

  private getRecordIcon(): string {
    const iconMap: Record<string, string> = {
      '浇水': '💧',
      '施肥': '🌿',
      '播种': '🌱',
      '收获': '✂️',
      '观察': '👀',
      '除虫': '🐛'
    };
    return iconMap[this.recordType] || '📝';
  }

  private getTypeColor(): ResourceColor {
    const colorMap: Record<string, ResourceColor> = {
      '浇水': '#2196F3',
      '施肥': '#4CAF50',
      '播种': '#FFA500',
      '收获': '#FF6B6B',
      '观察': '#9C27B0',
      '除虫': '#795548'
    };
    return colorMap[this.recordType] || '#666666';
  }

  private formatDate(dateString: string): string {
    if (!dateString) return '';

    try {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now.getTime() - date.getTime();
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

      if (diffDays === 0) return '今天';
      if (diffDays === 1) return '昨天';
      if (diffDays < 7) return `${diffDays}天前`;

      return `${date.getMonth() + 1}月${date.getDate()}日`;
    } catch (e) {
      return dateString;
    }
  }
}

// 使用示例
// @Component
// struct ExampleUsage {
//   @State productData: ProductItemParams = {
//     productName: '西红柿',
//     productType: ProductType.VEGETABLE,
//     productStatus: ProductStatus.GROWING,
//     productCount: 10,
//     plantingDate: '2024-01-15',
//     currentStage: '开花期',
//     progress: 60,
//     onItemClick: () => {
//       console.log('点击了产品项');
//     },
//     onActionClick: () => {
//       console.log('点击了管理按钮');
//     }
//   };

//   build() {
//     Column() {
//       ProductItem({
//         productName: this.productData.productName,
//         productType: this.productData.productType,
//         productStatus: this.productData.productStatus,
//         productCount: this.productData.productCount,
//         plantingDate: this.productData.plantingDate,
//         currentStage: this.productData.currentStage,
//         progress: this.productData.progress,
//         onItemClick: this.productData.onItemClick,
//         onActionClick: this.productData.onActionClick
//       })
//     }
//   }
// }
