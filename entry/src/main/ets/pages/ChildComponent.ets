// 子组件 ChildComponent.ets
@Component
struct ChildComponent {
  // 将 @Prop 改为 @Link
  @Link countLink: number;

  build() {
    Column() {
      Text(`接收的Link: ${this.countLink}`)
      Button('直接修改Link')
        .onClick(() => {
          // 现在可以直接修改，修改会同步到父组件
          this.countLink += 1;
        })
    }
  }
}

// 父组件 PageA.ets
@Entry
@Component
struct PageA {
  @State countState: number = 0;

  build() {
    Column() {
      Text(`父组件Count: ${this.countState}`)
      // 传递状态时使用 $ 符号建立双向绑定
      ChildComponent({ countLink: $countState })
    }
  }
}