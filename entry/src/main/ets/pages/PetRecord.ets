import CloudDBService from "../service/CloudDBService";
import { PetModel } from "../model/PetModel";

// 实现完整 IDataSource 接口，4个必写方法一个不能少
class RecordDataSource implements IDataSource {
  private recordList: Array<Record<string, string>> = [];
  private listeners: Array<DataChangeListener> = [];

  async loadData(petId: string) {
    this.recordList = await CloudDBService.getPetAllRecord(petId);
    this.notifyDataReload();
  }

  // 1. 获取数据总条数
  totalCount(): number {
    return this.recordList.length;
  }

  // 2. 根据下标获取单条数据
  getData(index: number): Record<string, string> {
    return this.recordList[index];
  }

  // 3. 注册监听（必须实现）
  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }

  // 4. 移除监听（接口强制要求，缺失就报你上面的错）
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const targetIndex = this.listeners.indexOf(listener);
    if (targetIndex !== -1) {
      this.listeners.splice(targetIndex, 1);
    }
  }

  // 自定义：通知列表刷新
  private notifyDataReload(): void {
    this.listeners.forEach(list => list.onDataReloaded());
  }
}

@Entry
@Component
struct PetRecordPage {
  @State currentPet: PetModel = new PetModel(
    "001", "哈哈", "美国短毛猫", "GG", "2025-04-01", "2023-01-01", "", 1253
  );
  dataSource: RecordDataSource = new RecordDataSource();

  aboutToAppear() {
    this.dataSource.loadData(this.currentPet.petId);
  }



  build() {
    List({ space: 10 }) {
      LazyForEach(this.dataSource, (item: Record<string, string>) => {
        ListItem() {
          Text(`${item.recordDate} | ${item.content}`)
            .fontSize(16)
            .padding(12)
            .width("100%")
            .backgroundColor("#FFF9E8")
            .borderRadius(12)
        }
      }, (item: Record<string, string>) => item.recordId)
    }
    .width("100%")
    .height("100%")
    .padding(12)
    .backgroundColor("#FFF2D0")
  }
}