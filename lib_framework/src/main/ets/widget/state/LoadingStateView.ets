import { CommonConstants } from '../../common/CommonConstants'

@Component
export struct LoadingStateView {
  loadingColor: ResourceColor = $r('sys.color.font_secondary')

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(this.loadingColor)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
