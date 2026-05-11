/**
 * 面包屑导航的单个层级
 */
export interface BreadcrumbSegment {

  /** 显示名称 */
  label: string

  /** 对应的目录路径 */
  path: string

  /** 是否为当前层级（最后一个） */
  isCurrent: boolean
}
