import { uri } from '@kit.ArkTS'
import Cookie from './Cookie'

export default interface CookieJar {
  /**
   * 从请求地址中保存 cookie
   * @param url 请求地址
   * @param cookies cookies
   */
  saveFromResponse(url: uri.URI, cookies: Cookie[]): void

  /**
   * 从请求地址中获取 cookie
   * @param url 请求地址
   * @returns
   */
  loadForRequest(url: uri.URI): Cookie[]

  /**
   * 清除 cookie
   */
  clear(): void
}