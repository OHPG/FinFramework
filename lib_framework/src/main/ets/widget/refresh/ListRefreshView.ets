import { AppEventHub, AppEvents, AppModel } from "@ohpg/fin-core"
import { LoadType } from "@ohpg/fin-core"
import { ListAttr, ListView, RefreshController } from '@abner/refresh';
import { CommonConstants } from "../../common/CommonConstants"
import { emptyStateViewBuilder } from "../state/EmptyStateView"
import { ErrorStateView } from "../state/ErrorStateView"
import { loadStateBuilder } from "../state/LoadStateView"
import { RefreshRepository } from "./RefreshRepository"

@Component
export struct ListRefreshView {

  private controller = new RefreshController()

  @Require source?: RefreshRepository = undefined

  @BuilderParam
  itemLayout?: (item: ESObject, index: number) => void;

  listAttribute?: (attribute: ListAttr) => void;

  @State model: AppModel = new AppModel()

  private activeInfoChanged = () => {
    this.loadData('Refresh')
  }

  aboutToAppear(): void {
    this.loadData()
    AppEventHub.on(AppEvents.EVENT_ACTIVE_INFO_CHANGED, this.activeInfoChanged)
  }

  @Builder
  private errorStateBuilder() {
    ErrorStateView({
      callback: () => {
        this.loadData('Init')
      }
    })
  }

  build() {
    ListView({
      lazyDataSource: this.source?.getDataSource(),
      controller: this.controller,
      enableRefresh: this.model.init,
      enableLoadMore: false,
      autoShowEmptyLayout: true,
      showErrorLayout: this.model.type === 'Init' && this.model.state === 'Fail',
      showLoadingLayout: this.model.type === 'Init' && this.model.state === 'Loading',
      loadingLayout: loadStateBuilder,
      emptyLayout: emptyStateViewBuilder,
      errorLayout: () => {
        this.errorStateBuilder()
      },
      itemLayout: this.itemLayout,
      listAttribute: this.listAttribute,
      onRefresh: () => this.loadData('Refresh')
    })
      .width(CommonConstants.FULL_PERCENT)
  }

  private loadData(type: LoadType = "Init") {
    this.model.type = type
    this.model.state = 'Loading'
    this.source?.loadData(type)
      .then(() => {
        if (!this.model.init) {
          this.model.init = true
        }
        this.model.state = 'Success'
        this.controller.finishRefresh()
      })
      .catch((error: Error) => {
        this.model.state = 'Fail'
        this.controller.finishRefresh()
      })
  }

  aboutToDisappear(): void {
    AppEventHub.off(AppEvents.EVENT_ACTIVE_INFO_CHANGED)
  }

}