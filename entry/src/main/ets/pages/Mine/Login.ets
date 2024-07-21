import { toast } from '../../common/Toast'
import API from '../../network/API'
import UserService from '../../service/UserService'
import { LoadState, PageLoading } from '../../widgets/PageLoading'
import { router } from '@kit.ArkUI'
import TitleLayout from '../../widgets/TitleLayout'

@Entry
@Component
struct Login {
  @State loadState: LoadState = LoadState.SUCCESS
  @State showLoading: boolean = false
  @State title: string = "登录"
  private account: string = ""
  private password: string = ""

  build() {
    Stack() {
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading
      }) {
        Column() {
          TitleLayout({
            title: this.title,
            enableBack: false
          })

          Column() {
            TextInput({
              placeholder: "请输入用户名"
            })
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .type(InputType.Email)
              .onChange((value) => {
                this.account = value
              })

            TextInput({
              placeholder: "请输入密码"
            })
              .fontSize(15)
              .margin({ top: 16 })
              .fontColor($r("app.color.text_h1"))
              .type(InputType.Password)
              .onChange((value) => {
                this.password = value
              })

            Button("登录", {
              type: ButtonType.Capsule
            })
              .width("100%")
              .margin({ top: 50 })
              .fontSize(15)
              .fontColor($r("app.color.white"))
              .backgroundColor($r("app.color.main"))
              .onClick(() => {
                this.login().catch()
              })

            Button("注册账号", {
              type: ButtonType.Capsule,
            })
              .stateEffect(false)
              .width("100%")
              .margin({top: 30})
              .fontColor(Color.Gray)
              .fontSize(12)
              .backgroundColor("#00000000")
              .onClick(() =>{
                router.replaceUrl({
                  url: "pages/Mine/Register"
                })
              })
          }
          .width("100%")
          .margin({ top: 120 })
          .padding({ left: 16, right: 16 })

        }
        .width("100%")
        .height("100%")
      }
    }
    .width("100%")
    .height("100%")
  }

  private async login() {
    if (!this.account) {
      toast("请输入用户名")
      return
    }
    if (!this.password) {
      toast("请输入密码")
      return
    }

    this.showLoading = true
    const response = await API.login(this.account, this.password)
    this.showLoading = false
    if (response.isSuccessWithData()) {
      UserService.setUser(response.data)
      const user = await UserService.updateUser()
      if (user) {
        router.back()
      }
    } else {
      toast(response.errorMsg)
    }
  }
}