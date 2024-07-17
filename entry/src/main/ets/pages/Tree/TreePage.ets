import API from '../../network/API';
import { LoadState, PageLoading } from '../../widgets/PageLoading';
import TitleLayout from '../../widgets/TitleLayout';
import { Tree } from '../../network/model/Tree'
import { ListDataSource } from '../../network/model/ListDataSource';
import { TreeItemComponent } from './TreeItemComponent';

@Component
export struct TreePage {
  @State loadState: LoadState = LoadState.LOADING
  @State treeList: ListDataSource<Tree> = new ListDataSource()

  build() {
    Column() {
      TitleLayout({
        title: "体系",
        enableBack: false
      })

      PageLoading({
        loadState: this.loadState,
        showLoading: false,
        content: () => {
          this.listTreeBuilder()
        }
      })
    }
  }

  aboutToAppear(): void {
    this.loadTreeData()
  }

  private async loadTreeData() {
    const response = await API.getTree()
    if (response.isSuccessWithData()) {
      if (response.getDataOrThrow().length > 0) {
        this.loadState = LoadState.SUCCESS
        this.treeList.resetAllData(response.getDataOrThrow())
      } else {
        this.loadState = LoadState.EMPTY
      }
    } else {
      this.loadState = LoadState.FAIL
    }
  }

  @Builder
  private listTreeBuilder() {
    List() {
      LazyForEach(this.treeList, (item: Tree) => {
        ListItem() {
          TreeItemComponent({
            tree: item
          })
        }
      }, (item: Tree, index) => `${item.id} + ${index}`)
    }
    .cachedCount(5)
  }
}