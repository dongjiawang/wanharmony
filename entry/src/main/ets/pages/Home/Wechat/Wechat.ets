import API from '../../../network/API'
import { WeChatAuthor } from '../../../network/model/WeChat'
import { LoadState, PageLoading } from '../../../widgets/PageLoading'
import { WechatTab } from './WechatTab'

@Component
export struct Wechat {
  @State title: string = "公众号"
  @State loadState: LoadState = LoadState.LOADING
  @State showLoading: boolean = false
  @State authors: WeChatAuthor[] = []

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
          barPosition: BarPosition.Start
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
      }
    }
    .width("100%")
    .height("100%")
  }

  aboutToAppear(): void {
    this.loadData()
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    API.getWechatAuthorList().then((response) => {
      if (response.isSuccessWithData()) {
        this.authors = response.getDataOrThrow()
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