// model/WeightModel.ets
export class WeightModel {
  id: string;
  petId: string;
  weight: number;
  recordDate: string;
  createTime: number;

  constructor(id: string, petId: string, weight: number, recordDate: string, createTime: number) {
    this.id = id;
    this.petId = petId;
    this.weight = weight;
    this.recordDate = recordDate;
    this.createTime = createTime;
  }
}