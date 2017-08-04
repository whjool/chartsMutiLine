//
//  ViewController.m
//  LineChartViewDemo
//
//  Created by hundred on 2017/7/11.
//  Copyright © 2017年 LFX. All rights reserved.
//

#import "ViewController.h"

#import "LineChartView.h"

@interface ViewController ()

@property (nonatomic, strong) LineChartView *lineView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *dateArr = [@[] mutableCopy];
    for (int i =1; i<=12; i++)
    {
        [dateArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    NSArray *xDataArray = dateArr;
    
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
    
    
    
    
    
    [self.view addSubview:_lineView];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_lineView.frame) + 60, self.view.frame.size.width, 30)];
    [btn setTitle:@"重新绘制" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(animationDraw) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
}


-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animationDraw];
    });
}

- (void)animationDraw {

    [_lineView resetDrawWithAnimate:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
