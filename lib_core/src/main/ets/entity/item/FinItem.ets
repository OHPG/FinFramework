import { FinCollectionType } from "./FinCollectionType"
import { FinImage } from "./FinImage"
import { FinItemData } from "./FinItemData"
import { FinItemType } from "./FinItemType"
import { FinPerson } from "./FinPerson"
import { FinSource } from "./FinSource"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/11 21:19
 * @Version V1.0
 * @Description fin item
 */
export interface FinItem {

  id: string

  name: string

  type?: FinItemType

  originalTitle?: String

  overview?: string

  seriesName?: string

  seriesId?: string

  seasonId?: string

  canPlay?: boolean

  canDownload?: boolean

  path?: string

  sources?: Array<FinSource>

  items?: Array<FinItem>

  runtimeTicks?: number

  unplayedItemCount?: number

  productionYear?: string

  officialRating?: string

  communityRating?: string

  image?: FinImage

  genres?: Array<string>;

  person?: Array<FinPerson>

  data?: FinItemData

  parentIndex?: number

  index?: number

  collectionType?: FinCollectionType

  providerIds?: Record<string, string>

  /**
   * 是否为虚拟条目（Jellyfin/Emby 中 LocationType === "Virtual" 的集，即尚未入库的缺失集）
   */
  isVirtual?: boolean
}