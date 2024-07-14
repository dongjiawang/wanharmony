import WindowUtils from '../common/WindowUtils'
import { router } from '@kit.ArkUI'

@Component
export struct TitleLayout {
  @Prop title: string
  isJustShowStatusBar: boolean = false
  showBack: boolean = true
  menuIcon?: Resource
  onMenuClick?: () => void
  onBack: () => void = () => {
    router.back()
  }

  build() {
    Column() {
      Blank().height(WindowUtils.statusBarHeight)

      if (this.isJustShowStatusBar === false) {
        Row() {
          if (this.showBack) {
            Image($r("app.media.ic_back"))
              .width(48)
              .height(48)
              .padding(14)
              .fillColor($r("app.color.text_h1"))
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                this.onBack()
              })
          }
          Text(this.title)
            .layoutWeight(1)
            .fontSize(17)
            .fontColor($r("app.color.text_h1"))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 16, right: 16 })

          if (this.menuIcon) {
            Image(this.menuIcon)
              .width(48)
              .height(48)
              .padding(14)
              .fillColor($r("app.color.text_h1"))
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                if (this.onMenuClick) {
                  this.onMenuClick()
                }
              })
          }
        }
        .width("100%")
        .height(48)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width("100%")
    .backgroundColor($r("app.color.title_bar_bg"))
  }
}
