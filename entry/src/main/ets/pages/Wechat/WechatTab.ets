import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import API from '../../network/API'
import { Article } from '../../network/model/Article'
import { ListDataSource } from '../../network/model/ListDataSource'
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent'
import { LoadState, PageLoading } from '../../widgets/PageLoading'

@Component
export struct WechatTab {
  authorId: number = 0
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State articles: ListDataSource<Article> = new ListDataSource()
  private scroller: Scroller = new Scroller()
  private refreshConfig = new PullToRefreshConfigurator()
  private nextPage: number = 1
  private hasMore: boolean = true

  build() {
    Column() {
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: (() => {
          this.loadData()
        }),
        content: (() => {
          this.pullToRefreshBuilder()
        })
      })
        .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
  }

  aboutToAppear(): void {
    this.refreshConfig.setHasRefresh(false)
    this.loadData()
  }

  private loadData() {
    if (this.authorId) {
      this.loadState = LoadState.LOADING
      this.loadDataByPage(0).then((data) => {
        data.forEach((item) => {
          this.articles.pushData(item)
        })
        if (this.articles.totalCount() == 0) {
          this.loadState = LoadState.EMPTY
        } else {
          this.loadState = LoadState.SUCCESS
        }
      }, () => {
        this.loadState = LoadState.FAIL
      })
    } else {
      this.loadState = LoadState.FAIL
    }
  }

  private async loadDataByPage(page: number) {
    const response = await API.getWechatArticleList(this.authorId, page)
    if (response.isSuccessWithData()) {
      const list = response.getDataOrThrow().datas
      return Promise.resolve(list)
    } else {
      return Promise.reject()
    }
  }

  @Builder
  private pullToRefreshBuilder() {
    PullToRefresh({
      data: $articles,
      scroller: this.scroller,
      refreshConfigurator: this.refreshConfig,
      customList: () => {
        this.listViewBuilder()
      },
      onLoadMore: (() => {
        return new Promise<string>((resolve, reject) => {
          if (this.hasMore) {
            this.loadDataByPage(this.nextPage).then((data) => {
              if (data.length > 0) {
                this.nextPage++
                data.forEach((item) => {
                  this.articles.pushData(item)
                })
                resolve("加载成功")
              } else {
                this.hasMore = false
                resolve("没有更多了")
              }
            }, () => {
              reject("加载失败")
            })
          } else {
            resolve("没有更多了")
          }
        })
      })
    })
  }

  @Builder
  private listViewBuilder() {
    List({ scroller: this.scroller }) {
      LazyForEach(this.articles, (item: Article, index) => {
        ListItem() {
          ArticleItemComponent({
            article: item,
            updateCollectCallBack: async () => {
              item.collect = !item.collect
              this.articles.notifyDataChange(index)
            }
          })
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