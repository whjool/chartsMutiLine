//
//  ZXView.m
//  折线图
//
//  Created by iOS on 16/6/28.
//  Copyright © 2016年 iOS. All rights reserved.
//

#import "LineChartView.h"

@interface LineChartView ()<CAAnimationDelegate>

@property (nonatomic) int columCount;
@property (nonatomic) int rowCount;

@property (nonatomic, strong) CAShapeLayer *lineChartLayer;
@property (nonatomic, strong) UIBezierPath * path1;
@property (nonatomic, strong) NSArray<UIBezierPath *> * pathArr;//贝瑟尔曲线数组
/** 渐变背景视图 */
@property (nonatomic, strong) UIView *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray *gradientLayerColors;

@end

@implementation LineChartView

static CGFloat bounceX = 30;
static CGFloat bounceY = 20;

- (instancetype)initWithFrame:(CGRect)frame withColumCount:(int)columCount rowCount:(int)rowCount {
    
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = [UIColor whiteColor];
        self.columCount = columCount;//纵向的数据
        self.rowCount = rowCount;   //横向的数据
        
        [self createLabelX];
        [self createLabelY];
        [self drawGradientLayer];
        [self setHorLineDash];  //横向虚线绘制
        [self setVerLineDash];  //
        
    }
    return self;
}

//坐标轴
- (void)drawRect:(CGRect)rect
{
    
    /*******画出坐标轴********/
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);//坐标轴背景颜色
    CGContextMoveToPoint(context, bounceX, bounceY);                        //原点
    CGContextAddLineToPoint(context, bounceX, rect.size.height - bounceY);  //Y
    CGContextAddLineToPoint(context,rect.size.width -  bounceX, rect.size.height - bounceY);//X轴
    CGContextMoveToPoint(context, rect.size.width -  bounceX, bounceY);
    CGContextAddLineToPoint(context,rect.size.width -  bounceX, rect.size.height - bounceY);//右侧Y轴
    CGContextStrokePath(context);
}

