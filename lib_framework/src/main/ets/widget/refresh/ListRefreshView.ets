import { AppModel } from "@ohpg/fin-core"
import { ListAttr, ListView, RefreshController } from '@abner/refresh';
import { CommonConstants } from "../../common/CommonConstants"
import { EmptyStateView } from "../state/EmptyStateView"
import { ErrorStateView } from "../state/ErrorStateView"
import { LoadingStateView } from "../state/LoadingStateView"
import { RefreshRepository } from "./RefreshRepository"
import { LoadHelper } from "./LoadHelper";

const DELETE_MENU_WIDTH = 72

@Component
export struct ListRefreshView {

  private controller = new RefreshController()

  @Require source?: RefreshRepository = undefined

  @BuilderParam
  itemLayout?: (item: ESObject, index: number) => void;

  listAttribute?: (attribute: ListAttr) => void;

  /**
   * 条目删除回调，传入条目数据和索引，返回 Promise。
   * 设置后自动启用横滑删除菜单。
   */
  onItemDelete?: (item: Object, index: number) => Promise<void>

  @State model: AppModel = new AppModel()

  private loader?: LoadHelper

  aboutToAppear(): void {
    this.loader= new LoadHelper(this.model, this.source!, this.controller)
    this.loader.load()
  }

  @Builder
  private errorStateBuilder() {
    ErrorStateView({
      onRetry: () => {
        this.loader?.load('Init')
      }
    })
  }

  @Builder
  private loadingStateBuilder() {
    LoadingStateView()
  }

  @Builder
  private emptyStateBuilder() {
    EmptyStateView()
  }

  @Builder
  private deleteMenuBuilder(index: number) {
    Row() {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontColor([Color.White])
        .fontSize(24)
    }
    .width(DELETE_MENU_WIDTH)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Red)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.handleDelete(index)
    })
  }

  private handleDelete(index: number) {
    let dataSource = this.source?.getDataSource()
    if (!dataSource || !this.onItemDelete) return
    let item = dataSource.getData(index)
    this.onItemDelete(item, index)
      .then(() => {
        dataSource!.deleteData(index)
      })
  }

  build() {
    ListView({
      lazyDataSource: this.source?.getDataSource(),
      controller: this.controller,
      enableRefresh: this.model.init,
      enableLoadMore: this.model.more,
      autoShowEmptyLayout: true,
      showErrorLayout: this.model.type === 'Init' && this.model.state === 'Fail',
      showLoadingLayout: this.model.type === 'Init' && this.model.state === 'Loading',
      loadingLayout: this.loadingStateBuilder,
      emptyLayout: this.emptyStateBuilder,
      errorLayout: () => {
        this.errorStateBuilder()
      },
      itemLayout: this.itemLayout,
      listAttribute: this.listAttribute,
      swipeRightMenuLayout: this.onItemDelete !== undefined
        ? (index: number) => { this.deleteMenuBuilder(index) }
        : undefined,
      swipeRightAreaDistance: this.onItemDelete !== undefined ? DELETE_MENU_WIDTH : undefined,
      onRefresh: () => this.loader?.load('Refresh'),
      onLoadMore: () => this.loader?.load("More")
    })
      .width(CommonConstants.FULL_PERCENT)
  }

  aboutToDisappear(): void {
    this.loader?.clear()
  }

}
