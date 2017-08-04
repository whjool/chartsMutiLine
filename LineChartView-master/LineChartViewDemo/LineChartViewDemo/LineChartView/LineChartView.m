//
//  ZXView.m
//  折线图
//
//  Created by iOS on 16/6/28.
//  Copyright © 2016年 iOS. All rights reserved.
//

#import "LineChartView.h"

#define XLBTag 1000
#define LeftLBTag 2000
#define RightLBTag 2500
#define ChartYRate 1.2/2.0
#define YCommonMargin 10
#define XCommonMargin 20

#define ChartLeftColor [UIColor redColor]
#define ChartRightColor [UIColor greenColor]

@interface LineChartView ()<CAAnimationDelegate>

@property (nonatomic) int columCount;
@property (nonatomic) int rowCount;

@property (nonatomic, strong) CAShapeLayer *lineChartLayer;
@property (nonatomic, strong) CAShapeLayer *lineChartRightLayer;//根据右边的曲线
@property (nonatomic, strong) UIBezierPath * path1;
@property (nonatomic, strong) NSArray<UIBezierPath *> * pathArr;//贝瑟尔曲线数组
/** 渐变背景视图 */
@property (nonatomic, strong) UIView *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray *gradientLayerColors;

@property (nonatomic, strong) NSArray<NSString *> *yLeftDataArray;//y 坐标数据
@property (nonatomic, strong) NSArray<NSString *> *yRightDataArray;//y 坐标数据


@end

@implementation LineChartView

static CGFloat bounceX = 50;
static CGFloat bounceY = 60;



#pragma mark - public

-(void)setModel:(LineChartModel *)model
{
    _model = model;
    self.yRightTitle = model.rightTitle;
    self.yLeftTitle = model.leftTitle;
    self.xTitle = model.bottomTitle;
    self.dataArray = model.dataArray;           //左边的折线
    self.dataRightArray = model.dataRightArray; //右边的折线
    
}


#pragma mark - private
- (instancetype)initWithFrame:(CGRect)frame
               withColumCount:(int)columCount
                     rowCount:(int)rowCount
{
    
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor whiteColor];
        self.columCount = columCount;//纵向的数据
        self.rowCount = rowCount;   //横向的数据
        
        [self createLabelX];
        [self createLeftLabelY];    //创建左边数据!
        [self createRightLabelY];   //创建右边数据!
        [self drawGradientLayer];
        [self setHorLineDash];  //横向虚线绘制
        [self setVerLineDash];  //纵向数据绘制
        
    }
    return self;
}

//坐标轴
- (void)drawRect:(CGRect)rect
{
    
    /*******画出坐标轴********/
    CGFloat XMagin = bounceX+XCommonMargin;
    CGFloat YMagin = bounceY*ChartYRate ;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//坐标轴背景颜色
    CGContextMoveToPoint(context, XMagin, bounceY-YCommonMargin);                        //原点
    CGContextAddLineToPoint(context, XMagin, rect.size.height - YMagin);  //Y
    //获取最长的label的数据
    UILabel * label1 = (UILabel*)[self viewWithTag:XLBTag + self.columCount- 1];
    CGFloat centerX = label1.frame.origin.x;
    //导致右边
    CGContextAddLineToPoint(context,centerX, rect.size.height - YMagin);//X轴
    CGContextMoveToPoint(context, centerX , bounceY-YCommonMargin);
    CGContextAddLineToPoint(context,centerX , rect.size.height - YMagin);//右侧Y轴
    CGContextStrokePath(context);
}



#pragma mark 添加纵向虚线
- (void)setVerLineDash{
    
    for (NSInteger i = 1;i < self.columCount; i++ ) {
        
        if (i!= self.columCount - 1) {
            UILabel * label1 = (UILabel*)[self viewWithTag:XLBTag + i];
            CGFloat XMagin = bounceX;
            CGFloat YMagin = bounceY*ChartYRate+bounceY;
            
            //垂直
            UIBezierPath * path = [[UIBezierPath alloc]init];
            [path moveToPoint:CGPointMake(label1.frame.origin.x - XMagin, -YCommonMargin)];
            [path addLineToPoint:CGPointMake(label1.frame.origin.x - XMagin,self.frame.size.height - YMagin)];
            
            CAShapeLayer * dashLayer = [CAShapeLayer layer];
            dashLayer.strokeColor = [UIColor blackColor].CGColor;
            dashLayer.fillColor = [[UIColor clearColor] CGColor];
            // 默认设置路径宽度为0，使其在起始状态下不显示
            dashLayer.lineWidth = 0.6;
            //设置虚线
            NSArray *dash = @[@3,@2];
            dashLayer.lineDashPattern = dash;
            //设置实线
            dashLayer.lineDashPattern = nil;
            
            dashLayer.path = path.CGPath;
            
            [self.gradientLayer addSublayer:dashLayer];
        }
        
    }
}