#pragma mark 添加横向虚线
- (void)setHorLineDash{

    for (NSInteger i = 0;i <= self.rowCount; i++ ) {
        
        UILabel * label1 = (UILabel*)[self viewWithTag:2000 + i];
        
        UIBezierPath * path = [[UIBezierPath alloc]init];
        [path moveToPoint:CGPointMake(0, label1.frame.origin.y - bounceY)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - 2*bounceX,label1.frame.origin.y - bounceY)];
        
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

#pragma mark 添加纵向虚线
- (void)setVerLineDash{
    
    for (NSInteger i = 1;i < self.columCount; i++ ) {
        
        UILabel * label1 = (UILabel*)[self viewWithTag:1000 + i];
        
        UIBezierPath * path = [[UIBezierPath alloc]init];
        [path moveToPoint:CGPointMake(label1.frame.origin.x - bounceX, 0)];
        [path addLineToPoint:CGPointMake(label1.frame.origin.x - bounceX,self.frame.size.height - 2*bounceY)];
        
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

#pragma mark 画折线图
- (void)drawLine{
    if (self.dataArray)
    {
        [self singleLine];
    }else if (self.mutiDataArray)
    {
        [self multiLine];
    }
   
}

-(void)singleLine
{
    CGFloat maxValue = [self.yLeftDataArray[self.rowCount - 1] floatValue];
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    self.path1 = path;
    //创建折现点标记
    for (NSInteger i = 0; i< self.dataArray.count; i++) {
        
        UILabel * label = (UILabel*)[self viewWithTag:1000 + i];
        CGFloat yValue = [self.dataArray[i] floatValue];
        
        CGFloat y = (maxValue - yValue) / maxValue * (self.frame.size.height - bounceY*2);
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
    self.lineChartLayer.strokeColor = [UIColor blackColor].CGColor;
    self.lineChartLayer.fillColor = [UIColor clearColor].CGColor;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    self.lineChartLayer.lineWidth = 1.0;
    [self.gradientLayer addSublayer:self.lineChartLayer];

}

//多线条绘制
-(void)multiLine
{
    NSInteger totalNum = self.mutiDataArray.count;
    CGFloat maxValue = [self.yLeftDataArray[self.rowCount - 2] floatValue];
    
//    while (<#condition#>)
//    {
//        <#statements#>
//    }
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    self.path1 = path;
    //创建折现点标记
    for (NSInteger i = 0; i< self.dataArray.count; i++) {
        
        UILabel * label = (UILabel*)[self viewWithTag:1000 + i];
        CGFloat yValue = [self.dataArray[i] floatValue];
        
        CGFloat y = (maxValue - yValue) / maxValue * (self.frame.size.height - bounceY*2);
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
    self.lineChartLayer.strokeColor = [UIColor blackColor].CGColor;
    self.lineChartLayer.fillColor = [UIColor clearColor].CGColor;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    self.lineChartLayer.lineWidth = 1.0;
    [self.gradientLayer addSublayer:self.lineChartLayer];
}
#pragma mark 创建x轴的数据
- (void)createLabelX {
    
    for (NSInteger i = 0; i < self.columCount; i++) {
        UILabel * LabelMonth = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 2*bounceX)/self.columCount * i + bounceX, self.frame.size.height - bounceY + bounceY*0.3, (self.frame.size.width - 2*bounceX)/self.columCount- 2, bounceY/2)];
        LabelMonth.tag = 1000 + i;
        LabelMonth.font = [UIFont systemFontOfSize:10];
//        LabelMonth.transform = CGAffineTransformMakeRotation(M_PI * 0.1);//不做旋转
        [self addSubview:LabelMonth];
    }
}

- (void)setXDataArray:(NSArray<NSString *> *)xDataArray {

    _xDataArray = [xDataArray copy];
    
    for (int i = 0; i < self.columCount; i ++) {
        
        UILabel *label = (UILabel *)[self viewWithTag:1000 + i];
        label.text = xDataArray[i];
    }
}

#pragma mark 创建y轴数据
- (void)createLabelY{
    
    for (NSInteger i = 0; i <= self.rowCount; i++) {
        
        UILabel * labelYdivision = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 2 * bounceY)/self.rowCount *i + bounceY, bounceX, bounceY/2.0)];
        labelYdivision.tag = 2000 + i;
        labelYdivision.textAlignment = NSTextAlignmentCenter;
        if (i == self.rowCount)
        {
            labelYdivision.text = @"11111";
        }else
            labelYdivision.text = [NSString stringWithFormat:@"%.1f",(self.rowCount - i)*100.0];
        labelYdivision.font = [UIFont systemFontOfSize:10];
        [self addSubview:labelYdivision];
    }
}

//设置左边Y轴设计
-(void)setYLeftDataArray:(NSArray<NSString *> *)yLeftDataArray
{

    _yLeftDataArray = [yLeftDataArray copy];
    
    //由于最顶部需要
    int total = self.rowCount;
    for (int i = total ; i >= 0; i --) {
        
        UILabel *label = (UILabel *)[self viewWithTag:2000 + total - i];
        if (i != total) {
            label.text = yLeftDataArray[i];
        }
        
    }
}

-(void)setYRightDataArray:(NSArray<NSString *> *)yRightDataArray
{
    
}

#pragma mark 渐变的颜色
- (void)drawGradientLayer {

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

- (void)resetDraw {

    if (self.lineChartLayer) {
        
        [self.lineChartLayer removeFromSuperlayer];
        for (NSInteger i = 0; i < 12; i++) {
            UILabel * label = (UILabel*)[self viewWithTag:3000 + i];
            [label removeFromSuperview];
        }
    }
    
    [self drawLine];
    
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

- (void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"开始®");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"停止~~~~~~~~");
}
@end
