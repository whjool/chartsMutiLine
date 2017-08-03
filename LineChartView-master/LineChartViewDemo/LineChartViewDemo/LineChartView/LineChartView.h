//
//  ZXView.h
//  折线图
//
//  Created by iOS on 16/6/28.
//  Copyright © 2016年 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineChartView : UIView

@property (nonatomic, strong) NSArray<NSString *> *xDataArray;//x坐标 数据
@property (nonatomic, strong) NSArray<NSString *> *yDataArray;//y 坐标数据
//@property (nonatomic, strong) NSArray<NSNumber *> *dataArray;//折线上点对应的数据
@property (nonatomic, strong) NSArray<NSNumber *> *dataArray;//折线上点对应的数据
- (instancetype)initWithFrame:(CGRect)frame withColumCount:(int)columCount rowCount:(int)rowCount;

- (void)resetDraw;

@end
