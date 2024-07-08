import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import CollectUtils from '../common/CollectUtils'
import API from '../network/API'
import { Article } from '../network/model/Article'
import { ArticleItemComponent } from '../widgets/ArticleItemComponent'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { router } from '@kit.ArkUI'
import { TitleLayout } from '../widgets/TitleLayout'

@Entry
@Component
struct SearchResult {
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State title: string = ""
  @State data: Article[] = []
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
      }) {
        Column() {
          PullToRefresh({
            data: $data,
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
                      this.data = this.data.concat(data)
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
        .width("100%")
        .height("100%")
      }
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
      this.data = data
      if (this.data.length === 0) {
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
        item.title = this.removeHtmlTags(item.title)
      })
      return Promise.resolve(list)
    } else {
      return Promise.reject()
    }
  }

  /**
   * 移除 html 的标签字符
   * @param text
   * @returns
   */
  private removeHtmlTags(text: string): string {
    return text.replace(/<[^>]+>/g, '')
      .replace('&gt;', '>')
      .replace('&lt;', '<')
  }

  @Builder
  private listViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (item: Article) => {
        ListItem() {
          ArticleItemComponent({
            article: item,
            onCollectClick: (article: Article) => {
              CollectUtils.collect(article).then((success) => {
                if (success) {
                  this.data = this.data.map(item => item)
                }
              })
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

export class SearchResultParams {
  keyword: string = ""

  constructor(keyword: string) {
    this.keyword = keyword
  }
}