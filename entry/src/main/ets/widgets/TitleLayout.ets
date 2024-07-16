import WindowUtils from '../common/WindowUtils'
import { router } from '@kit.ArkUI'
import { SymbolEffectStrategy } from '@ohos.arkui.advanced.SubHeader'

@Component
export default struct TitleLayout {
  enableBack: boolean = true
  @Prop title: string = ""
  rightImage?: Resource | null = null
  rightText?: string | null = null
  rightSymbol?: Resource | null = null
  bgColor: Resource = $r("app.color.main")
  onBackClick?: () => void
  onRightTextClick?: () => void
  onRightImageClick?: () => void
  onRightSymbolClick?: () => void

  build() {
    Column() {
      Blank().height(WindowUtils.statusBarHeight)

      RelativeContainer() {
        RelativeContainer() {
          Stack() {
            SymbolGlyph($r("sys.symbol.chevron_left"))
              .fontSize(30)
              .fontColor([$r("app.color.title_bar_text")])
          }
          .width(44)
          .height(44)
          .alignRules({
            center: { anchor: "__container__", align: VerticalAlign.Center },
            left: { anchor: "__container__", align: HorizontalAlign.Start }
          })
          .alignContent(Alignment.Center)
          .visibility(this.enableBack ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            if (this.onBackClick) {
              this.onBackClick()
            } else {
              router.back()
            }
          })
          .id("back")

          Text(this.title)
            .fontColor($r("app.color.title_bar_text"))
            .fontSize(18)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
            .width("60%")
            .alignRules({
              middle: { anchor: "__container__", align: HorizontalAlign.Center },
              center: { anchor: "__container__", align: VerticalAlign.Center }
            })
            .id("title")
        }


        Row() {
          Stack() {
            Text(this.rightText == null ? "" : this.rightText)
              .fontSize(16)
              .fontColor($r("app.color.text_h1"))
          }
          .height(44)
          .padding({ left: 10, right: 10 })
          .alignContent(Alignment.Center)
          .visibility(this.rightText == null ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (this.onRightTextClick) {
              this.onRightTextClick()
            }
          })

          Stack() {
            Image(this.rightImage == null ? null : this.rightImage)
              .width(22)
              .height(22)
              .fillColor($r("app.color.title_bar_text"))
              .objectFit(ImageFit.Contain)
          }
          .height(44)
          .padding({ left: 10, right: 10 })
          .alignContent(Alignment.Center)
          .visibility(this.rightImage == null ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (this.onRightImageClick) {
              this.onRightImageClick()
            }
          })

          Stack() {
            SymbolGlyph(this.rightSymbol)
              .fontSize(22)
              .fontColor([$r("app.color.title_bar_text")])
          }
          .height(44)
          .padding({ left: 10, right: 10 })
          .alignContent(Alignment.Center)
          .visibility(this.rightSymbol == null ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (this.onRightSymbolClick) {
              this.onRightSymbolClick()
            }
          })
        }
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          right: { anchor: "__container__", align: HorizontalAlign.End },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
        .id("right")
      }
      .alignRules({
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        top: { anchor: "__container__", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      })
      .id("content")
      .width("100%")
      .height(44)
    }
    .width("100%")
    .backgroundColor(this.bgColor)
  }
}
