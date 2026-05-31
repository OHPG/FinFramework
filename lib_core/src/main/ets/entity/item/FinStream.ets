import { FinStreamType } from "./FinStreamType"
import { FinVideoRangeType } from "./FinVideoRangeType"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2024/11/11 21:30
 * @Version V1.0
 * @Description media stream
 */
export interface FinStream {

  title: string

  displayTitle?: string

  language: string

  type: FinStreamType

  codec: string

  isExternal: boolean

  isDefault?: boolean

  path?: string

  channelLayout?: string

  channels?: number

  bitRate?: number

  bitDepth?: number

  sampleRate?: number

  frameRate?: number

  profile?: string

  level?: number

  aspectRatio?: string

  pixelFormat?: string

  videoRangeType?: FinVideoRangeType

  width?: number

  height?: number

  videoDoViTitle?: string
}