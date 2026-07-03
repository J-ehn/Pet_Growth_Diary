/** 宠物实体 - 多宠物档案管理核心模型 */
export class PetModel {
  petId: string; // 唯一ID
  petName: string; // 宠物昵称
  petType: string; // 品种
  petGender: string; // 性别GG/MM
  birthDay: string; // 生日
  createDay: string; // 领养日期
  avatarUrl: string; // 头像云存储地址
  accompanyDays: number; // 陪伴天数

  constructor(
    petId: string,
    petName: string,
    petType: string,
    petGender: string,
    birthDay: string,
    createDay: string,
    avatarUrl: string,
    accompanyDays: number
  ) {
    this.petId = petId;
    this.petName = petName;
    this.petType = petType;
    this.petGender = petGender;
    this.birthDay = birthDay;
    this.createDay = createDay;
    this.avatarUrl = avatarUrl;
    this.accompanyDays = accompanyDays;
  }
}

// 功能类型枚举
export enum FuncType {
  REMIND,
  ACCOUNT,
  ALBUM,
  SHOP,
  NOTE,
  WEIGHT,
  CASE,
  CERT
}

// 功能文字映射Map
export const FuncTypeTextMap = new Map<FuncType, string>([
  [FuncType.REMIND, "提醒"],
  [FuncType.ACCOUNT, "账本"],
  [FuncType.ALBUM, "相册"],
  [FuncType.SHOP, "商城"],
  [FuncType.NOTE, "备忘录"],
  [FuncType.WEIGHT, "体重记录"],
  [FuncType.CASE, "病历"],
  [FuncType.CERT, "证件"],
]);

// 原始条目接口：仅保存资源名字符串，不生成Resource
export interface FuncIconRawItem {
  type: FuncType;
  iconRes: string; // 仅存sys.media完整字符串
  color: ResourceColor;
}

// 渲染用接口：页面转换后使用
export interface FuncIconItem {
  type: FuncType;
  icon: Resource;
  color: ResourceColor;
}

export const FuncIconRawList: FuncIconRawItem[] = [
  { type: FuncType.REMIND, iconRes: "sys.media.icon_remind", color: "#FF7D00" },
  { type: FuncType.ACCOUNT, iconRes: "sys.media.icon_account", color: "#00B42A" },
  { type: FuncType.ALBUM, iconRes: "sys.media.icon_album", color: "#1677FF" },
  { type: FuncType.SHOP, iconRes: "sys.media.icon_shop", color: "#F53F3F" },
  { type: FuncType.NOTE, iconRes: "sys.media.icon_note", color: "#722ED1" },
  { type: FuncType.WEIGHT, iconRes: "sys.media.icon_weight", color: "#FF9500" },
  { type: FuncType.CASE, iconRes: "sys.media.icon_case", color: "#0FC6C2" },
  { type: FuncType.CERT, iconRes: "sys.media.icon_cert", color: "#86909C" },
];