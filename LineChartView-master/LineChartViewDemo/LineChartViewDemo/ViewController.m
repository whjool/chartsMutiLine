//
//  ViewController.m
//  LineChartViewDemo
//
//  Created by 鱼米app on 2017/7/11.
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
    
    NSArray *xDataArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    NSArray *yDataArray = @[@"100",@"200",@"300",@"400",@"500",@"600",@"700",@"800"];
    _lineView = [[LineChartView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 240) withColumCount:(int)xDataArray.count rowCount:(int)yDataArray.count];
    _lineView.xDataArray = xDataArray;
    _lineView.yDataArray = yDataArray;
    _lineView.dataArray = @[@(69),@(376),@(500),@(789),@(456),@(650),@(310)];
    
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

    [_lineView resetDraw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
