// utils/WeatherUtils.ts
// 温度单位接口
interface TemperatureUnitsType {
  CELSIUS: string;
  FAHRENHEIT: string;
}

// 风速单位接口
interface SpeedUnitsType {
  KMPH: string;
  MPH: string;
  MPS: string;
}

// 风速等级接口
interface WindSpeedLevelType {
  max: number;
  level: number;
  description: string;
}

// AQI等级接口
interface AQILevelType {
  max: number;
  level: string;
  color: string;
  description: string;
}

// UV等级接口
interface UVLevelType {
  max: number;
  level: string;
  color: string;
  protection: string;
}

// AQI信息接口
interface AQIInfoType {
  level: string;
  color: string;
  description: string;
}

// UV信息接口
interface UVInfoType {
  level: string;
  color: string;
  protection: string;
}

// 天气数据验证接口
interface WeatherDataValidationType {
  temperature?: number;
  humidity?: number;
  windSpeed?: number;
}

// 验证结果接口
interface ValidationResultType {
  isValid: boolean;
  errors: string[];
}

/**
 * 天气工具类 - 提供天气相关的各种实用功能
 * 包括单位转换、图标映射、舒适度评估、农业建议等
 */
export class WeatherUtils {
  // 温度单位枚举
  static readonly TemperatureUnits: TemperatureUnitsType = {
    CELSIUS: 'celsius',
    FAHRENHEIT: 'fahrenheit'
  };
  // 风速单位枚举
  static readonly SpeedUnits: SpeedUnitsType = {
    KMPH: 'km/h', // 公里/小时
    MPH: 'mph', // 英里/小时
    MPS: 'm/s'       // 米/秒
  };
  // 天气图标映射 [4](@ref)
  private static readonly WEATHER_ICON_MAP: Record<string, string> = {
    // 晴好天气
    '晴': '☀️',
    '晴朗': '☀️',
    'clear': '☀️',
    'sunny': '☀️',

    // 多云天气
    '多云': '⛅',
    '少云': '🌤️',
    '晴间多云': '🌤️',
    'cloudy': '⛅',
    'partly cloudy': '🌤️',

    // 阴天
    '阴': '☁️',
    '阴天': '☁️',
    'overcast': '☁️',

    // 雨
    '小雨': '🌦️',
    '中雨': '🌧️',
    '大雨': '⛈️',
    '暴雨': '⛈️',
    '雷阵雨': '🌩️',
    '阵雨': '🌦️',
    '毛毛雨': '🌦️',
    'rain': '🌧️',
    'light rain': '🌦️',
    'heavy rain': '⛈️',
    'thunderstorm': '🌩️',

    // 雪
    '小雪': '🌨️',
    '中雪': '❄️',
    '大雪': '☃️',
    '暴雪': '☃️',
    '雨夹雪': '🌨️',
    'snow': '❄️',
    'light snow': '🌨️',
    'heavy snow': '☃️',
    'sleet': '🌨️',

    // 特殊天气
    '雾': '🌫️',
    '雾霾': '🌫️',
    '沙尘': '🌪️',
    '扬沙': '🌪️',
    '浮尘': '🌪️',
    '沙尘暴': '🌪️',
    'fog': '🌫️',
    'haze': '🌫️',
    'dust': '🌪️',
    'sand': '🌪️'
  };
  // 风向映射 [1](@ref)
  private static readonly WIND_DIRECTION_MAP: Record<string, string> = {
    'N': '北风',
    'NNE': '北东北风',
    'NE': '东北风',
    'ENE': '东东北风',
    'E': '东风',
    'ESE': '东东南风',
    'SE': '东南风',
    'SSE': '南东南风',
    'S': '南风',
    'SSW': '南西南风',
    'SW': '西南风',
    'WSW': '西西南风',
    'W': '西风',
    'WNW': '西西北风',
    'NW': '西北风',
    'NNW': '北西北风'
  };
  // 风速等级描述 [1](@ref)
  private static readonly WIND_SPEED_LEVELS: WindSpeedLevelType[] = [
    { max: 0.2, level: 0, description: '无风' } as WindSpeedLevelType,
    { max: 1.5, level: 1, description: '软风' } as WindSpeedLevelType,
    { max: 3.3, level: 2, description: '轻风' } as WindSpeedLevelType,
    { max: 5.4, level: 3, description: '微风' } as WindSpeedLevelType,
    { max: 7.9, level: 4, description: '和风' } as WindSpeedLevelType,
    { max: 10.7, level: 5, description: '清劲风' } as WindSpeedLevelType,
    { max: 13.8, level: 6, description: '强风' } as WindSpeedLevelType,
    { max: 17.1, level: 7, description: '疾风' } as WindSpeedLevelType,
    { max: 20.7, level: 8, description: '大风' } as WindSpeedLevelType,
    { max: 24.4, level: 9, description: '烈风' } as WindSpeedLevelType,
    { max: 28.4, level: 10, description: '狂风' } as WindSpeedLevelType,
    { max: 32.6, level: 11, description: '暴风' } as WindSpeedLevelType,
    { max: 36.9, level: 12, description: '飓风' } as WindSpeedLevelType,
    { max: 41.4, level: 13, description: '强飓风' } as WindSpeedLevelType
  ];
  // AQI空气质量描述 [5](@ref)
  private static readonly AQI_LEVELS: AQILevelType[] = [
    {
      max: 50,
      level: '优',
      color: '#4CAF50',
      description: '空气质量令人满意'
    },
    {
      max: 100,
      level: '良',
      color: '#8BC34A',
      description: '空气质量可接受'
    },
    {
      max: 150,
      level: '轻度污染',
      color: '#FFC107',
      description: '敏感人群有影响'
    },
    {
      max: 200,
      level: '中度污染',
      color: '#FF9800',
      description: '对敏感人群影响较大'
    },
    {
      max: 300,
      level: '重度污染',
      color: '#F44336',
      description: '对健康有影响'
    },
    {
      max: 500,
      level: '严重污染',
      color: '#9C27B0',
      description: '健康威胁严重'
    }
  ];
  // UV指数描述
  private static readonly UV_LEVELS: UVLevelType[] = [
    {
      max: 2,
      level: '低',
      color: '#4CAF50',
      protection: '无需防护'
    },
    {
      max: 5,
      level: '中等',
      color: '#FFC107',
      protection: '需要防护'
    },
    {
      max: 7,
      level: '高',
      color: '#FF9800',
      protection: '加强防护'
    },
    {
      max: 10,
      level: '很高',
      color: '#F44336',
      protection: '必须防护'
    },
    {
      max: 100,
      level: '极高',
      color: '#9C27B0',
      protection: '避免外出'
    }
  ];

