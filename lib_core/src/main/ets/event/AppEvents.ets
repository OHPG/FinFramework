
export class AppEvents {

  /**
   * ActiveInfo change
   */
  public static readonly EVENT_ACTIVE_INFO_CHANGED = "event_active_info_changed"

  /**
   * SortInfo change
   */
  public static readonly EVENT_SORT_INFO_CHANGED = "event_sort_info_changed"

  /**
   * 用户同意隐私政策（仅触发一次）
   * 需要依赖隐私授权才能启动的模块，监听此事件后初始化自身。
   */
  public static readonly EVENT_PRIVACY_GRANTED = "event_privacy_granted"

  /**
   * 智能内外网切换完成，携带新地址 URL 字符串
   */
  public static readonly EVENT_LAN_SWITCHED = "event_lan_switched"

}