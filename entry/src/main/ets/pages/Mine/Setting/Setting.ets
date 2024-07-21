import EntryContext from '../../../common/EntryContext'
import Preferences from '../../../common/Preferences'
import TitleLayout from '../../../widgets/TitleLayout'
import { ConfigurationConstant } from '@kit.AbilityKit'

@Entry
@Component
struct Setting {
  @State isOn: boolean = false
  @State isDark: boolean = false
  private app = getContext().getApplicationContext()

  build() {
    Column() {
      TitleLayout({
        title: "设置"
      })

      Row() {
        Column({ space: 3}) {
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
          isOn: this.isOn
        })
          .onChange((value) => {
            this.isOn = value
            if (value) {
              Preferences.get(EntryContext.getContext() as Context).putColorMode(-1)
              this.app.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
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

      Row() {
        Text("深色模式")
          .fontColor(this.isOn ? $r("app.color.search_input_placeholder") : $r("app.color.text_h1"))
          .fontSize(16)

        Toggle({
          type: ToggleType.Switch,
          isOn: this.isDark
        })
          .enabled(!this.isOn)
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
    }
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    const colorMode = Preferences.get(EntryContext.getContext() as Context).getColorMode()
    this.isOn = colorMode == (-1 || undefined)
    this.isDark = colorMode == 0
  }
}