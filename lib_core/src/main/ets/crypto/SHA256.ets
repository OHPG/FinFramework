import { Cipher } from "./Cipher"
import { cryptoFramework } from "@kit.CryptoArchitectureKit"
import { buffer } from '@kit.ArkTS'

/**
 * SHA-256 digest utility.
 *
 * Used by dandanplay open platform signature:
 *   base64(sha256(AppId + Timestamp + Path + AppSecret))
 */
export class SHA256 extends Cipher {

  /**
   * SHA-256 digest, returns hex string (lowercase).
   */
  public static async digest(str: string): Promise<string> {
    let md = cryptoFramework.createMd("SHA256")
    await md.update({ data: SHA256.stringToUint8Array(str) })
    let bytes = (await md.digest()).data
    return SHA256.uint8ArrayToHexString(bytes)
  }

  /**
   * SHA-256 digest, returns hex string (lowercase). Synchronous version.
   */
  public static digestSync(str: string): string {
    let md = cryptoFramework.createMd("SHA256")
    md.updateSync({ data: SHA256.stringToUint8Array(str) })
    let bytes = md.digestSync().data
    return SHA256.uint8ArrayToHexString(bytes)
  }

  /**
   * SHA-256 digest, returns base64 string.
   * Used for dandanplay signature: base64(sha256(...)).
   */
  public static async digestBase64(str: string): Promise<string> {
    let md = cryptoFramework.createMd("SHA256")
    await md.update({ data: SHA256.stringToUint8Array(str) })
    let bytes = (await md.digest()).data
    return buffer.from(bytes).toString('base64')
  }

  /**
   * SHA-256 digest, returns base64 string. Synchronous version.
   */
  public static digestBase64Sync(str: string): string {
    let md = cryptoFramework.createMd("SHA256")
    md.updateSync({ data: SHA256.stringToUint8Array(str) })
    let bytes = md.digestSync().data
    return buffer.from(bytes).toString('base64')
  }

}
