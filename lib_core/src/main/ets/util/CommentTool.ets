import { common } from "@kit.AbilityKit";
import { deviceInfo } from "@kit.BasicServicesKit";
import { commentManager } from "@kit.AppGalleryKit";
import { MarketUtil } from "../util/MarketUtil";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/10/19 19:44
 * @Version V1.0
 * @Description
 */
export class CommentTool {

  /**
   * 是否支持内部来气评论
   * @returns
   */
  public static supportComment(): boolean {
    return deviceInfo.sdkApiVersion >= 20
  }

  /**
   * 拉起评论弹窗
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/appgallery-comment
   * @param context
   */
  public static async showComment(context: common.UIAbilityContext): Promise<void> {
    if (CommentTool.supportComment()) {
      if (canIUse("SystemCapability.AppGalleryService.Distribution.Comment")) {
        try {
          return await commentManager.showCommentDialog(context)
        } catch (e) {
          // ignore
        }
      }
    }
    // 跳转到市场
    return MarketUtil.gotoMarket(context)
  }

}