  /**
   * 根据天气类型获取对应的图标 [4](@ref)
   * @param weatherType 天气类型字符串
   * @returns 对应的天气图标
   */
  static getWeatherIcon(weatherType: string): string {
    if (!weatherType) {
      return '🌤️';
    }

    const normalizedType = weatherType.toLowerCase().trim();
    // 精确匹配
    for (const entry of Object.entries(WeatherUtils.WEATHER_ICON_MAP)) {
      if (normalizedType.includes(entry[0].toLowerCase())) {
        return entry[1];
      }
    }

    return '🌤️'; // 默认图标
  }

  /**
   * 摄氏度转华氏度 [1](@ref)
   * @param celsius 摄氏温度
   * @returns 华氏温度
   */
  static celsiusToFahrenheit(celsius: number): number {
    return (celsius * 9 / 5) + 32;
  }

  /**
   * 华氏度转摄氏度 [1](@ref)
   * @param fahrenheit 华氏温度
   * @returns 摄氏温度
   */
  static fahrenheitToCelsius(fahrenheit: number): number {
    return (fahrenheit - 32) * 5 / 9;
  }

  /**
   * 公里/小时转米/秒 [1](@ref)
   * @param kmph 公里每小时
   * @returns 米每秒
   */
  static kmphToMps(kmph: number): number {
    return kmph / 3.6;
  }

  /**
   * 英里/小时转公里/小时 [1](@ref)
   * @param mph 英里每小时
   * @returns 公里每小时
   */
  static mphToKmph(mph: number): number {
    return mph * 1.60934;
  }

  /**
   * 英里/小时转米/秒 [1](@ref)
   * @param mph 英里每小时
   * @returns 米每秒
   */
  static mphToMps(mph: number): number {
    return mph * 0.44704;
  }

