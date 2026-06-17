import { window } from "@kit.ArkUI";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/13 20:41
 * @Version V1.0
 * @Description
 */
export class AvoidAreaSystem {

  public static readonly CURRENT_AVOID_AREA = "currentAvoidArea"

  public static readonly CURRENT_WINDOW = "currentWindow"

  private win?: window.Window

  private avoidArea: window.AvoidArea = {
    visible: true,
    leftRect: {
      left: 0, top: 0, width: 0, height: 0
    },
    rightRect: {
      left: 0, top: 0, width: 0, height: 0
    },
    topRect: {
      left: 0, top: 0, width: 0, height: 0
    },
    bottomRect: {
      left: 0, top: 0, width: 0, height: 0
    }
  }

  private avoidAreaMap = new Map<window.AvoidAreaType, window.AvoidArea>()

  private avoidAreaChangeCallback: Callback<window.AvoidAreaOptions> = (avoidAreaOptions) => {
    if (avoidAreaOptions.type === window.AvoidAreaType.TYPE_SYSTEM
      || avoidAreaOptions.type === window.AvoidAreaType.TYPE_CUTOUT
      || avoidAreaOptions.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.avoidAreaMap.set(avoidAreaOptions.type, avoidAreaOptions.area)
      this.updateAvoidArea()
    }
  }

  public register(win: window.Window) {
    this.win = win
    AppStorage.setOrCreate(AvoidAreaSystem.CURRENT_WINDOW, win)
    let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    this.avoidAreaMap.set(window.AvoidAreaType.TYPE_SYSTEM, area)
    let cutout = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT)
    this.avoidAreaMap.set(window.AvoidAreaType.TYPE_CUTOUT, cutout)
    let indicator = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    this.avoidAreaMap.set(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR, indicator)
    this.updateAvoidArea()
    win.on("avoidAreaChange", this.avoidAreaChangeCallback)
  }
  private updateAvoidArea() {
    this.clearArea(this.avoidArea)
    const windowRect = this.win?.getWindowProperties().windowRect
    this.avoidAreaMap.forEach((area) => {
      this.mergeArea(this.avoidArea, area, windowRect)
    })
    AppStorage.setOrCreate(AvoidAreaSystem.CURRENT_AVOID_AREA, this.avoidArea)
  }

  /**
   * 将单个 type 的 AvoidArea 合并到最终结果中。
   * 每个方向根据 rect 的位置和尺寸计算真实侵入深度，取各 type 中的最大值。
   */
  private mergeArea(target: window.AvoidArea, source: window.AvoidArea, windowRect?: window.Rect) {
    // top: 侵入深度 = top + height（rect 下边界到屏幕顶部的距离）
    const topDepth = source.topRect.top + source.topRect.height
    if (topDepth > target.topRect.height) {
      target.topRect.left = 0
      target.topRect.top = 0
      target.topRect.width = source.topRect.left + source.topRect.width
      target.topRect.height = topDepth
    }
    // bottom: 侵入深度 = screenHeight - top（从屏幕底部到 rect 上边界的距离）
    const screenHeight = windowRect?.height ?? 0
    const bottomDepth = screenHeight > 0 && source.bottomRect.height > 0
      ? screenHeight - source.bottomRect.top
      : source.bottomRect.height
    if (bottomDepth > target.bottomRect.height) {
      target.bottomRect.left = source.bottomRect.left
      target.bottomRect.top = source.bottomRect.top
      target.bottomRect.width = source.bottomRect.width
      target.bottomRect.height = bottomDepth
    }
    // left: 侵入深度 = left + width（rect 右边界到屏幕左侧的距离）
    const leftDepth = source.leftRect.left + source.leftRect.width
    if (leftDepth > target.leftRect.width) {
      target.leftRect.left = 0
      target.leftRect.top = 0
      target.leftRect.width = leftDepth
      target.leftRect.height = source.leftRect.top + source.leftRect.height
    }
    // right: 侵入深度 = screenWidth - left（从屏幕右边缘到 rect 左边界的距离）
    const screenWidth = windowRect?.width ?? 0
    const rightDepth = screenWidth > 0 && source.rightRect.width > 0
      ? screenWidth - source.rightRect.left
      : source.rightRect.width
    if (rightDepth > target.rightRect.width) {
      target.rightRect.left = source.rightRect.left
      target.rightRect.top = source.rightRect.top
      target.rightRect.width = rightDepth
      target.rightRect.height = source.rightRect.height
    }
  }

  private clearArea(area: window.AvoidArea) {
    area.visible = false
    this.clearAreaRect(area.leftRect)
    this.clearAreaRect(area.topRect)
    this.clearAreaRect(area.rightRect)
    this.clearAreaRect(area.bottomRect)
  }

  private clearAreaRect(rect: window.Rect) {
    rect.width = 0
    rect.height = 0
    rect.left = 0
    rect.top = 0
  }

  unregister() {
    this.win?.off("avoidAreaChange", this.avoidAreaChangeCallback)
    this.win = undefined
  }

}