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
export struct ProductPage {
  // 使用@StorageLink监听数据变化
  @StorageLink('productDataChanged') productDataChanged: number = 0;
  @StorageLink('recordDataChanged') recordDataChanged: number = 0;
  @StorageLink('statisticsDataChanged') statisticsDataChanged: number = 0;
  @State productList: FarmProduct[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  @State selectedType: string = 'all';
  @State selectedStatus: string = 'all';
  @State showAddDialog: boolean = false;
  @State statistics: ProductStatistics = new ProductStatistics();
  @State isEdit: boolean = false;
  @State isInsert: boolean = true;
  @State editIndex: number = -1;
  // 关键修复：添加明确的同步状态变量
  @State totalRecords: number = 0; // 修复：明确的记录总数状态
  @State totalProducts: number = 0; // 修复：明确的产品总数状态
  @State growingCount: number = 0; // 修复：明确的生长中数量
  @State harvestableCount: number = 0; // 修复：明确的可收获数量
  // 新产品表单数据
  @State newProduct: FarmProduct = new FarmProduct();
  // 删除列表
  @State deleteList: FarmProduct[] = [];
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // 筛选选项
  private typeOptions: Array<OptionItem> = [
    { value: 'all', label: '全部类型' },
    { value: ProductType.VEGETABLE, label: '蔬菜' },
    { value: ProductType.FRUIT, label: '水果' },
    { value: ProductType.GRAIN, label: '谷物' },
    { value: ProductType.ROOT, label: '根茎类' },
    { value: ProductType.HERB, label: '草本植物' },
    { value: ProductType.FLOWER, label: '花卉' }
  ];
  private statusOptions: Array<OptionItem> = [
    { value: 'all', label: '全部状态' },
    { value: ProductStatus.GROWING, label: '生长中' },
    { value: ProductStatus.HARVESTABLE, label: '可收获' },
    { value: ProductStatus.HARVESTED, label: '已收获' },
    { value: ProductStatus.DORMANT, label: '休眠期' }
  ];

  aboutToAppear() {
    this.loadProducts();
  }

  // 监听数据变化 - 通过@StorageLink自动监听AppStorage变化
  // 当productDataChanged或recordDataChanged变化时，会自动触发重新加载数据

  // 加载产品数据
  async loadProducts() {
    this.isLoading = true;
    try {
      const filter: ProductFilter = {
        type: this.selectedType !== 'all' ? this.selectedType : undefined,
        status: this.selectedStatus !== 'all' ? this.selectedStatus : undefined,
        searchKeyword: this.searchKeyword
      };
      // 并行加载所有数据
      const results = await Promise.all([
        FarmDatabase.getProductsByFilter(filter),
        FarmDatabase.getAllGrowthRecords(), // 关键修复：同步加载记录数据
        FarmDatabase.getProductStatistics()
      ]);
      const products = results[0];
      const records = results[1];
      const stats = results[2];

      this.productList = products;
      this.statistics = stats as ProductStatistics;

      // 关键修复：同步设置所有统计数字，避免异步问题
      this.totalProducts = products.length;
      this.totalRecords = records.length; // 直接使用同步的长度，避免Promise问题
      this.growingCount = this.calculateGrowingCount(products);
      this.harvestableCount = this.calculateHarvestableCount(products);

      hilog.info(0x0000, 'ProductPage',
        `加载完成: ${products.length}个产品, ${records.length}条记录`);
    } catch (error) {
      hilog.error(0x0000, 'ProductPage', `加载产品失败: ${JSON.stringify(error)}`);
      this.productList = [];
      this.statistics = new ProductStatistics();

      // 修复：设置默认值，避免显示异常
      this.totalProducts = 0;
      this.totalRecords = 0;
      this.growingCount = 0;
      this.harvestableCount = 0;
    } finally {
      this.isLoading = false;
    }
  }

  // 添加新产品
  async addProduct() {
    if (!this.newProduct.name.trim()) {
      this.showToast('产品名称不能为空');
      return;
    }

    try {
      // 设置默认值
      this.newProduct.plantingDate = new Date().toISOString().split('T')[0];
      this.newProduct.status = this.newProduct.status || ProductStatus.GROWING;
      this.newProduct.currentStage = this.newProduct.currentStage || '播种期';

      // 关键修复：使用自动创建记录的方法
      const productId = await FarmDatabase.addProductWithAutoRecord(this.newProduct);

      if (productId > 0) {
        hilog.info(0x0000, 'ProductPage', `产品添加成功，ID: ${productId}`);
        this.showAddDialog = false;
        this.resetNewProductForm();

        // 重新加载数据
        await this.loadProducts();
        this.showToast('产品添加成功，已创建生长记录');

        // 触发数据同步通知
        await this.triggerDataSync();
      } else {
        this.showToast('添加产品失败');
      }
    } catch (error) {
      hilog.error(0x0000, 'ProductPage', `添加产品失败: ${JSON.stringify(error)}`);
      this.showToast('添加产品失败');
    }
  }

  // 更新产品
  async updateProduct() {
    if (!this.newProduct.name.trim()) {
      this.showToast('产品名称不能为空');
      return;
    }

    try {
      const success = await FarmDatabase.updateProduct(this.newProduct.id, this.newProduct);

      if (success) {
        hilog.info(0x0000, 'ProductPage', '产品更新成功');
        this.showAddDialog = false;
        this.resetNewProductForm();
        await this.loadProducts();
        this.showToast('产品更新成功');

        // 触发数据同步通知
        await this.triggerDataSync();
      } else {
        this.showToast('更新产品失败');
      }
    } catch (error) {
      hilog.error(0x0000, 'ProductPage', `更新产品失败: ${JSON.stringify(error)}`);
      this.showToast('更新产品失败');
    }
  }

  // 选择产品进行编辑
  private selectProduct(product: FarmProduct) {
    this.isInsert = false;
    this.editIndex = this.productList.indexOf(product);
    this.newProduct = this.deepCopyProduct(product);
    this.showAddDialog = true;
  }

  // 深拷贝产品对象
  private deepCopyProduct(product: FarmProduct): FarmProduct {
    const copied = new FarmProduct();
    copied.id = product.id;
    copied.name = product.name;
    copied.type = product.type;
    copied.plantingDate = product.plantingDate;
    copied.harvestDate = product.harvestDate;
    copied.status = product.status;
    copied.currentStage = product.currentStage;
    copied.temperature = product.temperature;
    copied.humidity = product.humidity;
    copied.imageUrl = product.imageUrl;
    copied.description = product.description;
    copied.createdAt = product.createdAt;
    return copied;
  }

  // 批量删除产品
  async deleteSelectedProducts() {
    const selectedCount = this.deleteList.length;
    if (selectedCount === 0) {
      this.showToast('请选择要删除的产品');
      return;
    }

    try {
      const productIds = this.deleteList.map(product => product.id);
      const success = await FarmDatabase.deleteProductsBatch(productIds);

      if (success) {
        hilog.info(0x0000, 'ProductPage', `成功删除 ${selectedCount} 个产品`);
        this.deleteList = [];
        this.isEdit = false;
        await this.loadProducts();
        this.showToast(`成功删除 ${selectedCount} 个产品`);

        // 触发数据同步通知
        await this.triggerDataSync();
      } else {
        this.showToast('删除产品失败');
      }
    } catch (error) {
      hilog.error(0x0000, 'ProductPage', `删除产品失败: ${JSON.stringify(error)}`);
      this.showToast('删除产品失败');
    }
  }

  // 手动触发数据同步
  private async triggerDataSync(): Promise<void> {
    try {
      const timestamp = Date.now();
      // 直接通过@StorageLink绑定的变量来触发更新
      this.productDataChanged = timestamp;
      this.recordDataChanged = timestamp;
      hilog.info(0x0000, 'ProductPage', '手动触发数据同步');
    } catch (error) {
      hilog.error(0x0000, 'ProductPage', `触发数据同步失败: ${JSON.stringify(error)}`);
    }
  }

  // 重置新产品表单
  private resetNewProductForm() {
    this.newProduct = new FarmProduct();
    this.editIndex = -1;
    this.isInsert = true;
  }

  // 显示Toast
  private showToast(message: string) {
    try {
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      hilog.error(0x0000, 'ProductPage', `显示Toast失败: ${JSON.stringify(error)}`);
    }
  }

  // 手动刷新数据
  async refreshData() {
    await this.loadProducts();
    this.showToast('数据已刷新');
  }

  // 计算生长中数量
  private calculateGrowingCount(products: FarmProduct[]): number {
    return products.filter(p => p.status === ProductStatus.GROWING).length;
  }

  // 计算可收获数量
  private calculateHarvestableCount(products: FarmProduct[]): number {
    return products.filter(p => p.status === ProductStatus.HARVESTABLE).length;
  }

  build() {
    Stack() {
      Column() {
        // 头部
        this.BuildHeader()

        // 搜索筛选栏
        this.BuildSearchFilterBar()

        // 统计信息卡片 - 关键修复：使用同步状态变量
        this.BuildStatisticsCard()

        // 主内容区域
        if (this.isLoading) {
          this.BuildLoadingState()
        } else if (this.productList.length === 0) {
          this.BuildEmptyState()
        } else {
          this.BuildProductList()
        }

        // 底部操作按钮
        this.BuildActionButtons()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8FBF8')

      // 添加产品对话框
      if (this.showAddDialog) {
        this.BuildAddProductDialog()
      }
    }
  }

  // 构建顶部标题栏
  @Builder
  BuildHeader() {
    Flex({ alignItems: ItemAlign.Center }) {
      if (this.isEdit) {
        Row() {
          Text('×')
            .fontSize(24)
            .fontColor('#333333')
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(40)
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .margin({ right: 8 })
        .onClick(() => {
          this.isEdit = false;
          this.deleteList = [];
        })
      }

      Text(this.isEdit ? '选择产品' : '产品管理')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .layoutWeight(1)

      Row() {
        if (this.isEdit) {
          Text('✓')
            .fontSize(20)
            .fontColor('#2E8B57')
        } else {
          Text('✎')
            .fontSize(18)
            .fontColor('#666666')
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)
      .onClick(() => {
        if (this.productList.length === 0 && !this.isEdit) {
          this.showToast('请先添加产品');
          return;
        }
        this.isEdit = !this.isEdit;
        if (!this.isEdit) {
          this.deleteList = [];
        }
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  // 构建搜索和筛选栏
  @Builder
  BuildSearchFilterBar() {
    Column() {
      Row() {
        TextInput({
          placeholder: '搜索产品名称...',
          text: this.searchKeyword
        })
          .placeholderColor('#999999')
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .margin({ right: 12 })

        Button('搜索')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E8B57')
          .height(40)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.loadProducts();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('类型:')
          .fontSize(14)
          .margin({ right: 8 })

        ForEach(this.typeOptions, (item: OptionItem) => {
          Button(item.label)
            .fontSize(12)
            .fontColor(this.selectedType === item.value ? '#FFFFFF' : '#666666')
            .backgroundColor(this.selectedType === item.value ? '#2E8B57' : '#F5F5F5')
            .borderRadius(16)
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedType = item.value;
              this.loadProducts();
            })
        })

        Blank().layoutWeight(1)

        Text('状态:')
          .fontSize(14)
          .margin({ right: 8 })

        ForEach(this.statusOptions, (item: OptionItem) => {
          Button(item.label)
            .fontSize(12)
            .fontColor(this.selectedStatus === item.value ? '#FFFFFF' : '#666666')
            .backgroundColor(this.selectedStatus === item.value ? '#2E8B57' : '#F5F5F5')
            .borderRadius(16)
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedStatus = item.value;
              this.loadProducts();
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }

  // 构建统计信息卡片 - 关键修复：使用同步状态变量
  @Builder
  BuildStatisticsCard() {
    Column() {
      Row() {
        Column() {
          // 修复：使用同步的totalProducts状态变量
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
          // 修复：使用同步的growingCount状态变量
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
          // 修复：使用同步的harvestableCount状态变量
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
          // 关键修复：使用同步的totalRecords状态变量，而不是异步计算
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
      Image($r('app.media.empty_products'))
        .width(120)
        .height(120)
        .margin({ bottom: 16 })

      Text('暂无产品')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      if (this.searchKeyword || this.selectedType !== 'all' || this.selectedStatus !== 'all') {
        Text('没有找到匹配的产品，请调整筛选条件')
          .fontSize(12)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
      } else {
        Text('点击下方按钮添加第一个产品')
          .fontSize(12)
          .fontColor('#999999')
      }
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 构建产品列表
  @Builder
  BuildProductList() {
    List({ space: 12 }) {
      ForEach(this.productList, (product: FarmProduct, index: number) => {
        ListItem() {
          this.BuildProductItem(product, index)
        }
      }, (product: FarmProduct) => product.id.toString())
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
  }

  // 构建产品项
  @Builder
  BuildProductItem(product: FarmProduct, index: number) {
    Column() {
      Row() {
        if (this.isEdit) {
          Toggle({ type: ToggleType.Checkbox, isOn: this.deleteList.includes(product) })
            .onChange((isSelected: boolean) => {
              if (isSelected) {
                this.deleteList.push(product);
              } else {
                const itemIndex = this.deleteList.indexOf(product);
                if (itemIndex !== -1) {
                  this.deleteList.splice(itemIndex, 1);
                }
              }
            })
            .margin({ right: 12 })
        }

        Column() {
          Text(this.getProductIcon(product.type))
            .fontSize(16)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.getTypeColor(product.type))
            .fontColor('#FFFFFF')
            .borderRadius(8)
        }
        .margin({ right: 12 })

        Column() {
          Row() {
            Text(product.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2D4D2D')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text(this.getStatusDisplay(product.status))
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor(this.getStatusColor(product.status))
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

          Text(`${this.getProductTypeDisplayName(product.type)} | ${product.currentStage}`)
            .fontSize(12)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 4 })

          Row() {
            Text(`种植: ${this.formatDate(product.plantingDate)}`)
              .fontSize(10)
              .fontColor('#888888')

            Blank()

            if (product.temperature > 0) {
              Text(`${product.temperature}°C`)
                .fontSize(10)
                .fontColor('#FF6B6B')
                .margin({ right: 8 })
            }

            if (product.humidity > 0) {
              Text(`${product.humidity}%`)
                .fontSize(10)
                .fontColor('#2196F3')
            }
          }
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (!this.isEdit) {
          Row() {
            Button('编辑')
              .fontSize(12)
              .fontColor('#2E8B57')
              .backgroundColor('#E8F5E8')
              .height(28)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.selectProduct(product);
              })
          }
        }
      }
      .width('100%')

      if (index < this.productList.length - 1) {
        Divider()
          .strokeWidth(0.5)
          .color('#F0F0F0')
          .margin({ top: 12, bottom: 4 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      if (this.isEdit) {
        const selected = this.deleteList.includes(product);
        if (selected) {
          const index = this.deleteList.indexOf(product);
          this.deleteList.splice(index, 1);
        } else {
          this.deleteList.push(product);
        }
      } else {
        this.viewProductDetails(product);
      }
    })
  }

  // 构建底部操作按钮
  @Builder
  BuildActionButtons() {
    Column() {
      if (this.isEdit) {
        Button() {
          Row() {
            Text('🗑️')
              .fontSize(16)
              .margin({ right: 8 })
            Text(`删除 (${this.deleteList.length})`)
              .fontSize(16)
          }
        }
        .width('90%')
        .height(44)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF4D4F')
        .borderRadius(22)
        .onClick(() => {
          this.deleteSelectedProducts();
        })
      } else {
        Row({ space: 12 }) {
          Button('刷新')
            .fontSize(14)
            .fontColor('#2E8B57')
            .backgroundColor('#E8F5E8')
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              this.refreshData();
            })

          Button('添加产品')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#2E8B57')
            .layoutWeight(2)
            .height(44)
            .onClick(() => {
              this.isInsert = true;
              this.resetNewProductForm();
              this.showAddDialog = true;
            })
        }
        .width('90%')
      }
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建添加产品对话框
  @Builder
  BuildAddProductDialog() {
    Column() {
      Blank()
        .layoutWeight(1)
        .onClick(() => {
          this.showAddDialog = false;
        })

      Column() {
        Row() {
          Text(this.isInsert ? '添加新产品' : '编辑产品')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2D4D2D')
            .layoutWeight(1)

          Text('×')
            .fontSize(24)
            .fontColor('#666666')
            .onClick(() => {
              this.showAddDialog = false;
            })
        }
        .width('100%')
        .margin({ bottom: 20 })

        Scroll() {
          Column({ space: 16 }) {
            Column() {
              Text('产品名称 *')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '输入产品名称', text: this.newProduct.name })
                .placeholderColor('#999999')
                .height(40)
                .width('100%')
                .padding(8)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => {
                  this.newProduct.name = value;
                })
            }

            Column() {
              Text('产品类型')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              Row() {
                ForEach(this.typeOptions.filter(item => item.value !== 'all'), (item: OptionItem) => {
                  Button(item.label)
                    .fontSize(12)
                    .fontColor(this.newProduct.type === item.value ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.newProduct.type === item.value ? '#2E8B57' : '#F5F5F5')
                    .borderRadius(16)
                    .padding({
                      left: 12,
                      right: 12,
                      top: 8,
                      bottom: 8
                    })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.newProduct.type = item.value as ProductType;
                    })
                })
              }
              .width('100%')
            }

            Column() {
              Text('产品状态')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              Row() {
                ForEach(this.statusOptions.filter(item => item.value !== 'all'), (item: OptionItem) => {
                  Button(item.label)
                    .fontSize(12)
                    .fontColor(this.newProduct.status === item.value ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.newProduct.status === item.value ? '#2E8B57' : '#F5F5F5')
                    .borderRadius(16)
                    .padding({
                      left: 12,
                      right: 12,
                      top: 8,
                      bottom: 8
                    })
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.newProduct.status = item.value as ProductStatus;
                    })
                })
              }
              .width('100%')
            }

            Column() {
              Text('生长阶段')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '例如：播种期、生长期、开花期等', text: this.newProduct.currentStage })
                .placeholderColor('#999999')
                .height(40)
                .width('100%')
                .padding(8)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => {
                  this.newProduct.currentStage = value;
                })
            }

            Row({ space: 12 }) {
              Column() {
                Text('温度 (°C)')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })

                TextInput({
                  placeholder: '0',
                  text: this.newProduct.temperature?.toString() || ''
                })
                  .placeholderColor('#999999')
                  .height(40)
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .onChange((value: string) => {
                    this.newProduct.temperature = Number.parseFloat(value) || 0;
                  })
              }
              .layoutWeight(1)

              Column() {
                Text('湿度 (%)')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })

                TextInput({
                  placeholder: '0',
                  text: this.newProduct.humidity?.toString() || ''
                })
                  .placeholderColor('#999999')
                  .height(40)
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .onChange((value: string) => {
                    this.newProduct.humidity = Number.parseFloat(value) || 0;
                  })
              }
              .layoutWeight(1)
            }

            Column() {
              Text('产品描述')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextArea({ placeholder: '输入产品描述信息...', text: this.newProduct.description || '' })
                .placeholderColor('#999999')
                .height(80)
                .width('100%')
                .padding(8)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => {
                  this.newProduct.description = value;
                })
            }
          }
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .margin({ bottom: 20 })

        Row() {
          Button('取消')
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              this.showAddDialog = false;
              this.resetNewProductForm();
            })
            .margin({ right: 12 })

          Button(this.isInsert ? '确认添加' : '确认更新')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#2E8B57')
            .layoutWeight(1)
            .height(44)
            .onClick(() => {
              if (this.isInsert) {
                this.addProduct();
              } else {
                this.updateProduct();
              }
            })
        }
        .width('100%')
      }
      .width('90%')
      .height('70%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({
        radius: 20,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
  }

  // 查看产品详情
  private viewProductDetails(product: FarmProduct): void {
    hilog.info(0x0000, 'ProductPage', `查看产品详情: ${product.name}`);

    router.pushUrl({
      url: 'pages/Recording',
      params: {
        productId: product.id.toString(),
        productName: product.name,
        productType: product.type,
        productStatus: product.status,
        plantingDate: product.plantingDate,
        currentStage: product.currentStage,
        temperature: product.temperature?.toString() || '0',
        humidity: product.humidity?.toString() || '0',
        description: product.description || ''
      }
    }).then(() => {
      hilog.info(0x0000, 'ProductPage', '跳转到Recording页面成功');
    }).catch((error: Error) => {
      hilog.error(0x0000, 'ProductPage', `跳转失败: ${JSON.stringify(error)}`);
    });
  }

  // 工具方法
  private getProductIcon(type: ProductType): string {
    const iconMap: Record<string, string> = {
      [ProductType.VEGETABLE]: '🥦',
      [ProductType.FRUIT]: '🍎',
      [ProductType.GRAIN]: '🌾',
      [ProductType.ROOT]: '🥔',
      [ProductType.HERB]: '🌿',
      [ProductType.FLOWER]: '🌸'
    };
    return iconMap[type] || '🌱';
  }

  private getTypeColor(type: ProductType): string {
    const colorMap: Record<string, string> = {
      [ProductType.VEGETABLE]: '#2E8B57',
      [ProductType.FRUIT]: '#FF6B6B',
      [ProductType.GRAIN]: '#FFA500',
      [ProductType.ROOT]: '#8B4513',
      [ProductType.HERB]: '#4CAF50',
      [ProductType.FLOWER]: '#E91E63'
    };
    return colorMap[type] || '#666666';
  }

  private getStatusDisplay(status: ProductStatus): string {
    const statusMap: Record<string, string> = {
      [ProductStatus.GROWING]: '生长中',
      [ProductStatus.HARVESTABLE]: '可收获',
      [ProductStatus.HARVESTED]: '已收获',
      [ProductStatus.DORMANT]: '休眠期'
    };
    return statusMap[status] || status;
  }

  private getStatusColor(status: ProductStatus): string {
    const colorMap: Record<string, string> = {
      [ProductStatus.GROWING]: '#4CAF50',
      [ProductStatus.HARVESTABLE]: '#FFA500',
      [ProductStatus.HARVESTED]: '#666666',
      [ProductStatus.DORMANT]: '#999999'
    };
    return colorMap[status] || '#666666';
  }

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

  private getProductTypeDisplayName(type: ProductType): string {
    return EnumUtils.getProductTypeDisplayName(type);
  }
}