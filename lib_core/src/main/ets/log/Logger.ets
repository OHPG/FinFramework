import { AppStorageKeys } from '../cons/AppStorageKeys'
import { LogLevel } from './LogLevel'
import { LogEntry } from './LogEntry'
import { LogFilter } from './LogFilter'
import { LogOutput, LogListener } from './LogOutput'
import { RingBuffer } from './RingBuffer'
import { ModuleLogger } from './ModuleLogger'

export class Logger {
  static readonly LOGGER_KEY: string = AppStorageKeys.KEY_LOGGER
  static readonly DEFAULT_BUFFER_CAPACITY: number = 1000

  private enabled: boolean
  private outputs: LogOutput[]
  private buffer: RingBuffer<LogEntry>
  private listeners: LogListener[]
  private minLevel: LogLevel
  private enabledModules: Set<string>
  private allModules: string[]
  private debugMode: boolean
  private moduleLoggers: Map<string, ModuleLogger>

  constructor(bufferCapacity: number, debugMode: boolean) {
    this.debugMode = debugMode
    this.outputs = []
    this.buffer = new RingBuffer<LogEntry>(bufferCapacity)
    this.listeners = []
    this.enabledModules = new Set<string>()
    this.allModules = []
    this.moduleLoggers = new Map<string, ModuleLogger>()

    if (debugMode) {
      this.enabled = true
      this.minLevel = LogLevel.DEBUG
    } else {
      this.enabled = false
      this.minLevel = LogLevel.INFO
    }
  }

  log(module: string, level: LogLevel, message: string): void {
    if (!this.enabled) {
      return
    }
    if (level < this.minLevel) {
      return
    }
    if (!this.enabledModules.has(module)) {
      return
    }

    const entry: LogEntry = {
      timestamp: Date.now(),
      module: module,
      level: level,
      message: message
    }

    this.buffer.push(entry)

    for (let i = 0; i < this.outputs.length; i++) {
      try {
        this.outputs[i].write(entry)
      } catch (e) {
        // Single output failure must not affect other outputs
      }
    }

    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i](entry)
    }
  }

  debug(module: string, message: string): void {
    this.log(module, LogLevel.DEBUG, message)
  }

  info(module: string, message: string): void {
    this.log(module, LogLevel.INFO, message)
  }

  warn(module: string, message: string): void {
    this.log(module, LogLevel.WARN, message)
  }

  error(module: string, message: string): void {
    this.log(module, LogLevel.ERROR, message)
  }

  getLogger(tag: string): ModuleLogger {
    let moduleLogger = this.moduleLoggers.get(tag)
    if (moduleLogger !== undefined) {
      return moduleLogger
    }
    this.registerModule(tag)
    moduleLogger = new ModuleLogger(tag, this)
    this.moduleLoggers.set(tag, moduleLogger)
    return moduleLogger
  }

  addOutput(output: LogOutput): void {
    this.outputs.push(output)
  }

  setMinLevel(level: LogLevel): void {
    this.minLevel = level
  }

  getMinLevel(): LogLevel {
    return this.minLevel
  }

  setEnabled(enabled: boolean): void {
    this.enabled = enabled
  }

  isEnabled(): boolean {
    return this.enabled
  }

  registerModule(module: string): void {
    if (!this.allModules.includes(module)) {
      this.allModules.push(module)
    }
    if (this.debugMode) {
      this.enabledModules.add(module)
    }
  }

  enableModule(module: string): void {
    this.enabledModules.add(module)
  }

  disableModule(module: string): void {
    this.enabledModules.delete(module)
  }

  isModuleEnabled(module: string): boolean {
    return this.enabledModules.has(module)
  }

  getAllModules(): string[] {
    return this.allModules
  }

  query(filter: LogFilter): LogEntry[] {
    const all: LogEntry[] = this.buffer.toArray()
    const result: LogEntry[] = []
    for (let i = 0; i < all.length; i++) {
      const entry: LogEntry = all[i]
      if (entry.level >= filter.minLevel && filter.enabledModules.includes(entry.module)) {
        result.push(entry)
      }
    }
    return result
  }

  addListener(listener: LogListener): void {
    this.listeners.push(listener)
  }

  removeListener(listener: LogListener): void {
    const index = this.listeners.indexOf(listener)
    if (index >= 0) {
      this.listeners.splice(index, 1)
    }
  }
}
