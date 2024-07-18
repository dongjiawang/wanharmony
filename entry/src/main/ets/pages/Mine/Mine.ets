import API from '../../network/API'
import UserService, { User } from '../../service/UserService'
import { promptAction, router } from '@kit.ArkUI'
import WindowUtils from '../../common/WindowUtils'
import { MineListItem, MineListItemModel } from '../../widgets/MineListItem'
import { toast } from '../../common/Toast'

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

  build() {

    Column() {
      Blank().height(WindowUtils.statusBarHeight)

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

      List() {
        ForEach(this.listData, (item: MineListItemModel, index) => {
          ListItem() {
            MineListItem({
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

      if (this.isLogin) {
        Column() {
          Button("退出登录")
            .width("100%")
            .fontSize(15)
            .fontColor($r("app.color.white"))
            .backgroundColor($r("app.color.red"))
            .onClick(() => {
              this.logout()
            })
        }
        .width("100%")
        .margin({ top: 50 })
        .padding({ left: 16, right: 16 })
      }
    }
    .margin({ top: 30 })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      UserService.checkLogin()
    })
  }

  aboutToAppear(): void {
    this.creatListModel()
    UserService.addUserObserver(this.userObserver)
    const user = UserService.getUser()
    this.userObserver(user)
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
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
    setting.icon = "sys.symbol.list_bullet"
    setting.title = "设置"

    let about = new MineListItemModel()
    about.icon = "sys.symbol.info_circle"
    about.title = "关于我们"

    this.listData = [coin, collect, share, setting, about]
  }
  
  private pushPageByIndex(index: number) {
    if (index == 1) {
      UserService.checkLogin(() =>{
        router.pushUrl({
          url: "pages/Mine/CollectList"
        })
      })
    } else {
      toast("功能开发中")
    }
  }

  async logout() {
    const response = await promptAction.showDialog({
      title: "提示",
      message: "确认退出登录？",
      buttons: [
        {
          text: "确认",
          color: $r("app.color.main")
        },
        {
          text: "取消",
          color: $r("app.color.text_h2")
        }
      ]
    })
    if (response.index === 0) {
      await API.logout()
      UserService.clearUser()
      this.listData[0].rightTitle = ""
    }
  }
}