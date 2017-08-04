```
//需要传入纵轴数目,和横轴数目
_lineView = [[LineChartView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 280)
withColumCount:(int)xDataArray.count
rowCount:8];
NSMutableArray *itemArr = [@[] mutableCopy];
for (int i =0; i<12; i++)
{
[itemArr addObject:@(arc4random_uniform(650))];
}
#if 1
LineChartModel *model = [LineChartModel new];
model.xDataArray = xDataArray;
model.bottomTitle = @"底部展示(元)";
model.leftTitle = @"左\n边\n展\n示\n(元)";
model.rightTitle = @"右\n边\n展\n示\n(元)";
//根据上述已经创建Y轴数目进行填充
//左边填充
model.dataArray = @[@(69),@(376),@(500),@(789),@(456),@(650),@(310),@(990),@(890),@(560)];
//根据右边填充
model.dataRightArray = itemArr;
_lineView.model = model;
#else
_lineView.xDataArray = xDataArray;
_lineView.xTitle = @"底部展示(元)";
_lineView.yLeftTitle = @"左\n边\n展\n示\n(元)";

//右边数据
//    _lineView.yRightDataArray = yDataArray;
_lineView.yRightTitle = @"右\n边\n展\n示\n(元)";
//左边填充
_lineView.dataArray = @[@(69),@(376),@(500),@(789),@(456),@(650),@(310),@(990),@(890),@(560)];
//根据右边填充
_lineView.dataRightArray = itemArr;
#endif

```


![效果](http://upload-images.jianshu.io/upload_images/3220449-e6604e3fecf5b76f.gif?imageMogr2/auto-orient/strip)
