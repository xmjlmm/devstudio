// entry/src/main/ets/model/DataModel.ets

/**
 * 作物实体类 - 定义农场作物的数据结构
 */
export class Crop {
  id?: number; // 主键，自增
  name: string = '';
  plantDate: string = '';
  growthStage: string = '幼苗期';
  lastWatering: string = '';
  soilMoisture: number = 50;
  temperature: number = 25;
  healthStatus: string = 'healthy';
  expectedHarvest: string = '';
  notes: string = '';

  constructor(name?: string) {
    if (name) {
      this.name = name;
      this.plantDate = new Date().toISOString().split('T')[0];
    }
  }
}

/**
 * 任务实体类 - 定义农事任务数据结构
 */
export class Task {
  id?: number;
  title: string = '';
  description: string = '';
  dueDate: string = '';
  priority: number = 1;
  isCompleted: boolean = false;
  relatedCropId?: number;
  taskType: string = 'watering';

  constructor(title: string, dueDate: string) {
    this.title = title;
    this.dueDate = dueDate;
  }
}

/**
 * 天气数据实体类
 */
export class WeatherData {
  temperature: number = 0;
  humidity: number = 0;
  condition: string = '晴朗';
  windSpeed: number = 0;
  timestamp: string = '';
  location: string = '智慧农场';

  constructor() {
    this.timestamp = new Date().toISOString();
  }
}

/**
 * 用户设置实体类
 */
export class UserSettings {
  temperatureUnit: string = 'celsius';
  language: string = 'zh-CN';
  notificationEnabled: boolean = true;
  syncFrequency: number = 30;
}