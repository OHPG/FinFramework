import { PrivacyProvider } from "../privacy/PrivacyProvider";
import { CoreApi } from "./CoreApi";
import { ServerType } from "../entity/ServerType";
import { bundleManager } from "@kit.AbilityKit";
import { ClientInfo, DeviceInfo } from "@ohpg/network";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/9/27 19:54
 * @Version V1.0
 * @Description
 */
export abstract class ApiFactory {

  /**
   * Context info
   */
  protected readonly context: Context

  /**
   * Client info
   */
  protected readonly clientInfo: ClientInfo

  /**
   * Device info（惰性，首次访问 .id 时才读取 ODID）
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
    this.deviceInfo = PrivacyProvider.getInstance()
  }

  protected abstract onCreateApi<T extends CoreApi>(serverType: ServerType): T;

  public createApi<T extends CoreApi>(type: ServerType): T {
    return this.onCreateApi(type) as T
  }

}