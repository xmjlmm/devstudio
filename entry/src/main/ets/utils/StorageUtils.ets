import preferences from '@ohos.data.preferences';
import { Context } from '@kit.AbilityKit';

export class StorageUtils {
  private static prefs: preferences.Preferences | null = null;

  // 初始化Preferences实例
  static async initPreferences(context: Context): Promise<void> {
    try {
      StorageUtils.prefs = await preferences.getPreferences(context, 'farmPreferences');
      console.info('Preferences initialized successfully');
    } catch (error) {
      console.error(`Failed to init preferences. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  // 保存字符串数据
  static async setString(key: string, value: string): Promise<void> {
    if (!StorageUtils.prefs) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await StorageUtils.prefs.put(key, value);
      await StorageUtils.prefs.flush();
      console.info(`Saved ${key}: ${value}`);
    } catch (error) {
      console.error(`Failed to save data. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  // 获取字符串数据
  static async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!StorageUtils.prefs) {
      console.error('Preferences not initialized');
      return defaultValue;
    }
    try {
      const value = await StorageUtils.prefs.get(key, defaultValue);
      return value.toString();
    } catch (error) {
      console.error(`Failed to get data. Code: ${error.code}, Message: ${error.message}`);
      return defaultValue;
    }
  }

  // 保存数字数据
  static async setNumber(key: string, value: number): Promise<void> {
    await StorageUtils.setString(key, value.toString());
  }

  // 获取数字数据
  static async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    const value = await StorageUtils.getString(key, defaultValue.toString());
    return Number.parseFloat(value);
  }

  // 保存布尔数据
  static async setBoolean(key: string, value: boolean): Promise<void> {
    await StorageUtils.setString(key, value ? 'true' : 'false');
  }

  // 获取布尔数据
  static async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    const value = await StorageUtils.getString(key, defaultValue.toString());
    return value === 'true';
  }

  // 删除数据
  static async remove(key: string): Promise<void> {
    if (!StorageUtils.prefs) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await StorageUtils.prefs.delete(key);
      await StorageUtils.prefs.flush();
      console.info(`Removed key: ${key}`);
    } catch (error) {
      console.error(`Failed to remove data. Code: ${error.code}, Message: ${error.message}`);
    }
  }

  // 清空所有数据
  static async clear(): Promise<void> {
    if (!StorageUtils.prefs) {
      console.error('Preferences not initialized');
      return;
    }
    try {
      await StorageUtils.prefs.clear();
      await StorageUtils.prefs.flush();
      console.info('Cleared all preferences');
    } catch (error) {
      console.error(`Failed to clear data. Code: ${error.code}, Message: ${error.message}`);
    }
  }
}