import TitleLayout from '../../../widgets/TitleLayout';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct OpenSource {
  build() {
    Column() {
      TitleLayout({
        title: "开源项目"
      })

      Column({space: 5}) {
        Text("PullToRefresh")
          .fontSize(16)
          .fontColor($r("app.color.text_h1"))

        Text("PullToRefresh 是一款 OpenHarmony 环境下可用的下拉刷新、上拉加载组件。")
          .fontSize(12)
          .fontColor($r("app.color.text_h2"))
      }
      .width("100%")
      .padding({ left: 16, right: 16 , top: 10})
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        router.pushUrl({
          url: "pages/Web/WebPage",
          params: {
            url: "https://gitee.com/openharmony-sig/PullToRefresh"
          }
        })
      })
    }
    .height('100%')
    .width('100%')
  }
}