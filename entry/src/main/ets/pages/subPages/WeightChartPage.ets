// 体重趋势页面 - 鸿蒙原生Path/Circle绘图，不依赖任何har包
import CloudDBService from '../../service/CloudDBService';
import { WeightRecordAddParam } from '../../service/CloudDBService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { WeightRecord } from "../../model/WeightRecord";

// 路由参数类型
interface WeightPageRouteParams {
  petId?: string;
}
// 图表坐标点类型
interface PointXY {
  x: number;
  y: number;
}
// 筛选区间枚举
type FilterRange = "week" | "month" | "ninety";

@Entry
@Component
struct WeightChartPage {
  @State todayWeight: string = "";
  @State allWeightList: Array<WeightRecord> = [];
  @State showList: Array<WeightRecord> = [];
  @State selectRange: FilterRange = "month";
  // 当前点击圆点下标，控制悬浮提示
  @State tipIndex: number = -1;
  petId: string = "";

  // 画布全局固定尺寸边距，折线圆点坐标统一计算，不会错位分离
  private readonly CANVAS_W = 320;
  private readonly CANVAS_H = 200;
  private readonly PAD = 24;
  // 主题色 宠物暖橙
  private readonly MAIN_COLOR = "#FF9F69";
  private readonly PAGE_BG = "#FFF9F5";
  private readonly CARD_BG = "#ffffff";

  aboutToAppear() {
    const params = router.getParams() as WeightPageRouteParams;
    if (params.petId) this.petId = params.petId;
    this.loadAllWeightData();
  }

  // 返回首页
  backToHome() {
    router.replaceUrl({ url: "pages/Index" })
  }

  async loadAllWeightData(): Promise<void> {
    if (!this.petId) return;
    const list = await CloudDBService.getPetWeightList(this.petId);
    this.allWeightList = list;
    this.filterDataByRange();
  }

  // 筛选时间范围数据
  filterDataByRange() {
    const now = new Date();
    let startDate = new Date();
    switch (this.selectRange) {
      case "week":
        startDate.setDate(now.getDate() - 7);
        break;
      case "month":
        startDate.setDate(now.getDate() - 30);
        break;
      case "ninety":
        startDate.setDate(now.getDate() - 90);
        break;
    }
    this.showList = this.allWeightList
      .filter(item => new Date(item.recordDate) >= startDate)
      .sort((a, b) => new Date(a.recordDate).getTime() - new Date(b.recordDate).getTime());
    this.tipIndex = -1;
  }

  changeRange(range: FilterRange) {
    this.selectRange = range;
    this.filterDataByRange();
  }

  // 顶部标题日期区间
  getRangeTitle(): string {
    if (this.showList.length === 0) return "暂无数据";
    const start = new Date(this.showList[0].recordDate);
    const end = new Date(this.showList[this.showList.length - 1].recordDate);
    return `${start.getMonth() + 1}月${start.getDate()}日 - ${end.getMonth() + 1}月${end.getDate()}日`;
  }

  // 计算首尾体重差值
  getWeightDiff(): number {
    if (this.showList.length < 2) return 0;
    const first = this.showList[0].weight;
    const last = this.showList[this.showList.length - 1].weight;
    return Number((last - first).toFixed(1));
  }

  // 保存新增体重
  async saveTodayWeight(): Promise<void> {
    if (!this.todayWeight) {
      promptAction.showToast({ message: "请输入体重数值" });
      return;
    }
    const num = Number(this.todayWeight);
    if (isNaN(num) || num <= 0) {
      promptAction.showToast({ message: "请输入合法正数体重（支持小数）" });
      return;
    }
    await CloudDBService.addWeightRecord({
      petId: this.petId,
      weight: num,
      recordDate: new Date().toLocaleDateString()
    });
    promptAction.showToast({ message: "体重保存成功" });
    this.todayWeight = "";
    await this.loadAllWeightData();
  }

  // 统一计算每个点XY坐标，折线圆点共用一套逻辑，杜绝分离错位
  getPoint(index: number): PointXY {
    const weightArr = this.showList.map(i => i.weight);
    const maxW = Math.max(...weightArr);
    const minW = Math.min(...weightArr);
    const valueRange = maxW - minW || 1;
    const targetItem = this.showList[index];

    const x = this.PAD + (this.CANVAS_W - this.PAD * 2) / (weightArr.length - 1) * index;
    const y = this.CANVAS_H - this.PAD - (targetItem.weight - minW) / valueRange * (this.CANVAS_H - this.PAD * 2);
    return { x, y } as PointXY;
  }

