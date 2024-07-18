@Component
export struct MineListItem {
  itemModel: MineListItemModel = new MineListItemModel()

  build() {
    Row() {
      SymbolGlyph($r(this.itemModel.icon))
        .fontSize(18)
        .fontColor([$r("app.color.main")])

      Text(this.itemModel.title)
        .fontSize(16)
        .fontColor($r("app.color.text_h1"))
        .padding({
          left: 16,
          right: 16
        })
        .layoutWeight(1)

      if (this.itemModel.rightTitle) {
        Text(this.itemModel.rightTitle)
          .textAlign(TextAlign.End)
          .fontSize(14)
          .fontColor($r("app.color.text_h1"))
          .padding({
            right: 16
          })
          .layoutWeight(1)
      }

      SymbolGlyph($r("sys.symbol.chevron_right"))
        .fontSize(18)
        .fontColor([$r("app.color.text_h2")])

    }
    .width("100%")
    .height(44)
    .padding({
      left: 16,
      right: 16
    })
  }
}

export class MineListItemModel {
  icon: string = ""
  title: string = ""
  rightTitle: string = ""
}