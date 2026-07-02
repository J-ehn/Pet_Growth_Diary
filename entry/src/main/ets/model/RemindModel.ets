// 全局统一提醒类型，两处服务共用
export interface RemindItem {
  cycleType: "month" | "year";
  remindTime: string;
  content: string;
}