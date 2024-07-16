import { PullToRefresh } from '@ohos/pulltorefresh';
import CollectUtils from '../../common/CollectUtils';
import API from '../../network/API';
import { Article } from '../../network/model/Article';
import { ListDataSource } from '../../network/model/ListDataSource';
import { Tree } from '../../network/model/Tree';
import { ArticleItemComponent } from '../../widgets/ArticleItemComponent';
import { LoadState, PageLoading } from '../../widgets/PageLoading';
import TitleLayout from '../../widgets/TitleLayout';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct TreeArticleList {
  @State treeId: number = 0
  private treeName: string = ""
  @State loadState: LoadState = LoadState.LOADING
  @State articleList: ListDataSource<Article> = new ListDataSource()
  private scroller: Scroller = new Scroller()
  private nextPage: number = 1
  private hasMore: boolean = true

  build() {
    Column() {
      TitleLayout({
        title: this.treeName
      })

      PageLoading({
        loadState: this.loadState,
        showLoading: false,
        onReload: (() => {
          this.loadDataByPage(0)
        }),
        content: (() => {
          this.pullToRefreshBuilder()
        })
      })
        .layoutWeight(1)
    }
  }

  aboutToAppear(): void {
    const param = router.getParams() as TreeListParams
    this.treeId = param.treeId
    this.treeName = param.treeName
    this.loadData()
  }

  private loadData() {
    this.loadDataByPage(0).then((data) => {
      data.forEach((item) => {
        this.articleList.pushData(item)
      })
      if (this.articleList.totalCount() == 0) {
        this.loadState = LoadState.EMPTY
      } else {
        this.loadState = LoadState.SUCCESS
      }
    }, () => {
      this.loadState = LoadState.FAIL
    })
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    this.loadState = LoadState.LOADING
    const response = await API.getTreeArticleList(this.treeId, page)
    this.loadState = LoadState.SUCCESS
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
      data: $articleList,
      scroller: this.scroller,
      customList: () => {
        this.listViewBuilder()
      },
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataByPage(0).then((data) => {
            data.forEach((item) => {
              this.articleList.pushData(item)
            })
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
                data.forEach((item) => {
                  this.articleList.pushData(item)
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
      }
    })
  }

  @Builder
  private listViewBuilder() {

    List({scroller: this.scroller}) {
      LazyForEach(this.articleList, (item: Article, index) => {
        ListItem(){
          ArticleItemComponent({
            article: item,
            onCollectClick: async (article: Article) => {
              const success = await CollectUtils.collect(article)
              if (success) {
                item.collect = !item.collect
                this.articleList.notifyDataChange(index)
              }
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

export class TreeListParams {
  treeId: number = 0
  treeName: string = ""

  constructor(treeId: number, treeName: string) {
    this.treeId = treeId
    this.treeName = treeName
  }
}