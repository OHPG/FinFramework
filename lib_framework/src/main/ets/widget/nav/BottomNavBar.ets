import { window } from '@kit.ArkUI'
import { CommonConstants } from '../../common/CommonConstants'
import { NavTabMeta } from './NavTabMeta'
import { NavTabItem } from './NavTabItem'

/**
 * 底部悬浮导航栏（竖屏 / 高度充足时使用）
 */
@Component
export struct BottomNavBar {

  @Require @Prop tabs: NavTabMeta[]

  @Require @Prop currentIndex: number

  @StorageProp('currentAvoidArea') currentAvoidArea?: window.AvoidArea = undefined

  onTabSelect?: (index: number) => void

  build() {
    Row({ space: 4 }) {
      ForEach(this.tabs, (meta: NavTabMeta, index: number) => {
        NavTabItem({
          isActive: this.currentIndex === index,
          title: meta.title,
          icon: meta.icon,
          onSelect: () => { this.onTabSelect?.(index) }
        })
      }, (_meta: NavTabMeta, index: number) => index.toString())
    }
    .padding({ left: 12, right: 12 })
    .margin({ bottom: px2vp(this.currentAvoidArea?.bottomRect.height) || CommonConstants.SPACE_8 })
    .width('auto') // 自适应宽度
    .borderRadius(28)
    .backgroundBlurStyle(BlurStyle.Thin)
    .backgroundColor($r('sys.color.comp_background_secondary'))
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
  }
}
