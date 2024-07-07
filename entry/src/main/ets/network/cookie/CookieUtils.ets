import Cookie from './Cookie';
import { uri } from '@kit.ArkTS';

export default class CookieUtils {
  /**
   * 解析网络请求中的 cookie 字符串
   * @param cookieString 字符串
   * @returns cookie 数组
   */
  static parseHttpRequestCookies(cookieString: string): Cookie[] {
    // 如果字符串为空，直接返回空数组
    if (!cookieString) {
      return []
    }
    // 定义数组记录 cookie
    const cookies: Cookie[] = []

    // 通过 \r\n 拆分字符串和 cookie
    const lines = cookieString.split("\r\n")
    // 遍历 cookie 数据，重新组装到 cookies 数组中
    lines.forEach((line) => {
      const attrs = line.split("\t")
      if (attrs.length !== 7 || !attrs[0]) {
        return
      }
      // 通过第一个数组对象数据，获取 domain 和是否 httpOnly
      let domain = attrs[0]
      let httpOnly = false
      if (domain.startsWith("#HttpOnly_")) {
        domain = domain.substring("#HttpOnly_".length)
        httpOnly = true
      }
      // 将cookie 数据 组装并添加到数组中
      cookies.push({
        domain: domain,
        path: attrs[2],
        expiresAt: parseInt(attrs[4]),
        name: attrs[5],
        value: attrs[6],
        httpOnly: httpOnly,
        persistent: true
      })
    })

    return cookies
  }

  /**
   * 生成 cookie 头
   * @param cookies
   * @returns
   */
  static cookieHeader(cookies: Cookie[]): string {
    let str: string = ""
    cookies.forEach((cookie, index) => {
      if (index > 0) {
        str += "; "
      }
      str += cookie.name + "=" + cookie.value
    })
    return str
  }

  /**
   * 判断 cookie 是否属于指定的地址
   * @param cookie
   * @param url
   * @returns
   */
  static matches(cookie: Cookie, url: uri.URI): boolean {
    const domainMatch = CookieUtils.domainMatch(url.host, cookie.domain)
    if (!domainMatch) {
      return false
    }
    if (!CookieUtils.pathMatch(url, cookie.path)) {
      return false
    }
    return true
  }

  /**
   * 生成 cookie 的 key 值
   * @param cookie
   * @returns
   */
  static creatCookieKey(cookie: Cookie): string {
    return `https://${cookie.domain}${cookie.path}${cookie.name}`
  }

  /**
   * 判断 cookie 是否过期
   * @param cookie
   * @returns
   */
  static isExpired(cookie: Cookie): boolean {
    const nowTime = Date.now() / 1000
    return cookie.expiresAt < nowTime
  }

  /**
   * 从 JSON 字符串中解析 cookie
   * @param json
   * @returns
   */
  static fromJson(json: string): Cookie | undefined {
    if (json.length === 0) {
      return undefined
    }
    const temp: Cookie | undefined = JSON.parse(json)
    return temp
  }

  /**
   * 比较 url 的地址与 cookie 的地址是否相同
   * @param url
   * @param path
   * @returns
   */
  private static pathMatch(url: uri.URI, path: string): boolean {
    const urlPath = url.path
    if (urlPath === path) {
      return true
    }
    if (urlPath.startsWith(path)) {
      if (path.endsWith("/")) {
        return true
      }
      if (urlPath[path.length] === "/") {
        return true
      }
    }
    return false
  }

  /**
   * 比较 host 与 cookie 的 domain 是否相同
   * @param urlHost
   * @param domain
   * @returns
   */
  private static domainMatch(urlHost: string, domain: string): boolean {
    if (urlHost === domain) {
      return true
    }
    return urlHost.endsWith(domain) && urlHost[urlHost.length - domain.length - 1] === "."
  }
}