  // 生成折线路径字符串
  getLinePath(): string {
    if (this.showList.length < 2) return "";
    let pathStr = "";
    for (let i = 0; i < this.showList.length; i++) {
      const p = this.getPoint(i);
      pathStr += i === 0 ? `M${p.x} ${p.y}` : ` L${p.x} ${p.y}`;
    }
    return pathStr;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button("←", { stateEffect: true })
          .fontSize(22)
          .fontColor(this.MAIN_COLOR)
          .backgroundColor("transparent")
          .onClick(() => this.backToHome())
        Blank()
        Text(this.getRangeTitle())
          .fontSize(20)
          .fontColor("#333333")
        Blank()
        Text("···")
          .fontSize(22)
          .fontColor("#999999")
      }
      .width("100%")
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.CARD_BG)

      // 时间筛选Tab
      Row() {
        Text("近1周")
          .fontSize(18)
          .fontColor(this.selectRange === "week" ? this.MAIN_COLOR : "#999999")
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => this.changeRange("week"))
        Text("近1月")
          .fontSize(18)
          .fontColor(this.selectRange === "month" ? this.MAIN_COLOR : "#999999")
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => this.changeRange("month"))
        Text("近90天")
          .fontSize(18)
          .fontColor(this.selectRange === "ninety" ? this.MAIN_COLOR : "#999999")
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => this.changeRange("ninety"))
      }
      .width("100%")
      .padding({ bottom: 12 })
      .backgroundColor(this.CARD_BG)

      // 图表卡片容器
      Stack() {
        Column() {
          // 折线
          Path()
            .width(this.CANVAS_W)
            .height(this.CANVAS_H)
            .fillOpacity(0)
            .stroke(this.MAIN_COLOR)
            .strokeWidth(3)
            .commands(this.getLinePath())
          // 底部X轴日期（首/中/末三个刻度）
          Row() {
            if (this.showList.length >= 3) {
              Text(this.showList[0].recordDate.slice(5))
                .fontSize(12)
                .fontColor("#cccccc")
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
              Text(this.showList[Math.floor(this.showList.length / 2)].recordDate.slice(5))
                .fontSize(12)
                .fontColor("#cccccc")
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              Text(this.showList[this.showList.length - 1].recordDate.slice(5))
                .fontSize(12)
                .fontColor("#cccccc")
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
          }
          .width(this.CANVAS_W)
          .padding({ left: this.PAD, right: this.PAD })
        }
        .width("100%")
        .height(240)

        // 数据圆点 + 点击悬浮提示
        ForEach(this.showList, (item: WeightRecord, idx: number) => {
          Circle({ width: 12, height: 12 })
            .fill("#ffffff")
            .stroke(this.MAIN_COLOR)
            .strokeWidth(3)
            .position({
              x: this.getPoint(idx).x - 6,
              y: this.getPoint(idx).y - 6
            })
            .onClick(() => {
              this.tipIndex = this.tipIndex === idx ? -1 : idx;
            })
          // 悬浮气泡
          if (this.tipIndex === idx) {
            Column() {
              Text(item.recordDate.slice(5))
                .fontSize(13)
                .fontColor("#666666")
              Text(`${Number(item.weight.toFixed(1))} kg`)
                .fontSize(15)
                .fontColor(this.MAIN_COLOR)
                .fontWeight(FontWeight.Bold)
            }
            .padding(6)
            .backgroundColor("#ffffff")
            .borderRadius(4)
            .shadow({ radius: 3, color: "#00000015" })
            .position({
              x: this.getPoint(idx).x - 35,
              y: this.getPoint(idx).y - 55
            })
          }
        })
      }
      .width("92%")
      .backgroundColor(this.CARD_BG)
      .borderRadius(14)
      .padding({ top: 10, bottom: 16, left: 8, right: 8 })
      .margin({ bottom: 16 })

      // 新增体重输入区域
      Row() {
        Text("今日体重(kg)")
          .fontSize(18)
          .fontColor("#333333")
        TextInput({ text: this.todayWeight, placeholder: "支持小数，如 5.2" })
          .width(180)
          .type(InputType.Number)
          .backgroundColor("#f7f7f7")
          .borderRadius(10)
          .padding({ left: 10, right: 10 })
          .onChange((val: string) => this.todayWeight = val)
        Button("保存", { stateEffect: true })
          .backgroundColor(this.MAIN_COLOR)
          .fontColor("#ffffff")
          .borderRadius(10)
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .onClick(() => this.saveTodayWeight())
      }
      .width("100%")
      .margin({ bottom: 20 })
      .padding({ left: 16, right: 16 })

      // 底部统计卡片：记录条数 / 体重变化
      Row() {
        Row() {
          Column() {
            Text("称重记录(天)")
              .fontSize(14)
              .fontColor("#999999")
            Text(this.showList.length.toString())
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor("#222222")
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)

        Row() {
          Column() {
            Text("体重变化(kg)")
              .fontSize(14)
              .fontColor("#999999")
            Text(this.getWeightDiff().toString())
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getWeightDiff() < 0 ? this.MAIN_COLOR : "#f04848")
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width("92%")
      .backgroundColor(this.CARD_BG)
      .borderRadius(14)
      .padding(18)
      .margin({ bottom: 16 })

      Blank()
    }
    .width("100%")
    .height("100%")
    .backgroundColor(this.PAGE_BG)
  }
}