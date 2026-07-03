import CloudDBService from "./CloudDBService";
import { WeightRecord } from "../model/WeightRecord";

export interface WeightSeriesItem {
  name: string;
  data: number[];
}

export interface WeightChartData {
  xAxis: string[];
  series: WeightSeriesItem[];
}

export default class ChartService {
  static async getPetWeightChartData(petId: string): Promise<WeightChartData> {
    // 原始数据 WeightRecord[]
    const rawRecords: WeightRecord[] = await CloudDBService.getPetWeightList(petId);

    const xAxis: string[] = [];
    const weightData: number[] = [];

    // 数据库查询已按recordDate升序，无需再次sort
    rawRecords.forEach(item => {
      xAxis.push(item.recordDate);
      weightData.push(item.weight);
    });

    const singleSeries: WeightSeriesItem = {
      name: "体重(kg)",
      data: weightData
    };

    const result: WeightChartData = {
      xAxis,
      series: [singleSeries]
    };
    return result;
  }

  static formatWeightChartData(list: Array<WeightRecord>): WeightChartData {
    const xAxis: string[] = [];
    const weightData: number[] = [];
    list.forEach(item => {
      xAxis.push(item.recordDate);
      weightData.push(item.weight);
    });

    const singleSeries: WeightSeriesItem = {
      name: "体重(kg)",
      data: weightData
    };

    return {
      xAxis,
      series: [singleSeries]
    };
  }
}