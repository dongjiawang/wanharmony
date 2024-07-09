import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import CollectUtils from '../common/CollectUtils'
import Preferences from '../common/Preferences'
import { Pair } from '../common/Struct'
import API from '../network/API'
import { Article } from '../network/model/Article'
import { Tree } from '../network/model/Tree'
import { ArticleItemComponent } from '../widgets/ArticleItemComponent'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { TitleLayout } from '../widgets/TitleLayout'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
export struct TreeTab {
  @State loadStateTree: LoadState = LoadState.LOADING
  @State loadStateArticle: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State title: string = "体系"
  @State treeList: Tree[] = []
  @State data: Article[] = []
  @State selectTrees: Pair<Tree | undefined, Tree | undefined> = { first: undefined, second: undefined }
  @State selectTreeTemp?: Tree = undefined
  @State showSelectLayer: boolean = false
  private treeScroll1: Scroller = new Scroller()
  private treeScroll2: Scroller = new Scroller()
  private articleScroller: Scroller = new Scroller()
  private refreshConfig = new PullToRefreshConfigurator()
  private nextPage: number = 1
  private hasMore: boolean = true

  build() {
    Column() {
      // 标题不需要显示
      TitleLayout({
        title: this.title,
        isJustShowStatusBar: true
      })
      // 整个页面的加载模块
      PageLoading({
        loadState: this.loadStateTree,
        showLoading: this.showLoading,
        onReload: () => {
          this.loadTreeData()
        }
      }) {
        Column() {
          if (this.selectTrees.first && this.selectTrees.second) { // 如果存在选中的体系，需要显示在顶部，同时有点击方法，点击展开体系列表
            Row() {
              Text(`${this.selectTrees.first.name} > ${this.selectTrees.second.name}`)
                .fontColor($r("app.color.text_h1"))
                .fontSize(17)
                .layoutWeight(1)
              Text("切换")
                .margin({ left: 12 })
                .fontColor($r("app.color.main"))
                .fontSize(16)
            }
            .width("100%")
            .height(48)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              if (this.showSelectLayer) {
                this.showSelectLayer = false
                this.selectTreeTemp = this.selectTrees.first
              } else {
                this.showSelectLayer = true
                setTimeout(() => {
                  // 滚动到选中的位置的前一个
                  const selectedIndex1 = this.treeList.findIndex(item => item.id === this.selectTrees.first!.id)
                  if (selectedIndex1 >= 0) {
                    this.treeScroll1.scrollToIndex(Math.max(selectedIndex1 - 1, 0))
                  }
                  const selectedIndex2 =
                    this.selectTrees.first!.children.findIndex(item => item.id === this.selectTrees.second!.id)
                  if (selectedIndex2 >= 2) {
                    this.treeScroll2.scrollToIndex(Math.max(selectedIndex2, 0))
                  }
                }, 16)
              }
            })
          }

          //底层的文章列表
          Stack() {
            // 文章列表加载模块
            PageLoading({
              loadState: this.loadStateArticle,
              showLoading: this.showLoading,
              onReload: (() => {
                this.loadArticleData()
              })
            }) {
              Column() {
                // 文章列表
                PullToRefresh({
                  data: $data,
                  scroller: this.articleScroller,
                  refreshConfigurator: this.refreshConfig,
                  customList: (() => {
                    this.listViewBuilder()
                  }),
                  onLoadMore: (() => {
                    return new Promise<string>((resolve, reject) => {
                      if (this.hasMore) {
                        this.loadArticleDataByPage(this.nextPage).then((data) => {
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
              .width("100%")
              .height("100%")
            }

            // 如果显示体系列表状态
            if (this.showSelectLayer) {
              Column() {
                // 一级体系列表
                Row() {
                  List({ scroller: this.treeScroll1 }) {
                    ForEach(this.treeList, (tree: Tree, index: number) => {
                      ListItem() {
                        Text(tree.name)
                          .width("100%")
                          .padding({
                            left: 12,
                            top: 8,
                            right: 12,
                            bottom: 8
                          })
                          .fontColor(this.selectTreeTemp!.id === tree.id ? $r("app.color.main") :
                          $r("app.color.text_h1"))
                          .fontSize(14)
                          .textAlign(TextAlign.Center)
                          .backgroundColor((index % 2 === 0) ? Color.Transparent : $r("app.color.hot_key_bg"))
                          .onClick(() => {
                            // 选中一级的内容，会更新二级对应的列表数据
                            this.selectTreeTemp = tree
                          })
                      }
                    })
                  }
                  .width("50%")
                  .height("100%")

                  Line()
                    .width(0.5)
                    .height("100%")
                    .backgroundColor($r("app.color.divider"))
                  // 二级体系列表
                  List({ scroller: this.treeScroll2 }) {
                    ForEach(this.selectTreeTemp!.children, (tree: Tree, index: number) => {
                      ListItem() {
                        Text(tree.name)
                          .width("100%")
                          .padding({
                            left: 12,
                            top: 8,
                            right: 12,
                            bottom: 8
                          })
                          .fontColor(this.selectTrees.second!.id === tree.id ? $r("app.color.main") :
                          $r("app.color.text_h1"))
                          .fontSize(14)
                          .textAlign(TextAlign.Center)
                          .backgroundColor((index % 2 === 0) ? Color.Transparent : $r("app.color.hot_key_bg"))
                          .onClick(() => {
                            // 选中二级体系，需要隐藏体系选择，并且同时刷新文章列表
                            this.selectTrees = { first: this.selectTreeTemp, second: tree }
                            Preferences.get(getContext())
                              .putSelectedTreeId(this.selectTrees.first!.id, this.selectTrees.second!.id)
                            this.showSelectLayer = false
                            this.hasMore = true
                            this.loadArticleData()
                          })
                      }
                    })
                  }
                  .width("50%")
                  .height("100%")
                }
                .width("100%")
                .height("70%")
                .backgroundColor($r("app.color.start_window_background"))
              }
              .width("100%")
              .height("100%")
              .backgroundColor($r("app.color.translucent_black_50"))
              .onClick(() => {
                this.showSelectLayer = false
                this.selectTreeTemp = this.selectTrees.first
              })
            }
          }
          .width("100%")
          .height("100%")
        }
        .width("100%")
        .height("100%")
      }
    }
    .width("100%")
    .height("100%")
  }

  aboutToAppear(): void {
    this.refreshConfig.setHasRefresh(false)
    this.loadTreeData()
  }

  /**
   * 获取体系列表，并判断本地是否有选择记录，否则默认选择第一个体系，然后加载对应体系的文章列表
   */
  private async loadTreeData() {
    this.loadStateTree = LoadState.LOADING
    const response = await API.getTree()
    if (response.isSuccessWithData()) {
      if (response.getDataOrThrow().length > 0) {
        this.treeList = response.getDataOrThrow()
        const selectedIds = Preferences.get(getContext()).getSelectedTreeId()
        const selectedTree1 = this.treeList.find((item) => item.id === selectedIds.first)
        const selectedTree2 = selectedTree1?.children.find((item) => item.id === selectedIds.second)

        if (selectedTree1 !== undefined && selectedTree2 !== undefined) {
          this.selectTreeTemp = selectedTree1
          this.selectTrees = { first: selectedTree1, second: selectedTree2 }
        } else {
          this.selectTreeTemp = this.treeList[0]
          this.selectTrees = { first: this.treeList[0], second: this.treeList[0].children[0] }
        }
        this.loadStateTree = LoadState.SUCCESS
        this.loadArticleData()
      } else {
        this.loadStateTree = LoadState.EMPTY
      }
    } else {
      this.loadStateTree = LoadState.FAIL
    }
  }

  /**
   * 开始加载第一页的文章
   */
  private loadArticleData() {
    this.loadStateArticle = LoadState.LOADING
    this.nextPage = 1
    this.loadArticleDataByPage(0).then((data) => {
      this.data = data
      if (this.data.length === 0) {
        this.loadStateArticle = LoadState.EMPTY
      } else {
        this.loadStateArticle = LoadState.SUCCESS
      }
    }, () => {
      this.loadStateArticle = LoadState.FAIL
    })
  }

  /**
   * 加载指定页码的文章
   * @param page
   * @returns
   */
  private async loadArticleDataByPage(page: number): Promise<Article[]> {
    const response = await API.getTreeArticleList(this.selectTrees.second!.id, page)
    if (response.isSuccessWithData()) {
      const list = response.getDataOrThrow().datas
      return Promise.resolve(list)
    } else {
      return Promise.reject()
    }
  }

  @Builder
  private listViewBuilder() {
    List({ scroller: this.articleScroller }) {
      ForEach(this.data, (item: Article) => {
        ListItem() {
          ArticleItemComponent({
            article: item,
            onCollectClick: ((article: Article) => {
              CollectUtils.collect(article).then((success) => {
                this.data = this.data.map(item => item)
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