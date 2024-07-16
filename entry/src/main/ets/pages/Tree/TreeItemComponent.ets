import { Tree } from '../../network/model/Tree'
import { router } from '@kit.ArkUI'
import { TreeListParams } from './TreeArticleList'

@Component
export struct TreeItemComponent {
  @Prop tree: Tree = new Tree()

  build() {
    Column() {
      Text(this.tree.name)
        .fontColor($r("app.color.text_h1"))
        .fontSize(16)
        .width("100%")
        .margin({ top: 16 })
        .padding({ left: 16, right: 16 })

      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap
      }) {
        ForEach(this.tree.children, (item: Tree) => {
          Text(item.name)
            .fontColor($r("app.color.text_h2"))
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
              router.pushUrl({
                url: "pages/Tree/TreeArticleList",
                params: new TreeListParams(item.id, item.name)
              })
            })
        })
      }
      .width("100%")
      .margin({ top: 8 })
      .padding({ left: 16, right: 16, bottom: 16 })
    }
  }
}