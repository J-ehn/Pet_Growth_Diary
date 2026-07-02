// 改用原生标准通知模块，统一一套类型，无冲突
import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@ohos.base';
import CloudDBService from "./CloudDBService";
import { RemindItem } from "../model/RemindModel";

export default class NotifyService {
  static async initRemindNotice(): Promise<void> {
    const remindList = await CloudDBService.getAllRemindData() as RemindItem[];
    for (const item of remindList) {
      // 修复：this → NotifyService
      NotifyService.setCycleTimer(item);
    }
  }

  static setCycleTimer(remindItem: RemindItem): void {
    const targetTime = new Date(remindItem.remindTime);
    const now = Date.now();
    const targetTs = targetTime.getTime();
    let firstDelay = targetTs - now;
    if (firstDelay < 0) firstDelay = 1000;

    const cycleMs = remindItem.cycleType === "month"
      ? 30 * 24 * 60 * 60 * 1000
      : 365 * 24 * 60 * 60 * 1000;

    setTimeout((): void => {
      // 修复：this → NotifyService
      NotifyService.pushRemindNotice(remindItem);
      setInterval((): void => NotifyService.pushRemindNotice(remindItem), cycleMs);
    }, firstDelay);
  }

  static pushRemindNotice(item: RemindItem): void {
    const notifyRequest: notificationManager.NotificationRequest = {
      id: Date.now(),
      content: {
        contentType:1,
        normal: {
          title: "宠物养护提醒",
          text: item.content
        }
      }
    };

    void notificationManager.publish(notifyRequest).catch((err: BusinessError): void => {
      console.error("推送提醒通知失败：", err.code, err.message);
    });
  }
}