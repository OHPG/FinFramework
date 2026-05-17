import { LogLevel } from './LogLevel'

export interface LogFilter {
  enabledModules: string[]
  minLevel: LogLevel
}
