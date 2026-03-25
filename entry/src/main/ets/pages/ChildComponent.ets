// @Component
// struct ChildComponent {
//   @Prop countProp: number; // 单向绑定的Prop属性
//   @Link countLink: number; // 双向绑定的Link属性
//   @State localCount: number = 0; // 子组件本地状态
//
//   build() {
//     Column({ space: 15 }) {
//       // 显示区域
//       Text('子组件状态显示')
//         .fontSize(16)
//         .fontWeight(FontWeight.Medium)
//
//       Text(`接收的Prop: ${this.countProp}`)
//         .fontSize(14)
//         .fontColor('#666666')
//
//       Text(`接收的Link: ${this.countLink}`)
//         .fontSize(14)
//         .fontColor('#666666')
//
//       Text(`本地状态: ${this.localCount}`)
//         .fontSize(14)
//         .fontColor('#666666')
//
//       // 操作按钮区域
//       Column({ space: 8 }) {
//         Button('修改Prop（不允许）')
//           .onClick(() => {
//             // @Prop是单向绑定，此操作不会影响父组件
//             // 实际开发中应避免直接修改@Prop变量
//           })
//           .width('90%')
//           .backgroundColor('#FFA500')
//           .enabled(false) // 禁用按钮以示范@Prop的单向特性
//
//         Button('修改Link（双向同步）')
//           .onClick(() => {
//             this.countLink++; // 会同步到父组件的@State变量
//           })
//           .width('90%')
//           .backgroundColor('#007DFF')
//
//         Button('修改本地状态')
//           .onClick(() => {
//             this.localCount++; // 仅影响子组件本地状态
//           })
//           .width('90%')
//           .backgroundColor('#28A745')
//       }
//       .margin({ top: 10 })
//     }
//     .width('95%')
//     .padding(15)
//     .backgroundColor('#F8F9FA')
//     .borderRadius(12)
//     .margin({ top: 10, bottom: 10 })
//   }
// }