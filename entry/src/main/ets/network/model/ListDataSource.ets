import { BaseDataSource } from './BaseDataSource';

export class ListDataSource<T> extends BaseDataSource<T> {
  dataArray: T[] = []

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
    this.dataArray.splice(index, 1)
    this.notifyDataDelete(index)
  }

  public clearData() {
    this.dataArray = [] // 不会引起状态变化
    // 必须通过DataChangeListener来更新
    this.notifyDataReload() // 重新加载数据
  }

  public resetAllData(datas: T[]) {
    this.dataArray = []
    this.dataArray.push(...datas)
    this.notifyDataReload()
  }

  public pushDataList(datas: T[]) {
    this.dataArray.push(...datas)
    this.notifyDataReload()
  }

  public reloadData() {
    // 必须通过DataChangeListener来更新
    this.notifyDataReload() // 重新加载数据
  }
}