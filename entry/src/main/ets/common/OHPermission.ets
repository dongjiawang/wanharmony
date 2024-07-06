import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@kit.BasicServicesKit'

export default class OHPermission {
  /**
   * 申请指定的权限
   * @param context context
   * @param permissionList 权限列表
   * @returns 结果回调
   */
  static requestPermission(context: Context, permissionList: Permissions[]): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const atManager = abilityAccessCtrl.createAtManager();
      // requestPermissionsFromUser 这个函数会判断授权状态来决定是否唤起弹窗
      atManager.requestPermissionsFromUser(context, permissionList)
        .then((data) => {
          const grantStatus: number[] = data.authResults;
          const length: number = grantStatus.length
          for (let i = 0; i < grantStatus.length; i++) {
            const element = grantStatus[i];
            if (element !== 0) {
              // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
              reject()
            }
          }
          // 授权成功
          resolve()
        })
        .catch((err: BusinessError) => {
          console.error(`获取权限失败, code 是 ${err.code}, 错误信息：${err.message}`)
          reject()
        })
    });
  }

  /**
   * 检查权限状态
   * @param permission 指定权限
   * @returns 结果
   */
  static async checkPermission(permission: Permissions): Promise<boolean> {
    const grantStatus: abilityAccessCtrl.GrantStatus = await OHPermission.checkAccessToken(permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 已经授权
      return true
    }
    // 未授权
    return false
  }

  /**
   * 通过 token 检查应用权限
   * @param permission 需要检查的权限
   * @returns 检查结果
   */
  private static async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED

    // 获取应用的 accessTokenID
    let tokenId: number = 0;
    try {
      const bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`检查权限状态失败, code 是 ${err.code}, 错误信息:${err.message}`)
    }

    // 校验应用是否被授权
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError
      console.error(`检查权限状态失败, code 是 ${err.code}, 错误信息:${err.message}`)
    }

    return grantStatus
  }
}