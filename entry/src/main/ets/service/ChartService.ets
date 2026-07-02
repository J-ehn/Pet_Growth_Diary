import CloudDBService from "./CloudDBService";

// 显式声明图表数据接口
export interface WeightChartData {
  xAxis: string[];
  weightList: number[];
}

export default class ChartService {
  // 函数返回值指定接口类型 WeightChartData
  static async getPetWeightChartData(petId: string): Promise<WeightChartData> {
    const rawRecords = await CloudDBService.getPetWeightList(petId);
    const xAxis: string[] = [];
    const weightList: number[] = [];
    rawRecords.forEach(item => {
      xAxis.push(item.recordDate);
      weightList.push(item.weight);
    })
    // 字面量赋值给显式接口类型，消除校验报错
    const result: WeightChartData = {
      xAxis,
      weightList
    };
    return result;
  }
}