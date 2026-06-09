import { CommonConstants } from '../../common/CommonConstants'
import { ToolBar } from '../../widget/bar/ToolBar'
import { webview } from '@kit.ArkWeb'
import { WebKitOption } from './WebKitOption'
import { FinPages } from '../FinPages'

@Entry({ routeName: FinPages.PAGE_FIN_WEBKIT })
@Component
struct WebKitPage {

  private webkitOption?: WebKitOption

  aboutToAppear(): void {
    let router = this.getUIContext().getRouter()
    let params: object = router.getParams()
    this.webkitOption = params as WebKitOption
  }

  build() {
    Column() {
      Column({ space: CommonConstants.SPACE_8 }) {
        ToolBar({ title: this.webkitOption?.title })
      }

      Web({ src: this.webkitOption?.url, controller: new webview.WebviewController() })
        .domStorageAccess(true)
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

}
