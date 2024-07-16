import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import CollectUtils from '../../common/CollectUtils'
import API from '../../network/API'
import { Article } from '../../network/model/Article'
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent'
import { LoadState, PageLoading } from '../../widgets/PageLoading'

@Component
export struct WechatTab {
  authorId: number = 0
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State data: Article[] = []
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
        this.data = data
        if (this.data.length === 0) {
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
      data: $data,
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
                this.data = this.data.concat(data)
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
      ForEach(this.data, (item: Article) => {
        ListItem() {
          ArticleItemComponent({
            article: item,
            onCollectClick: ((article: Article) => {
              CollectUtils.collect(article).then((success) => {
                if (success) {
                  this.data = this.data.map(item => item)
                }
              })
            })
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