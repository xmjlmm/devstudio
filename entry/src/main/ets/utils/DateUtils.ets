// entry/src/main/ets/utils/DateUtils.ets

export class DateUtils {
  static getCurrentDate(): string {
    return new Date().toISOString().split('T')[0];
  }

  static getCurrentTime(): string {
    return new Date().toLocaleString();
  }

  static formatDate(date: Date, format: string = 'YYYY-MM-DD'): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    return format.replace('YYYY', year.toString())
      .replace('MM', month)
      .replace('DD', day);
  }

  static getDaysDifference(date1: string, date2: string): number {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    const diffTime = Math.abs(d2.getTime() - d1.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }
}