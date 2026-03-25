
import relationalStore from '@ohos.data.relationalStore';
import { BusinessError } from '@ohos.base';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, AppStorageV2 } from '@kit.ArkUI';
import { FarmProduct, GrowthRecord, ProductStatistics, GrowthRecordStatistics } from '../model/DataModels';
import { ProductType, ProductStatus, RecordType } from '../model/Enums';

// 表配置接口定义
interface TableConfig {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

// 产品筛选接口定义
export interface ProductFilter {
  type?: string;
  status?: string;
  searchKeyword?: string;
}

// 数据库状态接口
interface DatabaseStatus {
  isInitialized: boolean;
  hasContext: boolean;
  hasStore: boolean;
}

// 数据库常量配置
export class FarmDatabaseConstants {
  // 数据库配置
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'FarmDatabase.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false
  };

  // 数据库版本管理
  static readonly DATABASE_VERSION = 1;

  // 产品表配置
  static readonly PRODUCTS_TABLE: TableConfig = {
    tableName: 'products',
    sqlCreate: `
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        planting_date TEXT NOT NULL,
        harvest_date TEXT,
        status TEXT NOT NULL,
        current_stage TEXT,
        temperature REAL,
        humidity REAL,
        image_url TEXT,
        description TEXT,
        created_at TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
        updated_at TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now'))
      )
    `,
    columns: ['id', 'name', 'type', 'planting_date', 'harvest_date', 'status',
      'current_stage', 'temperature', 'humidity', 'image_url', 'description', 'created_at', 'updated_at']
  };

  // 生长记录表配置
  static readonly GROWTH_RECORDS_TABLE: TableConfig = {
    tableName: 'growth_records',
    sqlCreate: `
      CREATE TABLE IF NOT EXISTS growth_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        record_type TEXT NOT NULL,
        record_date TEXT NOT NULL,
        stage TEXT NOT NULL,
        height REAL,
        weight REAL,
        notes TEXT,
        images TEXT,
        temperature REAL,
        humidity REAL,
        created_at TEXT DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now')),
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    `,
    columns: ['id', 'product_id', 'product_name', 'record_type', 'record_date', 'stage',
      'height', 'weight', 'notes', 'images', 'temperature', 'humidity', 'created_at']
  };

  // 日志标签
  static readonly TAG = 'FarmDatabase';
}

export class FarmDatabase {
  private static rdbStore: relationalStore.RdbStore | null = null;
  private static context: common.UIAbilityContext | null = null;
  private static isInitialized: boolean = false;

