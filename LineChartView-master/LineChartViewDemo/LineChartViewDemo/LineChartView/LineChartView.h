//
//  ZXView.h
//  折线图
//
//  Created by iOS on 16/6/28.
//  Copyright © 2016年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineChartView : UIView

@property(nonatomic,copy)NSString *yRightTitle ;//右边y轴的名称
@property(nonatomic,copy)NSString *yLeftTitle ;//左边y轴的名称
@property(nonatomic,copy)NSString *xTitle ;//x轴的名称
@property (nonatomic, strong) NSArray<NSString *> *xDataArray;//x坐标 数据
@property (nonatomic, strong) NSArray<NSString *> *yLeftDataArray;//y 坐标数据
@property (nonatomic, strong) NSArray<NSString *> *yRightDataArray;//y 坐标数据
@property (nonatomic, strong) NSArray<NSNumber *> *dataArray;           //折线上点对应的数据 (单条参照左边数据)
@property (nonatomic, strong) NSArray<NSNumber *> *dataRightArray;      //折线上点对应的数据 (单条参照右边数据)

//目前没做
@property (nonatomic, strong) NSArray<NSArray *> *mutiLeftDataArray;    //折线上点对应多条的数据(参考左边数据)
@property (nonatomic, strong) NSArray<NSArray *> *mutiRightDataArray;   //折线上点对应多条的数据(参考右边数据)

- (instancetype)initWithFrame:(CGRect)frame withColumCount:(int)columCount rowCount:(int)rowCount;

- (void)resetDraw;

@end
