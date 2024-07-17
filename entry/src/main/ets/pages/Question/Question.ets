import { PullToRefresh } from '@ohos/pulltorefresh';
import API from '../../network/API';
import { Article } from '../../network/model/Article';
import { ListDataSource } from '../../network/model/ListDataSource';
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent';
import { LoadState, PageLoading } from '../../widgets/PageLoading';
import TitleLayout from '../../widgets/TitleLayout';

@Component
export struct Question {
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  private title: string = '问答';
  @State articles: ListDataSource<Article> = new ListDataSource()
  private scroller: Scroller = new Scroller()
  private nextPage: number = 1
  private hasMore: boolean = true

  build() {
    Column() {
      TitleLayout({
        title: this.title,
        enableBack: false
      })

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
  }

  aboutToAppear(): void {
    this.loadData()
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0).then((data) => {
      this.articles.resetAllData(data)
      if (this.articles.totalCount() == 0) {
        this.loadState = LoadState.EMPTY
      } else {
        this.loadState = LoadState.SUCCESS
      }
    }, () => {
      this.loadState = LoadState.FAIL
    })
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    const response = await API.getWendaArticleList(page)
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
      customList: () => {
        this.listViewBuilder()
      },
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataByPage(0).then((data) => {
            this.articles.resetAllData(data)
            this.nextPage = 1
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