  // 初始化数据库
  static async initDatabase(context: common.UIAbilityContext): Promise<boolean> {
    try {
      if (FarmDatabase.isInitialized && FarmDatabase.rdbStore) {
        hilog.info(0x0000, FarmDatabaseConstants.TAG, '数据库已初始化，跳过重复初始化');
        return true;
      }

      FarmDatabase.context = context;

      // 获取数据库实例
      FarmDatabase.rdbStore = await relationalStore.getRdbStore(context, FarmDatabaseConstants.STORE_CONFIG);

      // 创建数据表
      await FarmDatabase.createTables();
      FarmDatabase.isInitialized = true;

      hilog.info(0x0000, FarmDatabaseConstants.TAG, '数据库初始化成功');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `数据库初始化失败. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }

  // 创建数据表
  private static async createTables(): Promise<void> {
    if (!FarmDatabase.rdbStore) {
      throw new Error('数据库未初始化');
    }

    try {
      await FarmDatabase.rdbStore.executeSql(FarmDatabaseConstants.PRODUCTS_TABLE.sqlCreate);
      await FarmDatabase.rdbStore.executeSql(FarmDatabaseConstants.GROWTH_RECORDS_TABLE.sqlCreate);
      hilog.info(0x0000, FarmDatabaseConstants.TAG, '所有数据表创建成功');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `创建数据表失败. Code: ${err.code}, Message: ${err.message}`);
      throw new Error(`创建数据表失败: ${err.message}`);
    }
  }

  // 检查数据库是否已初始化
  private static checkInitialized(): void {
    if (!FarmDatabase.isInitialized || !FarmDatabase.rdbStore) {
      throw new Error('数据库未初始化。请先调用 initDatabase() 方法。');
    }
  }

  // ========== 数据同步通知方法 ==========
  private static async notifyDataChange(dataType: 'product' | 'record' | 'all'): Promise<void> {
    try {
      const timestamp = Date.now();

      switch (dataType) {
        case 'product':
          AppStorage.setOrCreate('productDataChanged', timestamp);
          break;
        case 'record':
          AppStorage.setOrCreate('recordDataChanged', timestamp);
          break;
        case 'all':
          AppStorage.setOrCreate('productDataChanged', timestamp);
          AppStorage.setOrCreate('recordDataChanged', timestamp);
          break;
      }

      hilog.info(0x0000, FarmDatabaseConstants.TAG, `数据变化通知已发送: ${dataType} - ${timestamp}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `通知数据变化失败. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  // ========== 产品相关操作（添加同步通知） ==========

  // 添加产品（基础方法）
  static async addProduct(product: FarmProduct): Promise<number> {
    FarmDatabase.checkInitialized();

    const valueBucket: relationalStore.ValuesBucket = {
      'name': product.name || '',
      'type': product.type || ProductType.VEGETABLE,
      'planting_date': product.plantingDate || new Date().toISOString().split('T')[0],
      'harvest_date': product.harvestDate || '',
      'status': product.status || ProductStatus.GROWING,
      'current_stage': product.currentStage || '播种期',
      'temperature': product.temperature || 0,
      'humidity': product.humidity || 0,
      'image_url': product.imageUrl || '',
      'description': product.description || ''
    };

    try {
      const rowId = await FarmDatabase.rdbStore!.insert(
        FarmDatabaseConstants.PRODUCTS_TABLE.tableName,
        valueBucket
      );

      hilog.info(0x0000, FarmDatabaseConstants.TAG, `产品添加成功，ID: ${rowId}`);

      // 触发数据同步通知
      await FarmDatabase.notifyDataChange('product');

      return rowId;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `添加产品失败. Code: ${err.code}, Message: ${err.message}`);
      return -1;
    }
  }

  // 添加产品并自动创建初始生长记录（事务操作）- 解决同步问题的关键方法
  static async addProductWithAutoRecord(product: FarmProduct): Promise<number> {
    FarmDatabase.checkInitialized();

    try {
      // 开始事务
      await FarmDatabase.beginTransaction();

      // 1. 添加产品
      const productId = await FarmDatabase.addProduct(product);

      if (productId > 0) {
        // 2. 自动创建初始生长记录
        const initialRecord: GrowthRecord = new GrowthRecord();
        initialRecord.productId = productId;
        initialRecord.productName = product.name;
        initialRecord.recordType = RecordType.SOWING;
        initialRecord.recordDate = product.plantingDate || new Date().toISOString().split('T')[0];
        initialRecord.stage = product.currentStage || '播种期';
        initialRecord.notes = `开始种植${product.name}`;
        initialRecord.temperature = product.temperature || 0;
        initialRecord.humidity = product.humidity || 0;

        const recordId = await FarmDatabase.addGrowthRecord(initialRecord);

        if (recordId > 0) {
          // 提交事务
          await FarmDatabase.commitTransaction();

          // 通知所有数据变化
          await FarmDatabase.notifyDataChange('all');

          hilog.info(0x0000, FarmDatabaseConstants.TAG,
            `产品 ${productId} 和生长记录 ${recordId} 添加成功`);
          return productId;
        } else {
          await FarmDatabase.rollbackTransaction();
          hilog.error(0x0000, FarmDatabaseConstants.TAG, '添加生长记录失败，事务已回滚');
          return -1;
        }
      } else {
        await FarmDatabase.rollbackTransaction();
        return -1;
      }
    } catch (error) {
      await FarmDatabase.rollbackTransaction();
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `添加产品失败: ${err.code}, Message: ${err.message}`);
      return -1;
    }
  }

  // 更新产品信息
  static async updateProduct(productId: number, updates: Partial<FarmProduct>): Promise<boolean> {
    FarmDatabase.checkInitialized();

    const valueBucket: relationalStore.ValuesBucket = {};

    // 构建更新字段
    if (updates.name !== undefined) valueBucket['name'] = updates.name;
    if (updates.type !== undefined) valueBucket['type'] = updates.type;
    if (updates.status !== undefined) valueBucket['status'] = updates.status;
    if (updates.currentStage !== undefined) valueBucket['current_stage'] = updates.currentStage;
    if (updates.temperature !== undefined) valueBucket['temperature'] = updates.temperature;
    if (updates.humidity !== undefined) valueBucket['humidity'] = updates.humidity;
    if (updates.imageUrl !== undefined) valueBucket['image_url'] = updates.imageUrl;
    if (updates.description !== undefined) valueBucket['description'] = updates.description;
    if (updates.harvestDate !== undefined) valueBucket['harvest_date'] = updates.harvestDate;

    valueBucket['updated_at'] = new Date().toISOString();

    if (Object.keys(valueBucket).length === 0) {
      hilog.warn(0x0000, FarmDatabaseConstants.TAG, '没有要更新的字段');
      return true;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);
      predicates.equalTo('id', productId);

      const affectedRows = await FarmDatabase.rdbStore!.update(valueBucket, predicates);
      const success = affectedRows > 0;

      if (success) {
        // 触发数据同步通知
        await FarmDatabase.notifyDataChange('product');
        hilog.info(0x0000, FarmDatabaseConstants.TAG, `产品 ${productId} 更新成功`);
      }

      return success;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `更新产品失败. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }

  // 删除产品（级联删除相关记录）
  static async deleteProduct(productId: number): Promise<boolean> {
    FarmDatabase.checkInitialized();

    try {
      // 开始事务
      await FarmDatabase.beginTransaction();

      // 1. 先删除相关生长记录
      const recordsDeleted = await FarmDatabase.deleteGrowthRecordsByProductId(productId);
      hilog.info(0x0000, FarmDatabaseConstants.TAG,
        `删除产品 ${productId} 的相关记录，影响: ${recordsDeleted} 条`);

      // 2. 删除产品
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);
      predicates.equalTo('id', productId);

      const affectedRows = await FarmDatabase.rdbStore!.delete(predicates);
      const success = affectedRows > 0;

      if (success) {
        await FarmDatabase.commitTransaction();

        // 触发数据同步通知
        await FarmDatabase.notifyDataChange('all');
        hilog.info(0x0000, FarmDatabaseConstants.TAG, `产品 ${productId} 删除成功`);
      } else {
        await FarmDatabase.rollbackTransaction();
        hilog.warn(0x0000, FarmDatabaseConstants.TAG, `未找到产品 ${productId}，删除操作未执行`);
      }

      return success;
    } catch (error) {
      await FarmDatabase.rollbackTransaction();
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `删除产品失败. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }

  // 批量删除产品
  static async deleteProductsBatch(productIds: number[]): Promise<boolean> {
    FarmDatabase.checkInitialized();

    if (!productIds || productIds.length === 0) {
      hilog.warn(0x0000, FarmDatabaseConstants.TAG, '产品ID列表为空，跳过删除操作');
      return true;
    }

    try {
      await FarmDatabase.beginTransaction();

      let totalDeleted = 0;
      for (const productId of productIds) {
        const success = await FarmDatabase.deleteProduct(productId);
        if (success) {
          totalDeleted++;
        }
      }

      await FarmDatabase.commitTransaction();

      // 触发数据同步通知
      await FarmDatabase.notifyDataChange('all');
      hilog.info(0x0000, FarmDatabaseConstants.TAG, `批量删除完成，成功删除 ${totalDeleted} 个产品`);

      return totalDeleted > 0;
    } catch (error) {
      await FarmDatabase.rollbackTransaction();
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `批量删除产品失败. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }

  // ========== 生长记录相关操作 ==========

  // 添加生长记录
  static async addGrowthRecord(record: GrowthRecord): Promise<number> {
    FarmDatabase.checkInitialized();

    const valueBucket: relationalStore.ValuesBucket = {
      'product_id': record.productId,
      'product_name': record.productName || '',
      'record_type': record.recordType || RecordType.OBSERVATION,
      'record_date': record.recordDate || new Date().toISOString().split('T')[0],
      'stage': record.stage || '',
      'height': record.height || 0,
      'weight': record.weight || 0,
      'notes': record.notes || '',
      'images': record.images ? JSON.stringify(record.images) : '[]',
      'temperature': record.temperature || 0,
      'humidity': record.humidity || 0
    };

    try {
      const rowId = await FarmDatabase.rdbStore!.insert(
        FarmDatabaseConstants.GROWTH_RECORDS_TABLE.tableName,
        valueBucket
      );

      hilog.info(0x0000, FarmDatabaseConstants.TAG, `生长记录添加成功，ID: ${rowId}`);

      // 触发数据同步通知
      await FarmDatabase.notifyDataChange('record');

      return rowId;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `添加生长记录失败. Code: ${err.code}, Message: ${err.message}`);
      return -1;
    }
  }

