import { PullToRefreshConfigurator } from '@ohos/pulltorefresh'
import CollectUtils from '../common/CollectUtils'
import Preferences from '../common/Preferences'
import { Pair } from '../common/Struct'
import API from '../network/API'
import { Article } from '../network/model/Article'
import { Tree } from '../network/model/Tree'
import { ArticleItemComponent } from '../widgets/ArticleItemComponent'
import { LoadState } from '../widgets/PageLoading'

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
        const selectedTree1 = this.treeList.find((item) => {
          item.id === selectedIds.first
        })
        const selectedTree2 = selectedTree1?.children.find((item) => {
          item.id === selectedIds.second
        })

        if (selectedTree1 !== undefined && selectedTree2 !== undefined) {
          this.selectTreeTemp = selectedTree1
          this.selectTrees = { first: selectedTree1, second: selectedTree2 }
        } else {
          this.selectTreeTemp = this.treeList[0]
          this.selectTrees = { first: this.treeList[0], second: this.treeList[0].children[0] }
        }
        this.loadStateTree = LoadState.SUCCESS
        this.loadTreeData()
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