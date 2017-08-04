//
//  LineChartModel.h
//  LineChartViewDemo
//
//  Created by hun on 2017/8/4.
//  Copyright © 2017年 LFX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineChartModel : NSObject


@property(nonatomic,copy)NSString *bottomTitle ;    //底部标题
@property(nonatomic,copy)NSString *leftTitle ;      //左边标题
@property(nonatomic,copy)NSString *rightTitle ;     //右边标题


@property (nonatomic, strong) NSArray<NSString *> *xDataArray;//x坐标 数据

@property (nonatomic, strong) NSArray<NSNumber *> *dataArray;           //折线上点对应的数据 (单条参照左边数据)
@property (nonatomic, strong) NSArray<NSNumber *> *dataRightArray;      //折线上点对应的数据 (单条参照右边数据)

@end
