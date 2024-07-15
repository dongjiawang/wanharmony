import API from '../network/API'
import UserService, { User } from '../service/UserService'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { promptAction, router } from '@kit.ArkUI'
import WindowUtils from '../common/WindowUtils'

class UserInfo {
  name: string = ""
  icon: string = ""
  level: string = ""
  rank: string = ""
  point: string = ""
}

@Component
export struct Mine {
  @State loadState: LoadState = LoadState.SUCCESS
  @State showLoading: boolean = false
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
    } else {
      this.isLogin = false
      this.userInfo = this.unLoginInfo
    }
  }

  build() {
    PageLoading({
      loadState: this.loadState,
      showLoading: this.showLoading
    }) {
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
        .margin({ top: 30 })
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          UserService.checkLogin()
        })

        Row() {
          Text("我的积分")
            .layoutWeight(1)
            .fontSize(15)
            .fontColor($r("app.color.text_h1"))
          Text(this.userInfo.point)
            .fontSize(15)
            .fontColor($r("app.color.text_h1"))
        }
        .width("100%")
        .height(50)
        .margin({ top: 50 })
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          UserService.checkLogin()
        })

        Row()
          .width("100%")
          .height(0.5)
          .backgroundColor($r("app.color.divider"))

        Row() {
          Text("我的收藏")
            .layoutWeight(1)
            .fontSize(15)
            .fontColor($r("app.color.text_h1"))
          Image($r("app.media.ic_arrow_right"))
            .fillColor($r("app.color.text_h1"))
            .width(20)
            .height(20)
        }
        .width("100%")
        .height(50)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r("app.color.white"))
        .onClick(() => {
          UserService.checkLogin(() => {
            router.pushUrl({
              url: "pages/CollectList"
            })
          })
        })

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
      .width("100%")
      .height("100%")
    }
  }

  aboutToAppear(): void {
    UserService.addUserObserver(this.userObserver)
    const user = UserService.getUser()
    this.userObserver(user)
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
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
    }
  }
}