#pragma mark 画折线图
- (void)drawLine{
    if (self.dataArray||self.dataRightArray)//分别绘制左边线和右边线条
    {
        if (self.dataArray) {
            [self singleLeftLine];
        }
        if (self.dataRightArray) {
            [self singleRightLine];
        }
    }
   
}

//根据传入的最大值进行分组值
-(NSArray *)dataArrFromModelArr:(NSArray<NSNumber *> *)modelArr
{
    //横向数据
    NSInteger row = self.rowCount;
    CGFloat maxNum = modelArr[0].floatValue;
    NSInteger total = modelArr.count;
    NSInteger  i =1;
    while (i<total)
    {
        if (maxNum<modelArr[i].floatValue)
        {
            maxNum = modelArr[i].floatValue;
        }
        i++;
    }
    //这里就可以获得区间 0 - maxValue
    NSMutableArray *mewArr = [@[] mutableCopy];
    CGFloat speraValue = maxNum/(row*1.0);
    for (NSInteger j = 0; j<row; j++)
    {
        if (j == row - 1)
        {
            [mewArr addObject:@(maxNum)];
            //用最大的值!
//            [mewArr addObject:[NSString stringWithFormat:@"%.1f",maxNum]];
        }else
            [mewArr addObject:@(speraValue * j)];
//            [mewArr addObject:[NSString stringWithFormat:@"%.1f",speraValue]];
    }
    return mewArr;
    
}

-(CGFloat )arrMaxValue:(NSArray<NSNumber *> *)modelArr
{
    NSInteger total = modelArr.count;
    NSInteger  i =1;
    CGFloat maxNum = modelArr[0].floatValue;
    while (i<total)
    {
        if (maxNum<modelArr[i].floatValue)
        {
            maxNum = modelArr[i].floatValue;
        }
        i++;
    }
    return maxNum;
}

