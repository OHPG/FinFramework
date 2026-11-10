/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 14:21
 * @Version V1.0
 * @Description Server type
 */
export enum ServerType {

  /**
   * Jellyfin server
   */
  JELLYFIN = "Jellyfin",

  /**
   * Emby server
   */
  EMBY = "Emby",

  /**
   * Komga server
   */
  KOMGA = "Komga",

  /**
   * Plex server
   */
  PLEX = "Plex",

  /**
   * Local self-scraping mode
   */
  LOCAL = "Local",
  /**
   * fnOS (飞牛影视) compat mode (Jellyfin-like API)
   */
  FNOS_COMPAT = "FnOsCompat",

  /**
   * fnOS (飞牛影视) native mode (/v/api/v1 with authx signature)
   */
  FNOS_NATIVE = "FnOsNative"

}