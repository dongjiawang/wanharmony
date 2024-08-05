import WindowUtils from '../../common/WindowUtils'
import { Square } from './Square'
import { Home } from './Home'
import { router } from '@kit.ArkUI'
import { Wechat } from './Wechat/Wechat'

@Component
export struct Main {
  @State tabTitles: string[] = []
  private tabsController = new TabsController()
  @State currentIndex: number = 0
  @State needRefresh: boolean = false
  @Prop pageIndex: number
  @Prop @Watch("onRefresh") currentPosition: number

  build() {
    Column() {
      Blank()
        .height(WindowUtils.statusBarHeight)
        .backgroundColor($r("app.color.title_bar_bg"))

      Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
        ForEach(this.tabTitles, (title: string, index) => {
          TabContent() {
            if (index == 0) {
              Home({
                pageIndex: index,
                currentPosition: this.currentIndex
              })
            } else if (index == 1) {
              Square()
            } else {
              Wechat()
            }
          }.tabBar(this.tabBuilder(title, index, index == this.tabTitles.length - 1))
        })
      }
      .barMode(BarMode.Fixed)
      .width("100%")
      .barHeight(44)
      .divider(null)
      .barBackgroundColor($r("app.color.start_window_background"))
      .onChange((index) => {
        this.currentIndex = index
      })
    }
    .width("100%")
    .height("100%")
  }

  aboutToAppear(): void {
    this.creatTabs()
  }

  private creatTabs() {
    this.tabTitles = ["热门博文", "广场", "公众号"]
  }

  onRefresh(): void {
    if (this.pageIndex != this.currentPosition) {
      return
    }

    if (this.needRefresh) {
      this.creatTabs()
    }
  }

  @Builder
  tabBuilder(title: string, targetIndex: number, showSearchBtn: boolean) {
    Row() {
      Row() {
        Text(title)
          .fontColor(this.currentIndex == targetIndex ? $r("app.color.title_bar_text") :
          $r("app.color.navi_tab_unselect"))
          .fontSize(14)
          .onClick(() => {
            this.currentIndex = targetIndex
            this.tabsController.changeIndex(targetIndex)
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      if (showSearchBtn) {
        SymbolGlyph($r("sys.symbol.magnifyingglass"))
          .fontSize(22)
          .fontColor([$r("app.color.title_bar_text")])
          .width(44)
          .height(44)
          .padding({ left: 10, right: 10 })
          .backgroundColor($r("app.color.title_bar_bg"))
          .onClick(() => {
            router.pushUrl({
              url: "pages/Search/SearchEntry"
            })
          })
      }

    }
    .height("100%")
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r("app.color.title_bar_bg"))
  }
}