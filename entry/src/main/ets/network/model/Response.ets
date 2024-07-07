export class Response<T> {
  errorCode: number = 0
  errorMsg: string = ""
  data?: T = undefined

  /**
   * 是否成功
   * @returns
   */
  isSuccess(): Boolean {
    return this.errorCode === 0
  }

  /**
   * 是否成功且有返回数据
   * @returns
   */
  isSuccessWithData(): boolean {
    return this.errorCode === 0 && this.data !== undefined
  }

  /**
   * 获取返回的数据
   * @returns
   */
  getDataOrThrow(): T {
    return this.data!
  }
}