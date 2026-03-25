import { FarmDatabase, ProductFilter } from '../database/FarmDatabase';
import { FarmProduct, GrowthRecord, ProductStatistics } from '../model/DataModels';
import { ProductType, ProductStatus, RecordType, EnumUtils } from '../model/Enums';
import router from '@ohos.router';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { promptAction, AppStorageV2 } from '@kit.ArkUI';

interface OptionItem {
  value: string;
  label: string;
}

@Entry
@Component
export struct RecordPage {
  // 使用@StorageLink监听数据变化
  @StorageLink('productDataChanged') productDataChanged: number = 0;
  @StorageLink('recordDataChanged') recordDataChanged: number = 0;
  @StorageLink('statisticsDataChanged') statisticsDataChanged: number = 0;
  // 关键修复：添加明确的同步状态变量
  @State productList: FarmProduct[] = [];
  @State recordList: GrowthRecord[] = [];
  @State totalRecords: number = 0; // 修复：明确的记录总数状态
  @State totalProducts: number = 0; // 修复：明确的产品总数状态
  @State growingCount: number = 0; // 修复：明确的生长中数量
  @State harvestableCount: number = 0; // 修复：明确的可收获数量
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  @State selectedType: string = 'all';
  @State selectedStatus: string = 'all';
  @State statistics: ProductStatistics = new ProductStatistics();
  @State showRefreshButton: boolean = true;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear() {
    this.loadData();
  }

  // 监听数据变化 - 通过@StorageLink自动监听AppStorage变化
  // @StorageLink已经具备监听功能，无需额外使用@Watch
  async loadData() {
    this.isLoading = true;
    try {
      // 并行加载所有数据
      const results = await Promise.all([
        FarmDatabase.getAllProducts(),
        FarmDatabase.getAllGrowthRecords(),
        FarmDatabase.getProductStatistics()
      ]);

      this.productList = results[0];
      this.recordList = results[1];
      this.statistics = results[2] as ProductStatistics;
      // 关键修复：同步设置所有统计数字，避免异步问题
      this.totalProducts = this.productList.length;
      this.totalRecords = this.recordList.length;
      this.growingCount = this.calculateGrowingCount(this.productList);
      this.harvestableCount = this.calculateHarvestableCount(this.productList);

      hilog.info(0x0000, 'RecordPage',
        `数据加载完成: ${this.productList.length}个产品, ${this.recordList.length}条记录`);
    } catch (error) {
      hilog.error(0x0000, 'RecordPage', `数据加载失败: ${JSON.stringify(error)}`);
      this.showToast('数据加载失败');

      // 修复：设置默认值，避免显示异常
      this.totalProducts = 0;
      this.totalRecords = 0;
      this.growingCount = 0;
      this.harvestableCount = 0;
    } finally {
      this.isLoading = false;
    }
  }

  // 手动刷新数据
  async refreshData() {
    this.isLoading = true;
    try {
      await this.loadData();
      this.showToast('数据已刷新');
    } catch (error) {
      hilog.error(0x0000, 'RecordPage', `刷新数据失败: ${JSON.stringify(error)}`);
      this.showToast('刷新失败');
    }
  }

  // 加载统计信息
  async loadStatistics() {
    try {
      this.statistics = await FarmDatabase.getProductStatistics();
      hilog.info(0x0000, 'RecordPage', '统计信息已更新');
    } catch (error) {
      hilog.error(0x0000, 'RecordPage', `加载统计信息失败: ${JSON.stringify(error)}`);
    }
  }

  // 计算生长中数量
  private calculateGrowingCount(products: FarmProduct[]): number {
    return products.filter(p => p.status === ProductStatus.GROWING).length;
  }

  // 计算可收获数量
  private calculateHarvestableCount(products: FarmProduct[]): number {
    return products.filter(p => p.status === ProductStatus.HARVESTABLE).length;
  }

  // 显示Toast
  private showToast(message: string) {
    try {
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      hilog.error(0x0000, 'RecordPage', `显示Toast失败: ${JSON.stringify(error)}`);
    }
  }

  build() {
    Column() {
      // 状态栏
      this.BuildStatusBar()

      // 主内容区域
      Column() {
        // 头部信息
        this.BuildHeader()

        // 统计信息卡片
        this.BuildStatisticsCard()

        // 生长记录标题区域
        this.BuildRecordTitle()

        // 内容区域 - 关键修复：确保正确的布局结构
        if (this.isLoading) {
          this.BuildLoadingState()
        } else if (this.recordList.length === 0) {
          this.BuildEmptyState()
        } else {
          this.BuildContent()
        }
      }
      .layoutWeight(1) // 关键修复：确保内容区域可以扩展
      .width('100%')
    }
    .width('100%')
    .height('100%') // 关键修复：设置根容器高度
    .backgroundColor('#F8FBF8')
  }