  /**
   * 根据温度获取舒适度评价
   * @param temperature 温度值
   * @param unit 温度单位，默认为摄氏度
   * @returns 舒适度描述
   */
  static getComfortLevel(temperature: number, unit: string = WeatherUtils.TemperatureUnits.CELSIUS): string {
    let temp = temperature;

    // 如果是华氏度，先转换为摄氏度
    if (unit === WeatherUtils.TemperatureUnits.FAHRENHEIT) {
      temp = WeatherUtils.fahrenheitToCelsius(temp);
    }

    if (temp < 0) {
      return '严寒';
    }
    if (temp < 10) {
      return '寒冷';
    }
    if (temp < 18) {
      return '凉爽';
    }
    if (temp < 26) {
      return '舒适';
    }
    if (temp < 32) {
      return '温暖';
    }
    if (temp < 38) {
      return '炎热';
    }
    return '酷热';
  }

  /**
   * 获取舒适度对应的颜色
   * @param temperature 温度值
   * @param unit 温度单位
   * @returns 颜色值
   */
  static getComfortColor(temperature: number, unit: string = WeatherUtils.TemperatureUnits.CELSIUS): string {
    let temp = temperature;

    if (unit === WeatherUtils.TemperatureUnits.FAHRENHEIT) {
      temp = WeatherUtils.fahrenheitToCelsius(temp);
    }

    if (temp < 0) {
      return '#4FC3F7';
    } // 蓝色 - 严寒
    if (temp < 10) {
      return '#81D4FA';
    } // 浅蓝 - 寒冷
    if (temp < 18) {
      return '#4CAF50';
    } // 绿色 - 凉爽
    if (temp < 26) {
      return '#66BB6A';
    } // 舒适绿 - 舒适
    if (temp < 32) {
      return '#FF9800';
    } // 橙色 - 温暖
    if (temp < 38) {
      return '#F44336';
    } // 红色 - 炎热
    return '#9C27B0'; // 紫色 - 酷热
  }

  /**
   * 根据风速获取风级描述 [1](@ref)
   * @param speed 风速值
   * @param unit 风速单位，默认为km/h
   * @returns 风级描述
   */
  static getWindLevel(speed: number, unit: string = WeatherUtils.SpeedUnits.KMPH): string {
    let speedMps = speed;

    // 转换为米/秒进行统一比较
    switch (unit) {
      case WeatherUtils.SpeedUnits.KMPH:
        speedMps = WeatherUtils.kmphToMps(speed);
        break;
      case WeatherUtils.SpeedUnits.MPH:
        speedMps = WeatherUtils.mphToMps(speed);
        break;
      case WeatherUtils.SpeedUnits.MPS:
        speedMps = speed;
        break;
    }

    for (const level of WeatherUtils.WIND_SPEED_LEVELS) {
      if (speedMps <= level.max) {
        return `${level.description}(${level.level}级)`;
      }
    }

    return '强飓风(13级以上)';
  }

  /**
   * 根据风向缩写获取中文风向描述 [1](@ref)
   * @param direction 风向缩写
   * @returns 中文风向描述
   */
  static getWindDirectionText(direction: string): string {
    return WeatherUtils.WIND_DIRECTION_MAP[direction.toUpperCase()] || direction;
  }

  /**
   * 根据风向角度获取风向描述
   * @param degrees 风向角度(0-360度)
   * @returns 中文风向描述
   */
  static getWindDirectionFromDegrees(degrees: number): string {
    const directions = ['北风', '东北风', '东风', '东南风', '南风', '西南风', '西风', '西北风'];
    const index = Math.round((degrees % 360) / 45) % 8;
    return directions[index];
  }

