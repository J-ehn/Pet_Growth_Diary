import relationalStore from "@ohos.data.relationalStore";
import { PetModel } from "../model/PetModel";


// 体重记录实体类型
export interface WeightRecord {
  id: number;
  petId: string;
  weight: number;
  recordDate: string;
}

export interface WeightRecordAddParam {
  petId: string;
  weight: number;
  recordDate: string;
}

// 新增：提醒事项强类型，替代any
export interface RemindItem {
  remindId: string;
  petId: string;
  remindType: string;
  cycleType: string;
  remindTime: string;
  content: string;
}

export default class CloudDBService {
  static store: relationalStore.RdbStore | null = null;
  static readonly DB_NAME = "PetGrowDB";

  // 初始化数据库
  static async initDB(context: Context) {
    const config: relationalStore.StoreConfig = {
      name: CloudDBService.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    CloudDBService.store = await relationalStore.getRdbStore(context, config);
    await CloudDBService.createTable();
  }

  // 创建数据表
  static async createTable() {
    if (!CloudDBService.store) return;
    const petSql = `CREATE TABLE IF NOT EXISTS PetInfo(
      petId TEXT PRIMARY KEY,
      petName TEXT,
      petType TEXT,
      petGender TEXT,
      birthDay TEXT,
      createDay TEXT,
      avatarUrl TEXT,
      accompanyDays INTEGER
    )`
    await CloudDBService.store.executeSql(petSql);

    const weightSql = `CREATE TABLE IF NOT EXISTS WeightRecord(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      petId TEXT,
      weight FLOAT,
      recordDate TEXT
    )`
    await CloudDBService.store.executeSql(weightSql);

    const remindSql = `CREATE TABLE IF NOT EXISTS RemindItem(
      remindId TEXT PRIMARY KEY,
      petId TEXT,
      remindType TEXT,
      cycleType TEXT,
      remindTime TEXT,
      content TEXT
    )`
    await CloudDBService.store.executeSql(remindSql);

    const albumSql = `CREATE TABLE IF NOT EXISTS PetAlbum(
      photoId TEXT PRIMARY KEY,
      petId TEXT,
      photoUrl TEXT,
      uploadDate TEXT
    )`
    await CloudDBService.store.executeSql(albumSql);
  }

  // ========== 查询全部宠物档案（使用标准 getValue 取值） ==========
  static async getAllPetData(): Promise<PetModel[]> {
    if (!CloudDBService.store) return [];
    const predicates = new relationalStore.RdbPredicates("PetInfo");
    const resultSet = await CloudDBService.store.query(predicates);

    let petList: PetModel[] = [];
    while (resultSet.goToNextRow()) {
      // 1. 先根据列名获取数字索引
      const idxPetId = resultSet.getColumnIndex("petId");
      const idxPetName = resultSet.getColumnIndex("petName");
      const idxPetType = resultSet.getColumnIndex("petType");
      const idxPetGender = resultSet.getColumnIndex("petGender");
      const idxBirthDay = resultSet.getColumnIndex("birthDay");
      const idxCreateDay = resultSet.getColumnIndex("createDay");
      const idxAvatarUrl = resultSet.getColumnIndex("avatarUrl");
      const idxAccompanyDays = resultSet.getColumnIndex("accompanyDays");

      // 2. 传入数字下标取值 + 类型断言
      const petId = resultSet.getValue(idxPetId) as string;
      const petName = resultSet.getValue(idxPetName) as string;
      const petType = resultSet.getValue(idxPetType) as string;
      const petGender = resultSet.getValue(idxPetGender) as string;
      const birthDay = resultSet.getValue(idxBirthDay) as string;
      const createDay = resultSet.getValue(idxCreateDay) as string;
      const avatarUrl = resultSet.getValue(idxAvatarUrl) as string;
      const accompanyDays = resultSet.getValue(idxAccompanyDays) as number;

      const pet = new PetModel(
        petId,
        petName,
        petType,
        petGender,
        birthDay,
        createDay,
        avatarUrl,
        accompanyDays
      )
      petList.push(pet);
    }
    resultSet.close();
    return petList;
  }

  static async savePet(pet: PetModel) {
    if (!CloudDBService.store) return;
    const value: relationalStore.ValuesBucket = {
      petId: pet.petId,
      petName: pet.petName,
      petType: pet.petType,
      petGender: pet.petGender,
      birthDay: pet.birthDay,
      createDay: pet.createDay,
      avatarUrl: pet.avatarUrl,
      accompanyDays: pet.accompanyDays
    };
    await CloudDBService.store.insert("PetInfo", value);
  }

  // ========== 根据petId查询体重记录 ==========
  static async getPetWeightList(petId: string): Promise<WeightRecord[]> {
    if (!CloudDBService.store) return [];
    const predicates = new relationalStore.RdbPredicates("WeightRecord");
    predicates.equalTo("petId", petId);
    predicates.orderByAsc("recordDate");
    const resultSet = await CloudDBService.store.query(predicates);

    const list: WeightRecord[] = [];
    while (resultSet.goToNextRow()) {
      const idxId = resultSet.getColumnIndex("id");
      const idxPetId = resultSet.getColumnIndex("petId");
      const idxWeight = resultSet.getColumnIndex("weight");
      const idxRecordDate = resultSet.getColumnIndex("recordDate");

      const item: WeightRecord = {
        id: resultSet.getValue(idxId) as number,
        petId: resultSet.getValue(idxPetId) as string,
        weight: resultSet.getValue(idxWeight) as number,
        recordDate: resultSet.getValue(idxRecordDate) as string
      };
      list.push(item);
    }
    resultSet.close();
    return list;
  }

  // 新增体重记录
  static async addWeightRecord(record: WeightRecordAddParam) {
    if (!CloudDBService.store) return;
    const bucket: relationalStore.ValuesBucket = {
      petId: record.petId,
      weight: record.weight,
      recordDate: record.recordDate
    };
    await CloudDBService.store.insert("WeightRecord", bucket);
  }

  // ========== 查询全部提醒事项（无any） ==========
  static async getAllRemindData(): Promise<RemindItem[]> {
    if (!CloudDBService.store) return [];
    const predicates = new relationalStore.RdbPredicates("RemindItem");
    const res = await CloudDBService.store.query(predicates);
    const list: RemindItem[] = [];
    while (res.goToNextRow()) {
      const idxRemindId = res.getColumnIndex("remindId");
      const idxPetId = res.getColumnIndex("petId");
      const idxRemindType = res.getColumnIndex("remindType");
      const idxCycleType = res.getColumnIndex("cycleType");
      const idxRemindTime = res.getColumnIndex("remindTime");
      const idxContent = res.getColumnIndex("content");

      const item: RemindItem = {
        remindId: res.getValue(idxRemindId) as string,
        petId: res.getValue(idxPetId) as string,
        remindType: res.getValue(idxRemindType) as string,
        cycleType: res.getValue(idxCycleType) as string,
        remindTime: res.getValue(idxRemindTime) as string,
        content: res.getValue(idxContent) as string
      }
      list.push(item);
    }
    res.close();
    return list;
  }

  static async getPetAllRecord(petId: string) {
    return [];
  }

  // async deletePetById(petId: string): Promise<void> {
  //   const db = await this.getDB();
  //   await db.delete("PetTable", petId);
  // }
}