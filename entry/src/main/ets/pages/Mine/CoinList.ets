import { PullToRefresh } from '@ohos/pulltorefresh';
import API from '../../network/API';
import { CoinModel } from '../../network/model/CoinModel';
import { ListDataSource } from '../../network/model/ListDataSource';
import UserService, { User } from '../../service/UserService';
import { MineCoinItemComponent } from '../../widgets/MineCoinItemComponent';
import { LoadState, PageLoading } from '../../widgets/PageLoading';
import TitleLayout from '../../widgets/TitleLayout';

@Entry
@Component
struct CoinList {
  @State loadState: LoadState = LoadState.LOADING
  @State coinList: ListDataSource<CoinModel> = new ListDataSource()
  @State userCoin: number = 0
  private scroller: Scroller = new Scroller()
  private nextPage: number = 1
  private hasMore: boolean = true

  private userObserver = (user?: User) => {
    if (user) {
      this.userCoin = user.coinCount
    } else {
      this.userCoin = 0
    }
  }

  build() {
    Column() {
      TitleLayout({
        title: "我的积分"
      })

      Text(this.userCoin.toString())
        .fontSize(50)
        .fontColor($r("app.color.title_bar_text"))
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
        .backgroundColor($r("app.color.title_bar_bg"))
        .width("100%")
        .height("15%")

      PageLoading({
        loadState: this.loadState,
        showLoading: false,
        content: () => {
          this.pullToRefreshBuilder()
        }
      })
        .layoutWeight(1)

    }
    .height('100%')
    .width('100%')
  }

  async aboutToAppear(): Promise<void> {
    UserService.addUserObserver(this.userObserver)
    const user = await UserService.updateUser()
    this.userObserver(user)
    UserService.updateUser()

    this.loadData()
  }

  aboutToDisappear(): void {
    UserService.removeUserObserver(this.userObserver)
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0).then((data) => {
      this.coinList.resetAllData(data)
      if (this.coinList.totalCount() == 0) {
        this.loadState = LoadState.EMPTY
      } else {
        this.loadState = LoadState.SUCCESS
      }
    }, () => {
      this.loadState = LoadState.FAIL
    })
  }

  private async loadDataByPage(page: number): Promise<CoinModel[]> {
    const response = await API.getMineCoin(page)
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
      data: $coinList,
      scroller: this.scroller,
      customList: () => {
        this.listViewBuilder()
      },
      onRefresh: () => {
        return new Promise<string>((resolve, reject) => {
          this.loadDataByPage(0).then((data) => {
            this.coinList.clearData()
            this.coinList.resetAllData(data)
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
                this.coinList.pushDataList(data)
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
      LazyForEach(this.coinList, (item: CoinModel) => {
        ListItem() {
          MineCoinItemComponent({
            coin: item,
          })
        }
      }, (item: CoinModel) => `${item.id}`)
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