  /**
   * 获取农业天气建议 [5](@ref)
   * @param weather 天气状况
   * @param temperature 温度
   * @param humidity 湿度
   * @param unit 温度单位
   * @returns 农业建议字符串
   */
  static getFarmAdvice(weather: string, temperature: number, humidity?: number,
    unit: string = WeatherUtils.TemperatureUnits.CELSIUS): string {
    let temp = temperature;
    if (unit === WeatherUtils.TemperatureUnits.FAHRENHEIT) {
      temp = WeatherUtils.fahrenheitToCelsius(temp);
    }

    let advice = '当前天气条件适宜大多数作物生长。';

    // 基于温度的建议
    if (temp < 5) {
      advice = '气温较低，建议采取保温措施，注意防寒防冻。';
    } else if (temp > 35) {
      advice = '气温较高，注意及时灌溉，防止作物热害。';
    }

    // 基于天气的建议
    if (weather.includes('雨')) {
      if (weather.includes('小雨') || weather.includes('毛毛雨')) {
        advice += ' 有小雨，有利于作物生长，可减少灌溉。';
      } else if (weather.includes('大雨') || weather.includes('暴雨')) {
        advice += ' 有强降雨，注意排水防涝，检查农田设施。';
      } else {
        advice += ' 有降雨，注意田间排水。';
      }
    } else if (weather.includes('晴')) {
      advice += ' 天气晴朗，适合进行施肥、除草等田间管理。';
    } else if (weather.includes('雪')) {
      advice += ' 有降雪，温室作物需加强保温，露地作物注意防冻。';
    } else if (weather.includes('风')) {
      advice += ' 有风天气，注意保护大棚等农业设施。';
    }

    // 基于湿度的建议
    if (humidity !== undefined) {
      if (humidity < 30) {
        advice += ' 空气干燥，需增加灌溉频率。';
      } else if (humidity > 80) {
        advice += ' 湿度过高，注意防治病虫害。';
      }
    }

    return advice;
  }

  /**
   * 获取AQI空气质量描述 [5](@ref)
   * @param aqi AQI数值
   * @returns 空气质量信息对象
   */
  static getAQIInfo(aqi: number): AQIInfoType {
    for (const level of WeatherUtils.AQI_LEVELS) {
      if (aqi <= level.max) {
        return {
          level: level.level,
          color: level.color,
          description: level.description
        };
      }
    }
    return { level: '未知', color: '#666666', description: '数据异常' };
  }

  /**
   * 获取AQI空气质量描述
   * @param aqi AQI数值
   * @returns 空气质量描述字符串
   */
  static getAQIDescription(aqi: number): string {
    return WeatherUtils.getAQIInfo(aqi).description;
  }

  /**
   * 获取AQI对应的颜色
   * @param aqi AQI数值
   * @returns 颜色值
   */
  static getAQIColor(aqi: number): string {
    return WeatherUtils.getAQIInfo(aqi).color;
  }

  /**
   * 获取UV指数防护建议
   * @param uvIndex UV指数
   * @returns UV防护信息
   */
  static getUVIndexInfo(uvIndex: number): UVInfoType {
    for (const level of WeatherUtils.UV_LEVELS) {
      if (uvIndex <= level.max) {
        return {
          level: level.level,
          color: level.color,
          protection: level.protection
        };
      }
    }
    return { level: '极高', color: '#9C27B0', protection: '避免外出' };
  }

  /**
   * 获取温度显示（支持单位转换）
   * @param temp 温度值
   * @param fromUnit 原始单位
   * @param toUnit 目标单位
   * @param decimals 小数位数
   * @returns 格式化后的温度字符串
   */
  static getFormattedTemperature(temp: number, fromUnit: string, toUnit: string, decimals: number = 1): string {
    if (fromUnit === toUnit) {
      return `${temp.toFixed(decimals)}${WeatherUtils.getTemperatureUnitSymbol(toUnit)}`;
    }

    let convertedTemp = temp;

    if (fromUnit === WeatherUtils.TemperatureUnits.CELSIUS && toUnit === WeatherUtils.TemperatureUnits.FAHRENHEIT) {
      convertedTemp = WeatherUtils.celsiusToFahrenheit(temp);
    } else if (fromUnit === WeatherUtils.TemperatureUnits.FAHRENHEIT &&
      toUnit === WeatherUtils.TemperatureUnits.CELSIUS) {
      convertedTemp = WeatherUtils.fahrenheitToCelsius(temp);
    }

    return `${convertedTemp.toFixed(decimals)}${WeatherUtils.getTemperatureUnitSymbol(toUnit)}`;
  }

  /**
   * 获取温度单位符号
   * @param unit 温度单位
   * @returns 单位符号
   */
  static getTemperatureUnitSymbol(unit: string): string {
    return unit === WeatherUtils.TemperatureUnits.FAHRENHEIT ? '°F' : '°C';
  }

