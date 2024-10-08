import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import API from '../../network/API'
import { Article } from '../../network/model/Article'
import { ListDataSource } from '../../network/model/ListDataSource'
import UserService, { User } from '../../service/UserService'
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent'
import { LoadState, PageLoading } from '../../widgets/PageLoading'

@Component
export struct Square {
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State articles: ListDataSource<Article> = new ListDataSource()
  private scroller: Scroller = new Scroller()
  private refreshConfig = new PullToRefreshConfigurator()
  private nextPage: number = 0
  private hasMore: boolean = true
  @State needRefresh: boolean = false
  @Prop @Watch("onRefresh") isShow: boolean
  private userObserver = (user?: User) => {
    // 用户状态变化，刷新列表
    if (user) {
      this.needRefresh = true
      this.onRefresh()
    } else {
      this.articles.dataArray.forEach((item, index) => {
        if (!Array.isArray(item)) {
          if (item.collect) {
            item.collect = false
            this.articles.notifyDataChange(index)
          }
        }
      })
    }
  }

  build() {
    Column() {

      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: () => {
          this.loadData()
        }
      }) {
        Column() {
          PullToRefresh({
            data: $articles,
            scroller: this.scroller,
            refreshConfigurator: this.refreshConfig,
            customList: () => {
              this.listViewBuilder()
            },
            onRefresh: () => {
              return new Promise<string>((resolve, reject) => {
                this.loadDataByPage(0).then((data) => {
                  this.articles.resetAllData(data)
                  this.nextPage = 1
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
        .width("100%")
        .height("100%")
      }
    }
    .width("100%")
    .height("100%")
  }

  onRefresh(): void {
    if (this.isShow === false) {
      return
    }

    if (this.needRefresh) {
      this.loadData()
      this.needRefresh = false
    }
  }

  aboutToAppear(): void {
    this.loadData()
    UserService.addUserObserver(this.userObserver)
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0).then((data) => {
      this.articles.resetAllData(data)
      if (this.articles.totalCount() === 0) {
        this.loadState = LoadState.EMPTY
        this.nextPage = 0
      } else {
        this.loadState = LoadState.SUCCESS
        this.nextPage = 1
      }
    }, () => {
      this.loadState = LoadState.FAIL
    })
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    const response = await API.getSquareArticleList(page)
    if (response.isSuccessWithData()) {
      const list = response.getDataOrThrow().datas
      return Promise.resolve(list)
    } else {
      return Promise.reject()
    }
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