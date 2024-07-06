import window from '@ohos.window';

/**
 * 窗口布局的工具类
 */
export default class WindowUtils {
  /**
   * 状态栏高度
  */
  static statusBarHeight: number = 0
  /**
   * 导航栏高度
   */
  static navigationBarHeight: number = 0
  /**
   * 窗口宽度
   */
  static windowWidth: number = 0
  /**
   * 窗口高度
   */
  static windowHeight: number = 0

  static init(windowClass: window.Window) {
    const windowRect = windowClass.getWindowProperties().windowRect;
    WindowUtils.windowWidth = windowRect.width;
    WindowUtils.windowHeight = windowRect.height;

    const statusBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    WindowUtils.statusBarHeight = statusBarAvoidArea.topRect.height;

    const navigationBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    WindowUtils.navigationBarHeight = navigationBarAvoidArea.bottomRect.height;
  }
}
