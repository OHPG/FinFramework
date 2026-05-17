import { LogLevel, LogFilter } from '@ohpg/fin-core'
import { LengthMetrics } from '@kit.ArkUI'

interface LevelOption {
  level: LogLevel
  label: Resource
}

@Component
export struct LogFilterPanel {
  @Prop modules: string[] = []
  @Prop selectedModules: string[] = []
  @Prop selectedMinLevel: LogLevel = LogLevel.DEBUG
  onFilterChanged: (filter: LogFilter) => void = () => {}

  private readonly levelOptions: LevelOption[] = [
    { level: LogLevel.DEBUG, label: $r('app.string.log_level_debug') },
    { level: LogLevel.INFO, label: $r('app.string.log_level_info') },
    { level: LogLevel.WARN, label: $r('app.string.log_level_warn') },
    { level: LogLevel.ERROR, label: $r('app.string.log_level_error') }
  ]

  private isAllSelected(): boolean {
    if (this.modules.length === 0) {
      return false
    }
    for (let i = 0; i < this.modules.length; i++) {
      if (!this.selectedModules.includes(this.modules[i])) {
        return false
      }
    }
    return true
  }

  private notifyFilterChanged(newModules: string[], newLevel: LogLevel): void {
    const filter: LogFilter = {
      enabledModules: newModules,
      minLevel: newLevel
    }
    this.onFilterChanged(filter)
  }

  private toggleSelectAll(): void {
    if (this.isAllSelected()) {
      this.notifyFilterChanged([], this.selectedMinLevel)
    } else {
      const allModules: string[] = []
      for (let i = 0; i < this.modules.length; i++) {
        allModules.push(this.modules[i])
      }
      this.notifyFilterChanged(allModules, this.selectedMinLevel)
    }
  }

  private toggleModule(module: string): void {
    const newModules: string[] = []
    let found = false
    for (let i = 0; i < this.selectedModules.length; i++) {
      if (this.selectedModules[i] === module) {
        found = true
      } else {
        newModules.push(this.selectedModules[i])
      }
    }
    if (!found) {
      newModules.push(module)
    }
    this.notifyFilterChanged(newModules, this.selectedMinLevel)
  }

  private selectLevel(level: LogLevel): void {
    this.notifyFilterChanged(this.selectedModules, level)
  }

  build() {
    Column({ space: 12 }) {
      // Module filter section
      Row() {
        Text($r('app.string.log_filter_module'))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Blank()
        Text(this.isAllSelected() ? $r('app.string.log_deselect_all') : $r('app.string.log_select_all'))
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_primary'))
          .onClick(() => {
            this.toggleSelectAll()
          })
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.modules, (module: string) => {
          Row({ space: 4 }) {
            Checkbox()
              .select(this.selectedModules.includes(module))
              .onChange((checked: boolean) => {
                this.toggleModule(module)
              })
              .width(16)
              .height(16)
            Text(module)
              .fontSize(12)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
          }
        }, (module: string) => module)
      }
      .width('100%')

      // Level filter section
      Text($r('app.string.log_filter_level'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .width('100%')

      Row({ space: 8 }) {
        ForEach(this.levelOptions, (option: LevelOption) => {
          Text(option.label)
            .fontSize(12)
            .fontColor(this.selectedMinLevel === option.level ?
              $r('sys.color.ohos_id_color_text_primary_contrary') :
              $r('sys.color.ohos_id_color_text_primary'))
            .backgroundColor(this.selectedMinLevel === option.level ?
              $r('sys.color.ohos_id_color_primary') :
              $r('sys.color.ohos_id_color_button_normal'))
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              this.selectLevel(option.level)
            })
        }, (option: LevelOption) => option.level.toString())
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .borderRadius(12)
  }
}
