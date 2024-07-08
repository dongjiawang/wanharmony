import API from '../network/API'
import { Article, ArticleTag } from '../network/model/Article'
import { HomeBannerData } from '../network/model/Banner'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { BannerComponent } from './BannerComponent'
import { ArticleItemComponent } from '../widgets/ArticleItemComponent'
import { TitleLayout } from '../widgets/TitleLayout'
import { PullToRefresh } from '@ohos/pulltorefresh'
import CollectUtils from '../common/CollectUtils'
import { router } from '@kit.ArkUI'

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
      // 加载第一页数据,同时需要加载 banner 和置顶文章
      const bannerResponse = await API.getHomeBanner()
      const topResponse = await API.getTopArticle()
      const articleResponse = await API.getHomeArticleList(page)

      if (bannerResponse.isSuccessWithData() && topResponse.isSuccessWithData() &&
      articleResponse.isSuccessWithData()) {
        // 处理文章数据
        // 将置顶文章的数据添加置顶标签并放到文章列表顶部
        let articleList: Article[] = []
        topResponse.getDataOrThrow().forEach((item) => {
          const tag = new ArticleTag()
          tag.name = "置顶"
          item.tags = [tag].concat(item.tags)
          articleList.push(item)
        })
        // 拼接其他文章列表数据
        articleList = articleList.concat(articleResponse.getDataOrThrow().datas)
        // 转换为页面使用的数据模型
        let dataList: HomeItemData[] = []
        // 拼接banner 数据
        const bannerList = bannerResponse.getDataOrThrow()
        dataList.push(bannerList)
        // 拼接文章数据
        dataList = dataList.concat(articleList)
        return Promise.resolve(dataList)
      } else {
        return Promise.reject()
      }
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
    PageLoading({
      loadState: this.loadState,
      showLoading: this.showLoading,
      onReload: () => {
        this.LoadData()
      }
    }) {
      Column() {
        TitleLayout({
          title: this.title,
          showBack: false,
          menuIcon: $r("app.media.ic_search"),
          onMenuClick: () => {
            router.pushUrl({
              url: "pages/SearchEntry",
            })
          }
        })
        PullToRefresh({
          data: $data,
          scroller: this.scroller,
          customList: () => {
            this.listViewBuilder()
          },
          onRefresh: () => {
            return new Promise<string>((resolve, reject) => {
              this.loadDataByPage(0)
                .then((data) => {
                  this.nextPage = 1
                  this.data = data
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
                      this.nextPage++
                      this.data = this.data.concat(data)
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
                reject("没有更多了")
              }
            })
          }
        })
          .width("100%")
          .height("100%")
      }
    }
  }

  @Builder
  private listViewBuilder() {
    List({
      scroller: this.scroller
    }) {
      ForEach(this.data, (item: HomeItemData) => {
        ListItem() {
          if (item instanceof Array) {
            BannerComponent({
              bannerList: item
            })
          } else {
            ArticleItemComponent({
              article: item as Article,
              onCollectClick: async (article: Article) => {
                const success = await CollectUtils.collect(article)
                if (success) {
                  this.data = this.data.map(item => item)
                }
              }
            })
          }
        }
      })
    }
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