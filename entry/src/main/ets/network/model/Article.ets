/**
 * 文章列表模型
 */
export class ArticleList {
  curPage: number = 0
  datas: Article[] = []
  offset: number = 0
  over: boolean = false
  pageCount: number = 0
  size: number = 0
  total: number = 0
}

/**
 * 文章详情模型
 */
export class Article {
  id: number = 0
  apkLink: string = ""
  audit: number = 0
  author: string = ""
  canEdit: boolean = false
  chapterId: number = 0
  chapterName: string = ""
  collect: boolean = false
  courseId: number = 0
  desc: string = ""
  descMd: string = ""
  envelopePic: string = ""
  fresh: boolean = false
  host: string = ""
  link: string = ""
  niceDate: string = ""
  niceShareDate: string = ""
  origin: string = ""
  prefix: string = ""
  projectLind: string = ""
  publishTime: number = 0
  realSuperChapterId: number = 0
  selfVisible: number = 0
  shareDate: number = 0
  shareUser: string = ""
  superChapterId: number = 0
  superChapterName: string = ""
  tags: ArticleTag[] = []
  title: string = ""
  type: number = 0
  userId: number = 0
  visible: number = 0
  zan: number = 0
  originId: number = 0
}

/**
 * 文章标签模型
 */
export class ArticleTag {
  name: string = ""
  url: string = ""
}

/**
 * 获取文章作者
 * @param article 文章
 * @returns 结果
 */
export function getArticleAuthor(article: Article): string {
  if (article.author.length > 0) {
    return article.author
  }
  return article.shareUser
}

/**
 * 获取文章章节
 * @param article 文章
 * @returns 结果
 */
export function getArticleChapter(article: Article): string {
  let chapter = article.chapterName
  if (article.superChapterName) {
    chapter = article.superChapterName + " • " + chapter
  }
  return chapter
}

/**
 * 获取标签颜色
 * @param tag 标签
 * @returns 结果
 */
export function getTagColor(tag: ArticleTag): Resource {
  switch (tag.name) {
    case "置顶":
      return $r("app.color.red")
    case "本站发布":
      return $r("app.color.blue")
    case "问答":
      return $r("app.color.cyan")
    case "公众号":
      return $r("app.color.green")
    case "项目":
      return $r("app.color.teal")
    default:
      return $r("app.color.main")
  }
}