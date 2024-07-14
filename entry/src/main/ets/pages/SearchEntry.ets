import preferences from '../common/Preferences'
import { toast } from '../common/Toast'
import API from '../network/API'
import { HotKey } from '../network/model/Search'
import { router } from '@kit.ArkUI'
import { SearchResultParams } from './SearchResult'
import WindowUtils from '../common/WindowUtils'

@Entry
@Component
struct SearchEntry {
  @State showKeyword: string = ""
  @State hotkeys: HotKey[] = []
  @State historyKeys: string[] = []
  private keyword: string = ""

  async aboutToAppear() {
    this.historyKeys = preferences.get(getContext()).getSearchHistory()
    const response = await API.getSearchHotKey()
    if (response.isSuccessWithData()) {
      this.hotkeys = response.getDataOrThrow()
    }
  }

  build() {
    Column() {
      Blank().height(WindowUtils.statusBarHeight)
      Row() {
        Image($r("app.media.ic_back"))
          .width(48)
          .height(48)
          .padding(14)
          .fillColor($r("app.color.text_h1"))
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back()
          })

        TextInput({
          placeholder: "关键词以空格隔开",
          text: this.showKeyword
        })
          .layoutWeight(1)
          .fontSize(17)
          .fontColor($r("app.color.text_h1"))
          .padding({ left: 16, right: 16 })
          .onChange((value) => {
            this.keyword = value
          })
          .onSubmit(() => {
            this.search()
          })

        Image($r("app.media.ic_search"))
          .width(48)
          .height(48)
          .padding(14)
          .fillColor($r("app.color.text_h1"))
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.search()
          })
      }
      .width("100%")
      .height(48)
      .alignItems(VerticalAlign.Center)

      Column() {
        Text("热门搜索")
          .fontColor($r("app.color.text_h1"))
          .fontSize(16)
          .width("100%")
          .margin({ top: 16 })
          .padding({ left: 16, right: 16 })

        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap
        }) {
          ForEach(this.hotkeys, (key: HotKey) => {
            Text(key.name)
              .fontColor($r("app.color.text_h1"))
              .fontSize(14)
              .padding({
                left: 12,
                top: 6,
                right: 12,
                bottom: 6
              })
              .maxLines(1)
              .backgroundColor($r("app.color.hot_key_bg"))
              .borderRadius(50)
              .margin({ top: 8, right: 8 })
              .onClick(() => {
                this.showKeyword = key.name
                this.keyword = key.name
                this.search()
              })
          })
        }
        .width("100%")
        .margin({ top: 8 })
        .padding({ left: 16, right: 16 })

        if (this.historyKeys.length > 0) {
          Text("搜索历史")
            .fontColor($r("app.color.text_h1"))
            .fontSize(16)
            .width("100%")
            .margin({ top: 16 })
            .padding({ left: 16, right: 16 })

          List() {
            ForEach(this.historyKeys, (key: string, index: number) => {
              ListItem() {
                Row() {
                  Text(key)
                    .fontSize(14)
                    .fontColor($r("app.color.text_h2"))
                    .layoutWeight(1)
                    .maxLines(1)

                  Image($r("app.media.ic_close"))
                    .width(20)
                    .height(20)
                    .fillColor($r("app.color.text_h2"))
                    .onClick(() => {
                      this.deleteHistory(index)
                    })
                }
                .width("100%")
                .padding({
                  left: 16,
                  top: 12,
                  right: 16,
                  bottom: 12
                })
              }
            })
          }
          .width("100%")
          .height("100%")
          .listDirection(Axis.Vertical)
          .margin({ top: 16 })
        }
      }
      .width("100%")
    }
    .width("100%")
    .height("100%")
  }

  /**
   * 开始搜索
   */
  private search() {
    if (!this.keyword) {
      toast("请输入关键词")
      return
    }
    // 记录并移除重复的记录，将当前搜索关键词移到最上
    let historyKeys: string[] = []
    historyKeys = historyKeys.concat(this.historyKeys)
    const existIndex = historyKeys.findIndex((value) => {
      return this.keyword === value
    })
    if (existIndex >= 0) {
      historyKeys.splice(existIndex, 1)
    }

    historyKeys.unshift(this.keyword)
    this.historyKeys = historyKeys
    preferences.get(getContext()).putSearchHistory(historyKeys)
    router.pushUrl({
      url: "pages/SearchResult",
      params: new SearchResultParams(this.keyword)
    })
  }

  /**
   * 删除搜索记录
   * @param index 要删除的下标
   */
  private deleteHistory(index: number) {
    let historyKeys: string[] = []
    historyKeys = historyKeys.concat(this.historyKeys)
    historyKeys.splice(index, 1)
    this.historyKeys = historyKeys
    preferences.get(getContext()).putSearchHistory(historyKeys)
  }
}