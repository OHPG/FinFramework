import { FinImage } from "./FinImage"
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

  played?: boolean

  favorite?: boolean

  canPlay?: boolean

  canDownload?: boolean

  path?: string

  sources?: Array<FinSource>

  runtimeTicks?: number

  playbackPositionTicks?: number

  unplayedItemCount?: number

  productionYear?: string

  officialRating?: string

  communityRating?: string

  image?: FinImage

  person?: Array<FinPerson>
}