  // 根据产品ID删除所有相关生长记录
  static async deleteGrowthRecordsByProductId(productId: number): Promise<number> {
    FarmDatabase.checkInitialized();

    try {
      const predicates = new relationalStore.RdbPredicates(
        FarmDatabaseConstants.GROWTH_RECORDS_TABLE.tableName
      );
      predicates.equalTo('product_id', productId);

      const affectedRows = await FarmDatabase.rdbStore!.delete(predicates);

      hilog.info(0x0000, FarmDatabaseConstants.TAG,
        `删除产品 ${productId} 的生长记录，影响行数: ${affectedRows}`);

      return affectedRows;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `删除生长记录失败. Code: ${err.code}, Message: ${err.message}`);
      return 0;
    }
  }

  // ========== 事务管理 ==========

  // 开始事务
  private static async beginTransaction(): Promise<void> {
    if (!FarmDatabase.rdbStore) {
      throw new Error('数据库未初始化');
    }
    await FarmDatabase.rdbStore.beginTransaction();
  }

  // 提交事务
  private static async commitTransaction(): Promise<void> {
    if (!FarmDatabase.rdbStore) {
      throw new Error('数据库未初始化');
    }
    await FarmDatabase.rdbStore.commit();
  }
  // 回滚事务
  private static async rollbackTransaction(): Promise<void> {
    if (!FarmDatabase.rdbStore) {
      throw new Error('数据库未初始化');
    }
    await FarmDatabase.rdbStore.rollback(0);
  }

  // ========== 查询方法 ==========

  // 获取所有产品
  static async getAllProducts(): Promise<FarmProduct[]> {
    FarmDatabase.checkInitialized();

    try {
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);
      predicates.orderByDesc('created_at');

      const resultSet = await FarmDatabase.rdbStore!.query(
        predicates,
        FarmDatabaseConstants.PRODUCTS_TABLE.columns
      );

      const products: FarmProduct[] = [];
      while (resultSet.goToNextRow()) {
        products.push(FarmDatabase.parseProductFromResultSet(resultSet));
      }
      resultSet.close();

      return products;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `获取产品列表失败. Code: ${err.code}, Message: ${err.message}`);
      return [];
    }
  }

  // 根据ID获取产品
  static async getProductById(productId: number): Promise<FarmProduct | null> {
    FarmDatabase.checkInitialized();

    try {
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);
      predicates.equalTo('id', productId);

      const resultSet = await FarmDatabase.rdbStore!.query(
        predicates,
        FarmDatabaseConstants.PRODUCTS_TABLE.columns
      );

      if (resultSet.goToFirstRow()) {
        const product = FarmDatabase.parseProductFromResultSet(resultSet);
        resultSet.close();
        return product;
      } else {
        resultSet.close();
        return null;
      }
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `获取产品详情失败. Code: ${err.code}, Message: ${err.message}`);
      return null;
    }
  }

  // 根据条件筛选产品
  static async getProductsByFilter(filters: ProductFilter): Promise<FarmProduct[]> {
    FarmDatabase.checkInitialized();

    try {
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);

      if (filters.type && filters.type !== 'all') {
        predicates.equalTo('type', filters.type);
      }

      if (filters.status && filters.status !== 'all') {
        predicates.equalTo('status', filters.status);
      }

      if (filters.searchKeyword) {
        predicates.like('name', `%${filters.searchKeyword}%`)
          .or()
          .like('description', `%${filters.searchKeyword}%`);
      }

      predicates.orderByDesc('created_at');

      const resultSet = await FarmDatabase.rdbStore!.query(
        predicates,
        FarmDatabaseConstants.PRODUCTS_TABLE.columns
      );

      const products: FarmProduct[] = [];
      while (resultSet.goToNextRow()) {
        products.push(FarmDatabase.parseProductFromResultSet(resultSet));
      }
      resultSet.close();

      return products;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `筛选产品失败. Code: ${err.code}, Message: ${err.message}`);
      return [];
    }
  }

  // 获取所有生长记录
  static async getAllGrowthRecords(): Promise<GrowthRecord[]> {
    FarmDatabase.checkInitialized();

    try {
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.GROWTH_RECORDS_TABLE.tableName);
      predicates.orderByDesc('record_date');

      const resultSet = await FarmDatabase.rdbStore!.query(
        predicates,
        FarmDatabaseConstants.GROWTH_RECORDS_TABLE.columns
      );

      const records: GrowthRecord[] = [];
      while (resultSet.goToNextRow()) {
        records.push(FarmDatabase.parseGrowthRecordFromResultSet(resultSet));
      }
      resultSet.close();

      return records;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `获取生长记录失败. Code: ${err.code}, Message: ${err.message}`);
      return [];
    }
  }

  // 查询产品的生长记录
  static async getGrowthRecordsByProductId(productId: number): Promise<GrowthRecord[]> {
    FarmDatabase.checkInitialized();

    try {
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.GROWTH_RECORDS_TABLE.tableName);
      predicates.equalTo('product_id', productId);
      predicates.orderByDesc('record_date');

      const resultSet = await FarmDatabase.rdbStore!.query(
        predicates,
        FarmDatabaseConstants.GROWTH_RECORDS_TABLE.columns
      );

      const records: GrowthRecord[] = [];
      while (resultSet.goToNextRow()) {
        records.push(FarmDatabase.parseGrowthRecordFromResultSet(resultSet));
      }
      resultSet.close();

      return records;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `获取产品生长记录失败. Code: ${err.code}, Message: ${err.message}`);
      return [];
    }
  }

  // ========== 数据解析方法 ==========

  // 从ResultSet解析产品数据
  private static parseProductFromResultSet(resultSet: relationalStore.ResultSet): FarmProduct {
    const product = new FarmProduct();
    product.id = resultSet.getLong(resultSet.getColumnIndex('id'));
    product.name = resultSet.getString(resultSet.getColumnIndex('name'));
    product.type = resultSet.getString(resultSet.getColumnIndex('type')) as ProductType;
    product.plantingDate = resultSet.getString(resultSet.getColumnIndex('planting_date'));
    product.harvestDate = resultSet.getString(resultSet.getColumnIndex('harvest_date'));
    product.status = resultSet.getString(resultSet.getColumnIndex('status')) as ProductStatus;
    product.currentStage = resultSet.getString(resultSet.getColumnIndex('current_stage'));
    product.temperature = resultSet.getDouble(resultSet.getColumnIndex('temperature'));
    product.humidity = resultSet.getDouble(resultSet.getColumnIndex('humidity'));
    product.imageUrl = resultSet.getString(resultSet.getColumnIndex('image_url'));
    product.description = resultSet.getString(resultSet.getColumnIndex('description'));
    product.createdAt = resultSet.getString(resultSet.getColumnIndex('created_at'));

    return product;
  }

  // 从ResultSet解析生长记录数据
  private static parseGrowthRecordFromResultSet(resultSet: relationalStore.ResultSet): GrowthRecord {
    const record = new GrowthRecord();
    record.id = resultSet.getLong(resultSet.getColumnIndex('id'));
    record.productId = resultSet.getLong(resultSet.getColumnIndex('product_id'));
    record.productName = resultSet.getString(resultSet.getColumnIndex('product_name'));
    record.recordType = resultSet.getString(resultSet.getColumnIndex('record_type')) as RecordType;
    record.recordDate = resultSet.getString(resultSet.getColumnIndex('record_date'));
    record.stage = resultSet.getString(resultSet.getColumnIndex('stage'));
    record.height = resultSet.getDouble(resultSet.getColumnIndex('height'));
    record.weight = resultSet.getDouble(resultSet.getColumnIndex('weight'));
    record.notes = resultSet.getString(resultSet.getColumnIndex('notes'));

    // 解析图片数组
    const imagesJson = resultSet.getString(resultSet.getColumnIndex('images'));
    record.images = imagesJson ? JSON.parse(imagesJson) : [];

    record.temperature = resultSet.getDouble(resultSet.getColumnIndex('temperature'));
    record.humidity = resultSet.getDouble(resultSet.getColumnIndex('humidity'));
    record.createdAt = resultSet.getString(resultSet.getColumnIndex('created_at'));

    return record;
  }

  // ========== 统计方法 ==========

  // 获取产品统计信息
  static async getProductStatistics(): Promise<ProductStatistics> {
    FarmDatabase.checkInitialized();

    try {
      // 获取总数
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);
      const resultSet = await FarmDatabase.rdbStore!.query(predicates, ['id']);
      const total = resultSet.rowCount;
      resultSet.close();

      // 按类型统计
      const typeStats: Record<string, number> = {};
      const typeResult = await FarmDatabase.rdbStore!.querySql(
        'SELECT type, COUNT(*) as count FROM products GROUP BY type'
      );
      while (typeResult.goToNextRow()) {
        const type = typeResult.getString(typeResult.getColumnIndex('type'));
        const count = typeResult.getLong(typeResult.getColumnIndex('count'));
        typeStats[type] = count;
      }
      typeResult.close();

      // 按状态统计
      const statusStats: Record<string, number> = {};
      const statusResult = await FarmDatabase.rdbStore!.querySql(
        'SELECT status, COUNT(*) as count FROM products GROUP BY status'
      );
      while (statusResult.goToNextRow()) {
        const status = statusResult.getString(statusResult.getColumnIndex('status'));
        const count = statusResult.getLong(statusResult.getColumnIndex('count'));
        statusStats[status] = count;
      }
      statusResult.close();

      return new ProductStatistics(total, typeStats, statusStats);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `获取统计信息失败. Code: ${err.code}, Message: ${err.message}`);
      return new ProductStatistics(0, {}, {});
    }
  }
  // 获取生长记录统计信息
  static async getGrowthRecordStatistics(): Promise<GrowthRecordStatistics> {
    FarmDatabase.checkInitialized();

    try {
      // 获取记录总数
      const predicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.GROWTH_RECORDS_TABLE.tableName);
      const resultSet = await FarmDatabase.rdbStore!.query(predicates, ['id']);
      const total = resultSet.rowCount;
      resultSet.close();

      // 按类型统计记录
      const byType: Record<string, number> = {};
      const typeResult = await FarmDatabase.rdbStore!.querySql(
        'SELECT record_type, COUNT(*) as count FROM growth_records GROUP BY record_type'
      );
      while (typeResult.goToNextRow()) {
        const recordType = typeResult.getString(typeResult.getColumnIndex('record_type'));
        const count = typeResult.getLong(typeResult.getColumnIndex('count'));
        byType[recordType] = count;
      }
      typeResult.close();
      return { total, byType } as GrowthRecordStatistics;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `获取记录统计信息失败. Code: ${err.code}, Message: ${err.message}`);
      return { total: 0, byType: {} } as GrowthRecordStatistics;
    }
  }

  // ========== 工具方法 ==========

  // 获取数据库状态信息
  static getDatabaseStatus(): DatabaseStatus {
    return {
      isInitialized: FarmDatabase.isInitialized,
      hasContext: FarmDatabase.context !== null,
      hasStore: FarmDatabase.rdbStore !== null
    };
  }

  // 清空所有数据（开发调试用）
  static async clearAllData(): Promise<boolean> {
    FarmDatabase.checkInitialized();

    try {
      await FarmDatabase.beginTransaction();

      // 清空生长记录表
      const recordPredicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.GROWTH_RECORDS_TABLE.tableName);
      await FarmDatabase.rdbStore!.delete(recordPredicates);

      // 清空产品表
      const productPredicates = new relationalStore.RdbPredicates(FarmDatabaseConstants.PRODUCTS_TABLE.tableName);
      await FarmDatabase.rdbStore!.delete(productPredicates);

      await FarmDatabase.commitTransaction();

      // 通知数据变化
      await FarmDatabase.notifyDataChange('all');
      hilog.info(0x0000, FarmDatabaseConstants.TAG, '所有数据已清空');

      return true;
    } catch (error) {
      await FarmDatabase.rollbackTransaction();
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `清空数据失败. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }

  // 修复现有数据同步问题的方法
  static async fixDataSyncIssue(): Promise<boolean> {
    FarmDatabase.checkInitialized();

    try {
      hilog.info(0x0000, FarmDatabaseConstants.TAG, '开始修复数据同步问题...');

      // 1. 获取所有产品
      const products = await FarmDatabase.getAllProducts();

      // 2. 获取所有生长记录
      const records = await FarmDatabase.getAllGrowthRecords();

      // 3. 检查哪些产品缺少初始记录
      let fixedCount = 0;
      for (const product of products) {
        const productRecords = records.filter(record => record.productId === product.id);

        if (productRecords.length === 0) {
          // 为缺少记录的产品创建初始记录
          const initialRecord: GrowthRecord = new GrowthRecord();
          initialRecord.productId = product.id;
          initialRecord.productName = product.name;
          initialRecord.recordType = RecordType.SOWING;
          initialRecord.recordDate = product.plantingDate;
          initialRecord.stage = product.currentStage;
          initialRecord.notes = `修复数据：为${product.name}创建初始记录`;

          await FarmDatabase.addGrowthRecord(initialRecord);
          fixedCount++;
          hilog.info(0x0000, FarmDatabaseConstants.TAG, `为产品 ${product.name} 创建了初始记录`);
        }
      }

      // 4. 通知数据变化
      await FarmDatabase.notifyDataChange('all');

      hilog.info(0x0000, FarmDatabaseConstants.TAG, `数据同步修复完成，修复了 ${fixedCount} 个产品的记录`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, FarmDatabaseConstants.TAG,
        `修复数据同步失败. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }
}

export default FarmDatabase;