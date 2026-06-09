import { deviceInfo } from '@kit.BasicServicesKit'
import { MD5 } from '../crypto/MD5'
import { DeviceInfo } from '@ohpg/network'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/6/8
 * @Version V1.0
 * @Description 隐私敏感数据的统一供给源
 *
 * 所有涉及用户设备标识的获取必须通过此类，禁止直接访问 deviceInfo.ODID。
 * - 惰性获取：仅在首次被消费时才读取系统 API
 * - 缓存结果：避免重复计算
 * - 单一入口：方便合规审计和未来隐私变更
 * - 实现 DeviceInfo 接口，可直接作为设备信息传递给 ApiClient
 */
export class PrivacyProvider implements DeviceInfo {

  private static instance?: PrivacyProvider

  /** 模块标识 */
  private readonly module: string

  /** 缓存的设备标识 */
  private cachedDeviceId?: string

  private constructor(module: string) {
    this.module = module
  }

  /**
   * 初始化（首次调用时创建单例，后续调用忽略）
   */
  static init(module: string): void {
    if (!PrivacyProvider.instance) {
      PrivacyProvider.instance = new PrivacyProvider(module)
    }
  }

  /**
   * 获取全局单例（需先调用 init）
   */
  static getInstance(): PrivacyProvider {
    if (!PrivacyProvider.instance) {
      throw new Error('PrivacyProvider not initialized. Call PrivacyProvider.init(module) first.')
    }
    return PrivacyProvider.instance
  }

  /**
   * 设备标识（惰性，首次访问时才读取 ODID 并缓存）
   * 格式：MD5(ODID + "-" + module)
   */
  get id(): string {
    if (!this.cachedDeviceId) {
      this.cachedDeviceId = MD5.digestSync(deviceInfo.ODID + "-" + this.module)
    }
    return this.cachedDeviceId
  }

  /**
   * 设备名称（非隐私敏感，可直接读取）
   */
  get name(): string {
    return deviceInfo.marketName
  }
}
