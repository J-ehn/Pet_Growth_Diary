// 补齐缺失导入
import ChartService, { WeightChartData } from "../../service/ChartService";
import { McLineChart } from "@mcui/mccharts";
import { PetModel } from "../../model/PetModel";
import CloudDBService, { WeightRecordAddParam } from "../../service/CloudDBService";

@Entry
@Component
struct PetWeightChartPage {
  // 状态变量绑定接口
  @State chartData: WeightChartData = { xAxis: [], weightList: [] };
  @State currentPet: PetModel = new PetModel(
    "001", "哈哈", "美国短毛猫", "GG", "2025-04-01", "2023-01-01", "", 1253
  );

  aboutToAppear() {
    const pageThis = this;
    ChartService.getPetWeightChartData(pageThis.currentPet.petId)
      .then((res: WeightChartData) => {
        pageThis.chartData = res;
      })
  }

  async addNewWeight() {
    const param: WeightRecordAddParam = {
      petId: this.currentPet.petId,
      weight: 3.5,
      recordDate: "2026-07-02"
    }
    await CloudDBService.addWeightRecord(param);
    this.chartData = await ChartService.getPetWeightChartData(this.currentPet.petId);
  }

  build() {
    Column() {
      Text(`${this.currentPet.petName} 体重成长趋势`)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      if (this.chartData.xAxis.length > 0) {
        Column() {
          McLineChart({
            chartOption: {
              xAxis: {
                data: this.chartData.xAxis,
                name: "记录日期"
              },
              yAxis: {
                name: "体重(kg)"
              },
              series: [
                {
                  name: "体重(kg)",
                  data: this.chartData.weightList,
                  lineStyle: {
                    color: "#FFBB44"
                  },
                  itemStyle: {
                    color: "#FF9922"
                  }
                }
              ]
            }
          })
        }
        .width("100%")
        .height(260)
      } else {
        Column() {
          Text("暂无体重记录，快去添加数据吧")
            .fontSize(16)
            .fontColor("#888888")
        }
        .width("100%")
        .height(260)
        .justifyContent(FlexAlign.Center)
      }

      Button("新增体重记录", { stateEffect: true })
        .margin({ top: 20 })
        .backgroundColor("#FFBB44")
        .fontSize(16)
        .onClick(() => {
          this.addNewWeight();
        })
    }
    .width("100%")
    .height("100%")
    .padding(16)
    .backgroundColor("#FFF2D0")
  }
}