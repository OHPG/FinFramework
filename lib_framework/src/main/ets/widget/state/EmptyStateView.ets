import { CommonConstants } from '../../common/CommonConstants'

@Component
export struct EmptyStateView {
  @Prop icon: string = '📂'
  @Prop title: ResourceStr = ''
  @Prop subtitle: ResourceStr = ''
  titleColor: ResourceColor = $r('sys.color.font_secondary')
  subtitleColor: ResourceColor = $r('sys.color.font_tertiary')

  build() {
    Column({ space: CommonConstants.SPACE_12 }) {
      Text(this.icon)
        .fontSize(40)
      Text(this.title)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(this.titleColor)
        .textAlign(TextAlign.Center)
      Text(this.subtitle)
        .fontSize($r('sys.float.Body_S'))
        .fontColor(this.subtitleColor)
        .textAlign(TextAlign.Center)
        .visibility(this.subtitle ? Visibility.Visible : Visibility.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
