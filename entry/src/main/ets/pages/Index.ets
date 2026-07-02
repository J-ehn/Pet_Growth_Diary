import { PetModel } from "../model/PetModel";
import { PetInfoCard } from "../components/PetCard";
import { FuncGrid } from "../components/FunctionGrid";
import { PetIllustration } from "../components/IllustBottom";
import CloudDBService from "../service/CloudDBService";
import NotifyService from "../service/NotifyService";
import router from "@ohos.router";
import promptAction from "@ohos.promptAction";
import { BusinessError } from "@ohos.base";

@Entry
@Component
struct PetIndexPage {
  @State petList: Array<PetModel> = [];
  @State currentPet: PetModel | null = null;
  @State loading: boolean = true;
  @State swiperIndex: number = 0;
  // 弹窗控制
  @State showOperatePop: boolean = false;

  async aboutToAppear() {
    const ctx = getContext(this);
    try {
      await CloudDBService.initDB(ctx);
      const res = await CloudDBService.getAllPetData();
      this.petList = res;
      if (res.length > 0) {
        this.currentPet = res[0];
      } else {
        this.currentPet = null;
      }
    } catch(err) {
      console.error("数据库初始化失败", err);
      this.currentPet = null;
    } finally {
      this.loading = false;
    }
    setTimeout(()=>{
      NotifyService.initRemindNotice();
    }, 500)
  }

  onPageShow() {
    CloudDBService.getAllPetData().then((res: PetModel[]) => {
      this.petList = res;
      if (res.length === 0) {
        this.currentPet = null;
        return;
      }
      const tempPet = this.currentPet;
      if (tempPet === null) {
        this.currentPet = res[0];
        this.swiperIndex = 0;
        return;
      }
      const idx = res.findIndex(p => p.petId === tempPet.petId);
      this.swiperIndex = idx === -1 ? 0 : idx;
    })
  }

  navSetting() {
    router.pushUrl({ url: "pages/PetSetting" });
  }

  navRecord() {
    router.pushUrl({ url: "pages/PetRecord" });
  }

  // 打开操作弹窗
  openOperatePop() {
    if(this.currentPet) {
      this.showOperatePop = true;
    }
  }

  // 修改宠物档案，跳转编辑页，携带petId参数
  editPet() {
    if(!this.currentPet) return;
    this.showOperatePop = false;
    router.pushUrl({
      url: `pages/subPages/PetAddPage?petId=${this.currentPet.petId}`
    })
  }

  // // 删除宠物档案
  // async deletePet() {
  //   if(!this.currentPet) return;
  //   try {
  //     await CloudDBService.deletePetById(this.currentPet.petId);
  //     promptAction.showToast({ message: "删除成功" });
  //     this.showOperatePop = false;
  //     // 刷新列表
  //     const newList = await CloudDBService.getAllPetData();
  //     this.petList = newList;
  //     if(newList.length > 0) {
  //       this.currentPet = newList[0];
  //       this.swiperIndex = 0;
  //     } else {
  //       this.currentPet = null;
  //     }
  //   } catch (e) {
  //     promptAction.showToast({ message: "删除失败" });
  //   }
  // }

  // 操作弹窗Builder
  @Builder
  OperatePopup() {
    Column({ space: 12 }) {
      Text("档案操作")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8 })
      Button("修改档案")
        .width("100%")
        .height(48)
        .backgroundColor("#FFB86C")
        .fontColor("#fff")
        .borderRadius(12)
        .onClick(() => this.editPet())
      // Button("删除档案")
      //   .width("100%")
      //   .height(48)
      //   .backgroundColor("#ee5555")
      //   .fontColor("#fff")
      //   .borderRadius(12)
      //   .onClick(() => this.deletePet())
      Button("取消")
        .width("100%")
        .height(48)
        .backgroundColor("#eeeeee")
        .fontColor("#333")
        .borderRadius(12)
        .onClick(() => this.showOperatePop = false)
    }
    .width("85%")
    .padding(20)
    .backgroundColor("#ffffff")
    .borderRadius(16)
  }

  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Text("宠物日记")
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333333")
          .width("100%")
          .textAlign(TextAlign.Center)
        Text("体重、健康随时追踪")
          .fontSize(30)
          .fontColor("#888888")
          .margin({ top: 8 })
          .width("100%")
          .textAlign(TextAlign.Center)
      }
      .width("100%")
      .padding({ left: 20, top: 20, bottom: 16 })

      // 加载中占位
      if (this.loading) {
        Text("加载宠物数据中...")
          .fontSize(16)
          .fontColor("#666")
      } else if (this.currentPet !== null && this.petList.length > 0) {
        // 滑动宠物卡片（末尾带添加新宠物按钮）
        Swiper() {
          ForEach(this.petList, (pet: PetModel) => {
            PetInfoCard({
              currentPet: pet,
              navigateToSetting: (): void => this.navSetting()
            })
              .margin({ left: 12, right: 12 })
              .onClick(() => {
                // 点击卡片弹出修改删除弹窗
                this.currentPet = pet;
                this.openOperatePop();
              })
          })

          // 添加新宠物卡片
          Column() {
            Text("+")
              .fontSize(30)
              .fontColor("#ffb040")
            Text("添加新宠物")
              .fontSize(15)
              .fontColor("#666")
              .margin({ top: 10 })
          }
          .width("92%")
          .height(95)
          .backgroundColor("#fff9e8")
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ left: 12, right: 12 })
          .onClick(() => {
            router.pushUrl({ url: "pages/subPages/PetAddPage" })
          })
        }
        .index(this.swiperIndex)
        .loop(false)
        .indicator(false)
        .onChange((idx: number) => {
          if (idx < this.petList.length) {
            this.currentPet = this.petList[idx];
            this.swiperIndex = idx;
          }
        })
        .margin({ bottom: 16 })

        // 关键区域：图片铺满下方，八宫格在图片上层
        Stack({ alignContent: Alignment.Top }) {
          // 底层插画铺满
          Column() {
            PetIllustration()
          }
          .width("100%")
          .height("100%")

          // 上层八宫格：靠顶部，占上半部分
          Column() {
            FuncGrid()
          }
          .width("95%")
          .height("45%")
          .backgroundColor("#20111111")
          .borderRadius(16)
          .padding({ left: 12, right: 12, top: 5 ,bottom:5})
          .margin({ top: 0 })
        }
        .width("100%")
        .layoutWeight(1)
      } else {
        // 无宠物时提示添加
        Column() {
          Text("暂无宠物档案，前往添加第一只宠物")
            .fontSize(16)
            .fontColor("#3366cc")
            .decoration({ type: TextDecorationType.Underline })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          promptAction.showToast({ message: "点击触发了！" });
          router.pushUrl({ url: "pages/subPages/PetAddPage" })
            .catch((err: BusinessError) => {
              promptAction.showToast({ message: "跳转失败：" + JSON.stringify(err) });
            })
        })
      }
      // 弹窗改用条件渲染，彻底删掉报错的bindPopup
      if (this.showOperatePop) {
        Stack() {
          // 遮罩层
          Rect()
            .width("100%")
            .height("100%")
            .fill("#00000040")
            .onClick(() => this.showOperatePop = false)
          this.OperatePopup()
        }
        .width("100%")
        .height("100%")
        .position({ x: 0, y: 0 })
      }

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#FFF2D0")

  }
}