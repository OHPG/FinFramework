import { window } from '@kit.ArkUI'
import { NavTabMeta } from './NavTabMeta'
import { NavTabItem } from './NavTabItem'

/**
 * 左侧悬浮导航栏（横屏矮屏时使用）
 */
@Component
export struct SideNavBar {

  @Require @Prop tabs: NavTabMeta[]

  @Require @Prop currentIndex: number

  @StorageProp('currentAvoidArea') currentAvoidArea?: window.AvoidArea = undefined

  onTabSelect?: (index: number) => void

  build() {
    Column({ space: 4 }) {
      ForEach(this.tabs, (meta: NavTabMeta, index: number) => {
        NavTabItem({
          isActive: this.currentIndex === index,
          title: meta.title,
          icon: meta.icon,
          onSelect: () => { this.onTabSelect?.(index) }
        })
      }, (_meta: NavTabMeta, index: number) => index.toString())
    }
    .padding({ top: 12, bottom: 12})
    .margin({ left: px2vp(this.currentAvoidArea?.leftRect.width ?? 0) + 8, right: 8 })
    .borderRadius(28)
    .backgroundBlurStyle(BlurStyle.Thin)
    .backgroundColor($r('sys.color.comp_background_secondary'))
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
  }
}
