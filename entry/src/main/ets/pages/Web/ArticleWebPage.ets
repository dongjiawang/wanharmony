import webview from '@ohos.web.webview';
import { router } from '@kit.ArkUI';
import WindowUtils from '../../common/WindowUtils';
import Preferences from '../../common/Preferences';
import EntryContext from '../../common/EntryContext';

@Entry
@Component
struct ArticleWebPage {
  private webController: webview.WebviewController = new webview.WebviewController()
  private url: string = (router.getParams() as WebPageParams).url
  @State progress: number = 0
  @State upButtonOpacity: number = 0
  private isOnlyDark: boolean = false

  aboutToAppear() {
    this.isOnlyDark = Preferences.get(EntryContext.getContext() as Context).getColorMode() == 0
  }

  onBackPress(): boolean | void {
    if (this.webController.accessBackward()) {
      this.webController.backward()
      return true
    }
    return false
  }

  build() {
    Column() {
      Blank().height(WindowUtils.statusBarHeight)

      if (this.progress !== 100) {
        Progress({
          value: this.progress,
          total: 100,
          type: ProgressType.Linear
        })
          .width("100%")
      }

      Stack({ alignContent: Alignment.BottomStart }) {
        Web({
          src: this.url,
          controller: this.webController
        })
          .width("100%")
          .height("100%")
          .backgroundColor($r("app.color.start_window_background"))
          .onlineImageAccess(true)
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .databaseAccess(true)
          .mixedMode(MixedMode.All)
          .darkMode(this.isOnlyDark ? WebDarkMode.On : WebDarkMode.Auto)
          .forceDarkAccess(true)
          .onProgressChange((event) => {
            this.progress = event?.newProgress ?? 0
          })
          .onScroll((event) => {
            this.upButtonOpacity = event.yOffset > 200 ? 0.9 : 0
          })

        Row() {
          Row() {
            SymbolGlyph($r("sys.symbol.arrow_left"))
              .fontSize(20)
              .fontColor([Color.White])
              .padding({
                left: 5,
                right: 5,
                top: 5,
                bottom: 5
              })
          }
          .backgroundColor($r("app.color.main"))
          .opacity(0.9)
          .width(30)
          .height(30)
          .borderRadius(20)
          .onClick(() => {
            if (this.webController.accessBackward()) {
              this.webController.backward()
            } else {
              router.back()
            }
          })

          SymbolGlyph($r("sys.symbol.arrow_up_to_line"))
            .fontSize(30)
            .fontColor([$r("app.color.main")])
            .opacity(this.upButtonOpacity)
            .width(30)
            .height(30)
            .align(Alignment.Center)
            .onClick(() => {
              this.webController.scrollTo(0, 0)
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width("100%")
        .padding({
          left: 16,
          right: 16,
          bottom: WindowUtils.navigationBarHeight
        })

      }
      .width("100%")
      .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
  }
}

export class WebPageParams {
  url: string = ""

  constructor(url: string) {
    this.url = url
  }
}