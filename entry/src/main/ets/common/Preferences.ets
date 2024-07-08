import dataPreferences from '@ohos.data.preferences';
import { Context } from '@ohos.abilityAccessCtrl';
import { User } from '../service/UserService';
import { JSON } from '@kit.ArkTS';

const PREFERENCES_NAME = "top.djw.wanharmony"
const KEY_USER_INFO = "user_info"

export default class Preferences {
  private static instance: Preferences
  private preferences: dataPreferences.Preferences

  private  constructor(context: Context) {
    this.preferences = dataPreferences.getPreferencesSync(context, {
      name: PREFERENCES_NAME
    })
  }

  static get(context: Context): Preferences {
    if (Preferences.instance === undefined) {
      Preferences.instance = new Preferences(context)
    }
    return Preferences.instance
  }

  /**
   * 获取本地保存的用户信息
   * @returns
   */
  getUser(): User | undefined {
    const json = this.preferences.getSync(KEY_USER_INFO, "").toString()
    if (json) {
      const user: User = JSON.parse(json) as User
      return user
    }
    return undefined
  }
  /**
   * 将用户信息保存到本地
   * @param user
   */
  putUser(user?: User) {
    if (user) {
      this.preferences.putSync(KEY_USER_INFO, JSON.stringify(user, undefined, undefined))
    } else {
      this.preferences.deleteSync(KEY_USER_INFO)
    }
    this.preferences.flush()
  }
}