#pragma mark 添加横向虚线
- (void)setHorLineDash{
    //获取最长的label的数据
    UILabel * label= (UILabel*)[self viewWithTag:XLBTag + self.columCount- 1];
    CGFloat centerX = label.frame.origin.x;
    CGFloat YMagin = bounceY*ChartYRate + YCommonMargin;
    for (NSInteger i = 0;i <= self.rowCount; i++ ) {
        if (i != self.rowCount)
        {
            UILabel * label1 = (UILabel*)[self viewWithTag:LeftLBTag + i];
            
            UIBezierPath * path = [[UIBezierPath alloc]init];
            [path moveToPoint:CGPointMake(XCommonMargin, label1.frame.origin.y - YMagin)];
            [path addLineToPoint:CGPointMake(centerX - bounceX,label1.frame.origin.y - YMagin)];
            CAShapeLayer * dashLayer = [CAShapeLayer layer];
            dashLayer.strokeColor = [UIColor blackColor].CGColor;
            dashLayer.fillColor = [UIColor clearColor].CGColor;
            dashLayer.lineWidth = 0.6;
            dashLayer.path = path.CGPath;
            NSArray *dash = @[@3,@2];
            dashLayer.lineDashPattern = dash;
            [self.gradientLayer addSublayer:dashLayer];
        }
    }
}
//绘画以左边为基准的折线
-(void)singleLeftLine
{
    //创建左边的label数目
    NSArray *leftLbArr = [self dataArrFromModelArr:self.dataArray];
    self.yLeftDataArray = leftLbArr;
    
    //创建X部分,根据传入的点的数目
    
    
    //以下是创建绘图
    CGFloat maxValue = [self arrMaxValue:leftLbArr];
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    self.path1 = path;
    
    //这是间隔的高度,主要是顶部的要去掉
    CGFloat marginY = bounceY*ChartYRate;
    CGFloat totalH = self.frame.size.height - marginY - bounceY +YCommonMargin;
    CGFloat sperateH = (totalH)/self.rowCount;
    
    //所以总高度要减去一个分割
    CGFloat lineTotalH = totalH - sperateH;
    //创建折现点标记
    for (NSInteger i = 0; i< self.dataArray.count; i++) {
        
        UILabel * label = (UILabel*)[self viewWithTag:XLBTag + i];
        CGFloat yValue = [self.dataArray[i] floatValue];
        
        //这里要注意,最高点的值是不要的,所以应该剪掉
        CGFloat rate = (maxValue - yValue) / maxValue;
        //注意0点处
        //totalH*rate -YCommonMargin;//如果最高点算  最高点不算 YCommonMargin+sperateH
        CGFloat y = lineTotalH*rate - YCommonMargin+sperateH;
        CGFloat x = label.frame.origin.x - bounceX;
        if (i == 0) {
            
            [path moveToPoint:CGPointMake(x, y)];
        }else {
            
            [path addLineToPoint:CGPointMake(x,  y)];
        }
        //        //拐点标注点
        //        UILabel * falglabel = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x , (maxValue -yValue) /maxValue * (self.frame.size.height - bounceY*2 )+ bounceY, 30, 15)];
        //        if (yValue < [self.yLeftDataArray[0] floatValue]) {
        //
        //            falglabel.frame = CGRectMake(label.frame.origin.x, (maxValue -yValue) /maxValue * (self.frame.size.height - bounceY*2 )+ bounceY - 10, 30, 15);
        //        }
        //        falglabel.tag = 3000+ i;
        //        falglabel.text = [NSString stringWithFormat:@"%.1f",yValue];
        //        falglabel.font = [UIFont systemFontOfSize:8.0];
        //        falglabel.textColor = [UIColor whiteColor];
        //        [self addSubview:falglabel];
    }
    
    self.lineChartLayer = [CAShapeLayer layer];
    self.lineChartLayer.path = path.CGPath;
    self.lineChartLayer.strokeColor = ChartLeftColor.CGColor;
    self.lineChartLayer.fillColor = [UIColor clearColor].CGColor;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    self.lineChartLayer.lineWidth = 1.0;
    [self.gradientLayer addSublayer:self.lineChartLayer];

}



//绘画以左边为基准的折线
-(void)singleRightLine
{
    //创建左边的label数目
    NSArray *leftLbArr = [self dataArrFromModelArr:self.dataRightArray];
    self.yRightDataArray = leftLbArr;
    
    //创建X部分,根据传入的点的数目
    
    
    //以下是创建绘图
    CGFloat maxValue = [self arrMaxValue:leftLbArr];
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    self.path1 = path;
    
    //这是间隔的高度,主要是顶部的要去掉
    CGFloat marginY = bounceY*ChartYRate;
    CGFloat totalH = self.frame.size.height - marginY - bounceY +YCommonMargin;
    CGFloat sperateH = (totalH)/self.rowCount;
    
    //所以总高度要减去一个分割
    CGFloat lineTotalH = totalH - sperateH;
    //创建折现点标记
    for (NSInteger i = 0; i< self.yRightDataArray.count; i++) {
        
        UILabel * label = (UILabel*)[self viewWithTag:XLBTag + i];
        CGFloat yValue = [self.yRightDataArray[i] floatValue];
        
        //这里要注意,最高点的值是不要的,所以应该剪掉
        CGFloat rate = (maxValue - yValue) / maxValue;
        //注意0点处
        //totalH*rate -YCommonMargin;//如果最高点算  最高点不算 YCommonMargin+sperateH
        CGFloat y = lineTotalH*rate - YCommonMargin+sperateH;
        CGFloat x = label.frame.origin.x - bounceX;
        if (i == 0) {
            
            [path moveToPoint:CGPointMake(x, y)];
        }else {
            
            [path addLineToPoint:CGPointMake(x,  y)];
        }
//        //拐点标注点
//        UILabel * falglabel = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x , (maxValue -yValue) /maxValue * (self.frame.size.height - bounceY*2 )+ bounceY, 30, 15)];
//        if (yValue < [leftLbArr[0] floatValue]) {
//
//            falglabel.frame = CGRectMake(label.frame.origin.x, (maxValue -yValue) /maxValue * (self.frame.size.height - bounceY*2 )+ bounceY - 10, 30, 15);
//        }
//        falglabel.tag = 3000+ i;
//        falglabel.text = [NSString stringWithFormat:@"%.1f",yValue];
//        falglabel.font = [UIFont systemFontOfSize:8.0];
//        falglabel.textColor = [UIColor whiteColor];
//        [self addSubview:falglabel];
    }
    
    self.lineChartRightLayer = [CAShapeLayer layer];
    self.lineChartRightLayer.path = path.CGPath;
    self.lineChartRightLayer.strokeColor = ChartRightColor.CGColor;
    self.lineChartRightLayer.fillColor = [UIColor clearColor].CGColor;
    self.lineChartRightLayer.lineCap = kCALineCapRound;
    self.lineChartRightLayer.lineJoin = kCALineJoinRound;
    self.lineChartRightLayer.lineWidth = 1.0;
    [self.gradientLayer addSublayer:self.lineChartRightLayer];
    
}

