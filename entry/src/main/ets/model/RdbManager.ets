// entry/src/main/ets/model/RdbManager.ets
import relationalStore from '@ohos.data.relationalStore';
import { Crop, Task, WeatherData } from './DataModel';

export class RdbManager {
  private static rdbStore: relationalStore.RdbStore;
  private static readonly DB_NAME = 'farm_assistant.db';
  // 初始化数据库
  static async initRdbStore(context: Context): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: RdbManager.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    const SQL_CREATE_CROP_TABLE = `
      CREATE TABLE IF NOT EXISTS crops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        plantDate TEXT,
        growthStage TEXT,
        lastWatering TEXT,
        soilMoisture REAL,
        temperature REAL,
        healthStatus TEXT,
        expectedHarvest TEXT,
        notes TEXT
      )`;

    const SQL_CREATE_TASK_TABLE = `
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        priority INTEGER,
        isCompleted INTEGER DEFAULT 0,
        relatedCropId INTEGER,
        taskType TEXT
      )`;

    try {
      RdbManager.rdbStore = await relationalStore.getRdbStore(context, config);
      await RdbManager.rdbStore.executeSql(SQL_CREATE_CROP_TABLE);
      await RdbManager.rdbStore.executeSql(SQL_CREATE_TASK_TABLE);
      console.info('数据库初始化成功');
    } catch (error) {
      console.error('数据库初始化失败:', error);
      throw new Error('数据库初始化失败');
    }
  }

  // 插入作物数据
  static async insertCrop(crop: Crop): Promise<number> {
    const valueBucket = {
      'name': crop.name,
      'plantDate': crop.plantDate,
      'growthStage': crop.growthStage,
      'lastWatering': crop.lastWatering,
      'soilMoisture': crop.soilMoisture,
      'temperature': crop.temperature,
      'healthStatus': crop.healthStatus,
      'expectedHarvest': crop.expectedHarvest,
      'notes': crop.notes
    };
    return await this.rdbStore.insert('crops', valueBucket);
  }

  // 查询所有作物
  static async queryAllCrops(): Promise<Crop[]> {
    const predicates = new relationalStore.RdbPredicates('crops');
    const resultSet = await this.rdbStore.query(predicates, ['*']);
    const crops: Crop[] = [];

    if (resultSet.rowCount > 0) {
      while (resultSet.goToNextRow()) {
        const crop = new Crop();
        crop.id = resultSet.getLong(resultSet.getColumnIndex('id'));
        crop.name = resultSet.getString(resultSet.getColumnIndex('name'));
        crop.plantDate = resultSet.getString(resultSet.getColumnIndex('plantDate'));
        crop.growthStage = resultSet.getString(resultSet.getColumnIndex('growthStage'));
        crop.lastWatering = resultSet.getString(resultSet.getColumnIndex('lastWatering'));
        crop.soilMoisture = resultSet.getDouble(resultSet.getColumnIndex('soilMoisture'));
        crop.temperature = resultSet.getDouble(resultSet.getColumnIndex('temperature'));
        crop.healthStatus = resultSet.getString(resultSet.getColumnIndex('healthStatus'));
        crop.expectedHarvest = resultSet.getString(resultSet.getColumnIndex('expectedHarvest'));
        crop.notes = resultSet.getString(resultSet.getColumnIndex('notes'));
        crops.push(crop);
      }
    }
    resultSet.close();
    return crops;
  }

  // 查询待办任务数量
  static async queryPendingTaskCount(): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('tasks');
    predicates.equalTo('isCompleted', 0);

    const resultSet = await this.rdbStore.query(predicates, ['COUNT(*) as count']);
    let count = 0;

    if (resultSet.goToFirstRow()) {
      count = resultSet.getLong(resultSet.getColumnIndex('count'));
    }
    resultSet.close();
    return count;
  }

  // 更新作物信息
  static async updateCrop(crop: Crop): Promise<number> {
    const valueBucket = {
      'name': crop.name,
      'growthStage': crop.growthStage,
      'lastWatering': crop.lastWatering,
      'soilMoisture': crop.soilMoisture,
      'temperature': crop.temperature,
      'healthStatus': crop.healthStatus,
      'expectedHarvest': crop.expectedHarvest,
      'notes': crop.notes
    };

    const predicates = new relationalStore.RdbPredicates('crops');
    predicates.equalTo('id', crop.id);

    return await this.rdbStore.update(valueBucket, predicates);
  }

  // 删除作物
  static async deleteCrop(cropId: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('crops');
    predicates.equalTo('id', cropId);
    return await this.rdbStore.delete(predicates);
  }
}