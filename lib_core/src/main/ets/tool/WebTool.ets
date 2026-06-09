import { common, Want } from "@kit.AbilityKit"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/12/8 21:43
 * @Version V1.0
 * @Description 基础 Web 工具，仅负责跳转系统浏览器。
 */
export class WebTool {

  /**
   * 打开系统浏览器
   * @param context UIContext
   * @param url 地址
   * @returns AbilityResult
   */
  public static openSystemBrowser(context: UIContext, url: string): Promise<common.AbilityResult> {
    let abilityContext = context.getHostContext() as common.UIAbilityContext
    // https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-ability-58-V5
    let want: Want = {
      action: "ohos.want.action.viewData",
      entities: ['entity.system.browsable'],
      uri: url
    }
    return abilityContext.startAbilityForResult(want)
  }

}