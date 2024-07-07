import { Article, ArticleList } from './model/Article';
import { Response } from './model/Response';
import Network from './Network';
import { http } from '@kit.NetworkKit';
import { HomeBannerData } from './model/Banner';

export default class API {
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
}