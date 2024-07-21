import { MineListItemComponent, MineListItemModel } from '../../../widgets/MineListItemComponent'
import TitleLayout from '../../../widgets/TitleLayout'
import { router } from '@kit.ArkUI'
import { bundleManager } from '@kit.AbilityKit'

@Entry
@Component
struct About {
  @State listData: MineListItemModel[] = []
  @State versionName: string = ""
  @State versionCode: string = ""

  build() {
    Column() {
      TitleLayout({
        title: "关于我们"
      })

      Column() {
        Image($r("app.media.logo"))
          .width(80)
          .height(80)

        Text(this.versionName + `(${this.versionCode})`)
          .fontSize(14)
          .fontColor($r("app.color.text_h1"))
          .padding({ top: 10 })
      }
      .width("100%")
      .padding({ top: 50, bottom: 50 })

      List() {
        ForEach(this.listData, (item: MineListItemModel, index) => {
          MineListItemComponent({
            itemModel: item
          })
            .onClick(() => {
              this.pushPageByIndex(index)
            })
        })
      }
      .width("100%")
      .layoutWeight(1)
      .divider({
        strokeWidth: 0.5,
        color: $r("app.color.divider"),
        startMargin: 16,
        endMargin: 16
      })
    }
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName
      this.versionCode = bundleInfo.versionCode.toString()
    })

    this.creatListModel()
  }

  private pushPageByIndex(index: number) {
    switch (index) {
      case 0:
        router.pushUrl({
          url: "pages/Web/WebPage",
          params: {
            url: "https://www.wanandroid.com"
          }
        })

        break
      case 1:
        router.pushUrl({
          url: "pages/Web/WebPage",
          params: {
            url: "https://gitee.com/jiawangdong/wan-harmony"
          }
        })

        break
      case 2:
        router.pushUrl({
          url: "pages/Mine/About/OpenSource"
        })

        break
      default:
        break;
    }
  }

  private creatListModel() {
    let web = new MineListItemModel()
    web.title = "官方网站"

    let repostory = new MineListItemModel()
    repostory.title = "项目仓库"

    let openSource = new MineListItemModel()
    openSource.title = "开源项目"

    this.listData = [web, repostory, openSource]
  }
}