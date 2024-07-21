import EntryContext from '../../../common/EntryContext'
import Preferences from '../../../common/Preferences'
import TitleLayout from '../../../widgets/TitleLayout'
import { ConfigurationConstant } from '@kit.AbilityKit'
import UserService from '../../../service/UserService'
import { promptAction } from '@kit.ArkUI'
import API from '../../../network/API'
import WindowUtils from '../../../common/WindowUtils'

@Entry
@Component
struct Setting {
  @State isAutoColorModeOn: boolean = false
  @State isDark: boolean = false
  @State isBannerOff: boolean = false
  @State isTopOff: boolean = false
  private app = getContext().getApplicationContext()

  build() {
    Column() {
      Column() {
        TitleLayout({
          title: "设置"
        })

        Row() {
          Column({ space: 3 }) {
            Text("跟随系统深色模式")
              .fontSize(16)
              .fontColor($r("app.color.text_h1"))

            Text("开启后，将跟随系统打开或者关闭深色模式")
              .fontSize(12)
              .fontColor($r("app.color.navi_tab_unselect"))
          }
          .alignItems(HorizontalAlign.Start)

          Toggle({
            type: ToggleType.Switch,
            isOn: this.isAutoColorModeOn
          })
            .onChange((value) => {
              this.isAutoColorModeOn = value
              if (value) {
                Preferences.get(EntryContext.getContext() as Context).putColorMode(-1)
                this.app.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
                this.isDark = false
              } else {
                Preferences.get(EntryContext.getContext() as Context).putColorMode(1)
                this.app.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
              }
            })
        }
        .width("100%")
        .height(50)
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.SpaceBetween)

        Divider()
          .width("100%")
          .height(2)
          .backgroundColor(Color.Transparent)
          .padding({ left: 16, right: 16 })

        Row() {
          Text("深色模式")
            .fontColor(this.isAutoColorModeOn ? $r("app.color.search_input_placeholder") : $r("app.color.text_h1"))
            .fontSize(16)

          Toggle({
            type: ToggleType.Switch,
            isOn: this.isDark
          })
            .enabled(!this.isAutoColorModeOn)
            .onChange((value) => {
              this.isDark = value
              if (value) {
                Preferences.get(EntryContext.getContext() as Context).putColorMode(0)
                this.app.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
              } else {
                Preferences.get(EntryContext.getContext() as Context).putColorMode(1)
                this.app.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
              }
            })
        }
        .width("100%")
        .height(50)
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.SpaceBetween)

        Divider()
          .width("100%")
          .height(2)
          .backgroundColor(Color.Transparent)
          .padding({ left: 16, right: 16 })

        Row() {
          Text("显示首页轮播")
            .fontColor($r("app.color.text_h1"))
            .fontSize(16)

          Toggle({
            type: ToggleType.Switch,
            isOn: this.isBannerOff
          })
            .onChange((value) => {
              Preferences.get(EntryContext.getContext() as Context).putHomeBannerOff(!value)
            })
        }
        .width("100%")
        .height(50)
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.SpaceBetween)

        Divider()
          .width("100%")
          .height(2)
          .backgroundColor(Color.Transparent)
          .padding({ left: 16, right: 16 })

        Row() {
          Text("显示首页置顶文章")
            .fontColor($r("app.color.text_h1"))
            .fontSize(16)

          Toggle({
            type: ToggleType.Switch,
            isOn: this.isTopOff
          })
            .onChange((value) => {
              Preferences.get(EntryContext.getContext() as Context).putHomeTopOff(!value)
            })
        }
        .width("100%")
        .height(50)
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.SpaceBetween)
      }

      if (UserService.isLogin()) {
        Row() {
          Button("退出登录")
            .width("100%")
            .fontSize(15)
            .fontColor($r("app.color.red"))
            .borderColor($r("app.color.divider"))
            .backgroundColor("#00000000")
            .borderWidth(1)
            .borderRadius(2)
            .onClick(() => {
              this.logout()
            })
        }
        .width("100%")
        .padding({ left: 30, right: 30, bottom: WindowUtils.navigationBarHeight + 50 })
      }
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  aboutToAppear(): void {
    const preferences = Preferences.get(EntryContext.getContext() as Context)
    const colorMode = preferences.getColorMode()
    this.isAutoColorModeOn = colorMode == (-1 || undefined)
    this.isDark = colorMode == 0
    this.isBannerOff = !preferences.getHomeBannerOff()
    this.isTopOff = !preferences.getHomeTopOff()
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