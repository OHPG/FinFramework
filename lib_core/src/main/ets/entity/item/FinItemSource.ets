import { FinSubSource } from "./FinSubSource"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/5/29 10:00
 * @Version V1.0
 * @Description fin item source
 */
export interface FinItemSource {

  url: string

  sdr: boolean

  header?: Record<string, string>

  parts?: string[]

  sub?: Array<FinSubSource>

}
