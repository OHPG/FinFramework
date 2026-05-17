import { LogEntry } from './LogEntry'
import { LogLevel } from './LogLevel'
import { LogOutput } from './LogOutput'
import { formatLogEntry } from './LogFormatter'

export class ConsoleLogOutput implements LogOutput {
  write(entry: LogEntry): void {
    const formatted = formatLogEntry(entry)
    if (entry.level === LogLevel.ERROR) {
      console.error(formatted)
    } else if (entry.level === LogLevel.WARN) {
      console.warn(formatted)
    } else {
      console.info(formatted)
    }
  }
}
