import { ProductType, ProductStatus } from './Enums';

/**
 * 农产品数据模型
 * 代表农场中的一个具体产品（如西红柿、黄瓜等）
 */
export class FarmProduct {
  id: number = 0;
  name: string = '';
  type: ProductType = ProductType.VEGETABLE;
  plantingDate: string = '';
  harvestDate: string = '';
  status: ProductStatus = ProductStatus.GROWING;
  currentStage: string = '播种期';
  temperature: number = 0;
  humidity: number = 0;
  imageUrl: string = '';
  description: string = '';
  createdAt: string = '';
  // 关联的生长记录
  growthRecords: GrowthRecord[] = [];

  constructor() {
    const now = new Date().toISOString();
    this.plantingDate = now.split('T')[0];
    this.createdAt = now;
  }
}

/**
 * 生长记录数据模型
 * 记录产品生长过程中的关键事件和数据
 */
export class GrowthRecord {
  id: number = 0;
  productId: number = 0;
  productName: string = '';
  recordType: string = '';
  recordDate: string = '';
  stage: string = '';
  height: number = 0;
  weight: number = 0;
  notes: string = '';
  images: string[] = [];
  temperature: number = 0;
  humidity: number = 0;
  createdAt: string = '';

  constructor() {
    const now = new Date().toISOString();
    this.recordDate = now.split('T')[0];
    this.createdAt = now;
  }
}

/**
 * 天气信息数据模型
 * 包含当前天气和天气预报信息
 */
export class WeatherInfo {
  city: string = '未知';
  temperature: number = 0;
  weather: string = '晴';
  humidity: number = 0;
  windSpeed: number = 0;
  updateTime: string = '';
  forecast: WeatherForecast[] = [];

  constructor() {
    this.updateTime = new Date().toISOString();
  }
}

/**
 * 天气预报数据模型
 * 单日天气预报信息
 */
export class WeatherForecast {
  date: string = '';
  weather: string = '';
  maxTemp: number = 0;
  minTemp: number = 0;

  constructor() {
    this.date = new Date().toISOString().split('T')[0];
  }
}

/**
 * 农场概览数据模型
 * 包含农场的整体统计信息
 */
export class FarmData {
  name: string = '';
  description: string = '';
  totalProducts: number = 0;
  growingCount: number = 0;
  todayTasks: number = 0;
  onlineDevices: number = 0;

  constructor(name?: string, description?: string, totalProducts?: number,
    growingCount?: number, todayTasks?: number, onlineDevices?: number) {
    this.name = name || '智慧农场';
    this.description = description || '现代化智能农业示范基地';
    this.totalProducts = totalProducts || 0;
    this.growingCount = growingCount || 0;
    this.todayTasks = todayTasks || 0;
    this.onlineDevices = onlineDevices || 0;
  }
}

/**
 * 产品统计信息数据模型
 * 按类型和状态分类的产品统计
 */
export class ProductStatistics {
  total: number = 0;
  byType: Record<string, number> = {};
  byStatus: Record<string, number> = {};

  constructor(total?: number, byType?: Record<string, number>, byStatus?: Record<string, number>) {
    if (total !== undefined) {
      this.total = total;
    }
    if (byType !== undefined) {
      this.byType = byType;
    }
    if (byStatus !== undefined) {
      this.byStatus = byStatus;
    }
  }
}

/**
 * 生长记录统计信息接口
 */
export interface GrowthRecordStatistics {
  total: number;
  byType: Record<string, number>;
}

/**
 * 活动记录数据模型
 * 用于首页显示最新动态和活动记录
 */
export class Activity {
  id: number = 0;
  type: string = '';
  title: string = '';
  time: string = '';
  status: string = '';
  icon: string = '';
  color: string = '';
  statusColor: string = '';
  statusBgColor: string = '';

