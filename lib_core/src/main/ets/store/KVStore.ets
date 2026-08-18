import { ArkTSUtils } from "@kit.ArkTS";
import { distributedKVStore } from "@kit.ArkData";

export class KVStore {

  private readonly lock: ArkTSUtils.locks.AsyncLock

  private readonly config: distributedKVStore.KVManagerConfig

  private readonly name: string

  private kvManager?: distributedKVStore.KVManager

  private kvStore?: distributedKVStore.SingleKVStore

  constructor(context: Context, name: string) {
    this.config = {
      context: context,
      bundleName: context.applicationInfo.name
    }
    this.name = name
    this.lock = ArkTSUtils.locks.AsyncLock.request("KVStore_" + name)
  }

  public async getKVStore(): Promise<distributedKVStore.SingleKVStore> {
    return this.lock.lockAsync(async () => {
      if (this.kvStore) {
        return this.kvStore
      }
      if (!this.kvManager) {
        this.kvManager = distributedKVStore.createKVManager(this.config)
      }
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: false,
        // kvStoreType不填时，默认创建多设备协同数据库
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        // 多设备协同数据库：kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        securityLevel: distributedKVStore.SecurityLevel.S2
      };
      this.kvStore = await this.kvManager.getKVStore(this.name, options)
      return this.kvStore
    })
  }

  public async putString(key: string, value: string): Promise<void> {
    let kvStore = await this.getKVStore()
    await kvStore.put(key, value)
  }

  public async getString(key: string): Promise<string> {
    let kvStore = await this.getKVStore()
    let value = await kvStore.get(key)
    return value as string
  }

  public async delete(key: string): Promise<void> {
    let kvStore = await this.getKVStore()
    await kvStore.delete(key)
  }

}