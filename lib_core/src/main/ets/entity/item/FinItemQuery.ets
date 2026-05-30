import { FinItemType } from './FinItemType'
import { FinSortBy } from './FinSortBy'
import { FinSortOrder } from './FinSortOrder'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/5/31 00:00
 * @Version V1.0
 * @Description 统一媒体列表查询参数
 */
export interface FinItemQuery {
  /** 父级 ID（媒体库 ID） */
  parentId: string
  /** 筛选的媒体类型 */
  types?: Array<FinItemType>
  /** 是否递归查询子目录 */
  recursive?: boolean
  /** 分页偏移 */
  startIndex?: number
  /** 每页数量 */
  limit?: number
  /** 排序字段 */
  sortBy?: FinSortBy
  /** 排序方向 */
  sortOrder?: FinSortOrder
  /** Genre 筛选 */
  genres?: Array<string>
  /** 排除的 Genre */
  excludeGenres?: Array<string>
}
