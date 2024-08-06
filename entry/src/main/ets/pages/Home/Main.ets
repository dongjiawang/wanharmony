import WindowUtils from '../../common/WindowUtils'
import { router, SymbolGlyphModifier } from '@kit.ArkUI'
import { Hot } from './Hot/Hot'
import { Square } from './Square'
import { Wechat } from './Wechat/Wechat'

@Component
export struct Main {
  private menuList: Array<SelectMenuModel> = [
    { id: 0, value: "热门博文" },
    { id: 1, value: "广场" },
    { id: 1, value: "公众号" }
  ]
  @State selectedValue: string = "热门博文"
  @State selectedIndex: number = 0

  @Prop pageIndex: number
  @Prop @Watch("onRefresh") currentPosition: number
  @State isShow: boolean = false

  build() {
    Column() {
      Blank()
        .backgroundColor($r("app.color.title_bar_bg"))
        .height(WindowUtils.statusBarHeight)

      Row() {
        Row()
          .width(44)

        Select(this.menuList)
          .onSelect((index: number, value: string) => {
            this.selectedIndex = index
            this.selectedValue = value
          })
          .value(this.selectedValue)
          .selectedOptionFontColor($r("app.color.main"))
          .fontColor($r("app.color.title_bar_text"))
          .backgroundColor($r("app.color.title_bar_bg"))
          .menuBackgroundColor($r("app.color.start_window_background"))
          .menuAlign(MenuAlignType.CENTER)

        SymbolGlyph($r("sys.symbol.magnifyingglass"))
          .fontSize(22)
          .fontColor([$r("app.color.title_bar_text")])
          .width(44)
          .height("100%")
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            router.pushUrl({
              url: "pages/Search/SearchEntry"
            })
          })
      }
      .width("100%")
      .height(44)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r("app.color.title_bar_bg"))

      Column() {
        if (this.selectedIndex == 0) {
          Hot({
            isShow: this.isShow
          })
        } else if (this.selectedIndex == 1) {
          Square({
            isShow: this.isShow
          })
        } else {
          Wechat({
            isShow: this.isShow
          })
        }
      }
      .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
  }

  onRefresh(): void {

    this.isShow = this.pageIndex == this.currentPosition
  }
}


export class SelectMenuModel implements SelectOption {
  id: number = 0
  value: ResourceStr = ""
  icon?: ResourceStr | undefined
  symbolIcon?: SymbolGlyphModifier | undefined
}