import fs from '@ohos.file.fs'

/**
 * @Author peerless2012
 * @Email peerless2012@126.com
 * @DateTime 2026/5/31
 * @Version V1.0
 * @Description 文件工具类
 */
export class FileTool {

  /**
   * 确保目录存在，不存在则递归创建
   * @param dir 目录路径
   */
  public static ensureDir(dir: string): void {
    try {
      fs.mkdirSync(dir, true)
    } catch (_) {
    }
  }

  /**
   * 判断文件是否存在
   * @param path 文件路径
   * @returns true 存在，false 不存在
   */
  public static exists(path: string): boolean {
    try {
      return fs.accessSync(path)
    } catch (_) {
      return false
    }
  }

  /**
   * 将文本内容写入文件（覆盖写入）
   * @param path 文件路径
   * @param content 文本内容
   */
  public static writeText(path: string, content: string): void {
    let file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC)
    fs.writeSync(file.fd, content)
    fs.closeSync(file)
  }

  /**
   * 获取目录总大小（字节），非递归
   * @param dir 目录路径
   * @returns 目录下所有文件的总大小
   */
  public static getDirSize(dir: string): number {
    try {
      let files = fs.listFileSync(dir)
      let total = 0
      for (let file of files) {
        try {
          let stat = fs.statSync(dir + '/' + file)
          total += stat.size
        } catch (_) {
        }
      }
      return total
    } catch (_) {
      return 0
    }
  }

  /**
   * 删除目录下所有文件（非递归）
   * @param dir 目录路径
   */
  public static clearDir(dir: string): void {
    try {
      let files = fs.listFileSync(dir)
      for (let file of files) {
        try {
          fs.unlinkSync(dir + '/' + file)
        } catch (_) {
        }
      }
    } catch (_) {
    }
  }
}
