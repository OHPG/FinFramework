import { LogEntry } from './LogEntry'

export interface LogOutput {
  write(entry: LogEntry): void
}

export type LogListener = (entry: LogEntry) => void
