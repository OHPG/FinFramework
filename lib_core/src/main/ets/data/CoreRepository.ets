import { ActiveInfo } from "../entity/ActiveInfo"
import { DataStore } from "../store/DataStore"
import { ServerInfo } from "../entity/ServerInfo"
import { AddressInfo } from "../entity/AddressInfo"
import { UserInfo } from "../entity/UserInfo"
import { AppEventHub } from "../event/EventHub"
import { MD5 } from "../crypto/MD5"
import { AppEvents } from "../event/AppEvents"
import { AppStorageKeys } from "../cons/AppStorageKeys"
import { VersionTool } from "../tool/VersionTool"
import { FinApi } from "../api/FinApi"
import { ServerType } from "../entity/ServerType"
import { CoreFinApi } from "../api/FinApis"

/**
 * Fin core repository
 */
export abstract class CoreRepository {

  /**
   * Data store key
   */
  public static readonly REPOSITORY = "Repository"

  /**
   * Context info
   */
  protected readonly context: Context

  protected readonly finApiMapper: CoreFinApi

  /**
   * Fin api
   */
  protected finApi?: FinApi

  protected dataStore: DataStore

  protected activeInfo?: ActiveInfo

  constructor(context: Context, finApi: CoreFinApi) {
    this.context = context
    this.finApiMapper = finApi
    this.dataStore = new DataStore(context)
  }

  /**
   * Init active server and user
   * @returns
   */
  public async init(): Promise<void> {
    let activeInfo = await this.dataStore.queryActive()
    if (activeInfo) {
      this.initActiveInfo(activeInfo)
    }
  }

  private initActiveInfo(activeInfo: ActiveInfo): void {
    this.finApi = this.finApiMapper.activeFinApi(activeInfo)
    this.activeInfo = activeInfo
    this.onActiveInfoChanged()
    AppStorage.setOrCreate(AppStorageKeys.KEY_ACTIVE_INFO, activeInfo)
    AppEventHub.emit(AppEvents.EVENT_ACTIVE_INFO_CHANGED)
  }

  protected onActiveInfoChanged() {

  }

  public getActiveInfo(): ActiveInfo | undefined {
    return this.activeInfo
  }

  /**
   * get all server
   * @returns
   */
  public async getServers(): Promise<Array<ServerInfo>> {
    await this.dataStore.queryActive()
    return this.dataStore.queryAllServer()
  }

  /**
   * select server
   * @returns
   */
  public async selectServer(serverInfo: ServerInfo): Promise<void> {
    let addressArr = await this.dataStore.queryAllAddress(serverInfo.serverId)
    if (!addressArr || addressArr.length <= 0) {
      throw new Error("No match address.")
    }
    let userArr = await this.dataStore.queryAllUser(serverInfo.serverId)
    if (!userArr || userArr.length <= 0) {
      throw new Error("No match user.")
    }
    this.activeInfo!.serverInfo = serverInfo
    this.activeInfo!.addressInfo = addressArr[0]
    this.activeInfo!.userInfo = userArr[0]
    await this.dataStore.updateActive(this.activeInfo!)
    this.initActiveInfo(this.activeInfo!)
  }

  /**
   * delete server
   * @returns
   */
  public async deleteServer(serverInfo: ServerInfo): Promise<void> {
    await this.dataStore.deleteUserByServerId(serverInfo.serverId)
    await this.dataStore.deleteAddressByServerId(serverInfo.serverId)
    await this.dataStore.deleteServer(serverInfo.serverId)
  }

  /**
   * get all address
   * @returns
   */
  public async getAddresses(): Promise<Array<AddressInfo>> {
    if (this.activeInfo == undefined) {
      return []
    }
    return this.dataStore.queryAllAddress(this.activeInfo.serverInfo.serverId)
  }

