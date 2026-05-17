import { LogEntry, LogLevel, LogFilter, LogListener, Logger,
  formatLogEntry, getLogFileName } from '@ohpg/fin-core'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { fileIo as fs, fileUri } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'
import { ToolBar } from '../../widget/bar/ToolBar'
import { FinPages } from '../FinPages'
import { LogDataSource } from './LogDataSource'
import { LogEntryItem } from './LogEntryItem'
import { LogFilterPanel } from './LogFilterPanel'

interface MenuItem {
  value: ResourceStr
  action: () => void
}

@Entry({ routeName: FinPages.PAGE_FIN_LOG })
@Component
struct LogPage {
  @State private logDataSource: LogDataSource = new LogDataSource()
  @State private filterVisible: boolean = false
  @State private selectedModules: string[] = []
  @State private selectedMinLevel: LogLevel = LogLevel.DEBUG
  @State private allModules: string[] = []
  @State private logEnabled: boolean = false
  private logger: Logger | undefined = undefined
  private logListener: LogListener = (_entry: LogEntry) => {
    this.refreshList()
  }

  aboutToAppear(): void {
    this.logger = AppStorage.get<Logger>(Logger.LOGGER_KEY)
    if (this.logger !== undefined) {
      this.logEnabled = this.logger.isEnabled()
      this.allModules = this.logger.getAllModules()
      this.selectedModules = this.getEnabledModules()
      this.selectedMinLevel = this.logger.getMinLevel()
      this.logger.addListener(this.logListener)
      this.refreshList()
    }
  }

  aboutToDisappear(): void {
    if (this.logger !== undefined) {
      this.logger.removeListener(this.logListener)
    }
  }

  private getEnabledModules(): string[] {
    if (this.logger === undefined) {
      return []
    }
    const modules = this.logger.getAllModules()
    const enabled: string[] = []
    for (let i = 0; i < modules.length; i++) {
      if (this.logger.isModuleEnabled(modules[i])) {
        enabled.push(modules[i])
      }
    }
    return enabled
  }

  private refreshList(): void {
    if (this.logger === undefined) {
      return
    }
    this.allModules = this.logger.getAllModules()
    const filter: LogFilter = {
      enabledModules: this.selectedModules,
      minLevel: this.selectedMinLevel
    }
    const entries = this.logger.query(filter)
    this.logDataSource.updateEntries(entries.reverse())
  }

  private onFilterChanged(filter: LogFilter): void {
    this.selectedModules = filter.enabledModules
    this.selectedMinLevel = filter.minLevel
    this.filterVisible = false
    this.refreshList()
  }

  private onToggleLogging(): void {
    if (this.logger === undefined) {
      return
    }
    const isOn = !this.logEnabled
    this.logEnabled = isOn
    this.logger.setEnabled(isOn)
    if (isOn) {
      const modules = this.logger.getAllModules()
      for (let i = 0; i < modules.length; i++) {
        this.logger.enableModule(modules[i])
      }
      this.logger.setMinLevel(LogLevel.DEBUG)
      this.selectedModules = modules.slice()
      this.selectedMinLevel = LogLevel.DEBUG
    }
    this.refreshList()
  }

  private async exportLogs(): Promise<void> {
    try {
      if (this.logger === undefined) {
        return
      }
      const filter: LogFilter = {
        enabledModules: this.selectedModules,
        minLevel: this.selectedMinLevel
      }
      const entries = this.logger.query(filter)
      if (entries.length === 0) {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.log_export_empty') })
        return
      }
      const lines: string[] = []
      for (let i = 0; i < entries.length; i++) {
        lines.push(formatLogEntry(entries[i]))
      }
      const content = lines.join('\n')
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      const fileName = getLogFileName(Date.now())
      const exportPath = context.cacheDir + '/' + fileName
      const file = fs.openSync(exportPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC)
      fs.writeSync(file.fd, content)
      fs.closeSync(file)

      const uri = fileUri.getUriFromPath(exportPath)
      const record: systemShare.SharedRecord = {
        utd: utd.UniformDataType.PLAIN_TEXT,
        uri: uri,
        title: fileName
      }
      const shareData: systemShare.SharedData = new systemShare.SharedData(record)
      const controller: systemShare.ShareController = new systemShare.ShareController(shareData)
      await controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      })
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.log_export_fail') })
    }
  }

  private showMenu(): void {
    const toggleLabel: ResourceStr = this.logEnabled ?
      $r('app.string.log_action_disable') : $r('app.string.log_action_enable')
    const menuItems: MenuItem[] = [
      { value: toggleLabel, action: () => this.onToggleLogging() },
      { value: $r('app.string.log_action_filter'), action: () => { this.filterVisible = !this.filterVisible } },
      { value: $r('app.string.log_action_export'), action: () => this.exportLogs() }
    ]
    promptAction.showActionMenu({
      title: $r('app.string.log_action_title'),
      buttons: [
        { text: menuItems[0].value, color: $r('sys.color.ohos_id_color_text_primary') },
        { text: menuItems[1].value, color: $r('sys.color.ohos_id_color_text_primary') },
        { text: menuItems[2].value, color: $r('sys.color.ohos_id_color_text_primary') }
      ]
    }).then((result) => {
      if (result.index >= 0 && result.index < menuItems.length) {
        menuItems[result.index].action()
      }
    }).catch(() => {})
  }

  build() {
    Stack() {
      Column() {
        ToolBar({ title: $r('app.string.log_page_title') }) {
          Text($r('app.string.log_menu_more'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.showMenu()
            })
        }

        List() {
          LazyForEach(this.logDataSource, (entry: LogEntry) => {
            ListItem() {
              LogEntryItem({ entry: entry })
            }
          }, (entry: LogEntry) => entry.timestamp.toString() + entry.module + entry.message)
        }
        .width('100%')
        .layoutWeight(1)
        .contentStartOffset(8)
        .contentEndOffset(8)
        .alignListItem(ListItemAlign.Start)
        .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_list_separator') })
      }
      .width('100%')
      .height('100%')

      // Filter panel as overlay
      Column() {
        LogFilterPanel({
          modules: this.allModules,
          selectedModules: this.selectedModules,
          selectedMinLevel: this.selectedMinLevel,
          onFilterChanged: (filter: LogFilter) => {
            this.onFilterChanged(filter)
          }
        })
        .margin(16)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .visibility(this.filterVisible ? Visibility.Visible : Visibility.Hidden)
      .onClick(() => {
        this.filterVisible = false
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }
}
