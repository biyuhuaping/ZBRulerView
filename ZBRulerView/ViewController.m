//
//  ViewController.m
//  ZBRulerView
//
//  Created by 周博 on 2018/6/26.
//  Copyright © 2018年 周博. All rights reserved.
//

#import "ViewController.h"
#import "ZBRulerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightTextColor];
    
    ZBRulerView *rulerView = [[ZBRulerView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), 100)];
    rulerView.minAmount = 100;
    rulerView.maxAmount = 2000;
    [self.view addSubview:rulerView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
