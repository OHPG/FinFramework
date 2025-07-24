import { MD5 } from "../crypto/MD5"
import { FinApi } from "./FinApi"
import { ClientInfo, DeviceInfo } from "@ohpg/network"
import { bundleManager } from "@kit.AbilityKit"
import { deviceInfo } from "@kit.BasicServicesKit"
import { ServerType } from "../entity/ServerType"
import { ActiveInfo } from "../entity/ActiveInfo"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 14:34
 * @Version V1.0
 * @Description
 */
export abstract class FinApis {

  /**
   * FinApi key
   */
  public static readonly FIN_API = "FinApi"

  /**
   * Context info
   */
  protected readonly context: Context

  /**
   * Client info
   */
  protected readonly clientInfo: ClientInfo

  /**
   * Device info
   */
  protected readonly deviceInfo: DeviceInfo

  constructor(context: Context, module: string) {
    this.context = context
    let info = bundleManager.getBundleInfoForSelfSync(bundleManager
      .BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    this.clientInfo = {
      name: module,
      version: info.versionName
    }
    this.deviceInfo = {
      // Same developer has same odid.
      id: MD5.digestSync(deviceInfo.ODID + "-" + module),
      name: deviceInfo.marketName
    }
  }

  abstract activeFinApi(activeInfo: ActiveInfo): FinApi {
    this.finApi.updateUserInfo({id: activeInfo.userInfo.userId, token: activeInfo.userInfo.accessToken})
  }

  public getFinApi(type: ServerType): FinApi {

  }

  public setFinApi(type: ServerType): void {

  }

}