import { Article, ArticleList } from './model/Article';
import { Response } from './model/Response';
import Network from './Network';
import { http } from '@kit.NetworkKit';
import { HomeBannerData } from './model/Banner';
import { User } from '../service/UserService';
import { HotKey } from './model/Search';

export default class API {
  /**
   * 登录账户
   * @param username 用户名
   * @param password 密码
   * @returns
   */
  static async login(username: string, password: string): Promise<Response<User>> {
    return Network.requestSync(`/user/login?username=${username}&password=${password}`, http.RequestMethod.POST)
  }

  /**
   * 退出账号
   * @returns
   */
  static async logout(): Promise<Response<string>> {
    return Network.requestSync("/user/logout/json", http.RequestMethod.GET)
  }

  /**
   * 获取用户信息
   * @returns
   */
  static async getUserInfo(): Promise<Response<User>> {
    return Network.requestSync("/lg/coin/userinfo/json", http.RequestMethod.GET)
  }

  /**
   * 获取首页 banner 数据
   * @returns
   */
  static async getHomeBanner(): Promise<Response<HomeBannerData[]>> {
    return Network.requestSync("/banner/json", http.RequestMethod.GET)
  }

  /**
   * 获取首页文章列表
   * @param page 页码
   * @returns
   */
  static async getHomeArticleList(page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/article/list/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取置顶文章列表
   * @returns
   */
  static async getTopArticle(): Promise<Response<Article[]>> {
    return Network.requestSync("/article/top/json", http.RequestMethod.GET)
  }

  /**
   * 收藏文章
   * @param id
   * @returns
   */
  static async collect(id: number): Promise<Response<object>> {
    return Network.requestSync(`/lg/collect/${id}/json`, http.RequestMethod.POST)
  }

  /**
   * 取消收藏
   * @param id
   * @returns
   */
  static async unCollect(id: number): Promise<Response<object>> {
    return Network.requestSync(`/lg/uncollect_originId/${id}/json`, http.RequestMethod.POST)
  }

  /**
   * 收藏列表
   * @param page
   * @returns
   */
  static async getCollectList(page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/lg/collect/list/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取搜索热词
   * @returns
   */
  static async getSearchHotKey(): Promise<Response<HotKey[]>> {
    return Network.requestSync("/hotkey/json", http.RequestMethod.GET)
  }

  /**
   * 搜索
   * @param keyword 关键字
   * @param page 页码
   * @returns
   */
  static async search(keyword: string, page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/article/query/${page}/json?k=${encodeURIComponent(keyword)}`, http.RequestMethod.POST)
  }
}