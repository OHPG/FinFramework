import { LogEntry, LogLevel } from '@ohpg/fin-core'

@Reusable
@Component
export struct LogEntryItem {
  @Prop entry: LogEntry

  aboutToReuse(params: Record<string, Object>): void {
    this.entry = params['entry'] as LogEntry
  }

  private getLevelColor(): Resource {
    switch (this.entry.level) {
      case LogLevel.ERROR:
        return $r('sys.color.ohos_id_color_warning')
      case LogLevel.WARN:
        return $r('sys.color.ohos_id_color_warning')
      case LogLevel.INFO:
        return $r('sys.color.ohos_id_color_text_primary')
      case LogLevel.DEBUG:
        return $r('sys.color.ohos_id_color_text_secondary')
      default:
        return $r('sys.color.ohos_id_color_text_primary')
    }
  }

  private getLevelText(): Resource {
    switch (this.entry.level) {
      case LogLevel.ERROR:
        return $r('app.string.log_level_error')
      case LogLevel.WARN:
        return $r('app.string.log_level_warn')
      case LogLevel.INFO:
        return $r('app.string.log_level_info')
      case LogLevel.DEBUG:
        return $r('app.string.log_level_debug')
      default:
        return $r('app.string.log_level_info')
    }
  }

  private getWarnOpacity(): number {
    if (this.entry.level === LogLevel.WARN) {
      return 0.7
    }
    return 1.0
  }

  private formatTimestamp(): string {
    const date = new Date(this.entry.timestamp)
    const h = date.getHours().toString().padStart(2, '0')
    const m = date.getMinutes().toString().padStart(2, '0')
    const s = date.getSeconds().toString().padStart(2, '0')
    const ms = date.getMilliseconds().toString().padStart(3, '0')
    return `${h}:${m}:${s}.${ms}`
  }

  build() {
    Column({ space: 4 }) {
      Row({ space: 8 }) {
        Text(this.formatTimestamp())
          .fontSize(11)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        Text(this.entry.module)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        Text(this.getLevelText())
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getLevelColor())
          .opacity(this.getWarnOpacity())
      }
      .width('100%')

      Text(this.entry.message)
        .fontSize(13)
        .fontColor(this.getLevelColor())
        .opacity(this.getWarnOpacity())
        .width('100%')
        .maxLines(3)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }
}
