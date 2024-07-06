import promptAction from '@ohos.promptAction';
import WindowUtil from './WindowUtils'

/**
 * 在屏幕中间显示提示文字
 * @param message 提示文字
 */
export function toast(message: string | Resource) {
  if (message) {
    const bottom = WindowUtil.windowHeight > 0 ? (WindowUtil.windowHeight / 2 + "px") : undefined;
    promptAction.showToast({
      message: message,
      bottom: bottom
    })
  }
}