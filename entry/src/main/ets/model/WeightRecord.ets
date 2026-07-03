// 改为interface，支持直接字面量赋值，无构造器约束
export interface WeightRecord {
  id: number;
  petId: string;
  weight: number;
  recordDate: string;
}