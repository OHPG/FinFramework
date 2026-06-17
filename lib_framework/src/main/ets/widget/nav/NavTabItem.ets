/**
 * 导航栏单个 Tab 项（图标 + 文字）
 */
@Component
export struct NavTabItem {

  @Require @Prop isActive: boolean

  @Require title: ResourceStr = ''

  @Require icon: Resource = $r('sys.symbol.house_fill')

  onSelect?: () => void

  build() {
    Column({ space: 2 }) {
      SymbolGlyph(this.icon)
        .fontSize(24)
        .fontColor([this.isActive
          ? $r('sys.color.ohos_id_color_activated')
          : $r('sys.color.ohos_id_color_text_secondary')])
      Text(this.title)
        .fontSize(10)
        .fontColor(this.isActive
          ? $r('sys.color.ohos_id_color_activated')
          : $r('sys.color.ohos_id_color_text_secondary'))
    }
    .width(56)
    .height(52)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Transparent)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      this.onSelect?.()
    })
  }
}