#pragma mark 创建x轴的数据
- (void)createLabelX {
    CGFloat marginX = bounceX+XCommonMargin;
    for (NSInteger i = 0; i < self.columCount; i++) {
        UILabel * LabelMonth = [[UILabel alloc]initWithFrame:
                                CGRectMake((self.frame.size.width - 2*bounceX-XCommonMargin)/self.columCount * i + marginX,
                                                                        self.frame.size.height - bounceY + bounceY*0.3,
                                           (self.frame.size.width - 2*bounceX)/self.columCount- 2, bounceY/2)];
        LabelMonth.tag = XLBTag + i;
        LabelMonth.font = [UIFont systemFontOfSize:10];
//        LabelMonth.transform = CGAffineTransformMakeRotation(M_PI * 0.1);//不做旋转
        [self addSubview:LabelMonth];
    }
}

-(void)setXTitle:(NSString *)xTitle
{
    _xTitle = xTitle;
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = xTitle;
    [label sizeToFit];
    [self addSubview:label];
    label.center = (CGPoint){self.frame.size.width /2.0 ,self.frame.size.height - 10};

}

-(void)setYLeftTitle:(NSString *)yLeftTitle
{
    _yLeftTitle = yLeftTitle;
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = yLeftTitle;
    label.numberOfLines = yLeftTitle.length;
    [label sizeToFit];
    [self addSubview:label];
    label.center = (CGPoint){10,self.frame.size.height/2.0};
    
}

-(void)setYRightTitle:(NSString *)yRightTitle
{
    _yRightTitle = yRightTitle;
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = yRightTitle;
    label.numberOfLines = yRightTitle.length;
    [label sizeToFit];
    [self addSubview:label];
    label.center = (CGPoint){self.frame.size.width - 10,self.frame.size.height/2.0};
}



- (void)setXDataArray:(NSArray<NSString *> *)xDataArray {

    _xDataArray = [xDataArray copy];
    
    for (int i = 0; i < self.columCount; i ++) {
        
        UILabel *label = (UILabel *)[self viewWithTag:XLBTag + i];
        label.text = xDataArray[i];
    }
}

#pragma mark - 创建y轴数据

#pragma mark 创建左边Y
- (void)createLeftLabelY{
    CGFloat marginX = XCommonMargin;
    CGFloat marginY = bounceY*ChartYRate;
    CGFloat totalH = self.frame.size.height - marginY - bounceY +YCommonMargin;
    CGFloat sperateH = (totalH)/self.rowCount;
    
    for (NSInteger i = 0; i <= self.rowCount; i++) {
        
        UILabel * labelYdivision = [[UILabel alloc]initWithFrame:CGRectMake(marginX,
                                                                            sperateH*i  + marginY,
                                                                            bounceX, marginY/2.0)];
        labelYdivision.tag = LeftLBTag + i;
        labelYdivision.textAlignment = NSTextAlignmentCenter;
//        labelYdivision.text = [NSString stringWithFormat:@"%.1f",(self.rowCount - i)*100.0];
        
        labelYdivision.font = [UIFont systemFontOfSize:10];
        [self addSubview:labelYdivision];
    }
}

