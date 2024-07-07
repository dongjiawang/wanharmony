import CookiePersistor from './CookiePersistor'
import dataPreferences from "@ohos.data.preferences"
import { Context } from '@ohos.abilityAccessCtrl'
import Cookie from './Cookie'
import CookieUtils from './CookieUtils'

const PREFERENCES_NAME = "top.cookies.persistor"
const KEY_COOKIE_KEYS = "COOKIE_KEYS"

/**
 * 持久化 cookie
 */
export default class KVCookiePersistor implements CookiePersistor {
  private preferences: dataPreferences.Preferences

  constructor(context: Context) {
    this.preferences = dataPreferences.getPreferencesSync(context, {
      name: PREFERENCES_NAME
    })
  }

  loadAll(): Cookie[] {
    const cookies: Cookie[] = []
    const keys = this.preferences.getSync(KEY_COOKIE_KEYS, []) as string[]

    keys.forEach((key) => {
      const value = this.preferences.getSync(key, "") as string
      if (value.length > 0) {
        const cookie = CookieUtils.fromJson(value)
        if (cookie) {
          cookies.push(cookie)
        }
      }
    })
    return cookies
  }

  saveAll(cookies: Cookie[]): void {
    cookies.forEach((cookie) => {
      this.preferences.putSync(CookieUtils.creatCookieKey(cookie), JSON.stringify(cookie, undefined, undefined))
    })
    const keys = this.preferences.getSync(KEY_COOKIE_KEYS, []) as string[]
    cookies.forEach((cookie) => {
      const key = CookieUtils.creatCookieKey(cookie)
      if (keys.indexOf(key) < 0) {
        keys.push(key)
      }
    })
    this.preferences.putSync(KEY_COOKIE_KEYS, keys)
    this.preferences.flush()
  }

  removeAll(cookies: Cookie[]): void {
    const keys = this.preferences.getSync(KEY_COOKIE_KEYS, []) as string[]
    cookies.forEach((cookie) => {
      const key = CookieUtils.creatCookieKey(cookie)
      this.preferences.deleteSync(key)
      const index = keys.indexOf(key)
      if (index > 0) {
        keys.splice(index, 1)
      }
    })
    this.preferences.putSync(KEY_COOKIE_KEYS, keys)
    this.preferences.flush()
  }

  clear(): void {
    this.preferences.clearSync()
    this.preferences.flush()
  }
}