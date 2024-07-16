import { toast } from '../../common/Toast'
import API from '../../network/API'
import UserService from '../../service/UserService'
import { LoadState, PageLoading } from '../../widgets/PageLoading'
import TitleLayout from '../../widgets/TitleLayout'
import { router } from '@kit.ArkUI'

@Entry
@Component
export struct Register {
  @State loadState: LoadState = LoadState.SUCCESS
  @State showLoading: boolean = false
  @State title: string = "注册账号"
  private username: string = ""
  private password: string = ""
  private repassword: string = ""

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
                this.username = value
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

            TextInput({
              placeholder: "请确认输入密码"
            })
              .fontSize(15)
              .margin({ top: 16 })
              .fontColor($r("app.color.text_h1"))
              .type(InputType.Password)
              .onChange((value) => {
                this.repassword = value
              })

            Button("注册", {
              type: ButtonType.Capsule
            })
              .width("100%")
              .margin({ top: 50 })
              .fontSize(15)
              .fontColor($r("app.color.white"))
              .backgroundColor($r("app.color.main"))
              .onClick(() => {
                this.register().catch()
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

  private async register() {
    if (!this.username) {
      toast("请输入用户名")
      return
    }
    if (!this.password) {
      toast("请输入密码")
      return
    }

    if (!this.repassword) {
      toast("请输入确认密码")
      return
    }

    this.showLoading = true
    const response = await API.register(this.username, this.password, this.repassword)
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