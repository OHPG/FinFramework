import { LogEntry } from './LogEntry'
import { LogLevel } from './LogLevel'

const LEVEL_NAMES: string[] = ['DEBUG', 'INFO', 'WARN', 'ERROR']

function padZero(value: number, length: number): string {
  let result = value.toString()
  while (result.length < length) {
    result = '0' + result
  }
  return result
}

function formatTimestamp(timestamp: number): string {
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = padZero(date.getMonth() + 1, 2)
  const day = padZero(date.getDate(), 2)
  const hours = padZero(date.getHours(), 2)
  const minutes = padZero(date.getMinutes(), 2)
  const seconds = padZero(date.getSeconds(), 2)
  const millis = padZero(date.getMilliseconds(), 3)
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${millis}`
}

export function formatLogEntry(entry: LogEntry): string {
  const ts = formatTimestamp(entry.timestamp)
  const levelName = LEVEL_NAMES[entry.level] ?? 'UNKNOWN'
  return `[${ts}] [${entry.module}] [${levelName}] ${entry.message}`
}

export function parseLogEntry(line: string): LogEntry {
  // Format: [YYYY-MM-DD HH:mm:ss.SSS] [ModuleTag] [LEVEL] message
  const timestampStart = line.indexOf('[')
  const timestampEnd = line.indexOf(']', timestampStart)
  const tsStr = line.substring(timestampStart + 1, timestampEnd)

  const moduleStart = line.indexOf('[', timestampEnd + 1)
  const moduleEnd = line.indexOf(']', moduleStart)
  const moduleTag = line.substring(moduleStart + 1, moduleEnd)

  const levelStart = line.indexOf('[', moduleEnd + 1)
  const levelEnd = line.indexOf(']', levelStart)
  const levelStr = line.substring(levelStart + 1, levelEnd)

  const message = line.substring(levelEnd + 2) // skip '] '

  const levelIndex = LEVEL_NAMES.indexOf(levelStr)
  const level: LogLevel = levelIndex >= 0 ? levelIndex as LogLevel : LogLevel.INFO

  const parts = tsStr.split(' ')
  const dateParts = parts[0].split('-')
  const timeParts = parts[1].split(':')
  const secAndMillis = timeParts[2].split('.')

  const year = parseInt(dateParts[0])
  const month = parseInt(dateParts[1]) - 1
  const day = parseInt(dateParts[2])
  const hours = parseInt(timeParts[0])
  const minutes = parseInt(timeParts[1])
  const seconds = parseInt(secAndMillis[0])
  const millis = parseInt(secAndMillis[1])

  const date = new Date(year, month, day, hours, minutes, seconds, millis)

  const entry: LogEntry = {
    timestamp: date.getTime(),
    module: moduleTag,
    level: level,
    message: message
  }
  return entry
}

export function getLogFileName(timestamp: number): string {
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = padZero(date.getMonth() + 1, 2)
  const day = padZero(date.getDate(), 2)
  return `log_${year}-${month}-${day}.txt`
}
