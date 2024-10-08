import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import API from '../../network/API'
import { Article } from '../../network/model/Article'
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent'
import { LoadState, PageLoading } from '../../widgets/PageLoading'
import { router } from '@kit.ArkUI'
import TitleLayout from '../../widgets/TitleLayout'
import StringTool from '../../common/StringTool'
import { ListDataSource } from '../../network/model/ListDataSource'

@Entry
@Component
struct SearchResult {
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State title: string = ""
  @State articles: ListDataSource<Article> = new ListDataSource()
  private keyword: string = ""
  private refreshConfig = new PullToRefreshConfigurator()
  private scroller: Scroller = new Scroller()
  private nextPage: number = 1
  private hasMore: boolean = true

  build() {
    Column() {
      TitleLayout({
        title: this.title
      })
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: () => {
          this.loadData()
        },
        content:(() => {
          this.pullToRefreshBuilder()
        })
      })
        .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
  }

  aboutToAppear() {
    const param = router.getParams() as SearchResultParams
    this.keyword = param.keyword
    this.title = this.keyword
    this.refreshConfig.setHasRefresh(false)
    this.loadData()
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0).then((data) => {
      this.articles.resetAllData(data)
      if (this.articles.totalCount() === 0) {
        this.loadState = LoadState.EMPTY
      } else {
        this.loadState = LoadState.SUCCESS
      }
    },
      () => {
        this.loadState = LoadState.FAIL
      }
    )
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    const response = await API.search(this.keyword, page)
    if (response.isSuccessWithData()) {
      const list = response.getDataOrThrow().datas
      list.forEach((item) => {
        item.title = StringTool.removeHtmlTags(item.title)
      })
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
              reject("没有更多了")
            })
          } else {
            reject("没有更多了")
          }
        })
      },
      customLoad: null,
      customRefresh: null
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
              this.articles.notifyDataChange(index)
            }
          })
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

export class SearchResultParams {
  keyword: string = ""

  constructor(keyword: string) {
    this.keyword = keyword
  }
}