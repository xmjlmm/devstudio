import { ProductType, ProductStatus, EnumUtils } from '../model/Enums';
import { AppStorage } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 产品项参数接口
export interface ProductItemParams {
  productName: string;
  productType: string;
  productStatus: string;
  productCount: number;
  plantingDate?: string;
  currentStage?: string;
  progress?: number;
  imageUrl?: string;
  onItemClick?: () => void;
  onActionClick?: () => void;
}

@Component
export struct ProductItem {
  // 使用@Prop装饰器接收外部参数，支持响应式更新
  @Prop productName: string = '';
  @Prop productType: string = '';
  @Prop productStatus: string = '';
  @Prop productCount: number = 0;
  @Prop plantingDate: string = '';
  @Prop currentStage: string = '';
  @Prop progress: number = 0;
  @Prop imageUrl: string = '';

  // 事件回调
  private onItemClick: () => void = () => {};
  private onActionClick: () => void = () => {};

  // 监听数据变化，当外部数据更新时自动刷新组件
  @StorageLink('productDataChanged') productDataChanged: number = 0;

  // 组件初始化
  aboutToAppear() {
    hilog.info(0x0000, 'ProductItem', `组件初始化: ${this.productName}`);
  }

  // 监听数据变化
  @Watch('productDataChanged')
  onProductDataChanged() {
    hilog.info(0x0000, 'ProductItem', `产品数据变化，重新渲染: ${this.productName}`);
    // 这里可以添加特定的重新渲染逻辑
  }

