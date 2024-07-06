export default class EntryContext {
  private static context: object

  /**
   * 设置全局 context
   * @param context
   */
  static setContext(context: object) {
    EntryContext.context = context
  }

  /**
   * 获取获取 context
   * @returns
   */
  static getContext(): object {
    if (!EntryContext.context) {
      throw Error("context is not init")
    }
    return EntryContext.context
  }
}