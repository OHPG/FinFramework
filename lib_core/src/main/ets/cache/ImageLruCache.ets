import { image } from "@kit.ImageKit";
import { LruCache } from "./LruCache";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/9/28 11:13
 * @Version V1.0
 * @Description: 
 */
export class ImageLruCache<T> extends LruCache<T, PixelMap>{

  protected sizeOf(key: T, value: image.PixelMap): number {
    return value.getPixelBytesNumber()
  }

}