  /**
   * 获取天气背景色（用于UI主题）
   * @param weather 天气类型
   * @param isDaytime 是否为白天
   * @returns 背景颜色
   */
  static getWeatherBackground(weather: string, isDaytime: boolean = true): string {
    const backgroundMap: Record<string, string> = {
      '晴': isDaytime ? '#FFF9C4' : '#FFFDE7', // 浅黄色/浅米色
      '多云': isDaytime ? '#F5F5F5' : '#EEEEEE', // 浅灰色
      '阴': isDaytime ? '#E0E0E0' : '#BDBDBD', // 灰色
      '雨': isDaytime ? '#E3F2FD' : '#BBDEFB', // 浅蓝色
      '雪': isDaytime ? '#E0F7FA' : '#B2EBF2', // 冰蓝色
      '雾': isDaytime ? '#FAFAFA' : '#F5F5F5', // 白色
      '风': isDaytime ? '#F3E5F5' : '#E1BEE7'       // 浅紫色
    };
    for (const entry of Object.entries(backgroundMap)) {
      if (weather.includes(entry[0])) {
        return entry[1];
      }
    }

    return isDaytime ? '#E8F5E8' : '#C8E6C9'; // 默认浅绿色
  }

  /**
   * 格式化时间显示
   * @param timestamp 时间戳或日期字符串
   * @returns 格式化的时间字符串 (HH:MM)
   */
  static formatTime(timestamp: number | string): string {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  /**
   * 获取季节信息
   * @param month 月份 (1-12)
   * @returns 季节名称
   */
  static getSeason(month: number): string {
    if (month >= 3 && month <= 5) {
      return '春季';
    }
    if (month >= 6 && month <= 8) {
      return '夏季';
    }
    if (month >= 9 && month <= 11) {
      return '秋季';
    }
    return '冬季';
  }

  /**
   * 计算体感温度
   * @param temperature 实际温度
   * @param humidity 湿度百分比
   * @param windSpeed 风速 (km/h)
   * @param unit 温度单位
   * @returns 体感温度
   */
  static calculateFeelsLike(temperature: number, humidity: number, windSpeed: number,
    unit: string = WeatherUtils.TemperatureUnits.CELSIUS): number {
    let temp = temperature;

    // 如果是华氏度，先转为摄氏度计算，最后再转回去
    let isFahrenheit = unit === WeatherUtils.TemperatureUnits.FAHRENHEIT;
    if (isFahrenheit) {
      temp = WeatherUtils.fahrenheitToCelsius(temp);
    }

    // 简化的体感温度计算（实际应用可使用更精确的公式）
    let feelsLike = temp;

    // 湿度影响（高温高湿更闷热，低温高湿更湿冷）
    if (temp > 20) {
      feelsLike += (humidity - 50) * 0.05; // 高温时湿度增加体感温度
    } else {
      feelsLike -= (humidity - 50) * 0.03; // 低温时湿度降低体感温度
    }

    // 风速影响（风冷效应）
    if (temp < 10) {
      const windChill =
        13.12 + 0.6215 * temp - 11.37 * Math.pow(windSpeed, 0.16) + 0.3965 * temp * Math.pow(windSpeed, 0.16);
      feelsLike = Math.min(feelsLike, windChill);
    }
    // 转换回原始单位
    if (isFahrenheit) {
      feelsLike = WeatherUtils.celsiusToFahrenheit(feelsLike);
    }

    return Math.round(feelsLike * 10) / 10;
  }

  /**
   * 验证天气数据的有效性
   * @param weatherData 天气数据对象
   * @returns 验证结果
   */
  static validateWeatherData(weatherData: WeatherDataValidationType): ValidationResultType {
    const errors: string[] = [];

    if (!weatherData) {
      return { isValid: false, errors: ['天气数据为空'] };
    }

    if (typeof weatherData.temperature !== 'number' || weatherData.temperature < -100 ||
      weatherData.temperature > 100) {
      errors.push('温度数据无效');
    }

    if (typeof weatherData.humidity !== 'number' || weatherData.humidity < 0 || weatherData.humidity > 100) {
      errors.push('湿度数据无效');
    }

    if (typeof weatherData.windSpeed !== 'number' || weatherData.windSpeed < 0 || weatherData.windSpeed > 500) {
      errors.push('风速数据无效');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

export default WeatherUtils;