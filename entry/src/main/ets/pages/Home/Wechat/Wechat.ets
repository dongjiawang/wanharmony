import API from '../../../network/API'
import { WeChatAuthor } from '../../../network/model/WeChat'
import UserService, { User } from '../../../service/UserService'
import { LoadState, PageLoading } from '../../../widgets/PageLoading'
import { WechatTab } from './WechatTab'

@Component
export struct Wechat {
  @State title: string = "公众号"
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State authors: WeChatAuthor[] = []
  private tabsController = new TabsController()
  @State currentIndex: number = 0
  @State needRefresh: boolean = false
  @Prop @Watch("onRefresh") isShow: boolean
  private userObserver = (user?: User) => {
    // 用户状态变为已登录，刷新 tab 数据
    if (user) {
      this.needRefresh = true
      this.onRefresh()
    }
  }

  build() {
    Column() {
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: (() => {
          this.loadData()
        })
      }) {
        Tabs({
          barPosition: BarPosition.Start,
          index: this.currentIndex,
          controller: this.tabsController
        }) {
          ForEach(this.authors, (author: WeChatAuthor) => {
            TabContent() {
              WechatTab({
                authorId: author.id
              })
            }
            .tabBar(author.name)
          })
        }
        .width("100%")
        .height("100%")
        .scrollable(true)
        .barMode(BarMode.Scrollable)
        .barHeight(44)
        .onChange((index) => {
          this.currentIndex = index
        })
      }
    }
    .width("100%")
    .height("100%")
  }

  aboutToAppear(): void {
    this.loadData()
    UserService.addUserObserver(this.userObserver)
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
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

  private loadData() {
    this.loadState = LoadState.LOADING
    API.getWechatAuthorList().then((response) => {
      if (response.isSuccessWithData()) {
        let authors = response.getDataOrThrow()
        if (this.currentIndex >= authors.length) {
          this.currentIndex = 0
        }
        this.authors = authors
        if (this.authors.length === 0) {
          this.loadState = LoadState.EMPTY
        } else {
          this.loadState = LoadState.SUCCESS
        }
      } else {
        this.loadState = LoadState.FAIL
      }
    })
  }
}