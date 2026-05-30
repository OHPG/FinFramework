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
}
