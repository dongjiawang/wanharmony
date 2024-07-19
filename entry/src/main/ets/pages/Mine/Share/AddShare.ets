import TitleLayout from '../../../widgets/TitleLayout';

@Entry
@Component
struct AddShare {
  @State message: string = 'Hello World';

  build() {
    Column() {
      TitleLayout({
        title: "分享文章"
      })
    }
    .height('100%')
    .width('100%')
  }
}