  // 构建状态栏
  @Builder
  BuildStatusBar() {
    Row() {
      Text(this.getCurrentTime())
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2D4D2D')

      Blank()

      Text('已同步')
        .fontSize(12)
        .fontColor('#4CAF50')
        .margin({ right: 8 })

      Text('100%')
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
    .height(40) // 固定高度
  }

  // 构建头部信息
  @Builder
  BuildHeader() {
    Column() {
      Row() {
        Text('智慧农场助手')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D4D2D')
          .layoutWeight(1)

        Text(this.getCurrentTime())
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text('您好，农场管理员')
        .fontSize(16)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .height(80) // 固定高度
  }

  // 构建统计信息卡片
  @Builder
  BuildStatisticsCard() {
    Column() {
      Row() {
        Column() {
          Text(this.totalProducts.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2E8B57')
          Text('总产品数')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column() {
          Text(this.growingCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2196F3')
          Text('生长中')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column() {
          Text(this.harvestableCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFA500')
          Text('可收获')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)

        Column() {
          Text(this.totalRecords.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9C27B0')
          Text('总记录')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
      }
      .width('100%')
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
    .margin({ left: 16, right: 16, bottom: 16 })
    .height(100) // 固定高度
  }

  // 构建记录标题区域
  @Builder
  BuildRecordTitle() {
    Row() {
      Text('生长记录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .layoutWeight(1)

      Text(`共 ${this.totalRecords} 条记录`)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ right: 12 })

      Button('刷新数据')
        .fontSize(12)
        .fontColor('#2E8B57')
        .backgroundColor('#E8F5E8')
        .height(32)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.refreshData();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ bottom: 12 })
    .height(40) // 固定高度
  }

  // 构建加载状态
  @Builder
  BuildLoadingState() {
    Column() {
      Progress({ value: 0 })
        .width(40)
        .height(40)
        .color('#2E8B57')
        .margin({ bottom: 16 })

      Text('加载中...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }

  // 构建空状态
  @Builder
  BuildEmptyState() {
    Column() {
      Text('📊')
        .fontSize(64)
        .fontColor('#CCCCCC')
        .margin({ bottom: 16 })

      Text('暂无生长记录')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      Text('记录由产品管理页面添加和维护')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ bottom: 16 })

      Button('前往产品管理')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#2E8B57')
        .height(44)
        .padding({ left: 32, right: 32 })
        .onClick(() => {
          this.navigateToProductPage();
        })
        .margin({ bottom: 8 })

      Button('手动同步数据')
        .fontSize(12)
        .fontColor('#2E8B57')
        .backgroundColor('transparent')
        .height(36)
        .onClick(() => {
          this.manualSyncData();
        })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 构建内容区域 - 关键修复：重新设计滚动结构
  @Builder
  BuildContent() {
    Column() {
      // 关键修复：使用Scroll组件并正确配置滚动属性
      Scroll() {
        Column() {
          ForEach(this.recordList, (record: GrowthRecord, index: number) => {
            this.BuildRecordItem(record, index)
          })
        }
        .width('100%')
        .padding(16)
      }
      // 关键修复：配置滚动属性
      .scrollable(ScrollDirection.Vertical) // 明确设置垂直滚动方向
      .scrollBar(BarState.Auto) // 自动显示滚动条
      .edgeEffect(EdgeEffect.Spring) // 添加边缘效果
      .nestedScroll({
        // 关键修复：配置嵌套滚动以防止冲突 [2](@ref)
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
    .width('100%')
    .height('100%') // 关键修复：设置高度为100%
    .alignItems(HorizontalAlign.Center)
  }

  // 构建记录项 - 优化布局避免高度限制
  @Builder
  BuildRecordItem(record: GrowthRecord, index: number) {
    Column() {
      // 记录头部信息
      Row() {
        // 记录类型图标
        Column() {
          Text(this.getRecordIcon(record.recordType))
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .backgroundColor(this.getRecordColor(record.recordType))
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 12 })

        // 主要信息
        Column() {
          Row() {
            Text(record.productName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2D4D2D')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text(this.getRecordTypeDisplay(record.recordType))
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor(this.getRecordColor(record.recordType))
              .padding({
                left: 8,
                right: 8,
                top: 2,
                bottom: 2
              })
              .borderRadius(10)
          }
          .width('100%')
          .margin({ bottom: 4 })

          Text(`${this.formatDate(record.recordDate)} · ${record.stage}`)
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 记录详情
      Column() {
        // 环境数据
        Row() {
          if (record.temperature > 0) {
            Text(`🌡️ ${record.temperature}°C`)
              .fontSize(12)
              .fontColor('#FF6B6B')
              .margin({ right: 12 })
          }
          if (record.humidity > 0) {
            Text(`💧 ${record.humidity}%`)
              .fontSize(12)
              .fontColor('#2196F3')
              .margin({ right: 12 })
          }

          if (record.height > 0) {
            Text(`📏 ${record.height}cm`)
              .fontSize(12)
              .fontColor('#4CAF50')
          }

          Blank()

          Text(this.formatTime(record.createdAt))
            .fontSize(10)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 备注信息
        if (record.notes && record.notes.trim() !== '') {
          Text(record.notes)
            .fontSize(13)
            .fontColor('#666666')
            .textAlign(TextAlign.Start)
            .lineHeight(18)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .padding(8)
            .backgroundColor('#F8F9FA')
            .borderRadius(6)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('95%') // 关键修复：设置95%宽度，留出边距
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 2,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
    .margin({ bottom: 12 })
    .onClick(() => {
      this.viewRecordDetails(record);
    })
  }

  // 查看记录详情
  private viewRecordDetails(record: GrowthRecord): void {
    hilog.info(0x0000, 'RecordPage', `查看记录详情: ${record.productName} - ${record.recordType}`);

    router.pushUrl({
      url: 'pages/RecordDetail',
      params: {
        recordId: record.id.toString(),
        productName: record.productName,
        recordType: record.recordType,
        recordDate: record.recordDate,
        stage: record.stage,
        temperature: record.temperature?.toString() || '0',
        humidity: record.humidity?.toString() || '0',
        notes: record.notes || ''
      }
    }).then(() => {
      hilog.info(0x0000, 'RecordPage', '跳转到记录详情页面成功');
    }).catch((error: Error) => {
      hilog.error(0x0000, 'RecordPage', `跳转失败: ${JSON.stringify(error)}`);
    });
  }

  // 跳转到产品管理页面
  private navigateToProductPage(): void {
    router.pushUrl({
      url: 'pages/ProductPage'
    }).then(() => {
      hilog.info(0x0000, 'RecordPage', '跳转到产品管理页面成功');
    }).catch((error: Error) => {
      hilog.error(0x0000, 'RecordPage', `跳转失败: ${JSON.stringify(error)}`);
    });
  }

  // 手动同步数据
  private async manualSyncData(): Promise<void> {
    try {
      this.showToast('正在同步数据...');
      await this.loadData();
      this.showToast('数据同步完成');
    } catch (error) {
      hilog.error(0x0000, 'RecordPage', `手动同步数据失败: ${JSON.stringify(error)}`);
      this.showToast('同步失败');
    }
  }

  // 工具方法
  private getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }

  private getRecordIcon(recordType: string): string {
    const iconMap: Record<string, string> = {
      [RecordType.WATERING]: '💧',
      [RecordType.FERTILIZING]: '🌿',
      [RecordType.SOWING]: '🌱',
      [RecordType.HARVESTING]: '✂️',
      [RecordType.OBSERVATION]: '👀'
    };
    return iconMap[recordType] || '📝';
  }

  private getRecordColor(recordType: string): string {
    const colorMap: Record<string, string> = {
      [RecordType.WATERING]: '#2196F3',
      [RecordType.FERTILIZING]: '#4CAF50',
      [RecordType.SOWING]: '#FFA500',
      [RecordType.HARVESTING]: '#FF6B6B',
      [RecordType.OBSERVATION]: '#9C27B0'
    };
    return colorMap[recordType] || '#666666';
  }

  private getRecordTypeDisplay(recordType: string): string {
    const displayMap: Record<string, string> = {
      [RecordType.WATERING]: '浇水',
      [RecordType.FERTILIZING]: '施肥',
      [RecordType.SOWING]: '播种',
      [RecordType.HARVESTING]: '收获',
      [RecordType.OBSERVATION]: '观察'
    };
    return displayMap[recordType] || '记录';
  }

  private formatDate(dateString: string): string {
    try {
      const date = new Date(dateString);
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    } catch {
      return dateString;
    }
  }

  private formatTime(dateString: string): string {
    try {
      const date = new Date(dateString);
      return date.toLocaleTimeString('zh-CN', {
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return dateString;
    }
  }
}