import { toast } from '../../../common/Toast';
import API from '../../../network/API';
import TitleLayout from '../../../widgets/TitleLayout';
import { router } from '@kit.ArkUI';
import WindowUtils from '../../../common/WindowUtils';

@Entry
@Component
struct AddShare {
  @State showLoading: boolean = false
  @State articleTitle: string = ""
  @State articleLink: string = ""
  private tipString: string = "1. 只要是任何好文都可以分享哈，并不一定要是原创！投递的文章会进入广场 tab; \n " +
    "2. CSDN，掘金，简书等官方博客站点会直接通过，不需要审核;\n " +
    "3. 其他个人站点会进入审核阶段，不要投递任何无效链接，测试的请尽快删除，否则可能会对你的账号产生一定影响;\n" +
    "4. 目前处于测试阶段，如果你发现500等错误，可以向我提交日志，让我们一起使网站变得更好。\n" +
    "5. 由于本站只有我一个人开发与维护，会尽力保证24小时内审核，当然有可能哪天太累，会延期，请保持佛系...\n"

  build() {

    Column() {
      TitleLayout({
        title: "分享文章"
      })

      Stack() {
        Column() {
          Column({ space: 10 }) {
            Text("文章标题")
              .fontSize(16)
              .fontColor($r("app.color.text_h2"))

            TextArea({
              placeholder: "请输入文章标题(100字以内)"
            })
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .maxLength(100)
              .maxLines(5)
              .onChange((value) => {
                this.articleTitle = value.replaceAll("\n", "")
              })
              .borderRadius(2)

            Text("文章链接")
              .fontSize(16)
              .fontColor($r("app.color.text_h2"))
              .padding({
                top: 20
              })

            TextArea({
              placeholder: "请输入文章链接"
            })
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .maxLines(5)
              .onChange((value) => {
                this.articleLink = value.replaceAll("\n", "")
              })
              .borderRadius(2)

            Row() {
              Button("分享", {
                type: ButtonType.Capsule
              })
                .width("70%")
                .margin({ top: 50 })
                .fontSize(15)
                .fontColor($r("app.color.white"))
                .backgroundColor($r("app.color.main"))
                .onClick(() => {
                  this.share()
                })
            }
            .justifyContent(FlexAlign.Center)
            .width("100%")
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: 16,
            top: 20,
            right: 16,
            bottom: 20
          })

          Text(this.tipString)
            .fontSize(11)
            .fontColor($r("app.color.text_h2"))
            .width("100%")
            .lineHeight(20)
            .padding({
              left: 16,
              right: 16,
              bottom: WindowUtils.navigationBarHeight
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width("100%")
        .height("100%")

        if (this.showLoading) {
          Stack() {
            Stack() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color($r("app.color.white"))
            }
            .width(100)
            .height(100)
            .backgroundColor($r("app.color.translucent_black_50"))
            .borderRadius(8)
          }
          .width("100%")
          .height("100%")
        }

      }
      .width("100%")
      .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
  }

  private async share() {
    if (this.articleTitle.replace(" ", "").length == 0) {
      toast("请输入有效的文章标题")
      return
    }
    if (this.articleLink.replaceAll(" ", "").length == 0) {
      toast("请输入有效的文章链接")
      return
    }

    this.showLoading = true
    const response = await API.shareArticle(this.articleTitle, this.articleLink)
    this.showLoading = false
    if (response.isSuccessWithData()) {
      router.back()
    } else {
      toast(response.errorMsg)
    }
  }
}