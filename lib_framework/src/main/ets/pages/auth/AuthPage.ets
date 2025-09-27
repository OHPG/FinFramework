import { CoreRepository, ServerType, StringTool } from '@ohpg/fin-core'
import { FinPages } from '../FinPages'
import { ProgressDialog } from '../../dialog/ProgressDialog'
import { bundleManager, common } from '@kit.AbilityKit'
import { ToolBar } from '../../widget/bar/ToolBar'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/7 21:21
 * @Version V1.0
 * @Description
 */
@Preview
@Entry({routeName: FinPages.PAGE_FIN_ADD_SERVER})
@Component
struct AuthPage {

  private appIcon?: DrawableDescriptor

  private appName?: string

  private url?: string

  private userName?: string

  private psw?: string

  private progressDialog?: ProgressDialog

  private repository: CoreRepository = AppStorage.get(CoreRepository.REPOSITORY)!

  private canBack: boolean = true

  aboutToAppear(): void {
    let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    let resourceManager = this.getUIContext().getHostContext()!.resourceManager
    this.appIcon = resourceManager.getDrawableDescriptor(bundleInfo.appInfo.iconResource)
    this.appName = resourceManager.getStringSync(bundleInfo.appInfo.labelResource)
    this.progressDialog = new ProgressDialog(this.getUIContext())
    this.canBack = Number.parseInt(this.getUIContext().getRouter().getLength()) > 1
  }

  build() {
    Column() {

      if (this.canBack) {
        ToolBar({
          title: $r('app.string.login_auth')
        })
      }

      RelativeContainer() {

        TextInput({ placeholder: $r('app.string.login_user_name') })
          .id("user_name")
          .constraintSize({
            maxWidth: 300
          })
          .alignRules({
            middle: { anchor: "__container__", align: HorizontalAlign.Center },
            center: { anchor: "__container__", align: VerticalAlign.Center },
          })
          .onChange((value) => {
            this.userName = value
          })

        TextInput({ placeholder: $r('app.string.login_psw') })
          .id("user_psw")
          .type(InputType.Password)
          .constraintSize({
            maxWidth: 300
          })
          .margin({
            top: 15
          })
          .alignRules({
            middle: { anchor: "__container__", align: HorizontalAlign.Center },
            top: { anchor: "user_name", align: VerticalAlign.Bottom },
          })
          .onChange((value) => {
            this.psw = value
          })

        TextInput({ placeholder: $r('app.string.server_address') })
          .id("server_address")
          .type(InputType.URL)
          .constraintSize({
            maxWidth: 300
          })
          .alignRules({
            middle: {anchor: "__container__", align: HorizontalAlign.Center},
            bottom: { anchor: "user_name", align: VerticalAlign.Top}
          })
          .margin({
            bottom: 15
          })
          .onChange((value) => {
            this.url = value
          })

        Image(this.appIcon)
          .width(120)
          .height(120)
          .alignRules({
            middle: {anchor: "__container__", align: HorizontalAlign.Center},
            top: { anchor: "__container__", align: VerticalAlign.Top},
            bottom: { anchor: "server_address", align: VerticalAlign.Top}
          })


        Button($r('app.string.login_auth'))
          .id("server_connect")
          .width(160)
          .margin(15)
          .constraintSize({
            minWidth: 100
          })
          .margin({
            top: 15
          })
          .alignRules({
            middle: {anchor: "__container__", align: HorizontalAlign.Center},
            top: { anchor: "user_psw", align: VerticalAlign.Bottom}
          })
          .onClick(() => {
            this.onAuth()
          })

        Text($r('app.string.login_auth_tips'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .fontColor($r('sys.color.font_secondary'))
          .margin(36)
          .alignRules({
            middle: { anchor: "__container__", align: HorizontalAlign.Center },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
          })

      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  private onAuth() {
    if (!this.url || this.url.length <= 0) {
      this.getUIContext().getPromptAction().showToast({message: $r('app.string.error_url_empty')})
      return
    }
    if (!this.url.startsWith('http')) {
      this.getUIContext().getPromptAction().showToast({message: $r('app.string.error_url_not_start_with_http')})
      return
    }
    if (!StringTool.isUrlValid(this.url)) {
      this.getUIContext().getPromptAction().showToast({message: $r('app.string.error_url_not_validate')})
      return
    }
    if (!this.userName || this.userName.length <= 0) {
      this.getUIContext().getPromptAction().showToast({message: $r('app.string.error_user_name_empty')})
      return
    }
    this.progressDialog?.show()
    this.repository?.authAccount(ServerType.JELLYFIN, this.url!, this.userName, this.psw)
      .then(() => {
        this.progressDialog?.dismiss()
        let state = this.getUIContext().getRouter().getStateByIndex(0)
        if (state?.name == "pages/home/HomePage") {
          this.getUIContext().getRouter().back(0)
        } else {
          (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage
            .loadContent("pages/home/HomePage")
        }
      })
      .catch((error: Error) => {
        this.progressDialog?.dismiss()
        this.getUIContext().getPromptAction().showToast({message: error.message})
      })
  }

  aboutToDisappear(): void {
    this.progressDialog?.dismiss()
    this.progressDialog = undefined
  }

}