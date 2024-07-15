import { PullToRefresh } from '@ohos/pulltorefresh';
import API from '../network/API';
import { Article } from '../network/model/Article';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { ArticleItemComponent } from '../widgets/ArticleItemComponent';
import CollectUtils from '../common/CollectUtils';
import TitleLayout from '../widgets/TitleLayout';
import WindowUtils from '../common/WindowUtils';

@Entry
@Component
struct CollectList {
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  private title: string = '我的收藏';
  @State data: Article[] = []
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
    }, () => {
      this.loadState = LoadState.FAIL
    })
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    const response = await API.getCollectList(page)
    if (response.isSuccessWithData()) {
      const list = response.getDataOrThrow().datas
      list.forEach((item) => {
        item.collect = true
      })
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
      customList: () => {
        this.listViewBuilder()
      },
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataByPage(0).then((data) => {
            this.data = data
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
      }
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
              CollectUtils.collect(article, article.originId).then((success) => {
                if (success) {
                  const existIndex = this.data.findIndex((item) => {
                    return item.id === article.id
                  })
                  if (existIndex >= 0) {
                    this.data.splice(existIndex, 1)
                  }
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