@Builder
export function PetIllustration() {
  Column() {
    Image($r("app.media.pet_bg_illust")) // 手绘猫狗房间插画资源
      .width("100%")
      .height("100%")
      .objectFit(ImageFit.Cover)
  }
  .width("100%")
  .height("100%")

}