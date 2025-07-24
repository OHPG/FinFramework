import { FinAuthResult } from "../entity/item/FinAuthResult";
import { FinPublicSystemInfo } from "../entity/item/FinPublickSystemInfo";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/7/6 14:29
 * @Version V1.0
 * @Description Fin Api
 */
export interface FinApi {

  /**
   * 获取服务器公开信息
   * @param url 服务器地址
   * @returns 服务器公开信息
   */
  getPublicSystemInfo(url: string): Promise<FinPublicSystemInfo>

  /**
   * 认证用户
   * @param name 用户名
   * @param psw 密码
   * @returns 认证结果
   */
  authenticateUserByName(name: string, psw?: string): Promise<FinAuthResult>

  /**
   * 收藏媒体文件
   * @param id 媒体id
   * @returns
   */
  markFavoriteItem(id: string): Promise<void>

  /**
   * 取消收藏媒体文件
   * @param id 媒体id
   * @returns
   */
  unmarkFavoriteItem(id: string): Promise<void>

  /**
   * 设置媒体已播放
   * @param id 媒体id
   * @returns
   */
  markPlayedItem(id: string): Promise<void>

  /**
   * 设置媒体未播放
   * @param id 媒体id
   * @returns
   */
  markUnplayedItem(id: string): Promise<void>

}
