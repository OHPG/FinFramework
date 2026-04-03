import { CommonConstants } from '../../common/CommonConstants'

@Component
export struct ErrorStateView {
  @Prop message: ResourceStr = ''
  messageColor: ResourceColor = $r('sys.color.font_secondary')
  onRetry?: Callback<void> = undefined

  build() {
    Column({ space: CommonConstants.SPACE_12 }) {
      Text('⚠️')
        .fontSize(40)
      Text(this.message)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.messageColor)
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 })
      Button($r('app.string.state_retry'))
        .onClick(() => {
          this.onRetry?.()
        })
        .visibility(this.onRetry ? Visibility.Visible : Visibility.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
