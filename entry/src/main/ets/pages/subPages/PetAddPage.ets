import router from "@ohos.router";
import CloudDBService from "../../service/CloudDBService";
import { PetModel } from "../../model/PetModel";
import promptAction from "@ohos.promptAction";
import util from "@ohos.util";


// 先定义参数类型接口（ArkTS允许）
interface RouteParams {
  petId?: string;
}

@Entry
@Component
struct PetAddPage {
  @State petName: string = "";
  @State petType: string = "";
  @State petGender: string = "GG";
  @State birthStr: string = "";
  @State adoptStr: string = "";
  @State showBirth: boolean = false;
  @State showAdopt: boolean = false;

  editPetId: string | null = null;

  async aboutToAppear() {
    // 改用接口做类型转换，规避 arkts-no-obj-literals-as-types 限制
    const params = router.getParams() as RouteParams;
    if (params && params.petId) {
      this.editPetId = params.petId;
      /*
      const petInfo = await CloudDBService.getPetById(this.editPetId);
      if (petInfo) {
        this.petName = petInfo.petName;
        this.petType = petInfo.petType;
        this.petGender = petInfo.petGender;
        this.birthStr = petInfo.birthDay;
        this.adoptStr = petInfo.createDay;
      }
      */
    }
  }

  async savePet() {
    if (!this.petName || !this.petType || !this.birthStr || !this.adoptStr) {
      promptAction.showToast({ message: "请完整填写信息" });
      return;
    }

    if (this.editPetId) {
      promptAction.showToast({ message: "数据库暂不支持修改，仅可新增" });
      return;
    } else {
      const petId = util.generateRandomUUID(false);
      const newPet = new PetModel(
        petId,
        this.petName,
        this.petType,
        this.petGender,
        this.birthStr,
        this.adoptStr,
        "",
        0
      );
      await CloudDBService.savePet(newPet);
      promptAction.showToast({ message: "添加成功" });
    }
    router.replaceUrl({ url: "pages/PetIndex" });
  }

  build() {
    Column() {
      Row() {
        Text("<")
          .fontSize(28)
          .fontColor("#333")
          .onClick(() => router.back())
        Text(this.editPetId ? "修改宠物档案" : "添加新宠物")
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width("100%")
      .padding({ left: 12, right: 12, top: 10, bottom: 16 })

      Row() {
        Image($r("app.media.pet_bg_illust"))
          .width(88)
          .height(88)
          .borderRadius(44)
          .objectFit(ImageFit.Cover)
      }
      .width("100%")
      .padding({ top: 10, bottom: 24 })
      .justifyContent(FlexAlign.Center)

      List({ space: 1 }) {
        ListItem() {
          Row() {
            Text("宠物昵称")
              .fontSize(18)
              .fontColor("#222")
            Blank()
            Row() {
              TextInput({ text: this.petName, placeholder: "填写昵称" })
                .width(160)
                .fontSize(16)
                .textAlign(TextAlign.End)
                .backgroundColor("#00ffffff")
                .onChange((val: string) => this.petName = val)
              Text(">")
                .fontSize(20)
                .fontColor("#999")
                .margin({ left: 6 })
            }
          }
          .width("100%")
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor("#ffffff")
        }

        ListItem() {
          Row() {
            Text("品种")
              .fontSize(18)
              .fontColor("#222")
            Blank()
            Row() {
              TextInput({ text: this.petType, placeholder: "英短/金毛" })
                .width(160)
                .fontSize(16)
                .textAlign(TextAlign.End)
                .backgroundColor("#00ffffff")
                .onChange((val: string) => this.petType = val)
              Text(">")
                .fontSize(20)
                .fontColor("#999")
                .margin({ left: 6 })
            }
          }
          .width("100%")
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor("#ffffff")
        }

        ListItem() {
          Row() {
            Text("性别")
              .fontSize(18)
              .fontColor("#222")
            Blank()
            Row() {
              Text(this.petGender === "GG" ? "公" : "母")
                .fontSize(16)
                .fontColor("#999")
              Text(">")
                .fontSize(20)
                .fontColor("#999")
                .margin({ left: 6 })
            }
          }
          .width("100%")
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor("#ffffff")
          .onClick(() => {
            this.petGender = this.petGender === "GG" ? "MM" : "GG";
          })
        }

        ListItem() {
          Column() {
            Row() {
              Text("生日")
                .fontSize(18)
                .fontColor("#222")
              Blank()
              Row() {
                Text(this.birthStr || "选择日期")
                  .fontSize(16)
                  .fontColor(this.birthStr ? "#333" : "#999")
                Text(">")
                  .fontSize(20)
                  .fontColor("#999")
                  .margin({ left: 6 })
              }
            }
            .width("100%")
            .height(60)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.showBirth = !this.showBirth;
              this.showAdopt = false;
            })

            if (this.showBirth) {
              DatePicker()
                .width("100%")
                .height(140)
                .padding({ left: 16, right: 16 })
                .onChange((res) => {
                  const m = String(res.month).padStart(2, "0");
                  const d = String(res.day).padStart(2, "0");
                  this.birthStr = `${res.year}-${m}-${d}`;
                })
            }
          }
          .width("100%")
          .backgroundColor("#ffffff")
        }

        ListItem() {
          Column() {
            Row() {
              Text("领养日期")
                .fontSize(18)
                .fontColor("#222")
              Blank()
              Row() {
                Text(this.adoptStr || "选择日期")
                  .fontSize(16)
                  .fontColor(this.adoptStr ? "#333" : "#999")
                Text(">")
                  .fontSize(20)
                  .fontColor("#999")
                  .margin({ left: 6 })
              }
            }
            .width("100%")
            .height(60)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.showAdopt = !this.showAdopt;
              this.showBirth = false;
            })

            if (this.showAdopt) {
              DatePicker()
                .width("100%")
                .height(140)
                .padding({ left: 16, right: 16 })
                .onChange((res) => {
                  const m = String(res.month).padStart(2, "0");
                  const d = String(res.day).padStart(2, "0");
                  this.adoptStr = `${res.year}-${m}-${d}`;
                })
            }
          }
          .width("100%")
          .backgroundColor("#ffffff")
        }
      }
      .width("100%")
      .layoutWeight(1)
      .backgroundColor("#eee")

      Button(this.editPetId ? "修改档案" : "保存宠物档案")
        .width("92%")
        .height(52)
        .margin({ bottom: 24 })
        .backgroundColor("#FFB86C")
        .fontSize(18)
        .fontColor("#ffffff")
        .borderRadius(14)
        .onClick(() => this.savePet())
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#ffffff")
  }
}