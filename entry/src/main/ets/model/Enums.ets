/**
 * 智慧农场助手 - 枚举类型定义
 * 修复索引访问、映射类型和对象字面量错误
 */

// 产品类型枚举
export enum ProductType {
  VEGETABLE = 'vegetable',      // 蔬菜
  FRUIT = 'fruit',              // 水果
  GRAIN = 'grain',              // 谷物
  ROOT = 'root',                // 根茎类
  HERB = 'herb',                // 草本植物
  FLOWER = 'flower',            // 花卉
  OTHER = 'other'               // 其他
}

// 产品状态枚举
export enum ProductStatus {
  PLANTING = 'planting',        // 播种期
  GERMINATING = 'germinating',  // 发芽期
  GROWING = 'growing',          // 生长期
  FLOWERING = 'flowering',      // 开花期
  FRUITING = 'fruiting',        // 结果期
  HARVESTABLE = 'harvestable',  // 可收获
  HARVESTED = 'harvested',      // 已收获
  DORMANT = 'dormant'           // 休眠期
}

// 记录类型枚举
export enum RecordType {
  SOWING = 'sowing',            // 播种
  WATERING = 'watering',        // 浇水
  FERTILIZING = 'fertilizing',  // 施肥
  PRUNING = 'pruning',          // 修剪
  WEEDING = 'weeding',          // 除草
  PEST_CONTROL = 'pest_control', // 病虫害防治
  HARVESTING = 'harvesting',    // 收获
  OBSERVATION = 'observation',  // 观察记录
  MEASUREMENT = 'measurement',  // 测量记录
  OTHER = 'other'               // 其他
}

// 天气类型枚举
export enum WeatherType {
  SUNNY = 'sunny',              // 晴
  CLOUDY = 'cloudy',            // 多云
  OVERCAST = 'overcast',         // 阴
  LIGHT_RAIN = 'light_rain',     // 小雨
  MODERATE_RAIN = 'moderate_rain', // 中雨
  HEAVY_RAIN = 'heavy_rain',     // 大雨
  THUNDERSTORM = 'thunderstorm', // 雷阵雨
  SNOW = 'snow',                 // 雪
  FOG = 'fog',                   // 雾
  WINDY = 'windy',               // 风
  HAZE = 'haze'                  // 雾霾
}

// 季节枚举
export enum Season {
  SPRING = 'spring',            // 春季
  SUMMER = 'summer',            // 夏季
  AUTUMN = 'autumn',            // 秋季
  WINTER = 'winter'             // 冬季
}

// 温度单位枚举
export enum TemperatureUnit {
  CELSIUS = 'celsius',          // 摄氏度
  FAHRENHEIT = 'fahrenheit'     // 华氏度
}

// 测量单位枚举
export enum MeasurementUnit {
  GRAM = 'gram',                // 克
  KILOGRAM = 'kilogram',        // 千克
  CENTIMETER = 'centimeter',    // 厘米
  METER = 'meter',              // 米
  LITER = 'liter',              // 升
  MILLILITER = 'milliliter',    // 毫升
  PIECE = 'piece'               // 个/件
}

// 通知类型枚举
export enum NotificationType {
  WATERING_REMINDER = 'watering_reminder',      // 浇水提醒
  FERTILIZING_REMINDER = 'fertilizing_reminder', // 施肥提醒
  HARVEST_REMINDER = 'harvest_reminder',        // 收获提醒
  WEATHER_ALERT = 'weather_alert',              // 天气预警
  SYSTEM_NOTIFICATION = 'system_notification',  // 系统通知
  TASK_REMINDER = 'task_reminder'              // 任务提醒
}

// 任务优先级枚举
export enum TaskPriority {
  LOW = 'low',                  // 低优先级
  MEDIUM = 'medium',            // 中优先级
  HIGH = 'high',                // 高优先级
  URGENT = 'urgent'             // 紧急
}

// 设备状态枚举
export enum DeviceStatus {
  ONLINE = 'online',            // 在线
  OFFLINE = 'offline',          // 离线
  MAINTENANCE = 'maintenance',  // 维护中
  FAULT = 'fault'               // 故障
}

