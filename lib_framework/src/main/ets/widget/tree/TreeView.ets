import { TreeNode } from './TreeNode'
import { TreeController } from './TreeController'
import { BreadcrumbNavigator } from '../bar/BreadcrumbNavigator'
import { BreadcrumbSegment } from '../../model/BreadcrumbSegment'

@Component
export struct TreeView {
  @Require controller: TreeController = new TreeController()
  @BuilderParam contentBuilder: (node: TreeNode, index: number) => void = this.defaultBuilder
  rootName?: ResourceStr = '根目录'
  onFolderChange?: (node: TreeNode) => void

  @State private nodeStack: TreeNode[] = []
  @State private swiperIndex: number = 0

  @Builder
  defaultBuilder(_node: TreeNode, _index: number) {
  }

  aboutToAppear(): void {
    // Push root node
    let rootNode = new TreeNode(this.rootName ?? '根目录')
    this.nodeStack.push(rootNode)

    // Bind controller implementations
    this.controller.bindForward((name: ResourceStr, item?: object) => this.forwardFolder(name, item))
    this.controller.bindGoBack(() => this.goBackInternal())
    this.controller.bindGetNodeStack(() => this.nodeStack)
  }

  private forwardFolder(name: ResourceStr, item?: object): void {
    let newNode = new TreeNode(name, item)
    this.nodeStack.push(newNode)
    this.swiperIndex = this.nodeStack.length - 1
    this.onFolderChange?.(newNode)
  }

  private goBackInternal(): boolean {
    if (this.nodeStack.length > 1) {
      this.backwardTo(this.nodeStack.length - 2)
      return true
    }
    return false
  }

  private backwardTo(index: number): void {
    if (index < 0 || index >= this.nodeStack.length) {
      return
    }
    this.nodeStack.splice(index + 1)
    this.swiperIndex = index
    this.onFolderChange?.(this.nodeStack[index])
  }

  private buildSegments(): BreadcrumbSegment[] {
    let segments: BreadcrumbSegment[] = []
    let lastIndex = this.nodeStack.length - 1
    for (let i = 0; i < this.nodeStack.length; i++) {
      let node = this.nodeStack[i]
      let segment: BreadcrumbSegment = {
        label: node.name as string,
        path: `${i}`,
        isCurrent: i === lastIndex
      }
      segments.push(segment)
    }
    return segments
  }

  build() {
    Column() {
      BreadcrumbNavigator({
        segments: this.buildSegments(),
        onSegmentClick: (index: number) => {
          this.backwardTo(index)
        }
      })

      Swiper() {
        ForEach(this.nodeStack, (node: TreeNode, index: number) => {
          this.contentBuilder(node, index)
        }, (_node: TreeNode, index: number) => `${index}`)
      }
      .index(this.swiperIndex)
      .disableSwipe(true)
      .indicator(false)
      .loop(false)
      .duration(0)
      .effectMode(EdgeEffect.None)
      .layoutWeight(1)
    }
    .width('100%')
  }
}
