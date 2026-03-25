@Component
export struct SettingsPage {
  @State notificationsEnabled: boolean = true;
  @State temperatureUnit: string = 'celsius';
  @State userName: string = '农场管理员';
  @State farmName: string = '阳光农场';

  build() {
    Scroll() {
      Column() {
        // 用户设置
        this.BuildUserSettings()

        // 应用设置
        this.BuildAppSettings()

        // 关于应用
        this.BuildAboutSection()
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FBF8')
  }

  @Builder
  BuildUserSettings() {
    Column() {
      Text('用户设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      this.BuildSettingItem('👤', '用户名称', this.userName, () => {
        console.log('修改用户名称');
      })

      this.BuildSettingItem('🌾', '农场名称', this.farmName, () => {
        console.log('修改农场名称');
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .margin({ bottom: 16 })
  }

  @Builder
  BuildAppSettings() {
    Column() {
      Text('应用设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      // 通知开关
      Row() {
        Text('🔔')
          .fontSize(16)
          .margin({ right: 12 })

        Text('推送通知')
          .fontSize(16)
          .fontColor('#2D4D2D')
          .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.notificationsEnabled })
          .onChange((value: boolean) => {
            this.notificationsEnabled = value;
            console.log('通知设置:', value ? '开启' : '关闭');
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })

      Divider()
        .strokeWidth(1)
        .color('#F0F0F0')

      // 温度单位
      Row() {
        Text('🌡️')
          .fontSize(16)
          .margin({ right: 12 })

        Text('温度单位')
          .fontSize(16)
          .fontColor('#2D4D2D')
          .layoutWeight(1)

        Text(this.temperatureUnit === 'celsius' ? '摄氏度' : '华氏度')
          .fontSize(14)
          .fontColor('#666666')
          .onClick(() => {
            this.temperatureUnit = this.temperatureUnit === 'celsius' ? 'fahrenheit' : 'celsius';
            console.log('温度单位:', this.temperatureUnit);
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .margin({ bottom: 16 })
  }

  @Builder
  BuildAboutSection() {
    Column() {
      Text('关于应用')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D4D2D')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      this.BuildAboutItem('📱', '版本信息', 'v1.0.0')
      this.BuildAboutItem('🏢', '开发团队', '智慧农业团队')
      this.BuildAboutItem('📧', '联系支持', 'support@smartfarm.com')

      Button('数据备份', { type: ButtonType.Capsule })
        .width('100%')
        .height(40)
        .fontColor('#FFFFFF')
        .backgroundColor('#2E8B57')
        .margin({ top: 16 })
        .onClick(() => {
          console.log('执行数据备份');
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  BuildSettingItem(icon: string, label: string, value: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(16)
        .margin({ right: 12 })

      Text(label)
        .fontSize(16)
        .fontColor('#2D4D2D')
        .layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ right: 8 })

      Text('›')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      onClick();
    })

    Divider()
      .strokeWidth(1)
      .color('#F0F0F0')
  }

  @Builder
  BuildAboutItem(icon: string, label: string, value: string) {
    Row() {
      Text(icon)
        .fontSize(16)
        .margin({ right: 12 })

      Text(label)
        .fontSize(16)
        .fontColor('#2D4D2D')
        .layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })

    Divider()
      .strokeWidth(1)
      .color('#F0F0F0')
  }
}