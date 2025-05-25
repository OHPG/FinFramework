import { router } from "@kit.ArkUI";
import { FinPages } from "./FinPages";

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2025/3/18 21:43
 * @Version V1.0
 * @Description Fin router
 */
export class FinRouter {

  /**
   * Add server
   * @returns
   */
  public static async auth(replace?: boolean): Promise<void> {
    await import ("./auth/AuthPage")
    if (replace) {
      await router.replaceNamedRoute({name: FinPages.PAGE_FIN_ADD_SERVER})
    } else {
      await router.pushNamedRoute({name: FinPages.PAGE_FIN_ADD_SERVER})
    }
  }

  /**
   * Edit server
   * @returns
   */
  public static async editServer(): Promise<void> {
    await import ("./edit/server/EditServerPage")
    await router.pushNamedRoute({name: FinPages.PAGE_FIN_EDIT_SERVER})
  }

  /**
   * Edit address
   * @returns
   */
  public static async editAddress(): Promise<void> {
    await import ('./edit/address/EditAddressPage')
    await router.pushNamedRoute({name: FinPages.PAGE_FIN_EDIT_ADDRESS})
  }

  /**
   * Edit user
   * @returns
   */
  public static async editUser(): Promise<void> {
    await import ('./edit/user/EditUserPage')
    await router.pushNamedRoute({name: FinPages.PAGE_FIN_EDIT_USER})
  }

}