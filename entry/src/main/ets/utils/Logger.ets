// entry/src/main/ets/utils/Logger.ets

export class Logger {
  private static readonly TAG = 'FarmAssistant';

  static info(message: string, data?: object): void {
    const dataStr = data ? JSON.stringify(data) : '';
    console.info(`[${this.TAG}] INFO: ${message}`, dataStr);
  }

  static error(message: string, error?: Error): void {
    const errorMsg = error ? error.message : '';
    console.error(`[${this.TAG}] ERROR: ${message}`, errorMsg);
  }

  static debug(message: string, data?: object): void {
    const dataStr = data ? JSON.stringify(data) : '';
    console.debug(`[${this.TAG}] DEBUG: ${message}`, dataStr);
  }

  static warn(message: string, data?: object): void {
    const dataStr = data ? JSON.stringify(data) : '';
    console.warn(`[${this.TAG}] WARN: ${message}`, dataStr);
  }
}