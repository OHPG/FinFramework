export class RingBuffer<T> {
  private data: (T | undefined)[]
  private head: number
  private count: number
  private capacity: number

  constructor(capacity: number) {
    this.capacity = capacity < 1 ? 1 : Math.floor(capacity)
    this.data = new Array<T | undefined>(this.capacity)
    this.head = 0
    this.count = 0
  }

  push(item: T): void {
    this.data[this.head] = item
    this.head = (this.head + 1) % this.capacity
    if (this.count < this.capacity) {
      this.count++
    }
  }

  toArray(): T[] {
    const result: T[] = []
    if (this.count === 0) {
      return result
    }
    const start = (this.head - this.count + this.capacity) % this.capacity
    for (let i = 0; i < this.count; i++) {
      const index = (start + i) % this.capacity
      result.push(this.data[index] as T)
    }
    return result
  }

  getCount(): number {
    return this.count
  }

  getCapacity(): number {
    return this.capacity
  }

  clear(): void {
    this.data = new Array<T | undefined>(this.capacity)
    this.head = 0
    this.count = 0
  }
}