//填充左边的Y
-(void)setYLeftDataArray:(NSArray<NSString *> *)yLeftDataArray
{

    _yLeftDataArray = [yLeftDataArray copy];
    
    //由于最顶部需要
    int total = self.rowCount;
    for (int i = total ; i >= 0; i --) {
        
        UILabel *label = (UILabel *)[self viewWithTag:LeftLBTag + total - i];
        if (i != total) {
            label.text = [NSString stringWithFormat:@"%.1f",yLeftDataArray[i].floatValue];;
        }else
        {
            label.text = @"";
        }
        
    }
}

#pragma mark - 创建右边Y

- (void)createRightLabelY
{
//    CGFloat marginX = (self.frame.size.width - 2*bounceX)+bounceX/2.0;
    CGFloat marginX = self.frame.size.width - 2*bounceX +1.5*XCommonMargin;
    CGFloat marginY = bounceY*ChartYRate-YCommonMargin;
    CGFloat totalH = self.frame.size.height - marginY - bounceY +YCommonMargin;
    CGFloat sperateH = (totalH)/self.rowCount;
    //创建右边的Y
    for (NSInteger i = 0; i <= self.rowCount; i++) {
        
        UILabel * labelYdivision = [[UILabel alloc]initWithFrame:CGRectMake(
                                                                            marginX,
                                                                            sperateH *i + marginY,
                                                                            bounceX, bounceY/2.0)];
        labelYdivision.tag = RightLBTag + i;
        labelYdivision.textAlignment = NSTextAlignmentCenter;
//        labelYdivision.text = [NSString stringWithFormat:@"%.1f",(self.rowCount - i)*100.0];
        
        labelYdivision.font = [UIFont systemFontOfSize:10];
        [self addSubview:labelYdivision];
    }
}

//填充右边的Y
-(void)setYRightDataArray:(NSArray<NSString *> *)yRightDataArray
{
    _yRightDataArray = [yRightDataArray copy];
    
    //由于最顶部需要
    int total = self.rowCount;
    for (int i = total ; i >= 0; i --) {
        
        UILabel *label = (UILabel *)[self viewWithTag:RightLBTag + total - i];
        if (i != total) {
            label.text = [NSString stringWithFormat:@"%.0f",yRightDataArray[i].floatValue];;
        }else
        {
            label.text = @"";
        }
        
    }
}

#pragma mark 渐变的颜色
- (void)drawGradientLayer
{

//    /** 创建并设置渐变背景图层（不包含坐标轴） */
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = CGRectMake(bounceX, bounceY, self.bounds.size.width - bounceX * 2, self.bounds.size.height - 2 * bounceY);
    [self.layer addSublayer:self.gradientLayer];
//    //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
//    self.gradientLayer.startPoint = CGPointMake(0, 0);
//    self.gradientLayer.endPoint = CGPointMake(1.0, 1.0);
//    //设置颜色的渐变过程
//    self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)[UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:251 / 255.0 green:37 / 255.0 blue:45 / 255.0 alpha:1.0].CGColor]];
//    self.gradientLayer.colors = self.gradientLayerColors;
//    //将CAGradientlayer对象添加在我们要设置背景图层layer
    [self.layer addSublayer:self.gradientLayer];
}

- (void)resetDrawWithAnimate:(BOOL)isAnimate
{

    if (self.lineChartLayer) {
        
        [self.lineChartLayer removeFromSuperlayer];
//删除驻点
//        for (NSInteger i = 0; i < 12; i++) {
//            UILabel * label = (UILabel*)[self viewWithTag:3000 + i];
//            [label removeFromSuperview];
//        }
        [self.lineChartRightLayer removeFromSuperlayer];

        //删除驻点
//        for (NSInteger i = 0; i < 12; i++) {
//            UILabel * label = (UILabel*)[self viewWithTag:3000 + i];
//            [label removeFromSuperview];
//        }
    }
    
    [self drawLine];
    if (isAnimate)
    {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 3;
        pathAnimation.repeatCount = 1;
        pathAnimation.removedOnCompletion = YES;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        // 设置动画代理，动画结束时添加一个标签，显示折线终点的信息
        pathAnimation.delegate = self;
        [self.lineChartLayer addAnimation:pathAnimation forKey:@"strokeEnd"];

    }
}

- (void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"开始®");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"停止~~~~~~~~");
}


@end
