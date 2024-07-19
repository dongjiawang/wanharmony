import { Article, ArticleTag, getArticleAuthor, getArticleChapter, getTagColor } from '../network/model/Article'
import { router } from '@kit.ArkUI'
import StringTool from '../common/StringTool'
import CollectUtils from '../common/CollectUtils'

@Component
export struct ArticleItemComponent {
  // 是否为分享的文章
  isShare: boolean = false
  article: Article = new Article()
  @State collect: boolean = false
  updateCollectCallBack?: () => void
  deleteCallBack?: () => void

  aboutToAppear(): void {
    this.collect = this.article.collect
  }

  build() {
    Column() {
      Row() {
        if (this.article.fresh) {
          Text("新")
            .fontColor($r("app.color.main"))
            .fontSize(10)
            .padding({ right: 8 })
        }
        // 创建文章作者控件
        Text(getArticleAuthor(this.article))
          .fontColor($r("app.color.text_h1"))
          .fontSize(12)
          .padding({ right: 8 })

        // 标签显示,根据标签数量创建控件
        ForEach(this.article.tags, (tag: ArticleTag) => {
          Text(tag.name)
            .fontColor(getTagColor(tag))
            .fontSize(10)
            .textAlign(TextAlign.Center)
            .borderWidth(0.5)
            .border({
              width: 0.5,
              color: getTagColor(tag),
              radius: 3
            })
            .padding({
              left: 2,
              top: 1,
              right: 1,
              bottom: 1
            })

          Divider()
            .width(8)
            .height(0)
            .color(Color.Transparent)
        })

        // 发表时间
        Text(this.article.niceDate)
          .layoutWeight(1)
          .fontColor($r("app.color.text_h2"))
          .fontSize(12)
          .textAlign(TextAlign.End)
      }

      Divider()
        .width("100%")
        .height(5)
        .color(Color.Transparent)

      if (this.article.desc) {
        // 文章标题
        Text(this.article.title)
          .width("100%")
          .fontColor($r("app.color.text_h1"))
          .fontSize(15)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(StringTool.removeHtmlTags(this.article.desc))
          .width("100%")
          .fontColor($r("app.color.text_h2"))
          .fontSize(11)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({
            top: 5
          })
      } else {
        // 文章标题
        Text(this.article.title)
          .width("100%")
          .fontColor($r("app.color.text_h1"))
          .fontSize(15)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      Divider()
        .width("100%")
        .height(5)
        .color(Color.Transparent)

      // 底部的章节、是否收藏等等
      Row() {
        // 章节
        Text(getArticleChapter(this.article))
          .fontColor($r("app.color.text_h2"))
          .fontSize(12)

        Blank()

        if (this.isShare) {
          Text("删除")
            .fontSize(14)
            .fontColor($r("app.color.text_h2"))
            .onClick( () => {
              if (this.deleteCallBack) {
                this.deleteCallBack()
              }
            })
        } else {
          // 收藏状态
          SymbolGlyph(this.collect ? $r("sys.symbol.heart_fill") : $r("sys.symbol.heart"))
            .fontSize(22)
            .fontColor(this.collect ? [$r("app.color.red")] : [$r("app.color.text_h2")])
            .onClick(async () => {
              const success = await CollectUtils.collect(this.article, this.article.originId)

              this.collect = this.article.collect

              if (this.updateCollectCallBack && success) {
                this.updateCollectCallBack()
              }
            })
        }
      }
      .justifyContent(FlexAlign.Center)
      .width("100%")
    }
    .width("100%")
    .padding({
      left: 16,
      top: 10,
      right: 16,
      bottom: 10
    })
    .onClick(() => {
      router.pushUrl({
        url: "pages/Web/WebPage",
        params: {
          url: this.article.link
        }
      })
    })
  }
}