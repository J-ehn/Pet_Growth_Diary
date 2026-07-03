import { FuncIconRawList, FuncType, FuncIconItem, FuncTypeTextMap } from "../model/PetModel";
import router from "@ohos.router";
import promptAction from '@ohos.promptAction';

@Component
export struct FuncGrid {
  // 父页面传入当前选中宠物ID
  currentPetId: string | null = null;

  @State iconList: FuncIconItem[] = FuncIconRawList.map(raw => {
    const item: FuncIconItem = {
      type: raw.type,
      icon: $r(raw.iconRes),
      color: raw.color
    };
    return item;
  })

  // 根据功能类型匹配对应页面
  navToPage(type: FuncType): void {
    // 新增打印，判断点击是否进入函数
    console.info("【八宫格点击】类型：", type, "当前宠物ID：", this.currentPetId);

    // 仅体重页面需要校验宠物是否选中
    if (type === FuncType.WEIGHT && this.currentPetId === null) {
      promptAction.showToast({ message: "请先选择一只宠物" });
      return;
    }

    let targetUrl: string = "";
    // 一一对应8个页面路由
    switch (type) {
      case FuncType.REMIND:
        targetUrl = "subPages/RemindPage";
        break;
      case FuncType.ACCOUNT:
        targetUrl = "pages/subPages/AccountPage";
        break;
      case FuncType.ALBUM:
        targetUrl = "pages/subPages/AlbumPage";
        break;
      case FuncType.SHOP:
        targetUrl = "pages/subPages/ShopPage";
        break;
      case FuncType.NOTE:
        targetUrl = "pages/subPages/NotePage";
        break;
      case FuncType.WEIGHT:
        targetUrl = "pages/subPages/WeightChartPage";
        break;
      case FuncType.CASE:
        targetUrl = "pages/subPages/CaseRecordPage";
        break;
      case FuncType.CERT:
        targetUrl = "pages/subPages/CertPage";
        break;
      default:
      // 兜底，防止新增枚举无匹配页面
        promptAction.showToast({ message: "该功能页面开发中" });
        return;
    }

    // 路由参数：只有体重页面携带petId
    const routeParams: Record<string, string> = {};
    if (type === FuncType.WEIGHT && this.currentPetId) {
      routeParams.petId = this.currentPetId;
    }

    // 执行页面跳转
    router.pushUrl({
      url: targetUrl,
      params: routeParams
    });
  }

  build() {
    Grid() {
      ForEach(this.iconList, (item: FuncIconItem) => {
        GridItem() {
          Column() {
            Image(item.icon)
              .width(48)
              .height(48)
            Text(FuncTypeTextMap.get(item.type) ?? "")
              .fontSize(14)
              .fontColor("#333")
              .margin({ top: 6 })
          }
          .width("100%")
          .padding(8)
          .alignItems(HorizontalAlign.Center)
          // 点击图标/文字，传入当前功能类型
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