// 设备类型枚举
export enum DeviceType {
  SENSOR = 'sensor',            // 传感器
  IRRIGATION = 'irrigation',    // 灌溉设备
  LIGHTING = 'lighting',        // 光照设备
  VENTILATION = 'ventilation',  // 通风设备
  MONITORING = 'monitoring'     // 监控设备
}

// 用户角色枚举
export enum UserRole {
  ADMIN = 'admin',              // 管理员
  MANAGER = 'manager',          // 农场经理
  WORKER = 'worker',            // 工作人员
  VIEWER = 'viewer'             // 观察者
}

// 数据同步状态枚举
export enum SyncStatus {
  SYNCED = 'synced',            // 已同步
  PENDING = 'pending',          // 待同步
  SYNCING = 'syncing',          // 同步中
  FAILED = 'failed'             // 同步失败
}

// 显式类型定义 - 修复对象字面量错误
interface ProductTypeDisplayMap {
  VEGETABLE: string;
  FRUIT: string;
  GRAIN: string;
  ROOT: string;
  HERB: string;
  FLOWER: string;
  OTHER: string;
}

interface ProductStatusDisplayMap {
  PLANTING: string;
  GERMINATING: string;
  GROWING: string;
  FLOWERING: string;
  FRUITING: string;
  HARVESTABLE: string;
  HARVESTED: string;
  DORMANT: string;
}

interface RecordTypeDisplayMap {
  SOWING: string;
  WATERING: string;
  FERTILIZING: string;
  PRUNING: string;
  WEEDING: string;
  PEST_CONTROL: string;
  HARVESTING: string;
  OBSERVATION: string;
  MEASUREMENT: string;
  OTHER: string;
}

interface WeatherTypeDisplayMap {
  SUNNY: string;
  CLOUDY: string;
  OVERCAST: string;
  LIGHT_RAIN: string;
  MODERATE_RAIN: string;
  HEAVY_RAIN: string;
  THUNDERSTORM: string;
  SNOW: string;
  FOG: string;
  WINDY: string;
  HAZE: string;
}

interface WeatherTypeIconMap {
  SUNNY: string;
  CLOUDY: string;
  OVERCAST: string;
  LIGHT_RAIN: string;
  MODERATE_RAIN: string;
  HEAVY_RAIN: string;
  THUNDERSTORM: string;
  SNOW: string;
  FOG: string;
  WINDY: string;
  HAZE: string;
}

/**
 * 枚举工具类 - 修复索引访问和映射类型错误
 * 使用switch语句替代动态属性访问
 */
export class EnumUtils {
  /**
   * 获取产品类型的中文显示名称 - 使用switch替代映射类型
   */
  static getProductTypeDisplayName(type: ProductType): string {
    switch (type) {
      case ProductType.VEGETABLE:
        return '蔬菜';
      case ProductType.FRUIT:
        return '水果';
      case ProductType.GRAIN:
        return '谷物';
      case ProductType.ROOT:
        return '根茎类';
      case ProductType.HERB:
        return '草本植物';
      case ProductType.FLOWER:
        return '花卉';
      case ProductType.OTHER:
        return '其他';
      default:
        return '未知';
    }
  }

  /**
   * 获取产品状态的中文显示名称 - 使用switch替代映射类型
   */
  static getProductStatusDisplayName(status: ProductStatus): string {
    switch (status) {
      case ProductStatus.PLANTING:
        return '播种期';
      case ProductStatus.GERMINATING:
        return '发芽期';
      case ProductStatus.GROWING:
        return '生长期';
      case ProductStatus.FLOWERING:
        return '开花期';
      case ProductStatus.FRUITING:
        return '结果期';
      case ProductStatus.HARVESTABLE:
        return '可收获';
      case ProductStatus.HARVESTED:
        return '已收获';
      case ProductStatus.DORMANT:
        return '休眠期';
      default:
        return '未知';
    }
  }