  /**
   * verify address
   * @param url
   * @returns
   */
  public async addAddressByUrl(url: string): Promise<void> {
    let preAddress = await this.dataStore.queryAddress(this.activeInfo!.serverInfo.serverId, MD5.digestSync(url))
    if (preAddress) {
      throw new Error("Url already exists.")
    }
    let systemInfo = await this.finApi!.getPublicSystemInfo(url)
    if (systemInfo.Id === this.activeInfo!.serverInfo.serverId) {
      let addressInfo: AddressInfo = {
        address: url,
        addressId: MD5.digestSync(url),
        serverId: systemInfo.Id!
      }
      await this.dataStore.insertAddress(addressInfo)
      return
    }
    throw new Error("Unknown server.")
  }

  /**
   * select address
   * @param addressInfo
   * @returns
   */
  public async selectAddress(addressInfo: AddressInfo): Promise<void> {
    this.activeInfo!.addressInfo = addressInfo
    await this.dataStore.updateActive(this.activeInfo!)
    this.initActiveInfo(this.activeInfo!)
  }

  /**
   * delete address
   * @param addressInfo
   * @returns
   */
  public async deleteAddress(addressInfo: AddressInfo): Promise<void> {
    await this.dataStore.deleteAddress(addressInfo)
  }

  /**
   * get all user
   * @returns
   */
  public async getUsers(): Promise<Array<UserInfo>> {
    if (this.activeInfo == undefined) {
      return []
    }
    return this.dataStore.queryAllUser(this.activeInfo.serverInfo.serverId)
  }

  /**
   * select user
   * @param userInfo
   * @returns
   */
  public async selectUser(userInfo: UserInfo): Promise<void> {
    this.activeInfo!.userInfo = userInfo
    await this.dataStore.updateActive(this.activeInfo!)
    this.initActiveInfo(this.activeInfo!)
  }

  /**
   * delete user
   * @param userInfo
   * @returns
   */
  public async deleteUser(userInfo: UserInfo): Promise<void> {
    await this.dataStore.deleteUser(userInfo)
  }

  /**
   * auth account
   * @param name
   * @param psw
   * @returns
   */
  public async authAccount(type: ServerType, url: string, name: string, psw?: string): Promise<void> {
    let finApi = this.finApiMapper.getFinApi(type)
    let systemInfo = await finApi.getPublicSystemInfo(url)
    if (!systemInfo.StartupWizardCompleted) {
      throw new Error("Server startup wizard not complete.")
    }
    if (type === ServerType.JELLYFIN) {
      if (!systemInfo.Version || !VersionTool.isVersionAtLeast(systemInfo.Version, 10, 10)) {
        throw new Error("Server version must be 10.10.x or above.")
      }
    } else if (type === ServerType.EMBY) {
      // TODO 判断emby兼容最低的版本
    }

    let preServer = await this.dataStore.queryServer(systemInfo.Id!)
    if (preServer) {
      throw new Error("Server already exists.")
    }

    let serverInfo: ServerInfo = {
      serverId: systemInfo.Id!,
      serverName: systemInfo.ServerName!,
      serverType: type
    }
    let addressInfo: AddressInfo = {
      addressId: MD5.digestSync(url),
      address: url,
      serverId: systemInfo.Id!
    }

    // auth
    let authResult = await this.finApi!.authenticateUserByName(name, psw)

    let userInfo: UserInfo = {
      userId: authResult.UserId!,
      userName: authResult.UserName!,
      serverId: authResult.ServerId!,
      accessToken: authResult.AccessToken!
    }

    let activeInfo: ActiveInfo = { serverInfo: serverInfo, addressInfo: addressInfo, userInfo: userInfo}
    await this.dataStore.insertActive(activeInfo)
    this.initActiveInfo(activeInfo)
  }

  /**
   * Add account
   * @param name
   * @param psw
   * @returns
   */
  public async addAccount(name: string, psw?: string): Promise<void> {
    let authResult = await this.finApi!.authenticateUserByName(name, psw)
    let userInfo: UserInfo = {
      userId: authResult.UserId!,
      userName: authResult.UserName!,
      serverId: authResult.ServerId!,
      accessToken: authResult.AccessToken!
    }
    await this.dataStore.insertUser(userInfo)
  }

}