@Entry
@Component
struct WidgetCard {
  build() {
    Column() {
      Text("宠物日记小组件")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Text("快捷查看宠物提醒")
        .fontSize(12)
        .fontColor("#666")
    }
    .width("100%")
    .height("100%")
    .padding(12)
    .backgroundColor("#FFF9E8")
  }
}