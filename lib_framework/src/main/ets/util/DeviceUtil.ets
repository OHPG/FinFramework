import { window } from "@kit.ArkUI";
import { Constants } from "../cons/Constants";
import { BusinessError } from "@kit.BasicServicesKit";
import hilog from "@ohos.hilog";
import { audio } from "@kit.AudioKit";
const TAG = 'DeviceUtil';

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/4/26 20:46
 * @Version V1.0
 * @Description
 */
export class DeviceUtil {

  private static readonly DEFAULT_BRIGHTNESS: number = -1;

  private static readonly MAX_BRIGHTNESS: number = 1;

  private static windowClass: window.Window | undefined = undefined;

  public static MAX_VOLUME = 15

  public static BRIGHTNESS = -1

  /**
   * init windowClass
   *
   * @param windowClass Window object
   */
  public static initWindow(windowClass?: window.Window) {
    DeviceUtil.windowClass = windowClass;
    DeviceUtil.MAX_VOLUME = DeviceUtil.getMaxVolume()
  }

  public static getBrightness(): number {
    let brightness = DeviceUtil.windowClass?.getWindowProperties().brightness
    if (brightness === undefined) {
      brightness = 0
    }
    return brightness
  }

  /**
   * Set brightness
   *
   * @param brightness Page key cached in brightness map | brightness
   * @param setMode There are two modes for setting brightness based on business differentiation.
   * 0: Enter the page or return to the homepage to set the brightness once, and read the page brightness from the map;
   * 1: Continuous sliding adjustment of brightness on video page
   */
  public static setBrightness(brightness: number): void {
    try {
      DeviceUtil.windowClass?.setWindowBrightness(brightness as number);
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed Set brightness, errorCode: ${err.code}`);
    }
  }

  public static saveBrightness(): void {
    DeviceUtil.BRIGHTNESS = DeviceUtil.getBrightness()
    DeviceUtil.setBrightness(-1)
  }

  public static restoreBrightness(): void {
    DeviceUtil.setBrightness(DeviceUtil.BRIGHTNESS)
  }

  /**
   * Keep screen brightness
   *
   * @param isKeepOn true：keep；false:cancel keep
   */
  public static setWindowKeepScreenState(isKeepOn: boolean): void {
    try {
      DeviceUtil.windowClass?.setWindowKeepScreenOn(isKeepOn, (err: BusinessError) => {
        const errCode: number = err.code;
        if (errCode) {
          hilog.error(0x0000, TAG, `Failed set window keep screen state, errorCode: ${err.code}`);
          return;
        }
        hilog.info(0x0000, TAG, `Success set window keep screen state`);
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed set window keep screen state, errorCode: ${err.code}`);
    }
  }

  /**
   * Set the font color of the status bar
   *
   * @param name Page name
   * @param colorRes Font color of status bar
   */
  public static setStateBarContentColor(name: string, colorRes: string): void {
    if (name !== Constants.NAV_DESTINATION_ITEM_PAY_CODE) {
      return;
    }
    let sysBarPros: window.SystemBarProperties = {
      statusBarContentColor: colorRes
    }
    try {
      DeviceUtil.windowClass?.setWindowSystemBarProperties(sysBarPros).then(() => {
        hilog.info(0x0000, TAG, `Success set window systemBar content color`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `Failed set window systemBar content color, errorCode:${err.code}`);
      })
    } catch (err) {
      hilog.error(0x0000, TAG, `Success set window systemBar content color, errorCode:${err.code}`);
    }
  }

  public static getVolume(): number {
    let audioManager = audio.getAudioManager();
    let audioVolumeManager = audioManager.getVolumeManager();
    let gm = audioVolumeManager.getVolumeGroupManagerSync(audio.DEFAULT_VOLUME_GROUP_ID)
    return gm.getVolumeSync(audio.AudioVolumeType.MEDIA)
  }

  private static getMaxVolume(): number {
    let audioManager = audio.getAudioManager();
    let audioVolumeManager = audioManager.getVolumeManager();
    let gm = audioVolumeManager.getVolumeGroupManagerSync(audio.DEFAULT_VOLUME_GROUP_ID)
    return gm.getMaxVolumeSync(audio.AudioVolumeType.MEDIA)
  }

}