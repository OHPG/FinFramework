import { BreakpointSystem } from '@ohpg/fin-core'
import { CommonConstants } from '../../common/CommonConstants'
import { NavTabMeta } from './NavTabMeta'
import { BottomNavBar } from './BottomNavBar'
import { SideNavBar } from './SideNavBar'
import { window } from '@kit.ArkUI'

// 手机横屏高度阈值（vp），低于此值切换为左侧导航
const COMPACT_HEIGHT_THRESHOLD = 600

/**
 * 自适应导航栏（不包含内容区域）
 * - 竖屏（或高度充足时）→ 底部悬浮导航
 * - 横屏（HEIGHT_SM + 高度 < 阈值）→ 左侧悬浮导航
 *
 * 通过 @Link 向外回传四个方向的 offset，父组件 @Provide 给子页面 @Consume。
 */
@Component
export struct AdaptiveNavBar {

  @StorageProp("currentAvoidArea") avoidArea?: window.AvoidArea = undefined

  @Require @Prop tabs: NavTabMeta[]

  @Require @Prop currentIndex: number

  onTabSelect?: (index: number) => void

  @Link navTopOffset: number
  @Link navBottomOffset: number
  @Link navStartOffset: number
  @Link navEndOffset: number

  @StorageProp(BreakpointSystem.CURRENT_HEIGHT_BREAKPOINT) @Watch('onLayoutChanged')
  currentHeightBreakpoint: HeightBreakpoint = HeightBreakpoint.HEIGHT_MD

  @StorageProp(BreakpointSystem.CURRENT_WINDOW_HEIGHT_VP) @Watch('onLayoutChanged')
  currentWindowHeightVp: number = 0

  @State isCompactHeight: boolean = false

  aboutToAppear(): void {
    this.updateLayout()
  }

  private onLayoutChanged(): void {
    this.updateLayout()
  }

  private updateLayout(): void {
    this.isCompactHeight = this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_SM
      && this.currentWindowHeightVp < COMPACT_HEIGHT_THRESHOLD
    this.updateOffsets()
  }

  private updateOffsets(): void {
    if (this.tabs.length <= 1) {
      this.navTopOffset = 0 + px2vp(this.avoidArea?.topRect.height)
      this.navBottomOffset = 0 + px2vp(this.avoidArea?.bottomRect.height)
      this.navStartOffset = 0 + px2vp(this.avoidArea?.leftRect.width)
      this.navEndOffset = 0 + px2vp(this.avoidArea?.rightRect.width)
    } else if (this.isCompactHeight) {
      this.navTopOffset = 0 + px2vp(this.avoidArea?.topRect.height)
      this.navBottomOffset = 0 + px2vp(this.avoidArea?.bottomRect.height)
      this.navStartOffset = 88 + px2vp(this.avoidArea?.leftRect.width)
      this.navEndOffset = 0 + px2vp(this.avoidArea?.rightRect.width)
    } else {
      this.navTopOffset = 0 + px2vp(this.avoidArea?.topRect.height)
      this.navBottomOffset = 66 + px2vp(this.avoidArea?.bottomRect.height)
      this.navStartOffset = 0 + px2vp(this.avoidArea?.leftRect.width)
      this.navEndOffset = 0 + px2vp(this.avoidArea?.rightRect.width)
    }
  }

  build() {
    RelativeContainer() {
      // 左侧悬浮导航（手机横屏时显示）
      SideNavBar({
        tabs: this.tabs,
        currentIndex: this.currentIndex,
        onTabSelect: (index: number) => { this.onTabSelect?.(index) }
      })
        .visibility(this.tabs.length > 1 && this.isCompactHeight ? Visibility.Visible : Visibility.None)
        .id("sideNav")
        .alignRules({
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          center: { anchor: "__container__", align: VerticalAlign.Center }
        })

      // 底部悬浮导航（默认显示，横屏时隐藏）
      BottomNavBar({
        tabs: this.tabs,
        currentIndex: this.currentIndex,
        onTabSelect: (index: number) => { this.onTabSelect?.(index) }
      })
        .visibility(this.tabs.length > 1 && !this.isCompactHeight ? Visibility.Visible : Visibility.None)
        .id("bottomNav")
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .hitTestBehavior(HitTestMode.Transparent)
  }
}
