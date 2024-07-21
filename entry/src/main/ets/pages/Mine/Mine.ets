import UserService, { User } from '../../service/UserService'
import WindowUtils from '../../common/WindowUtils'
import { MineListItemComponent, MineListItemModel } from '../../widgets/MineListItemComponent'
import { toast } from '../../common/Toast'
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
      Blank().height(WindowUtils.statusBarHeight)

      Column() {
        Image(this.isLogin ? this.userInfo.icon : $r("app.media.logo"))
          .width(100)
          .height(100)
          .borderRadius(50)
          .borderWidth(2)
          .borderColor($r("app.color.main"))

        Text(this.userInfo.name)
          .fontColor($r("app.color.text_h1"))
          .fontSize(17)
          .margin({ top: 16 })

        Row({ space: 5 }) {
          Text("LV" + this.userInfo.level)
            .fontColor($r("app.color.white"))
            .fontSize(15)
            .backgroundColor($r("app.color.main"))
            .padding({
              left: 4,
              top: 2,
              right: 4,
              bottom: 2
            })

          Text("排名" + this.userInfo.rank)
            .fontColor($r("app.color.white"))
            .fontSize(15)
            .backgroundColor($r("app.color.blue"))
            .padding({
              left: 4,
              top: 2,
              right: 4,
              bottom: 2
            })
        }
        .margin({ top: 16 })
      }
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
      .divider({
        strokeWidth: 0.5,
        color: $r("app.color.divider"),
        startMargin: 16,
        endMargin: 16
      })
      .padding({ top: 50 })
    }
    .width("100%")
    .height("100%")
    .margin({ top: 30 })
    .alignItems(HorizontalAlign.Center)
  }

  aboutToAppear(): void {
    UserService.addUserObserver(this.userObserver)
    const user = UserService.getUser()
    this.userObserver(user)
  }

  onPageShow(): void {
    this.isLogin = UserService.isLogin()
    if (this.isLogin == false) {
      this.listData[0].rightTitle = ""
    }
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

      default:
        toast("功能开发中")
        break;
    }
  }
}