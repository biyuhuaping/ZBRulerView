//
//  ZBRulerView.h
//  ZBRulerView
//
//  Created by 周博 on 2018/6/26.
//  Copyright © 2018年 周博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBRulerView : UIView

@property (nonatomic, assign) double minValue;      // 最小值，默认为0
@property (nonatomic, assign) double maxValue;      // 最大值，必需设置
@property (nonatomic, assign) double defaultValue;  // 默认值，默认为0

@end
