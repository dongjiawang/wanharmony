import OHPermission from "../common/OHPermission"
import WindowUtils from '../common/WindowUtils'
import { Home } from './Home/Home'
import { Mine } from './Mine/Mine'
import { TreePage } from "./Tree/TreePage"
import { common } from '@kit.AbilityKit'
import { toast } from '../common/Toast'
import { Question } from './Question/Question'

@Entry
@Component
struct Index {
  private backTimeStamp: number = 0
  private tabsController = new TabsController()
  @State currentIndex: number = 0
  @State isPermissionGrant: boolean = false

  build() {
    Column() {
      if (this.isPermissionGrant) {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
          TabContent() {
            Home({
              pageIndex: 0,
              currentPosition: this.currentIndex
            })
          }.tabBar(this.tabBuilder("首页", 0, $r("sys.symbol.house_fill"), $r("sys.symbol.house")))

          TabContent() {
            Question({
              pageIndex: 1,
              currentPosition: this.currentIndex
            })
          }
          .tabBar(this.tabBuilder("问答", 1, $r("sys.symbol.message_on_message_fill"),
            $r("sys.symbol.message_on_message")))

          TabContent() {
            TreePage()
          }.tabBar(this.tabBuilder("体系", 2, $r("sys.symbol.satellite_map_fill"), $r("sys.symbol.satellite_map")))

          TabContent() {
            Mine()
          }.tabBar(this.tabBuilder("我的", 3, $r("sys.symbol.person_shield_fill"), $r("sys.symbol.person_shield")))
        }
        .layoutWeight(1)
        .scrollable(true)
        .animationDuration(0)
        .onChange((index) => {
          this.currentIndex = index
        })
        .backgroundColor($r("app.color.start_window_background"))
      } else {
        Text("没有网络权限")
          .width("100%")
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      Blank().height(WindowUtils.navigationBarHeight).backgroundColor($r("app.color.navi_bar_bg"))
    }
  }

  aboutToAppear(): void {
    OHPermission.requestPermission(getContext(this), ["ohos.permission.INTERNET"])
      .then(() => {
        this.isPermissionGrant = true
      })
      .catch(() => {
        this.isPermissionGrant = false
      })
  }

  onBackPress(): boolean | void {
    let now = Date.now()
    if (now - this.backTimeStamp < 1000) {
      const ctx = getContext(this) as common.UIAbilityContext
      ctx.terminateSelf()
    } else {
      this.backTimeStamp = now
      toast("再按一次将退出应用")
    }
    return true
  }

  @Builder
  tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      SymbolGlyph(this.currentIndex == targetIndex ? selectedImg : normalImg)
        .fontSize(24)
        .fontColor(this.currentIndex == targetIndex ? [$r("app.color.main")] : [$r("app.color.navi_tab_unselect")])
        .symbolEffect(new ScaleSymbolEffect(EffectScope.WHOLE, EffectDirection.UP), this.currentIndex == targetIndex)
        .padding({ top: 5, bottom: 5 })

      Text(title)
        .fontColor(this.currentIndex == targetIndex ? $r("app.color.main") : $r("app.color.navi_tab_unselect"))
        .fontSize(11)
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.navi_bar_bg"))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex
      this.tabsController.changeIndex(targetIndex)
    })
  }
}
