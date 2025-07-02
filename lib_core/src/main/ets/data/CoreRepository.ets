import { ClientInfo, DeviceInfo, Jellyfin,
  PlaybackProgressInfo,
  PlaybackStartInfo,
  PlaybackStopInfo,
  UserItemDataDto } from "@ohpg/jellyfin"
import { deviceInfo } from "@kit.BasicServicesKit"
import { bundleManager } from "@kit.AbilityKit"
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

  /**
   * Client info
   */
  protected readonly clientInfo: ClientInfo

  /**
   * Device info
   */
  protected readonly deviceInfo: DeviceInfo

  /**
   * Jellyfin api
   */
  protected jellyfin: Jellyfin

  /**
   * Jellyfin api tmp
   */
  protected jellyfinTmp: Jellyfin

  protected dataStore: DataStore

  protected activeInfo?: ActiveInfo

  constructor(context: Context, module: string) {
    this.context = context
    let info = bundleManager.getBundleInfoForSelfSync(bundleManager
      .BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    this.clientInfo = {
      name: module,
      version: info.versionName
    }
    this.deviceInfo = {
      // Same developer has same odid.
      id: MD5.digestSync(deviceInfo.ODID + "-" + module),
      name: deviceInfo.marketName
    }
    this.dataStore = new DataStore(context)
    this.jellyfin = new Jellyfin({
      clientInfo: this.clientInfo,
      deviceInfo: this.deviceInfo,
    })
    this.jellyfinTmp = new Jellyfin({
      clientInfo: this.clientInfo,
      deviceInfo: this.deviceInfo,
    })
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
    this.jellyfin.apiClient.updateServerInfo({address: activeInfo.addressInfo.address})
    this.jellyfin.apiClient.updateUserInfo({id: activeInfo.userInfo.userId, token: activeInfo.userInfo.accessToken})
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
    this.jellyfinTmp.apiClient.updateServerInfo({address: url})
    let systemInfo = await this.jellyfinTmp.getSystemApi().getPublicSystemInfo()
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
  public async authAccount(url: string, name: string, psw?: string): Promise<void> {
    this.jellyfinTmp.apiClient.updateServerInfo({address: url})

    // query server info
    let systemInfo = await this.jellyfinTmp.getSystemApi().getPublicSystemInfo()
    if (!systemInfo.StartupWizardCompleted) {
      throw new Error("Server startup wizard not complete.")
    }
    if (!systemInfo.Version || !VersionTool.isVersionAtLeast(systemInfo.Version, 10, 10)) {
      throw new Error("Server version must be 10.10.x or above.")
    }

    let preServer = await this.dataStore.queryServer(systemInfo.Id!)
    if (preServer) {
      throw new Error("Server already exists.")
    }

    let serverInfo: ServerInfo = {
      serverId: systemInfo.Id!,
      serverName: systemInfo.ServerName!,
      serverType: "Jellyfin"
    }
    let addressInfo: AddressInfo = {
      addressId: MD5.digestSync(url),
      address: url,
      serverId: systemInfo.Id!
    }

    // auth
    let authResult = await this.jellyfinTmp.getUserApi().authenticateUserByName({
      Username: name,
      Pw: psw
    })

    let userInfo: UserInfo = {
      userId: authResult.User!.Id!,
      userName: authResult.User!.Name!,
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
    this.jellyfinTmp.apiClient.updateServerInfo({address: this.activeInfo!.addressInfo.address})
    let authResult = await this.jellyfinTmp.getUserApi().authenticateUserByName({
      Username: name,
      Pw: psw
    })
    let userInfo: UserInfo = {
      userId: authResult.User!.Id!,
      userName: authResult.User!.Name!,
      serverId: authResult.ServerId!,
      accessToken: authResult.AccessToken!
    }
    await this.dataStore.insertUser(userInfo)
  }

  public markFavorite(id: string): Promise<UserItemDataDto> {
    return this.jellyfin.getUserLibraryApi().markFavoriteItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  public unmarkFavorite(id: string): Promise<UserItemDataDto> {
    return this.jellyfin.getUserLibraryApi().unmarkFavoriteItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  public markPlayed(id: string): Promise<UserItemDataDto> {
    return this.jellyfin.getPlayStateApi().markPlayedItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  public unmarkPlayed(id: string): Promise<UserItemDataDto> {
    return this.jellyfin.getPlayStateApi().markUnplayedItem({
      itemId: id,
      userId: this.activeInfo!.userInfo.userId
    })
  }

  public onPlaybackStart(itemId: string): Promise<void> {
    return this.jellyfin.getPlayStateApi().onPlaybackStart({itemId: itemId})
  }

  public onPlaybackUpdate(itemId: string, position: number, playing: boolean): Promise<void> {
    return this.jellyfin.getPlayStateApi().onPlaybackProgress({itemId: itemId, positionTicks: position, isPaused: !playing})
  }

  public onPlaybackStop(itemId: string, position: number): Promise<void> {
    return this.jellyfin.getPlayStateApi().onPlaybackStopped({itemId: itemId, positionTicks: position})
  }

  public playbackStart(info: PlaybackStartInfo): Promise<void> {
    return this.jellyfin.getPlayStateApi().reportPlaybackStart({
      playbackStartInfo: info
    })
  }

  public playbackUpdate(info: PlaybackProgressInfo): Promise<void> {
    return this.jellyfin.getPlayStateApi().reportPlaybackProgress({
      playbackProgressInfo: info
    })
  }

  public playbackStop(info: PlaybackStopInfo): Promise<void> {
    return this.jellyfin.getPlayStateApi().reportPlaybackStopped({
      playbackStopInfo: info
    })
  }

}