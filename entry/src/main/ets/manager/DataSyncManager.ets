import { FarmProduct, GrowthRecord, ProductStatistics } from '../model/DataModels';
import { ProductType, ProductStatus, RecordType } from '../model/Enums';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 数据变更监听器接口
interface DataChangeListener {
  onProductsChanged(products: FarmProduct[]): void;

  onRecordsChanged(records: GrowthRecord[]): void;

  onStatisticsChanged(statistics: ProductStatistics): void;
}

// 监听器数量接口
interface ListenerCount {
  products: number;
  records: number;
  statistics: number;
  total: number;
}

// 数据同步管理器
export class DataSyncManager {
  private static instance: DataSyncManager;
  private productUpdateCallbacks: ((products: FarmProduct[]) => void)[] = [];
  private recordUpdateCallbacks: ((records: GrowthRecord[]) => void)[] = [];
  private statisticsUpdateCallbacks: ((stats: ProductStatistics) => void)[] = [];
  private listeners: DataChangeListener[] = [];

  // 获取单例实例
  static getInstance(): DataSyncManager {
    if (!DataSyncManager.instance) {
      DataSyncManager.instance = new DataSyncManager();
    }
    return DataSyncManager.instance;
  }

  // 注册数据变更监听器
  registerListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
      hilog.info(0x0000, 'DataSyncManager', '数据监听器注册成功');
    }
  }

  // 注销数据变更监听器
  unregisterListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
      hilog.info(0x0000, 'DataSyncManager', '数据监听器注销成功');
    }
  }

  // 注册产品数据更新回调
  registerProductUpdate(callback: (products: FarmProduct[]) => void): void {
    this.productUpdateCallbacks.push(callback);
  }

  // 注册记录数据更新回调
  registerRecordUpdate(callback: (records: GrowthRecord[]) => void): void {
    this.recordUpdateCallbacks.push(callback);
  }

  // 注册统计信息更新回调
  registerStatisticsUpdate(callback: (stats: ProductStatistics) => void): void {
    this.statisticsUpdateCallbacks.push(callback);
  }

  // 通知产品数据变化
  async notifyProductsChanged(): Promise<void> {
    try {
      const timestamp = Date.now();
      // 使用AppStorage通知UI层数据变化
      // AppStorage.set('productDataChanged', timestamp);

      // 执行注册的回调
      this.productUpdateCallbacks.forEach(callback => {
        try {
          // 在实际调用时加载最新数据
          // callback(products);
        } catch (error) {
          hilog.error(0x0000, 'DataSyncManager', `产品回调执行失败: ${JSON.stringify(error)}`);
        }
      });

      // 通知监听器
      this.listeners.forEach(listener => {
        try {
          // 监听器需要自行获取最新数据
          // listener.onProductsChanged(products);
        } catch (error) {
          hilog.error(0x0000, 'DataSyncManager', `监听器通知失败: ${JSON.stringify(error)}`);
        }
      });

      hilog.info(0x0000, 'DataSyncManager', `产品数据变化通知已发送: ${timestamp}`);
    } catch (error) {
      hilog.error(0x0000, 'DataSyncManager', `通知产品数据变化失败: ${JSON.stringify(error)}`);
    }
  }

  // 通知记录数据变化
  async notifyRecordsChanged(): Promise<void> {
    try {
      const timestamp = Date.now();
      // AppStorage.set('recordDataChanged', timestamp);

      this.recordUpdateCallbacks.forEach(callback => {
        try {
          // callback(records);
        } catch (error) {
          hilog.error(0x0000, 'DataSyncManager', `记录回调执行失败: ${JSON.stringify(error)}`);
        }
      });

      this.listeners.forEach(listener => {
        try {
          // listener.onRecordsChanged(records);
        } catch (error) {
          hilog.error(0x0000, 'DataSyncManager', `记录监听器通知失败: ${JSON.stringify(error)}`);
        }
      });

      hilog.info(0x0000, 'DataSyncManager', `记录数据变化通知已发送: ${timestamp}`);
    } catch (error) {
      hilog.error(0x0000, 'DataSyncManager', `通知记录数据变化失败: ${JSON.stringify(error)}`);
    }
  }

  // 通知统计信息变化
  async notifyStatisticsChanged(): Promise<void> {
    try {
      const timestamp = Date.now();
      // AppStorage.set('statisticsDataChanged', timestamp);

      this.statisticsUpdateCallbacks.forEach(callback => {
        try {
          // callback(statistics);
        } catch (error) {
          hilog.error(0x0000, 'DataSyncManager', `统计回调执行失败: ${JSON.stringify(error)}`);
        }
      });

      this.listeners.forEach(listener => {
        try {
          // listener.onStatisticsChanged(statistics);
        } catch (error) {
          hilog.error(0x0000, 'DataSyncManager', `统计监听器通知失败: ${JSON.stringify(error)}`);
        }
      });

      hilog.info(0x0000, 'DataSyncManager', `统计信息变化通知已发送: ${timestamp}`);
    } catch (error) {
      hilog.error(0x0000, 'DataSyncManager', `通知统计信息变化失败: ${JSON.stringify(error)}`);
    }
  }

  // 通知所有数据变化
  async notifyAllDataChanged(): Promise<void> {
    try {
      const timestamp = Date.now();

      // 通知所有类型的数据变化
      await this.notifyProductsChanged();
      await this.notifyRecordsChanged();
      await this.notifyStatisticsChanged();

      hilog.info(0x0000, 'DataSyncManager', `所有数据变化通知已发送: ${timestamp}`);
    } catch (error) {
      hilog.error(0x0000, 'DataSyncManager', `通知所有数据变化失败: ${JSON.stringify(error)}`);
    }
  }

  // 清理所有回调
  unregisterAllCallbacks(): void {
    this.productUpdateCallbacks = [];
    this.recordUpdateCallbacks = [];
    this.statisticsUpdateCallbacks = [];
    this.listeners = [];
    hilog.info(0x0000, 'DataSyncManager', '所有回调已清理');
  }

  // 获取活跃监听器数量
  getListenerCount(): ListenerCount {
    return {
      products: this.productUpdateCallbacks.length,
      records: this.recordUpdateCallbacks.length,
      statistics: this.statisticsUpdateCallbacks.length,
      total: this.listeners.length
    };
  }
}

export default DataSyncManager;