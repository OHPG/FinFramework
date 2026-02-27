import { bundleManager, common, Want } from "@kit.AbilityKit";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/10/19 19:57
 * @Version V1.0
 * @Description
 */
export class MarketUtil {

  /**
   * [打开市场](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-ability-59-V5)
   * @param context
   * @param id
   * @returns
   */
  public static gotoMarket(context: common.UIAbilityContext, id?: string): Promise<void> {
    if (!id) {
      let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      id = bundleInfo.name
    }
    let want: Want = {
      action: 'ohos.want.action.appdetail',
      uri: 'store://appgallery.huawei.com/app/detail?id=' + id,
    };
    return context.startAbility(want)
  }

}