import { LogLevel } from './LogLevel'

export interface LogEntry {
  timestamp: number
  module: string
  level: LogLevel
  message: string
}