  /**
   * 获取记录类型的中文显示名称 - 使用switch替代映射类型
   */
  static getRecordTypeDisplayName(type: RecordType): string {
    switch (type) {
      case RecordType.SOWING:
        return '播种';
      case RecordType.WATERING:
        return '浇水';
      case RecordType.FERTILIZING:
        return '施肥';
      case RecordType.PRUNING:
        return '修剪';
      case RecordType.WEEDING:
        return '除草';
      case RecordType.PEST_CONTROL:
        return '病虫害防治';
      case RecordType.HARVESTING:
        return '收获';
      case RecordType.OBSERVATION:
        return '观察记录';
      case RecordType.MEASUREMENT:
        return '测量记录';
      case RecordType.OTHER:
        return '其他';
      default:
        return '未知';
    }
  }

  /**
   * 获取天气类型的中文显示名称 - 使用switch替代映射类型
   */
  static getWeatherTypeDisplayName(type: WeatherType): string {
    switch (type) {
      case WeatherType.SUNNY:
        return '晴';
      case WeatherType.CLOUDY:
        return '多云';
      case WeatherType.OVERCAST:
        return '阴';
      case WeatherType.LIGHT_RAIN:
        return '小雨';
      case WeatherType.MODERATE_RAIN:
        return '中雨';
      case WeatherType.HEAVY_RAIN:
        return '大雨';
      case WeatherType.THUNDERSTORM:
        return '雷阵雨';
      case WeatherType.SNOW:
        return '雪';
      case WeatherType.FOG:
        return '雾';
      case WeatherType.WINDY:
        return '风';
      case WeatherType.HAZE:
        return '雾霾';
      default:
        return '未知';
    }
  }

  /**
   * 获取天气类型对应的图标 - 使用switch替代映射类型
   */
  static getWeatherTypeIcon(type: WeatherType): string {
    switch (type) {
      case WeatherType.SUNNY:
        return '☀️';
      case WeatherType.CLOUDY:
        return '⛅';
      case WeatherType.OVERCAST:
        return '☁️';
      case WeatherType.LIGHT_RAIN:
        return '🌦️';
      case WeatherType.MODERATE_RAIN:
        return '🌧️';
      case WeatherType.HEAVY_RAIN:
        return '⛈️';
      case WeatherType.THUNDERSTORM:
        return '🌩️';
      case WeatherType.SNOW:
        return '❄️';
      case WeatherType.FOG:
        return '🌫️';
      case WeatherType.WINDY:
        return '💨';
      case WeatherType.HAZE:
        return '😷';
      default:
        return '🌤️';
    }
  }

  /**
   * 获取季节的中文显示名称 - 使用switch替代映射类型
   */
  static getSeasonDisplayName(season: Season): string {
    switch (season) {
      case Season.SPRING:
        return '春季';
      case Season.SUMMER:
        return '夏季';
      case Season.AUTUMN:
        return '秋季';
      case Season.WINTER:
        return '冬季';
      default:
        return '未知';
    }
  }

  /**
   * 根据月份获取季节
   */
  static getSeasonByMonth(month: number): Season {
    if (month >= 3 && month <= 5) return Season.SPRING;
    if (month >= 6 && month <= 8) return Season.SUMMER;
    if (month >= 9 && month <= 11) return Season.AUTUMN;
    return Season.WINTER;
  }

  /**
   * 获取任务优先级的中文显示名称 - 使用switch替代映射类型
   */
  static getTaskPriorityDisplayName(priority: TaskPriority): string {
    switch (priority) {
      case TaskPriority.LOW:
        return '低';
      case TaskPriority.MEDIUM:
        return '中';
      case TaskPriority.HIGH:
        return '高';
      case TaskPriority.URGENT:
        return '紧急';
      default:
        return '未知';
    }
  }

  /**
   * 获取任务优先级的颜色 - 使用switch替代映射类型
   */
  static getTaskPriorityColor(priority: TaskPriority): string {
    switch (priority) {
      case TaskPriority.LOW:
        return '#4CAF50';     // 绿色
      case TaskPriority.MEDIUM:
        return '#FFA500';     // 橙色
      case TaskPriority.HIGH:
        return '#FF6B6B';     // 红色
      case TaskPriority.URGENT:
        return '#D32F2F';     // 深红色
      default:
        return '#666666';
    }
  }

