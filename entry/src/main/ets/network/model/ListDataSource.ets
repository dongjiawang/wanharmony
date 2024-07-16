import { BaseDataSource } from './BaseDataSource';

export class ListDataSource<T> extends BaseDataSource<T> {
  private dataArray: T[] = []

  public totalCount(): number {
    return this.dataArray.length
  }

  public getData(index: number): T {
    return this.dataArray[index]
  }

  public addData(index: number, data: T): void  {
    this.dataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  public pushData(data: T): void {
    this.dataArray.push(data)
    this.notifyDataAdd(this.dataArray.length - 1)
  }

  public deleteData(index: number): void {
    this.dataArray.slice(index, 1)
    this.notifyDataDelete(index)
  }

  public reloadData () {
    this.dataArray = [] // 不会引起状态变化
    // 必须通过DataChangeListener来更新
    this.notifyDataReload() // 重新加载数据
  }
}