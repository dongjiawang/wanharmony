import { Article, ArticleTag, getArticleAuthor, getArticleChapter, getTagColor } from '../network/model/Article'
import { router } from '@kit.ArkUI'

@Component
export struct ArticleItemComponent {
  article: Article = new Article()
  onCollectClick?: (article: Article) => void

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
        .height(4)
        .color(Color.Transparent)

      // 文章标题
      Text(this.article.title)
        .width("100%")
        .fontColor($r("app.color.text_h1"))
        .fontSize(15)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

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

        // 收藏状态
        Image(this.article.collect ? $r("app.media.ic_like_fill") : $r("app.media.ic_like"))
          .fillColor(this.article.collect ? $r("app.color.red") : $r("app.color.text_h2"))
          .width(24)
          .height(24)
          .onClick(() => {
            if (this.onCollectClick) {
              this.onCollectClick(this.article)
            }
          })
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
        url: "pages/WebPage",
        params: {
          url: this.article.link
        }
      })
    })
  }
}