import { FinImage } from "./FinImage"
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

  originalTitle?: String

  overview: string

  played: boolean

  favorite: boolean

  canPlay: boolean

  canDownload: boolean

  sources?: Array<FinSource>

  runtimeTicks: number

  playbackPositionTicks: number

  unplayedItemCount?: number

  image: FinImage
}