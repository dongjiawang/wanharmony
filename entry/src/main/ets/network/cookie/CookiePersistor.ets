import Cookie from './Cookie'

/**
 * cookie 持久化接口
 */
export default interface CookiePersistor {
  /**
   * 加载全部
   * @returns
   */
  loadAll(): Cookie[]

  /**
   * 保存全部
   * @param cookies
   */
  saveAll(cookies: Cookie[]): void

  /**
   * 移除指定的
   * @param cookie
   */
  removeAll(cookie: Cookie[]): void

  /**
   * 清除所有
   */
  clear(): void
}