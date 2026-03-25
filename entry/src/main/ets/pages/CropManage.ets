// entry/src/main/ets/pages/CropManage.ets
import router from '@ohos.router';
import { Crop } from '../model/DataModel';
import { RdbManager } from '../model/RdbManager';
import { CropCard } from '../components/CropCard';
import { Logger } from '../utils/Logger';

@Entry
@Component
struct CropManage {
  @State cropList: Crop[] = [];
  @State isAdding: boolean = false;
  @State newCropName: string = '';

  aboutToAppear() {
    this.loadCrops();
  }

  async loadCrops() {
    this.cropList = await RdbManager.queryAllCrops();
  }

  build() {
    Column({ space: 0 }) {
      // 标题栏
      Row() {
        Text('作物管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2C3E50')

        Blank()

        Button('添加', { type: ButtonType.Normal })
          .onClick(() => { this.is