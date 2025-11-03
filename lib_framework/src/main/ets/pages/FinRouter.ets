import { ServerType } from "@ohpg/fin-core";
import { AuthParam } from "./auth/AuthParam";
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
  public static async auth(context: UIContext, type: ServerType, replace?: boolean): Promise<void> {
    await import ("./auth/AuthPage")
    let router = context.getRouter()
    let param: AuthParam = {
      type: type
    }
    if (replace) {
      await router.replaceNamedRoute({name: FinPages.PAGE_FIN_ADD_SERVER, params: param})
    } else {
      await router.pushNamedRoute({name: FinPages.PAGE_FIN_ADD_SERVER, params: param})
    }
  }

  /**
   * Edit server
   * @returns
   */
  public static async editServer(context: UIContext): Promise<void> {
    await import ("./edit/server/EditServerPage")
    let router = context.getRouter()
    await router.pushNamedRoute({name: FinPages.PAGE_FIN_EDIT_SERVER})
  }

  /**
   * Edit address
   * @returns
   */
  public static async editAddress(context: UIContext): Promise<void> {
    await import ('./edit/address/EditAddressPage')
    let router = context.getRouter()
    await router.pushNamedRoute({name: FinPages.PAGE_FIN_EDIT_ADDRESS})
  }

  /**
   * Edit user
   * @returns
   */
  public static async editUser(context: UIContext): Promise<void> {
    await import ('./edit/user/EditUserPage')
    let router = context.getRouter()
    await router.pushNamedRoute({name: FinPages.PAGE_FIN_EDIT_USER})
  }

}