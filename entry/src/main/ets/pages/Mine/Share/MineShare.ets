import UserService from '../../../service/UserService'
import TitleLayout from '../../../widgets/TitleLayout'
import { router } from '@kit.ArkUI'
import { LoadState, PageLoading } from '../../../widgets/PageLoading'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { ListDataSource } from '../../../network/model/ListDataSource'
import { Article } from '../../../network/model/Article'
import { ArticleItemComponent } from '../../../widgets/ArticleItemComponent'
import API from '../../../network/API'

@Entry
@Component
struct MineShare {
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State articles: ListDataSource<Article> = new ListDataSource()
  private scroller: Scroller = new Scroller()
  private nextPage: number = 2
  private hasMore: boolean = true

  build() {
    Column() {
      TitleLayout({
        title: "我的分享",
        rightSymbol: $r("sys.symbol.plus"),
        onRightSymbolClick: () => {
          UserService.checkLogin(() => {
            router.pushUrl({
              url: "pages/Mine/Share/AddShare"
            })
          })
        }
      })

      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        content: () => {
          this.pullToRefreshBuilder()
        }
      })
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    this.loadData()
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(1).then((data) => {
      this.articles.resetAllData(data)
      if (this.articles.totalCount() === 0) {
        this.loadState = LoadState.EMPTY
      } else {
        this.loadState = LoadState.SUCCESS
      }
    }, () => {
      this.loadState = LoadState.FAIL
    })
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    const response = await API.getShareArticleList(page)
    if (response.isSuccessWithData()) {
      const list = response.getDataOrThrow().shareArticles.datas
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
      customList: () => {
        this.listViewBuilder()
      },
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataByPage(0).then((data) => {
            this.articles.resetAllData(data)
            this.nextPage = 2
            this.hasMore = true
            resolve("刷新成功")
          }, () => {
            reject("刷新失败")
          })
        })
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          if (this.hasMore) {
            this.loadDataByPage(this.nextPage).then((data) => {
              if (data.length > 0) {
                this.nextPage++
                this.articles.pushDataList(data)
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
      }
    })
  }

  @Builder
  private listViewBuilder() {

    List({
      scroller: this.scroller
    }) {
      LazyForEach(this.articles, (item: Article) => {
        ListItem() {
          ArticleItemComponent({
            isShare: true,
            article: item as Article,
            deleteCallBack: async () => {
              this.showLoading = true
              const success = await API.deleteSharedArticle(item.id)
              this.showLoading = false
              if (success) {
                this.articles.deleteData(this.articles.dataArray.indexOf(item))
                if (this.articles.totalCount() === 0) {
                  this.loadData()
                }
              }
            }
          })
        }
      }, (item: Article) => `${item.id}`)
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