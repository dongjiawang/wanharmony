import API from '../network/API';
import { Article } from '../network/model/Article';
import UserService from '../service/UserService';
import { toast } from './Toast';

export default class CollectUtils {
  /**
   * 修改文章的收藏状态
   * @param article 文章
   * @returns
   */
  static async collect(article: Article): Promise<boolean> {
    if (!UserService.isLogin()) {
      UserService.checkLogin()
      return Promise.reject()
    }

    if (article.collect) {
      const response = await API.unCollect(article.id)
      if (response.isSuccess()) {
        article.collect = false
        return Promise.resolve(true)
      } else {
        toast(response.errorMsg)
        return Promise.reject(false)
      }
    } else {
      const response = await API.collect(article.id)
      if (response.isSuccess()) {
        article.collect = true
        return Promise.resolve(true)
      } else {
        toast(response.errorMsg)
        return Promise.reject(false)
      }
    }
  }
}