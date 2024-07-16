export default class StringTool {
  static removeHtmlTags(text: string): string {
    return text.replace(/<[^>]+>/g, '')
      .replace('&gt;', '>')
      .replace('&lt;', '<')
  }
}