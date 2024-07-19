export class CoinModel {
  id: number = 0
  coinCount: number = 0
  desc: string = ""
  reason: string = ""
}

export class CoinList {
  curPage: number = 0
  datas: CoinModel[] = []
  offset: number = 0
  over: boolean = false
  pageCount: number = 0
  size: number = 0
  total: number = 0
}