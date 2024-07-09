import API from '../network/API';
import { Article } from '../network/model/Article';
import UserService from '../service/UserService';
import { toast } from './Toast';

export default class CollectUtils {
  /**
   * 修改文章的收藏状态
   * @param article article 文章
   * @param id article 文章的id 或 originId（比如收藏列表中使用时用的是 originId）
   * @returns
   */
  static async collect(article: Article, id?: number): Promise<boolean> {
    if (!UserService.isLogin()) {
      UserService.checkLogin()
      return Promise.reject()
    }

    if (!id) {
      id = article.id;
    }

    if (article.collect) {
      const response = await API.unCollect(id)
      if (response.isSuccess()) {
        article.collect = false
        return Promise.resolve(true)
      } else {
        toast(response.errorMsg)
        return Promise.reject(false)
      }
    } else {
      const response = await API.collect(id)
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