import { LogLevel } from './LogLevel'
import { Logger } from './Logger'

export class ModuleLogger {
  private readonly tag: string
  private readonly logger: Logger

  constructor(tag: string, logger: Logger) {
    this.tag = tag
    this.logger = logger
  }

  debug(message: string): void {
    this.logger.log(this.tag, LogLevel.DEBUG, message)
  }

  info(message: string): void {
    this.logger.log(this.tag, LogLevel.INFO, message)
  }

  warn(message: string): void {
    this.logger.log(this.tag, LogLevel.WARN, message)
  }

  error(message: string): void {
    this.logger.log(this.tag, LogLevel.ERROR, message)
  }
}
