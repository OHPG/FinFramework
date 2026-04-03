import { AppModel } from "@ohpg/fin-core"
import { ListAttr, ListView, RefreshController } from '@abner/refresh';
import { CommonConstants } from "../../common/CommonConstants"
import { EmptyStateView } from "../state/EmptyStateView"
import { ErrorStateView } from "../state/ErrorStateView"
import { LoadingStateView } from "../state/LoadingStateView"
import { RefreshRepository } from "./RefreshRepository"
import { LoadHelper } from "./LoadHelper";

@Component
export struct ListRefreshView {

  private controller = new RefreshController()

  @Require source?: RefreshRepository = undefined

  @BuilderParam
  itemLayout?: (item: ESObject, index: number) => void;

  listAttribute?: (attribute: ListAttr) => void;

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
      onRefresh: () => this.loader?.load('Refresh'),
      onLoadMore: () => this.loader?.load("More")
    })
      .width(CommonConstants.FULL_PERCENT)
  }

  aboutToDisappear(): void {
    this.loader?.clear()
  }

}