  /**
   * 获取设备状态的中文显示名称 - 使用switch替代映射类型
   */
  static getDeviceStatusDisplayName(status: DeviceStatus): string {
    switch (status) {
      case DeviceStatus.ONLINE:
        return '在线';
      case DeviceStatus.OFFLINE:
        return '离线';
      case DeviceStatus.MAINTENANCE:
        return '维护中';
      case DeviceStatus.FAULT:
        return '故障';
      default:
        return '未知';
    }
  }

  /**
   * 获取设备状态的颜色 - 使用switch替代映射类型
   */
  static getDeviceStatusColor(status: DeviceStatus): string {
    switch (status) {
      case DeviceStatus.ONLINE:
        return '#4CAF50';      // 绿色
      case DeviceStatus.OFFLINE:
        return '#666666';       // 灰色
      case DeviceStatus.MAINTENANCE:
        return '#FFA500';      // 橙色
      case DeviceStatus.FAULT:
        return '#FF6B6B';      // 红色
      default:
        return '#666666';
    }
  }

  /**
   * 获取设备类型的中文显示名称 - 使用switch替代映射类型
   */
  static getDeviceTypeDisplayName(type: DeviceType): string {
    switch (type) {
      case DeviceType.SENSOR:
        return '传感器';
      case DeviceType.IRRIGATION:
        return '灌溉设备';
      case DeviceType.LIGHTING:
        return '光照设备';
      case DeviceType.VENTILATION:
        return '通风设备';
      case DeviceType.MONITORING:
        return '监控设备';
      default:
        return '未知';
    }
  }

  /**
   * 获取用户角色的中文显示名称 - 使用switch替代映射类型
   */
  static getUserRoleDisplayName(role: UserRole): string {
    switch (role) {
      case UserRole.ADMIN:
        return '管理员';
      case UserRole.MANAGER:
        return '农场经理';
      case UserRole.WORKER:
        return '工作人员';
      case UserRole.VIEWER:
        return '观察者';
      default:
        return '未知';
    }
  }

  /**
   * 获取测量单位的中文显示名称 - 使用switch替代映射类型
   */
  static getMeasurementUnitDisplayName(unit: MeasurementUnit): string {
    switch (unit) {
      case MeasurementUnit.GRAM:
        return '克';
      case MeasurementUnit.KILOGRAM:
        return '千克';
      case MeasurementUnit.CENTIMETER:
        return '厘米';
      case MeasurementUnit.METER:
        return '米';
      case MeasurementUnit.LITER:
        return '升';
      case MeasurementUnit.MILLILITER:
        return '毫升';
      case MeasurementUnit.PIECE:
        return '个';
      default:
        return '未知';
    }
  }

  /**
   * 获取温度单位的中文显示名称 - 使用switch替代映射类型
   */
  static getTemperatureUnitDisplayName(unit: TemperatureUnit): string {
    switch (unit) {
      case TemperatureUnit.CELSIUS:
        return '摄氏度';
      case TemperatureUnit.FAHRENHEIT:
        return '华氏度';
      default:
        return '未知';
    }
  }

  /**
   * 获取通知类型的中文显示名称 - 使用switch替代映射类型
   */
  static getNotificationTypeDisplayName(type: NotificationType): string {
    switch (type) {
      case NotificationType.WATERING_REMINDER:
        return '浇水提醒';
      case NotificationType.FERTILIZING_REMINDER:
        return '施肥提醒';
      case NotificationType.HARVEST_REMINDER:
        return '收获提醒';
      case NotificationType.WEATHER_ALERT:
        return '天气预警';
      case NotificationType.SYSTEM_NOTIFICATION:
        return '系统通知';
      case NotificationType.TASK_REMINDER:
        return '任务提醒';
      default:
        return '未知';
    }
  }

  /**
   * 获取同步状态的中文显示名称 - 使用switch替代映射类型
   */
  static getSyncStatusDisplayName(status: SyncStatus): string {
    switch (status) {
      case SyncStatus.SYNCED:
        return '已同步';
      case SyncStatus.PENDING:
        return '待同步';
      case SyncStatus.SYNCING:
        return '同步中';
      case SyncStatus.FAILED:
        return '同步失败';
      default:
        return '未知';
    }
  }
}