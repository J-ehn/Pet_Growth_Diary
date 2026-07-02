import { PetModel } from "../model/PetModel";

@Component
export struct PetInfoCard {
  @Prop currentPet: PetModel;
  // 跳转设置页路由：函数参数禁止加 @Prop / @Link / @State
  //navigateToSetting!: () => void;
  navigateToSetting: () => void = () => {};

  build() {
    Row() {
      // 宠物头像
      Image(this.currentPet.avatarUrl)
        .width(60)
        .height(60)
        .borderRadius(30)
        .objectFit(ImageFit.Cover)
      Column() {
        Row() {
          Text(this.currentPet.petName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
          Text(this.currentPet.petGender)
            .fontSize(16)
            .fontColor("#999999")
          Text(this.currentPet.petType)
            .fontSize(16)
            .fontColor("#666666")
        }
        Text(`1岁3个月 已经陪伴您${this.currentPet.accompanyDays}天啦~`)
          .fontSize(14)
          .fontColor("#888888")
          .margin({ top: 4 })
      }
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 设置按钮
      Image($r("sys.media.ohos_ic_public_more"))
        .width(32)
        .height(32)
        .colorBlend("#999")
        .onClick(() => this.navigateToSetting())
    }
    .width("100%")
    .padding(16)
    .backgroundColor("#FFF9E8")
    .borderRadius(16)
  }
}