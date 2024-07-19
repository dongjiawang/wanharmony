import { DateUtils } from '../common/DateUtils'
import { CoinModel } from '../network/model/CoinModel'

@Component
export struct MineCoinItemComponent {
  coin: CoinModel = new CoinModel()

  build() {
    Row() {
      Column() {
        Text(this.coin.reason)
          .fontSize(14)
          .fontColor($r("app.color.text_h1"))
          .padding({
            bottom: 5
          })

        Text(DateUtils.getDateTime(this.coin.date, "yyyy-MM-dd HH:mm:ss"))
          .fontSize(10)
          .fontColor($r("app.color.text_h2"))
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
      }
      .alignItems(HorizontalAlign.Start)

      Text("+" + this.coin.coinCount.toString())
        .fontSize(18)
        .fontColor($r("app.color.main"))
    }
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      top: 10,
      right: 16,
      bottom: 10
    })
  }
}