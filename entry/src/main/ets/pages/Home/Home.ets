import API from '../../network/API'
import { Article, ArticleTag } from '../../network/model/Article'
import { HomeBannerData } from '../../network/model/Banner'
import { LoadState, PageLoading } from '../../widgets/PageLoading'
import { BannerComponent } from './BannerComponent'
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { ListDataSource } from '../../network/model/ListDataSource'
import Preferences from '../../common/Preferences'
import EntryContext from '../../common/EntryContext'
import UserService, { User } from '../../service/UserService'

declare type HomeItemData = Article | HomeBannerData[]

@Component
export struct Home {
  @State dataList: ListDataSource<HomeItemData> = new ListDataSource()
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  private nextPage: number = 1
  private hasMore: boolean = true
  private scroller: Scroller = new Scroller()
  @State bannerOff: boolean = false
  @State topOff: boolean = false
  @State needRefresh: boolean = false
  @Prop @Watch("onRefresh") isShow: boolean

  private userObserver = (user?: User) => {
    // 用户状态变化，刷新列表
    if (user) {
      this.needRefresh = true
      this.onRefresh()
    } else {
      this.dataList.dataArray.forEach((item, index) => {
        if (!Array.isArray(item)) {
          if (item.collect) {
            item.collect = false
            this.dataList.notifyDataChange(index)
          }
        }
      })
    }
  }

  aboutToAppear() {
    this.LoadData()

    this.bannerOff = Preferences.get(EntryContext.getContext() as Context).getHomeBannerOff()
    this.topOff = Preferences.get(EntryContext.getContext() as Context).getHomeTopOff()

    UserService.addUserObserver(this.userObserver)
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
  }

  onRefresh(): void {
    if (this.isShow == false) {
      return
    }

    const bannerOff = Preferences.get(EntryContext.getContext() as Context).getHomeBannerOff()
    if (this.bannerOff != bannerOff) {
      this.bannerOff = bannerOff
      this.needRefresh = true
    }
    const topOff = Preferences.get(EntryContext.getContext() as Context).getHomeTopOff()
    if (this.topOff != topOff) {
      this.topOff = topOff
      this.needRefresh = true
    }

    if (this.needRefresh) {
      this.LoadData()
    }
  }

  LoadData() {
    this.needRefresh = false
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0)
      .then((data) => {
        this.dataList.resetAllData(data)
        if (this.dataList.totalCount() == 0) {
          this.loadState = LoadState.EMPTY
        } else {
          this.loadState = LoadState.SUCCESS
        }
      }, () => {
        this.loadState = LoadState.FAIL
      })
  }

  private async loadDataByPage(page: number): Promise<HomeItemData[]> {
    if (page == 0) {

      let articleList: Article[] = []
      let dataList: HomeItemData[] = []

      const articleResponse = await API.getHomeArticleList(page)

      if (articleResponse.isSuccessWithData()) {
        articleList = articleList.concat(articleResponse.getDataOrThrow().datas)
      } else {
        return Promise.reject()
      }

      // 加载第一页数据,同时需要加载 banner 和置顶文章
      if (this.topOff == false) {
        const topResponse = await API.getTopArticle()

        if (topResponse.isSuccessWithData()) {
          topResponse.getDataOrThrow().forEach((item) => {
            const tag = new ArticleTag()
            tag.name = "置顶"
            item.tags = [tag].concat(item.tags)
            articleList.unshift(item)
          })
        }
      }

      if (this.bannerOff == false) {
        const bannerResponse = await API.getHomeBanner()

        if (bannerResponse.isSuccessWithData()) {
          const bannerList = bannerResponse.getDataOrThrow()
          dataList.unshift(bannerList)
        }
      }


      // 拼接文章数据
      dataList = dataList.concat(articleList)
      return Promise.resolve(dataList)

    } else {
      // 加载其他页码数据，只需要获取文章列表就可以
      const articleResponse = await API.getHomeArticleList(page)
      if (articleResponse.isSuccessWithData()) {
        return Promise.resolve(articleResponse.getDataOrThrow().datas)
      } else {
        return Promise.reject()
      }
    }
  }

  build() {

    Column() {
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: () => {
          this.LoadData()
        },
        content: (() => {
          this.pullToRefreshBuilder()
        })
      })
        .layoutWeight(1)
    }
  }

  @Builder
  private pullToRefreshBuilder() {
    PullToRefresh({
      data: $dataList,
      scroller: this.scroller,
      customList: () => {
        this.listViewBuilder()
      },
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataByPage(0)
            .then((data) => {
              this.dataList.resetAllData(data)
              this.nextPage = 1
              this.hasMore = true
              resolve("刷新成功")
            },
              () => {
                reject("刷新失败")
              })
        })
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          if (this.hasMore) {
            this.loadDataByPage(this.nextPage)
              .then((data) => {
                if (data.length > 0) {
                  this.dataList.pushDataList(data)
                  this.nextPage++
                  resolve("加载成功")
                } else {
                  this.hasMore = false
                  resolve("没有更多了")
                }
              },
                () => {
                  reject("加载失败")
                })
          } else {
            resolve("没有更多了")
          }
        })
      }
    })
  }

  @Builder
  private listViewBuilder() {

    List({
      scroller: this.scroller
    }) {
      LazyForEach(this.dataList, (item: HomeItemData, index) => {
        ListItem() {
          if (item instanceof Array) {
            BannerComponent({
              bannerList: item
            })
          } else {
            ArticleItemComponent({
              article: item as Article,
              updateCollectCallBack: async () => {
                this.dataList.notifyDataChange(index)
              }
            })
          }
        }
      }, (item: Article, index) => `${item.id} + ${index} + ${item.collect}`)
    }
    .cachedCount(5)
    .width("100%")
    .height("100%")
    .listDirection(Axis.Vertical)
    .divider({
      strokeWidth: 0.5,
      color: $r("app.color.divider"),
      startMargin: 16,
      endMargin: 16
    })
    .edgeEffect(EdgeEffect.None)
  }
}