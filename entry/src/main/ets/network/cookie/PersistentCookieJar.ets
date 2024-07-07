import CookieJar from './CookieJar';
import { HashMap, uri } from '@kit.ArkTS';
import Cookie from './Cookie';
import CookiePersistor from './CookiePersistor';
import KVCookiePersistor from './KVCookiePersistor';
import CookieUtils from './CookieUtils';

/**
 * 持久化 cookie 容器，通过实现 CookieJar 接口函数
 */
export default class PersistentCookieJar implements CookieJar {
  private static TAG = "PersistentCookieJar"
  private cache: HashMap<string, Cookie> = new HashMap()
  private persistor: CookiePersistor

  constructor(context: Context) {
    this.persistor = new KVCookiePersistor(context)
    const cookies = this.persistor.loadAll()
    cookies.forEach((cookie) => {
      this.cache.set(CookieUtils.creatCookieKey(cookie), cookie)
    })
  }

  saveFromResponse(url: uri.URI, cookies: Cookie[]): void {
    cookies.forEach((cookie) => {
      this.cache.set(CookieUtils.creatCookieKey(cookie), cookie)
    })
    this.persistor.saveAll(PersistentCookieJar.filterPersistentCookies(cookies))
  }

  loadForRequest(url: uri.URI): Cookie[] {
    const cookiesToRemove: Cookie[] = []
    const validCookies: Cookie[] = []

    const iterator: IterableIterator<Cookie> = this.cache.values()
    let result = iterator.next()
    while (!result.done) {
      const currentCookie: Cookie = result.value
      // 过滤已经过期的 cookie
      if (CookieUtils.isExpired(currentCookie)) {
        cookiesToRemove.push(currentCookie)
      } else if (CookieUtils.matches(currentCookie, url)) {
        validCookies.push(currentCookie)
      }
      result = iterator.next()
    }
    cookiesToRemove.forEach((cookie) => {
      this.cache.remove(CookieUtils.creatCookieKey(cookie))
    })
    this.persistor.removeAll(cookiesToRemove)
    return validCookies
  }

  clear(): void {
    this.cache.clear()
    this.persistor.clear()
  }

  /**
   * 筛选可持续的 cookie
   * @param cookies
   * @returns
   */
  private static filterPersistentCookies(cookies: Cookie[]): Cookie[] {
    return cookies.filter((cookie) => {
      return cookie.persistent
    })
  }
}