//
//  ZBRulerView.m
//  ZBRulerView
//
//  Created by 周博 on 2018/6/26.
//  Copyright © 2018年 周博. All rights reserved.
//

#import "ZBRulerView.h"

#define kScreenWidth     [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen] bounds].size.height

#define kPadding 10     //  最小刻度之间的宽度，像素
#define kMinScale 10    //  最小刻度值

@interface ZBRulerView ()<UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *markLine;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, assign) CGFloat scrollWidth;

@end

@implementation ZBRulerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initRulerViewData];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initRulerViewData];
    }
    return self;
}

- (void)initRulerViewData{
    _scrollWidth = kScreenWidth;
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scrollView];
    [self addSubview:self.textField];
    [self addSubview:self.bottomLine];
    [self addSubview:self.markLine];
    _minValue = 0;//设置默认初始值
}

- (void)setMinValue:(double)minValue{
    _minValue = minValue;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.textField.text = [NSString stringWithFormat:@"%.f", _minValue];
}

- (void)setMaxValue:(double)maxValue{
    _maxValue = maxValue;
    [self createIndicator];
}

- (void)setDefaultValue:(double)defaultValue{
    if (defaultValue > _maxValue) {
        _defaultValue = _maxValue;
    } else if (defaultValue < _minValue) {
        _defaultValue = _minValue;
    } else {
        _defaultValue = defaultValue;
    }
    self.scrollView.contentOffset = CGPointMake((_defaultValue-_minValue)/kMinScale*kPadding, 0);
    self.textField.text = [NSString stringWithFormat:@"%.f", _defaultValue];
}

- (void)createIndicator{
    for (NSUInteger i = self.minValue, j = 0; i <= self.maxValue; i+=kMinScale, j++) {
        _scrollWidth += kPadding;
        [self drawSegmentWithValue:i idx:j];
    }
    self.scrollView.contentSize = CGSizeMake(_scrollWidth-kPadding, CGRectGetHeight(self.frame));
}

- (void)drawSegmentWithValue:(NSUInteger)value idx:(NSUInteger)idx {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat x = kScreenWidth*0.5 + kPadding*idx;
    [path moveToPoint:CGPointMake(x, CGRectGetMinY(self.bottomLine.frame))];

    if (value % (kMinScale*10) == 0 || value == _minValue) { //每10个刻度，do something
        [path addLineToPoint:CGPointMake(x, CGRectGetMinY(self.bottomLine.frame)-10-10)];
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(x-50*0.5, CGRectGetMinY(self.bottomLine.frame)-20-10-5, 50, 10)];
        numLabel.font = [UIFont systemFontOfSize:12];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor redColor];
        numLabel.text = [NSString stringWithFormat:@"%ld", value];
        [self.scrollView addSubview:numLabel];
    } else if (value % (kMinScale*2) != 0) {   //每2个刻度，do something
        [path addLineToPoint:CGPointMake(x, CGRectGetMinY(self.bottomLine.frame)-5)];
    } else{
        [path addLineToPoint:CGPointMake(x, CGRectGetMinY(self.bottomLine.frame)-10)];
    }
    
    CAShapeLayer *line = [[CAShapeLayer alloc] init];
    //    line.frame = CGRectMake(0, 0, 20, 20);
    //    line.position = self.view.center;
    line.lineWidth = 1;
    line.strokeColor = [UIColor orangeColor].CGColor;
    line.path = path.CGPath;
    
    [self.scrollView.layer addSublayer:line];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat num = scrollView.contentOffset.x;
    double value = (num / kPadding) * kMinScale + self.minValue;
    if (value < self.minValue) {
        value = self.minValue;
    }else if (value > self.maxValue) {
        value = self.maxValue;
    }
    
    self.textField.text = [NSString stringWithFormat:@"%.f", value];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateDataWith:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        //OK,真正停止了，do something
        [self updateDataWith:scrollView];
    }
}

- (void)updateDataWith:(UIScrollView *)scrollView{
    CGFloat num = scrollView.contentOffset.x;
    NSInteger value = (num / kPadding) * kMinScale + self.minValue;
    value =  value - value % kMinScale;
    [self.scrollView setContentOffset:CGPointMake((value-_minValue)/kMinScale*kPadding, 0) animated:YES];
    self.textField.text = [NSString stringWithFormat:@"%ld", value];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.doubleValue < self.minValue) {
        textField.text = [NSString stringWithFormat:@"%.f",self.minValue];
    }
    if (textField.text.doubleValue > self.maxValue) {
        textField.text = [NSString stringWithFormat:@"%.f",self.maxValue];
    }
    
    [self.scrollView setContentOffset:CGPointMake((textField.text.doubleValue-_minValue)/kMinScale*kPadding, 0) animated:YES];
    self.textField.text = textField.text;
}

// 根据输入的数字变化
- (void)textDidChanged:(NSNotification *)info {
    UITextField *textField = info.object;
    NSString *text = textField.text;
    if (textField.isEditing) {
        self.scrollView.contentOffset = CGPointMake((text.doubleValue-_minValue)/kMinScale*kPadding, 0);
        self.textField.text = text;
    }
}

#pragma mark -
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake((kScreenWidth-100)*0.5, 10, 100, 20)];
        _textField.font = [UIFont systemFontOfSize:16];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.textColor = [UIColor blueColor];
        _textField.delegate = self;
    }
    return _textField;
}

- (UIView *)markLine {
    if (!_markLine) {
        _markLine = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-1)*0.5, CGRectGetMinY(self.bottomLine.frame)-50, 1, 50)];
        _markLine.backgroundColor = [UIColor orangeColor];
        
        UIView *circular = [[UIView alloc]initWithFrame:CGRectMake(-2.5, CGRectGetMaxY(_markLine.bounds)-3, 6, 6)];
        circular.backgroundColor = [UIColor orangeColor];
        circular.layer.cornerRadius = 3;
        [_markLine addSubview:circular];
    }
    return _markLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-5, kScreenWidth, 1)];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomLine;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(self.frame))];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)dealloc {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
