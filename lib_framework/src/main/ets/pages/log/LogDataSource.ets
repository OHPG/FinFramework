import { LogEntry } from '@ohpg/fin-core'

export class LogDataSource implements IDataSource {
  private entries: LogEntry[] = []
  private listeners: DataChangeListener[] = []

  totalCount(): number {
    return this.entries.length
  }

  getData(index: number): LogEntry {
    return this.entries[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  updateEntries(entries: LogEntry[]): void {
    this.entries = entries
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i].onDataReloaded()
    }
  }
}
