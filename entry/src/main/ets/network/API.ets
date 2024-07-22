import { Article, ArticleList } from './model/Article';
import { Response } from './model/Response';
import Network from './Network';
import { http } from '@kit.NetworkKit';
import { HomeBannerData } from './model/Banner';
import { User } from '../service/UserService';
import { HotKey } from './model/Search';
import { Tree } from './model/Tree';
import { WeChatAuthor } from './model/WeChat';
import { CoinList } from './model/CoinModel';
import { MineShare } from './model/MineShare';

export default class API {
  /**
   * 登录账户
   * @param username 用户名
   * @param password 密码
   * @returns
   */
  static async login(username: string, password: string): Promise<Response<User>> {
    return Network.requestSync(`/user/login`, http.RequestMethod.POST, `username=${username}&password=${password}`)
  }

  /**
   * 退出账号
   * @returns
   */
  static async logout(): Promise<Response<string>> {
    return Network.requestSync("/user/logout/json", http.RequestMethod.GET)
  }

  /**
   * 注册用户
   * @param username 用户名
   * @param password 密码
   * @param repassword 确认密码
   * @returns
   */
  static async register(username: string, password: string, repassword: string): Promise<Response<User>> {
    return Network.requestSync("/user/register",
      http.RequestMethod.POST, `username=${username}&password=${password}&repassword=${repassword}`)
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
    return Network.requestSync(`/article/query/${page}/json`, http.RequestMethod.POST, `k=${encodeURIComponent(keyword)}`)
  }

  /**
   * 获取广场数据
   * @param page 页码
   * @returns
   */
  static async getSquareArticleList(page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/user_article/list/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取体系列表
   * @returns
   */
  static async getTree(): Promise<Response<Tree[]>> {
    return Network.requestSync("/tree/json", http.RequestMethod.GET)
  }

  /**
   * 获取指定体系的文章列表
   * @param id
   * @param page
   * @returns
   */
  static async getTreeArticleList(cid: number, page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/article/list/${page}/json?cid=${cid}`, http.RequestMethod.GET)
  }

  /**
   * 获取微信公众号列表
   * @returns
   */
  static async getWechatAuthorList(): Promise<Response<WeChatAuthor[]>> {
    return Network.requestSync("/wxarticle/chapters/json", http.RequestMethod.GET)
  }

  /**
   * 获取指定公众号文章列表
   * @param id 公众号 id
   * @param page 页码
   * @returns
   */
  static async getWechatArticleList(id: number, page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/wxarticle/list/${id}/${page}/json`, http.RequestMethod.GET)
  }

  /**
   * 获取问答列表
   * @param page 页码
   * @returns
   */
  static async getWendaArticleList(page: number): Promise<Response<ArticleList>> {
    return Network.requestSync(`/wenda/list/${page}/json`, http.RequestMethod.GET)
  }

  /** 获取个人积分获取列表（需要登录后访问）
   *
   */
  static async getMineCoin(page: number): Promise<Response<CoinList>> {
    return Network.requestSync(`/lg/coin/list/${page}/json`, http.RequestMethod.GET)
  }

  /** 获取用户分享的文章列表
   * 页码，从1开始
   */
  static async getShareArticleList(page: number): Promise<Response<MineShare>> {
    return Network.requestSync(`/user/lg/private_articles/${page}/json`, http.RequestMethod.GET)
  }

  /** 分享文章
   *
   */
  static async shareArticle(title: string, link: string): Promise<Response<object>> {
    return Network.requestSync("/lg/user_article/add/json", http.RequestMethod.POST, `title=${title}&link=${link}`)
  }

  /** 删除分享的文章
   *
   */
  static async deleteSharedArticle(id: number): Promise<Response<object>> {
    return Network.requestSync(`/lg/user_article/delete/${id}/json`, http.RequestMethod.POST)
  }
}