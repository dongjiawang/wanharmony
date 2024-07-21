import dataPreferences from '@ohos.data.preferences';
import { Context } from '@ohos.abilityAccessCtrl';
import { User } from '../service/UserService';
import { JSON } from '@kit.ArkTS';
import { Pair } from './Struct';

const PREFERENCES_NAME = "top.djw.wanharmony"
const KEY_USER_INFO = "user_info"
const KEY_SEARCH_HISTORY = "search_history"
const kEY_COLOR_MODE = "color_mode"
const KEY_HOME_BANNER_OFF = "home_banner_off"
const KEY_HOME_TOP_OFF = "home_top_off"

export default class Preferences {
  private static instance: Preferences
  private preferences: dataPreferences.Preferences

  private constructor(context: Context) {
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

  /**
   * 获取搜索历史
   * @returns
   */
  getSearchHistory(): string[] {
    return this.preferences.getSync(KEY_SEARCH_HISTORY, []) as string[]
  }

  /**
   * 记录搜索
   * @param historyKeys
   */
  putSearchHistory(historyKeys: string[]) {
    this.preferences.putSync(KEY_SEARCH_HISTORY, historyKeys)
    this.preferences.flush()
  }

  /**
   * 记获取颜色模式
   * @returns
   */
  getColorMode(): ColorMode {
    return this.preferences.getSync(kEY_COLOR_MODE, -1) as ColorMode
  }

  /**
   * 记录颜色模式
   * @param number
   */
  putColorMode(number: ColorMode) {
    this.preferences.putSync(kEY_COLOR_MODE, number)
    this.preferences.flush()
  }

  /**
   * 获取首页 banner 是否关闭
   * @returns
   */
  getHomeBannerOff(): boolean {
    return this.preferences.getSync(KEY_HOME_BANNER_OFF, false) as boolean
  }

  /**
   * 关闭首页 banner 显示
   * @param off
   */
  putHomeBannerOff(off: boolean) {
    this.preferences.putSync(KEY_HOME_BANNER_OFF, off)
    this.preferences.flush()
  }

  /**
   * 获取首页置顶是否显示
   * @returns
   */
  getHomeTopOff(): boolean {
    return this.preferences.getSync(KEY_HOME_TOP_OFF, false) as boolean
  }

  /**
   * 关闭首页置顶显示
   * @param off
   */
  putHomeTopOff(off: boolean) {
    this.preferences.putSync(KEY_HOME_TOP_OFF, off)
    this.preferences.flush()
  }
}