import { bundleManager, common } from "@kit.AbilityKit"
import { PrivacyOptions } from "../../dialog/PrivacyDialog"
import { FinWebTool } from "../../tool/FinWebTool"

@Component
export struct PrivacyView {

  options?: PrivacyOptions

  @State appName?: string = undefined

  aboutToAppear(): void {
    let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    let resourceManager = getContext().resourceManager
    this.appName = resourceManager.getStringSync(bundleInfo.appInfo.labelResource)
  }

  build() {
    Column({ space: 0 }) {

      // 标题
      Text($r('app.string.privacy_dialog_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 28, bottom: 0, left: 24, right: 24 })

      // 正文
      Text() {
        Span($r('app.string.privacy_dialog_welcome_prefix'))
        Span(this.appName)
          .fontWeight(FontWeight.Medium)
        Span('\n\n')
        Span($r('app.string.privacy_dialog_content_prefix'))
        Span($r('app.string.privacy_dialog_privacy_link'))
          .fontColor($r('sys.color.ohos_id_color_activated'))
          .onClick(() => {
            FinWebTool.open(this.getUIContext(), '隐私声明', this.options!.privacy!)
          })
        Span($r('app.string.privacy_dialog_content_suffix'))
      }
      .fontSize(14)
      .fontColor($r('sys.color.font_secondary'))
      .lineHeight(22)
      .width('100%')
      .padding({ top: 16, bottom: 0, left: 24, right: 24 })

      // 分割线
      Divider()
        .strokeWidth(0.5)
        .color($r('sys.color.ohos_id_color_list_separator'))
        .margin({ top: 24 })

      // 按钮区
      Row() {
        // 不同意 - 次要按钮（灰色文字）
        Button($r('app.string.privacy_dialog_disagree'), { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(50)
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(16)
          .onClick(() => {
            (getContext() as common.UIAbilityContext).terminateSelf()
          })

        // 竖向分割线
        Divider()
          .vertical(true)
          .strokeWidth(0.5)
          .height(24)
          .color($r('sys.color.ohos_id_color_list_separator'))

        // 同意 - 主要按钮（品牌蓝）
        Button($r('app.string.privacy_dialog_agree'), { type: ButtonType.Normal })
          .layoutWeight(1)
          .height(50)
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.ohos_id_color_activated'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.options?.callback?.()
          })
      }
      .width('100%')

    }
    .border({ radius: 16 })
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .width(320)
    .clip(true)
  }

}
