import EntryContext from '../common/EntryContext'
import Preferences from '../common/Preferences'
import { Context } from '@ohos.abilityAccessCtrl'
import API from '../network/API'
import Network from '../network/Network'
import { promptAction, router } from '@kit.ArkUI'
import { toast } from '../common/Toast'

export default class UserService {
  private static instance: UserService
  private user?: User
  private userObservers: ((user?: User) => void)[] = []

  static get(): UserService {
    if (UserService.instance === undefined) {
      UserService.instance = new UserService()
    }
    return UserService.instance
  }

  private constructor() {
    const context = EntryContext.getContext() as Context
    const user = Preferences.get(context).getUser()
    if (user) {
      this.user = user

    }
  }

  /**
   * 保存用户信息
   * @param user
   */
  static setUser(user?: User) {
    UserService.get().user = user
    UserService.get().notifyObserver()
    const context = EntryContext.getContext() as Context
    Preferences.get(context).putUser(user)
  }

  /**
   * 获取用户信息
   * @returns
   */
  static getUser(): User | undefined {
    return UserService.get().user
  }

  static clearUser() {
    UserService.setUser(undefined)
    Network.clearCookie()
  }

  /**
   * 判断是否登录用户
   * @returns
   */
  static isLogin(): boolean {
    if (UserService.get().user) {
      return true
    }
    return false
  }

  /**
   * 检查登录状态并回调或跳转登录页面
   * @param onLogin
   */
  static checkLogin(onLogin?: () => void) {
    if (UserService.isLogin()) {
      if (onLogin !== undefined) {
        onLogin()
      }
    } else {
      try {
        promptAction.showDialog({
          title: "提示",
          message: "当前操作需要登录",
          buttons: [
            {
              text: "立即登录",
              color: $r("app.color.main")
            },
            {
              text: "取消",
              color: $r("app.color.text_h2")
            }
          ]
        })
          .then((resp) => {
            if (resp.index === 0) {
              router.pushUrl({
                url: "pages/Mine/Login"
              })
            }
          })
      } catch (error) {
        console.error(`showDialog args error code is ${error.code}, message is ${error.message}`)
      }
    }
  }

  /**
   * 登录账号
   * @param username
   * @param password
   * @param callBack
   */
  static async login(username: string, password: string, callBack: ((isLogin: boolean) => void)) {
    const response = await API.login(username, password)
    if (response.isSuccessWithData()) {
      UserService.get().user = response.data
      const user = await UserService.updateUser()
      if (user) {
        callBack(true)
      }
    } else {
      toast(response.errorMsg)
      callBack(false)
    }
  }

  /**
   * 更新用户信息
   * @returns
   */
  static async updateUser(): Promise<User> {
    if (UserService.isLogin()) {
      const response = await API.getUserInfo()
      if (response.isSuccessWithData()) {
        const user = UserService.get().user!!
        user.coinCount = response.getDataOrThrow().coinCount
        user.level = response.getDataOrThrow().level
        user.rank = response.getDataOrThrow().rank
        UserService.setUser(user)
        return Promise.resolve(user)
      } else {
        return Promise.reject(response.errorMsg)
      }
    } else {
      return Promise.reject()
    }
  }

  /**
   * 添加用户信息监听
   * @param observer
   */
  static addUserObserver(observer: (user?: User) => void) {
    if (!UserService.get().userObservers.includes(observer)) {
      UserService.get().userObservers.push(observer)
    }
  }

  /**
   * 移除用户信息监听
   * @param observer
   */
  static removeUserObserver(observer: (user?: User) => void) {
    const index = UserService.get().userObservers.indexOf(observer)
    if (index >= 0) {
      UserService.get().userObservers.splice(index, 1)
    }
  }

  /**
   * 执行用户信息监听
   */
  private notifyObserver() {
    this.userObservers.forEach((observer) => {
      if (observer) {
        observer(this.user)
      }
    })
  }
}

export class User {
  id: number = 0
  username: string = ""
  nickname: string = ""
  chapterTops: object[] = []
  coinCount: number = 0
  collectIds: number[] = []
  email: string = ""
  icon: string = ""
  level: string = ""
  rank: string = ""
}