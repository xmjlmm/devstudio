export class DateUtils {
  // 格式化日期为 YYYY-MM-DD
  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 格式化时间为 HH:MM
  static formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 计算两个日期之间的天数差
  static getDaysBetween(startDate: Date, endDate: Date): number {
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  // 获取作物生长阶段
  static getGrowthStage(plantingDate: string): string {
    const planted = new Date(plantingDate);
    const today = new Date();
    const days = DateUtils.getDaysBetween(planted, today);

    if (days < 7) {
      return '发芽期';
    }
    if (days < 30) {
      return '生长期';
    }
    if (days < 60) {
      return '开花期';
    }
    if (days < 90) {
      return '结果期';
    }
    return '成熟期';
  }

  // 获取友好时间显示
  static getFriendlyTime(date: Date): string {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffMins < 1) {
      return '刚刚';
    }
    if (diffMins < 60) {
      return `${diffMins}分钟前`;
    }
    if (diffHours < 24) {
      return `${diffHours}小时前`;
    }
    if (diffDays < 7) {
      return `${diffDays}天前`;
    }

    return DateUtils.formatDate(date);
  }
}