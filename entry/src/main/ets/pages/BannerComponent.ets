import { HomeBannerData } from '../network/model/Banner'
import { router } from '@kit.ArkUI'

/**
 * 首页的 banner 模块
 */
@Component
export struct BannerComponent {
  private swiperController: SwiperController = new SwiperController()
  @State private bannerPosition: number = 0
  bannerList: HomeBannerData[] = []

  build() {
    Stack() {
      Swiper(this.swiperController) {
        ForEach(this.bannerList, (item: HomeBannerData) => {
          this.bannerItemBuilder(item)
        })
      }
      .autoPlay(true)
      .index(this.bannerPosition)
      .loop(true)
      .indicator(
        DotIndicator.dot()
          .right(16)
          .bottom(0))
      .onChange((index) => {
        this.bannerPosition = index
      })
    }
    .width("100%")
    .height(220)
  }

  @Builder
  private bannerItemBuilder(data: HomeBannerData) {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(data.imagePath)
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.Cover)
      Text(data.title)
        .width("100%")
        .fontColor($r("app.color.white"))
        .fontSize(15)
        .maxLines(1)
        .backgroundColor($r("app.color.translucent_black_40"))
        .padding({
          left: 16,
          top: 6,
          right: 16,
          bottom: 6
        })
    }
    .width("100%")
    .height("100%")

    // .onClick(() => {
    //   router.pushUrl({
    //     url: "pages/web",
    //     params: {
    //       url: data.url
    //     }
    //   })
    // })
  }
}