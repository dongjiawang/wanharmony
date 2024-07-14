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
    WindowUtils.windowWidth = px2vp(windowRect.width);
    WindowUtils.windowHeight = px2vp(windowRect.height);

    const statusBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    WindowUtils.statusBarHeight = px2vp(statusBarAvoidArea.topRect.height);

    const navigationBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    WindowUtils.navigationBarHeight = px2vp(navigationBarAvoidArea.bottomRect.height);
  }
}
