import { TreeNode } from './TreeNode'

export class TreeController {
  // 内部绑定（由 TreeView 在 aboutToAppear 时设置）
  private _forward?: (name: ResourceStr, item?: object) => void
  private _goBack?: () => boolean
  private _getNodeStack?: () => TreeNode[]

  /** 前进到子级 */
  forward(name: ResourceStr, item?: object): void {
    this._forward?.(name, item)
  }

  /** 后退一级，返回是否消耗了事件 */
  goBack(): boolean {
    return this._goBack?.() ?? false
  }

  /** 获取当前导航栈（只读） */
  getNodeStack(): TreeNode[] {
    return this._getNodeStack?.() ?? []
  }

  /** 获取当前节点 */
  getCurrentNode(): TreeNode | undefined {
    let stack = this.getNodeStack()
    return stack.length > 0 ? stack[stack.length - 1] : undefined
  }

  /** 由 TreeView 在 aboutToAppear 时调用，绑定 forward 实现 */
  bindForward(fn: (name: ResourceStr, item?: object) => void): void {
    this._forward = fn
  }

  /** 由 TreeView 在 aboutToAppear 时调用，绑定 goBack 实现 */
  bindGoBack(fn: () => boolean): void {
    this._goBack = fn
  }

  /** 由 TreeView 在 aboutToAppear 时调用，绑定 getNodeStack 实现 */
  bindGetNodeStack(fn: () => TreeNode[]): void {
    this._getNodeStack = fn
  }
}
