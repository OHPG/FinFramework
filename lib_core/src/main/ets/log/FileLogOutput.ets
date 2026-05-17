import fs from '@ohos.file.fs'
import common from '@ohos.app.ability.common'
import { LogEntry } from './LogEntry'
import { LogOutput } from './LogOutput'
import { formatLogEntry, getLogFileName } from './LogFormatter'

export class FileLogOutput implements LogOutput {
  private context: common.Context
  private logsDirCreated: boolean = false

  constructor(context: common.Context) {
    this.context = context
  }

  write(entry: LogEntry): void {
    try {
      const logsDir = this.context.filesDir + '/logs'
      if (!this.logsDirCreated) {
        try {
          fs.mkdirSync(logsDir, true)
        } catch (e) {
          // Directory may already exist, ignore
        }
        this.logsDirCreated = true
      }
      const fileName = getLogFileName(entry.timestamp)
      const filePath = logsDir + '/' + fileName
      const line = formatLogEntry(entry) + '\n'
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.APPEND)
      fs.writeSync(file.fd, line)
      fs.closeSync(file)
    } catch (e) {
      console.error('FileLogOutput write failed: ' + (e as Error).message)
    }
  }
}
