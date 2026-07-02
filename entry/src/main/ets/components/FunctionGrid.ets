import { FuncIconRawList, FuncType, FuncIconItem, FuncTypeTextMap } from "../model/PetModel";
import router from "@ohos.router";

@Component
export struct FuncGrid {
  @State iconList: FuncIconItem[] = FuncIconRawList.map(raw => {
    // 显式标注对象类型，消除无类型字面量报错
    const item: FuncIconItem = {
      type: raw.type,
      icon: $r(raw.iconRes),
      color: raw.color
    };
    return item;
  })

  navToPage(type: FuncType): void {
    switch (type) {
      case FuncType.REMIND:
        router.pushUrl({ url: "pages/subPages/RemindPage" });
        break;
      case FuncType.ACCOUNT:
        router.pushUrl({ url: "pages/subPages/AccountPage" });
        break;
      case FuncType.ALBUM:
        router.pushUrl({ url: "pages/subPages/AlbumPage" });
        break;
      case FuncType.WEIGHT:
        router.pushUrl({ url: "pages/subPages/WeightChartPage" });
        break;
      case FuncType.CASE:
        router.pushUrl({ url: "pages/subPages/CaseRecordPage" });
        break;
      default:
        router.pushUrl({ url: `pages/subPages/${type}Page` });
    }
  }

  build() {
    Grid() {
      ForEach(this.iconList, (item: FuncIconItem) => {
        GridItem() {
          Column() {
            Image(item.icon)
              .width(48)
              .height(48)
              .renderMode(ImageRenderMode.Template)
              .colorBlend(item.color)
            Text(FuncTypeTextMap.get(item.type) ?? "")
              .fontSize(14)
              .fontColor("#333")
              .margin({ top: 6 })
          }
          .width("100%")
          .padding(8)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => this.navToPage(item.type))
        }
      })
    }
    .columnsTemplate("1fr 1fr 1fr 1fr")
    .columnsGap(8)
    .rowsGap(12)
    .width("100%")
    .padding({ left: 8, right: 8, top: 16, bottom: 16 })
    .backgroundColor("#FFF9E8")
    .borderRadius(16)
  }
}