  build() {
    Row() {
      // 左侧图标区域
      this.BuildIconSection()

      // 中间信息区域
      this.BuildInfoSection()

      // 右侧操作区域
      this.BuildActionSection()
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
  BuildIconSection() {
    Column() {
      Text(this.getProductIcon())
        .fontSize(20)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.getTypeColor())
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ right: 12 })
    }
  }

  @Builder
  BuildInfoSection() {
    Column() {
      // 产品名称和数量
      Row() {
        Text(this.productName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2D4D2D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text(this.productCount > 0 ? this.productCount.toString() : '')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2E8B57')
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 4 })

      // 类型和状态
      Text(`${this.getTypeDisplayName()} | ${this.getStatusDisplayName()}`)
        .fontSize(12)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 6 })

      // 生长进度（如果可用）
      if (this.progress > 0) {
        this.BuildProgressBar()
      }

      // 种植日期和当前阶段
      if (this.plantingDate || this.currentStage) {
        Row() {
          if (this.plantingDate) {
            Text(`种植: ${this.formatDate(this.plantingDate)}`)
              .fontSize(10)
              .fontColor('#888888')
          }

          if (this.currentStage) {
            Text(`阶段: ${this.currentStage}`)
              .fontSize(10)
              .fontColor('#2E8B57')
              .margin({ left: 12 })
          }
        }
        .alignSelf(ItemAlign.Start)
        .margin({ top: 4 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }

  @Builder
  BuildProgressBar() {
    Column() {
      Row() {
        Text('生长进度')
          .fontSize(10)
          .fontColor('#666666')

        Blank()

        Text(`${this.progress}%`)
          .fontSize(10)
          .fontColor('#2E8B57')
      }
      .width('100%')
      .margin({ bottom: 4 })

      // 进度条
      Stack() {
        // 背景轨道
        Rect()
          .width('100%')
          .height(4)
          .backgroundColor('#E8E8E8')
          .borderRadius(2)

        // 进度填充
        Rect()
          .width(`${this.progress}%`)
          .height(4)
          .backgroundColor(this.getProgressColor())
          .borderRadius(2)
      }
      .width('100%')
      .height(4)
    }
    .width('100%')
    .margin({ top: 6 })
  }

  @Builder
  BuildActionSection() {
    Column() {
      // 状态标签
      Text(this.getStatusDisplay())
        .fontSize(10)
        .fontColor(this.getStatusColor())
        .padding({
          left: 6,
          right: 6,
          top: 3,
          bottom: 3
        })
        .backgroundColor(this.getStatusBgColor())
        .borderRadius(4)
        .margin({ bottom: 8 })

      // 操作按钮
      Text('管理 ›')
        .fontSize(10)
        .fontColor('#2E8B57')
        .onClick((event: ClickEvent) => {
          event.stopPropagation(); // 阻止事件冒泡
          this.onActionClick();
        })
    }
    .alignItems(HorizontalAlign.End)
  }

  // 设置组件参数
  setParams(params: ProductItemParams) {
    this.productName = params.productName || '';
    this.productType = params.productType || '';
    this.productStatus = params.productStatus || '';
    this.productCount = params.productCount || 0;
    this.plantingDate = params.plantingDate || '';
    this.currentStage = params.currentStage || '';
    this.progress = params.progress || 0;
    this.imageUrl = params.imageUrl || '';
    this.onItemClick = params.onItemClick || (() => {});
    this.onActionClick = params.onActionClick || (() => {});
  }

  // 获取产品图标
  private getProductIcon(): string {
    const iconMap: Record<string, string> = {
      [ProductType.VEGETABLE]: '🥦',
      [ProductType.FRUIT]: '🍎',
      [ProductType.GRAIN]: '🌾',
      [ProductType.ROOT]: '🥔',
      [ProductType.HERB]: '🌿',
      [ProductType.FLOWER]: '🌸'
    };
    return iconMap[this.productType] || '🌱';
  }

  // 获取类型颜色
  private getTypeColor(): ResourceColor {
    const colorMap: Record<string, ResourceColor> = {
      [ProductType.VEGETABLE]: '#2E8B57',
      [ProductType.FRUIT]: '#FF6B6B',
      [ProductType.GRAIN]: '#FFA500',
      [ProductType.ROOT]: '#8B4513',
      [ProductType.HERB]: '#4CAF50',
      [ProductType.FLOWER]: '#E91E63'
    };
    return colorMap[this.productType] || '#666666';
  }

  // 获取类型显示名称
  private getTypeDisplayName(): string {
    try {
      return EnumUtils.getProductTypeDisplayName(this.productType as ProductType);
    } catch (error) {
      return this.productType;
    }
  }

  // 获取状态显示名称
  private getStatusDisplayName(): string {
    try {
      return EnumUtils.getProductStatusDisplayName(this.productStatus as ProductStatus);
    } catch (error) {
      return this.getStatusDisplay();
    }
  }

  // 获取进度颜色
  private getProgressColor(): ResourceColor {
    if (this.progress < 30) {
      return '#FF6B6B';
    }
    if (this.progress < 70) {
      return '#FFA500';
    }
    return '#4CAF50';
  }

  // 获取状态显示文本
  private getStatusDisplay(): string {
    const statusMap: Record<string, string> = {
      [ProductStatus.GROWING]: '生长中',
      [ProductStatus.HARVESTABLE]: '可收获',
      [ProductStatus.HARVESTED]: '已收获',
      [ProductStatus.DORMANT]: '休眠期'
    };
    return statusMap[this.productStatus] || this.productStatus;
  }

  // 获取状态颜色
  private getStatusColor(): ResourceColor {
    const colorMap: Record<string, ResourceColor> = {
      [ProductStatus.GROWING]: '#4CAF50',
      [ProductStatus.HARVESTABLE]: '#FFA500',
      [ProductStatus.HARVESTED]: '#666666',
      [ProductStatus.DORMANT]: '#999999'
    };
    return colorMap[this.productStatus] || '#666666';
  }

  // 获取状态背景色
  private getStatusBgColor(): ResourceColor {
    const colorMap: Record<string, ResourceColor> = {
      [ProductStatus.GROWING]: '#E8F5E8',
      [ProductStatus.HARVESTABLE]: '#FFF5E6',
      [ProductStatus.HARVESTED]: '#F5F5F5',
      [ProductStatus.DORMANT]: '#F0F0F0'
    };
    return colorMap[this.productStatus] || '#F5F5F5';
  }

  // 格式化日期
  private formatDate(dateString: string): string {
    if (!dateString) {
      return '';
    }
    try {
      const date = new Date(dateString);
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    } catch (e) {
      return dateString;
    }
  }

  // 更新产品信息
  updateProductInfo(updates: Partial<ProductItemParams>) {
    if (updates.productName !== undefined) {
      this.productName = updates.productName;
    }
    if (updates.productType !== undefined) {
      this.productType = updates.productType;
    }
    if (updates.productStatus !== undefined) {
      this.productStatus = updates.productStatus;
    }
    if (updates.productCount !== undefined) {
      this.productCount = updates.productCount;
    }
    if (updates.plantingDate !== undefined) {
      this.plantingDate = updates.plantingDate;
    }
    if (updates.currentStage !== undefined) {
      this.currentStage = updates.currentStage;
    }
    if (updates.progress !== undefined) {
      this.progress = updates.progress;
    }
    if (updates.imageUrl !== undefined) {
      this.imageUrl = updates.imageUrl;
    }
    if (updates.onItemClick !== undefined) {
      this.onItemClick = updates.onItemClick;
    }
    if (updates.onActionClick !== undefined) {
      this.onActionClick = updates.onActionClick;
    }

    hilog.info(0x0000, 'ProductItem', `产品信息已更新: ${this.productName}`);
  }

  // 重置组件状态
  reset() {
    this.productName = '';
    this.productType = '';
    this.productStatus = '';
    this.productCount = 0;
    this.plantingDate = '';
    this.currentStage = '';
    this.progress = 0;
    this.imageUrl = '';
    this.onItemClick = () => {};
    this.onActionClick = () => {};
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
