import API from '../network/API'
import { Article } from '../network/model/Article'
import { HomeBannerData } from '../network/model/Banner'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { data } from '@kit.TelephonyKit'
import { BannerComponent } from './BannerComponent'

declare type HomeItemData = Article | HomeBannerData[]

@Component
export struct Home {
  @State data: HomeItemData[] = []
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State bannerPosition: number = 0
  @State title: string = "首页"
  private static TAG = "首页"
  private nextPage: number = 1
  private hasMore: boolean = true
  private scroller: Scroller = new Scroller()

  async aboutToAppear() {
    this.LoadData()
  }

  async LoadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0)
      .then((data) => {
        this.data = data
        if (this.data.length === 0) {
          this.loadState = LoadState.EMPTY
        } else {
          this.loadState = LoadState.SUCCESS
        }
      }, () => {
        this.loadState = LoadState.FAIL
      })
  }

  private async loadDataByPage(page: number): Promise<HomeItemData[]> {
    if (page === 0) {
      const bannerResponse = await API.getHomeBanner()
      let dataList: HomeItemData[] = []


      if (bannerResponse.isSuccessWithData()) {
        const bannerList = bannerResponse.getDataOrThrow()
        dataList.push(bannerList)
      }

      if (dataList.length === 0) {
        return Promise.reject()
      }
      return Promise.resolve(dataList)
    }
    return Promise.reject()
  }

  build() {
    PageLoading({
      loadState: this.loadState,
      showLoading: this.showLoading,
      onReload: () => {
        this.LoadData()
      }
    }) {
      Column() {
        List({ scroller: this.scroller }) {
          ForEach(this.data, (item: HomeItemData) => {
            if (item instanceof Array) {
              BannerComponent({
                bannerList: item
              })
            }
          })
        }
      }
    }
  }
}