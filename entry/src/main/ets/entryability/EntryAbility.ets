import { AbilityConstant, ConfigurationConstant, UIAbility, Want, abilityAccessCtrl } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { FarmDatabase } from '../database/FarmDatabase'; // 导入数据库类
import { FarmProduct } from '../model/DataModels'; // 导入FarmProduct类
import { ProductType, ProductStatus } from '../model/Enums'; // 导入枚举类型

const DOMAIN = 0x0000;

interface PermissionResult {
  permissions: string[];
}

export default class EntryAbility extends UIAbility {
  // 添加数据库初始化状态
  private isDatabaseInitialized: boolean = false;

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 在创建阶段申请权限
    this.permissions();

    // 尝试初始化数据库
    await this.initializeDatabase();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 确保数据库已初始化
    if (!this.isDatabaseInitialized) {
      hilog.warn(DOMAIN, 'testTag', 'Database not initialized, retrying...');
      await this.initializeDatabase();
    }

    // 加载主页面
    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');

    // 应用回到前台时检查数据库状态
    this.checkDatabaseStatus();
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 初始化数据库
   */
  private async initializeDatabase(): Promise<void> {
    try {
      hilog.info(DOMAIN, 'testTag', 'Initializing database...');

      // 初始化数据库
      await FarmDatabase.initDatabase(this.context);
      this.isDatabaseInitialized = true;

      hilog.info(DOMAIN, 'testTag', 'Database initialized successfully');

      // 添加一些测试数据（可选）
      await this.addTestData();

    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize database. Cause: %{public}s', JSON.stringify(error));
      this.isDatabaseInitialized = false;

      // 可以添加重试逻辑
      setTimeout(() => {
        this.initializeDatabase();
      }, 3000); // 3秒后重试
    }
  }

  /**
   * 添加测试数据（可选）
   */
  private async addTestData(): Promise<void> {
    try {
      // 检查是否已有数据
      const existingProducts = await FarmDatabase.getAllProducts();

      if (existingProducts.length === 0) {
        hilog.info(DOMAIN, 'testTag', 'Adding test data...');
        const testProducts: FarmProduct[] = [
          new FarmProduct(),
          new FarmProduct(),
          new FarmProduct()
        ];

        // 设置第一个产品数据
        testProducts[0].name = '有机西红柿';
        testProducts[0].type = ProductType.VEGETABLE;
        testProducts[0].plantingDate = new Date().toISOString().split('T')[0];
        testProducts[0].status = ProductStatus.GROWING;
        testProducts[0].currentStage = '开花期';
        testProducts[0].temperature = 24;
        testProducts[0].humidity = 70;
        testProducts[0].description = '优质有机西红柿，生长良好';

        // 设置第二个产品数据
        testProducts[1].name = '奶油草莓';
        testProducts[1].type = ProductType.FRUIT;
        testProducts[1].plantingDate = new Date(Date.now() - 86400000 * 30).toISOString().split('T')[0]; // 30天前
        testProducts[1].status = ProductStatus.HARVESTABLE;
        testProducts[1].currentStage = '成熟期';
        testProducts[1].temperature = 22;
        testProducts[1].humidity = 65;
        testProducts[1].description = '香甜奶油草莓，可采摘';

        // 设置第三个产品数据
        testProducts[2].name = '黄金玉米';
        testProducts[2].type = ProductType.GRAIN;
        testProducts[2].plantingDate = new Date(Date.now() - 86400000 * 15).toISOString().split('T')[0]; // 15天前
        testProducts[2].status = ProductStatus.GROWING;
        testProducts[2].currentStage = '生长期';
        testProducts[2].temperature = 26;
        testProducts[2].humidity = 75;
        testProducts[2].description = '高产黄金玉米品种';

        for (const productData of testProducts) {
          await FarmDatabase.addProduct(productData);
        }

        hilog.info(DOMAIN, 'testTag', 'Test data added successfully');
      } else {
        hilog.info(DOMAIN, 'testTag', 'Database already contains data, skipping test data');
      }
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to add test data. Cause: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 检查数据库状态
   */
  private async checkDatabaseStatus(): Promise<void> {
    if (!this.isDatabaseInitialized) {
      hilog.warn(DOMAIN, 'testTag', 'Database not initialized, attempting to initialize...');
      await this.initializeDatabase();
    }

    try {
      // 检查数据库连接是否正常
      const productCount = await FarmDatabase.getAllProducts().then(products => products.length);
      hilog.info(DOMAIN, 'testTag', 'Database status: OK, product count: %{public}d', productCount);
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Database connection failed. Cause: %{public}s', JSON.stringify(error));
      this.isDatabaseInitialized = false;
    }
  }

  /**
   * Apply for the permission to exchange data between different devices.
   */
  private permissions(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context, [
      'ohos.permission.DISTRIBUTED_DATASYNC',
      'ohos.permission.INTERNET',
      'ohos.permission.GET_NETWORK_INFO'
    ])
      .then((data: PermissionResult) => {
        hilog.info(0x0000, 'EntryAbility', `Data permissions:${data.permissions}`);
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'EntryAbility', `request permissions failed, Code:${err.code},message: ${err.message}`);
      });
  }
}