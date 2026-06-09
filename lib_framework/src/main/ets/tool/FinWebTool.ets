import { WebTool } from '@ohpg/fin-core'
import { deviceInfo } from '@kit.BasicServicesKit'
import { FinRouter } from '../pages/FinRouter'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/6/9 12:00
 * @Version V1.0
 * @Description 扩展 WebTool，增加内置浏览器和回退策略。
 *              - TV/车机：直接打开内置 WebView
 *              - 手机/平板：优先系统浏览器，失败回退内置 WebView
 */
export class FinWebTool extends WebTool {

  /**
   * 智能打开浏览器（带回退策略）
   * @param context UIContext
   * @param title 页面标题
   * @param url 目标地址
   */
  public static async open(context: UIContext, title: ResourceStr, url: string): Promise<void> {
    if (deviceInfo.deviceType === 'tv' || deviceInfo.deviceType === 'car') {
      await FinWebTool.openAppBrowser(context, title, url)
    } else {
      try {
        await WebTool.openSystemBrowser(context, url)
      } catch (e) {
        // 无系统浏览器或用户取消，回退到内置 WebView
        await FinWebTool.openAppBrowser(context, title, url)
      }
    }
  }

  /**
   * 打开内置 WebView 页面
   * @param context UIContext
   * @param title 页面标题
   * @param url 目标地址
   */
  public static async openAppBrowser(context: UIContext, title: ResourceStr, url: string): Promise<void> {
    await FinRouter.openWebKit(context, title, url)
  }

}
