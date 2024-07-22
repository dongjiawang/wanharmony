import EntryContext from '../common/EntryContext'
import CookieJar from './cookie/CookieJar'
import PersistentCookieJar from './cookie/PersistentCookieJar'
import { Response } from './model/Response'
import { http } from '@kit.NetworkKit'
import CookieUtils from './cookie/CookieUtils'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { JSON, uri } from '@kit.ArkTS'

const TAG: string = "Network"
const BASE_URL: string = "https://www.wanandroid.com"
const cookieJar: CookieJar = new PersistentCookieJar(EntryContext.getContext() as Context)

export default class Network {
  private static instance: Network

  private constructor() {
  }

  static async requestSync<T>(path: string, method: http.RequestMethod, extraData?: Object): Promise<Response<T>> {
    return Network.get().requestSync(path, method, extraData)
  }

  /**
   * 请求网络数据
   * @param path 接口
   * @param method 请求方式
   * @param extraData 返回数据
   * @returns Promise 回调
   */
  private async requestSync<T>(path: string, method: http.RequestMethod, extraData?: Object): Promise<Response<T>> {
    return new Promise<Response<T>>((resolve, reject) => {
      const url = BASE_URL + path
      const uri = parseUri(url)

      if (method == http.RequestMethod.POST && !extraData) {
        extraData = new Object()
      }

      const httpRequest = http.createHttp()
      hilog.info(0, TAG, `开始请求 ${path}, method: ${method}`)

      httpRequest.request(
        url,
        {
          method: method,
          expectDataType: http.HttpDataType.OBJECT,
          header: this.creatHeader(uri, method),
          extraData: extraData
        },
        (err, data) => {
          const response = new Response<T>()
          if (err) {
            // 处理请求过程中出现的错误
            response.errorCode = -1
            response.errorMsg = err.message
            reject(response)
            hilog.error(0, TAG, `request failed, path：${path}, error: ${JSON.stringify(err, undefined, undefined)}`)
          } else if (data.responseCode == 200) {
            cookieJar.saveFromResponse(uri, CookieUtils.parseHttpRequestCookies(data.cookies))
            if (data.resultType === http.HttpDataType.STRING) {
              const result: Response<T> = JSON.parse(data.result as string) as Response<T>
              response.errorCode = result.errorCode
              response.errorMsg = result.errorMsg
              response.data = result.data
              resolve(response)
            } else if (data.resultType === http.HttpDataType.OBJECT) {
              const result = data.result as Response<T>
              response.errorCode = result.errorCode
              response.errorMsg = result.errorMsg
              response.data = result.data
              resolve(response)
            }
            hilog.info(0, TAG, `请求成功，接口：${path}, result:${JSON.stringify(response, undefined, undefined)}`)
          } else {
            // 处理其他响应码
            response.errorCode = data.responseCode
            response.errorMsg = `HTTP ${data.responseCode} error: ${data.result}`
            resolve(response)
            hilog.error(0, TAG, `请求失败，接口：${path}, errorCode: ${data.responseCode}, errorMsg: ${data.result}`)
          }
          // 当该请求使用完毕时，开发者务必调用destroy方法主动销毁该JavaScript Object。
          httpRequest.destroy()
        }
      )
    })
  }

  static get(): Network {
    if (Network.instance === undefined) {
      Network.instance = new Network()
    }
    return Network.instance
  }

  static clearCookie() {
    cookieJar.clear()
  }

  private creatHeader(uri: uri.URI, method: http.RequestMethod): Header {
    const cookies = cookieJar.loadForRequest(uri)

    if (method == http.RequestMethod.POST) {
      return {
        "Content-Type": "application/x-www-form-urlencoded",
        "Cookie": CookieUtils.cookieHeader(cookies)
      }
    }
    return {
      "Content-Type": "application/json",
      "Cookie": CookieUtils.cookieHeader(cookies)
    }
  }
}

function parseUri(url: string): uri.URI {
  return new uri.URI(url)
}

interface Header {
  "Content-Type": string
  "Cookie": string
}