  constructor() {
    this.time = new Date().toLocaleTimeString('zh-CN', {
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}

/**
 * 产品筛选条件接口
 * 用于产品列表的查询和筛选
 */
export interface ProductFilters {
  type?: string;
  status?: string;
  searchKeyword?: string;
  limit?: number;
  offset?: number;
}

/**
 * 分页结果接口
 * 通用分页数据结构
 */
export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

/**
 * 设备信息数据模型
 * 物联网设备信息
 */
export class DeviceInfo {
  id: number = 0;
  name: string = '';
  type: string = '';
  status: string = '';
  ipAddress: string = '';
  lastSeen: string = '';
  temperature: number = 0;
  humidity: number = 0;

  constructor() {
    this.lastSeen = new Date().toISOString();
  }
}

/**
 * 农场任务数据模型
 * 日常任务和计划任务
 */
export class FarmTask {
  id: number = 0;
  title: string = '';
  type: string = '';
  priority: string = '';
  dueDate: string = '';
  assignedTo: string = '';
  status: string = '';
  description: string = '';
  productId?: number;
  completed: boolean = false;

  constructor() {
    this.dueDate = new Date().toISOString().split('T')[0];
  }
}

/**
 * 用户设置数据模型
 * 用户个性化设置和系统配置
 */
export class UserSettings {
  userName: string = '农场管理员';
  farmName: string = '智慧农场';
  temperatureUnit: string = 'celsius';
  measurementUnit: string = 'metric';
  language: string = 'zh-CN';
  notificationsEnabled: boolean = true;
  autoSyncEnabled: boolean = true;
  theme: string = 'light';

  constructor() {
  }
}

/**
 * API响应包装类
 * 统一API响应格式
 */
export class ApiResponse<T> {
  success: boolean = true;
  data: T | null = null;
  message: string = '';
  code: number = 200;

  constructor(data?: T) {
    if (data) {
      this.data = data;
    }
  }
}

/**
 * 错误信息数据模型
 * 统一错误处理格式
 */
export class ErrorInfo {
  code: number = 0;
  message: string = '';
  details: object | null = null;
  timestamp: string = '';

  constructor(code: number, message: string, details?: object) {
    this.code = code;
    this.message = message;
    this.details = details || null;
    this.timestamp = new Date().toISOString();
  }
}

/**
 * 实用类型定义
 * 基于TypeScript实用类型的辅助类型
 */

// 部分更新类型
export type PartialFarmProduct = Partial<FarmProduct>;

export type PartialGrowthRecord = Partial<GrowthRecord>;

// 用于表单的简化类型
export class FarmProductForm {
  name: string = '';
  type: ProductType = ProductType.VEGETABLE;
  plantingDate: string = '';
  currentStage: string = '播种期';
  temperature: number = 0;
  humidity: number = 0;
  description: string = '';
}

export class GrowthRecordForm {
  productId: number = 0;
  recordType: string = '';
  stage: string = '';
  height: number = 0;
  weight: number = 0;
  notes: string = '';
  temperature: number = 0;
  humidity: number = 0;
}

// 用于显示的只读类型
export type ReadonlyFarmProduct = Readonly<FarmProduct>;

export type ReadonlyGrowthRecord = Readonly<GrowthRecord>;

// 字典类型
export type ProductDictionary = Record<number, FarmProduct>;

export type RecordDictionary = Record<number, GrowthRecord>;

/**
 * 类型检查函数
 * 用于运行时类型检查
 */
export function isFarmProduct(obj: object): boolean {
  const typedObj = obj as Record<string, string | number | boolean | object>;
  return obj && typeof typedObj.id === 'number' && typeof typedObj.name === 'string';
}

export function isGrowthRecord(obj: object): boolean {
  const typedObj = obj as Record<string, string | number | boolean | object>;
  return obj && typeof typedObj.id === 'number' && typeof typedObj.productId === 'number';
}

export function isWeatherInfo(obj: object): boolean {
  const typedObj = obj as Record<string, string | number | boolean | object>;
  return obj && typeof typedObj.temperature === 'number' && typeof typedObj.weather === 'string';
}

/**
 * 数据转换函数
 * 用于在不同格式间转换数据
 */
// 从API数据创建FarmProduct实例
export function createFarmProductFromApi(data: object): FarmProduct {
  const product = new FarmProduct();
  // 使用已知的属性名手动赋值，避免使用受限的API
  const dataObj = data as Record<string, string | number | boolean | object>;

  // 手动复制已知属性
  if (dataObj.id !== undefined) {
    product.id = dataObj.id as number;
  }
  if (dataObj.name !== undefined) {
    product.name = dataObj.name as string;
  }
  if (dataObj.type !== undefined) {
    product.type = dataObj.type as ProductType;
  }
  if (dataObj.plantingDate !== undefined) {
    product.plantingDate = dataObj.plantingDate as string;
  }
  if (dataObj.harvestDate !== undefined) {
    product.harvestDate = dataObj.harvestDate as string;
  }
  if (dataObj.status !== undefined) {
    product.status = dataObj.status as ProductStatus;
  }
  if (dataObj.currentStage !== undefined) {
    product.currentStage = dataObj.currentStage as string;
  }
  if (dataObj.temperature !== undefined) {
    product.temperature = dataObj.temperature as number;
  }
  if (dataObj.humidity !== undefined) {
    product.humidity = dataObj.humidity as number;
  }
  if (dataObj.imageUrl !== undefined) {
    product.imageUrl = dataObj.imageUrl as string;
  }
  if (dataObj.description !== undefined) {
    product.description = dataObj.description as string;
  }
  if (dataObj.createdAt !== undefined) {
    product.createdAt = dataObj.createdAt as string;
  }
  if (dataObj.growthRecords !== undefined) {
    product.growthRecords = dataObj.growthRecords as GrowthRecord[];
  }

  return product;
}

// 从API数据创建GrowthRecord实例
export function createGrowthRecordFromApi(data: object): GrowthRecord {
  const record = new GrowthRecord();
  // 使用已知的属性名手动赋值，避免使用受限的API
  const dataObj = data as Record<string, string | number | boolean | object>;

  // 手动复制已知属性
  if (dataObj.id !== undefined) {
    record.id = dataObj.id as number;
  }
  if (dataObj.productId !== undefined) {
    record.productId = dataObj.productId as number;
  }
  if (dataObj.productName !== undefined) {
    record.productName = dataObj.productName as string;
  }
  if (dataObj.recordType !== undefined) {
    record.recordType = dataObj.recordType as string;
  }
  if (dataObj.recordDate !== undefined) {
    record.recordDate = dataObj.recordDate as string;
  }
  if (dataObj.stage !== undefined) {
    record.stage = dataObj.stage as string;
  }
  if (dataObj.height !== undefined) {
    record.height = dataObj.height as number;
  }
  if (dataObj.weight !== undefined) {
    record.weight = dataObj.weight as number;
  }
  if (dataObj.notes !== undefined) {
    record.notes = dataObj.notes as string;
  }
  if (dataObj.images !== undefined) {
    record.images = dataObj.images as string[];
  }
  if (dataObj.temperature !== undefined) {
    record.temperature = dataObj.temperature as number;
  }
  if (dataObj.humidity !== undefined) {
    record.humidity = dataObj.humidity as number;
  }
  if (dataObj.createdAt !== undefined) {
    record.createdAt = dataObj.createdAt as string;
  }

  return record;
}

// 将对象转换为查询参数
export function toQueryParams(filters: ProductFilters): string {
  // 手动构建查询字符串，避免使用受限的URLSearchParams
  const params: string[] = [];
  const filtersObj = filters as Record<string, string | number | boolean | object>;

  // 手动处理已知的过滤属性
  if (filtersObj.name !== undefined && filtersObj.name !== null) {
    params.push(`name=${encodeURIComponent(filtersObj.name.toString())}`);
  }
  if (filtersObj.type !== undefined && filtersObj.type !== null) {
    params.push(`type=${encodeURIComponent(filtersObj.type.toString())}`);
  }
  if (filtersObj.status !== undefined && filtersObj.status !== null) {
    params.push(`status=${encodeURIComponent(filtersObj.status.toString())}`);
  }
  if (filtersObj.minTemperature !== undefined && filtersObj.minTemperature !== null) {
    params.push(`minTemperature=${encodeURIComponent(filtersObj.minTemperature.toString())}`);
  }
  if (filtersObj.maxTemperature !== undefined && filtersObj.maxTemperature !== null) {
    params.push(`maxTemperature=${encodeURIComponent(filtersObj.maxTemperature.toString())}`);
  }
  if (filtersObj.minHumidity !== undefined && filtersObj.minHumidity !== null) {
    params.push(`minHumidity=${encodeURIComponent(filtersObj.minHumidity.toString())}`);
  }
  if (filtersObj.maxHumidity !== undefined && filtersObj.maxHumidity !== null) {
    params.push(`maxHumidity=${encodeURIComponent(filtersObj.maxHumidity.toString())}`);
  }
  return params.length > 0 ? '?' + params.join('&') : '';
}

/**
 * 类型选项接口
 * 用于筛选和下拉选项的类型定义
 */
export interface TypeOption {
  value: string;
  label: string;
}