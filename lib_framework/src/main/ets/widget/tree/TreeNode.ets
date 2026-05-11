@Observed
export class TreeNode {
  /** 面包屑显示名称 */
  name: ResourceStr
  /** 打开此层级的源数据（root 为 undefined），app 自行解释 */
  item?: object

  constructor(name: ResourceStr, item?: object) {
    this.name = name
    this.item = item
  }
}
