import UserService, { User } from '../../service/UserService'
import WindowUtils from '../../common/WindowUtils'
import { MineListItemComponent, MineListItemModel } from '../../widgets/MineListItemComponent'
import { router } from '@kit.ArkUI'

class UserInfo {
  name: string = ""
  icon: string = ""
  level: string = ""
  rank: string = ""
  point: string = ""
}

@Component
export struct Mine {
  private unLoginInfo: UserInfo = {
    name: "未登录",
    icon: "",
    level: "",
    rank: "",
    point: ""
  }
  @State userInfo: UserInfo = this.unLoginInfo
  @State isLogin: boolean = false
  private userObserver = (user?: User) => {
    if (user) {
      this.isLogin = true
      this.userInfo = {
        name: user.nickname,
        icon: user.icon.length > 0 ? user.icon : "https://www.wanandroid.com/resources/image/pc/logo.png",
        level: user.level,
        rank: user.rank,
        point: user.coinCount.toString()
      }
      this.creatListModel()
      this.listData[0].rightTitle = user.coinCount.toString()
    } else {
      this.isLogin = false
      this.userInfo = this.unLoginInfo
      this.creatListModel()
    }
  }
  @State listData: MineListItemModel[] = []
  @Prop pageIndex: number
  @Prop @Watch("onRefresh") currentPosition: number

  build() {

    Column() {
      Blank().height(WindowUtils.statusBarHeight).backgroundColor($r("app.color.title_bar_bg"))

      Column() {
        Image(this.isLogin ? this.userInfo.icon : $r("app.media.logo"))
          .width(100)
          .height(100)
          .borderRadius(50)
          .borderWidth(1)
          .borderColor($r("app.color.white"))

        Text(this.userInfo.name)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.title_bar_text"))
          .fontSize(18)
          .margin({ top: 16 })

        if (this.isLogin) {
          Row({ space: 5 }) {
            Text("等级:" + this.userInfo.level)
              .fontColor($r("app.color.title_bar_text"))
              .fontSize(14)
              .padding({
                left: 4,
                top: 2,
                right: 4,
                bottom: 2
              })

            Text("排名:" + this.userInfo.rank)
              .fontColor($r("app.color.title_bar_text"))
              .fontSize(14)
              .padding({
                left: 4,
                top: 2,
                right: 4,
                bottom: 2
              })
          }
          .padding({ top: 5 })
        }
      }
      .padding({ top: 30, bottom: 30 })
      .backgroundColor($r("app.color.title_bar_bg"))
      .width("100%")
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        UserService.checkLogin()
      })

      List() {
        ForEach(this.listData, (item: MineListItemModel, index) => {
          ListItem() {
            MineListItemComponent({
              itemModel: item
            })
              .onClick(() => {
                this.pushPageByIndex(index)
              })
          }

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
    .width("100%")
    .height("100%")
    .alignItems(HorizontalAlign.Center)
  }

  aboutToAppear(): void {
    UserService.addUserObserver(this.userObserver)
    const user = UserService.getUser()
    this.userObserver(user)
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
  }

  onRefresh(): void {
    UserService.updateUser()
  }

  private creatListModel() {
    let coin = new MineListItemModel()
    coin.icon = "sys.symbol.hotspot"
    coin.title = "我的积分"
    coin.rightTitle = "0"

    let collect = new MineListItemModel()
    collect.icon = "sys.symbol.heart"
    collect.title = "我的收藏"

    let share = new MineListItemModel()
    share.icon = "sys.symbol.share"
    share.title = "我的分享"

    let setting = new MineListItemModel()
    setting.icon = "sys.symbol.gearshape"
    setting.title = "设置"

    let about = new MineListItemModel()
    about.icon = "sys.symbol.info_circle"
    about.title = "关于我们"

    this.listData = [coin, collect, share, setting, about]
  }

  private pushPageByIndex(index: number) {
    switch (index) {
      case 0:
        UserService.checkLogin(() => {
          router.pushUrl({
            url: "pages/Mine/CoinList"
          })
        })
        break;
      case 1:
        UserService.checkLogin(() => {
          router.pushUrl({
            url: "pages/Mine/CollectList"
          })
        })
        break
      case 2:
        UserService.checkLogin(() => {
          router.pushUrl({
            url: "pages/Mine/Share/MineShare"
          })
        })
        break
      case 3:
        router.pushUrl({
          url: "pages/Mine/Setting/Setting"
        })
        break
      case 4:
        router.pushUrl({
          url: "pages/Mine/About/About"
        })

      default:

        break;
    }
  }
}