import { FinSubSource } from "./FinSubSource"

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/5/29 10:00
 * @Version V1.0
 * @Description fin item source
 */
export interface FinItemSource {

  /**
   * 版本唯一标识（供选定版本后传回 getItemSources 使用）
   * Jellyfin/Emby: MediaSource.Id
   * Plex: Media.id
   * Local: MediaInfo.id
   */
  id: string

  /**
   * 版本展示名称（供版本选择器展示）
   * Jellyfin/Emby: MediaSource.Name
   * Plex: Media 分辨率/编码信息
   * Local: 文件名
   */
  name: string

  url: string

  sdr: boolean

  header?: Record<string, string>

  parts?: string[]

  sub?: Array<FinSubSource>

}
