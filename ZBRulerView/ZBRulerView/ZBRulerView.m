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

#define kPadding 5      //  最小刻度之间的宽度，像素
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
        _scrollWidth = kScreenWidth;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
        [self addSubview:self.textField];
        [self addSubview:self.markLine];
        [self addSubview:self.bottomLine];
        _minAmount = 0;     //设置默认初始值
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _scrollWidth = kScreenWidth;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
        [self addSubview:self.textField];
        [self addSubview:self.markLine];
        [self addSubview:self.bottomLine];
        _minAmount = 0;//设置默认初始值
    }
    return self;
}

- (void)setMinAmount:(double)minAmount{
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.textField.text = [NSString stringWithFormat:@"%.f", minAmount];
    _minAmount = minAmount;
}

- (void)setMaxAmount:(double)maxAmount{
    _maxAmount = maxAmount;
    [self createIndicator];
}

- (void)createIndicator{
    for (NSUInteger i = self.minAmount, j = 0; i <= self.maxAmount; i+=kMinScale, j++) {
        _scrollWidth += kPadding;
        [self drawSegmentWithAmount:i idx:j];
    }
    self.scrollView.contentSize = CGSizeMake(_scrollWidth-kPadding, CGRectGetHeight(self.frame));
}

- (void)drawSegmentWithAmount:(NSUInteger)amount idx:(NSUInteger)idx {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat x = kScreenWidth*0.5 + kPadding*idx;
    [path moveToPoint:CGPointMake(x, CGRectGetHeight(self.frame)-5)];
    
    if (amount % (kMinScale*10) == 0 || amount == _minAmount) { //每10个刻度，do something
        [path addLineToPoint:CGPointMake(x, CGRectGetHeight(self.frame)-10-5-10)];
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(x-50*0.5, CGRectGetHeight(self.frame)-20-10-5-5, 50, 10)];
        numLabel.font = [UIFont systemFontOfSize:12];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = [UIColor redColor];
        numLabel.text = [NSString stringWithFormat:@"%ld", amount];
        [self.scrollView addSubview:numLabel];
    } else if (amount % (kMinScale*2) != 0) {   //每2个刻度，do something
        [path addLineToPoint:CGPointMake(x, CGRectGetHeight(self.frame)-10)];
    } else{
        [path addLineToPoint:CGPointMake(x, CGRectGetHeight(self.frame)-10-5)];
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
    double amount = (num / kPadding) * kMinScale + self.minAmount;
    if (amount < self.minAmount) {
        amount = self.minAmount;
    }else if (amount > self.maxAmount) {
        amount = self.maxAmount;
    }
    self.textField.text = [NSString stringWithFormat:@"%.f", amount];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.doubleValue > self.maxAmount) {
        textField.text = [NSString stringWithFormat:@"%.f",self.maxAmount];
    }
    
    [self.scrollView setContentOffset:CGPointMake(textField.text.doubleValue/kMinScale*kPadding, 0) animated:YES];
    self.textField.text = textField.text;
}

// 根据输入的数字变化
- (void)textDidChanged:(NSNotification *)info {
    UITextField *textField = info.object;
    NSString *text = textField.text;
    if (textField.isEditing) {
        self.scrollView.contentOffset = CGPointMake((text.doubleValue-_minAmount)/kMinScale*kPadding, 0);
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
        _markLine = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-1)*0.5, CGRectGetMaxY(_textField.frame)+5, 1, CGRectGetHeight(self.frame)-CGRectGetMaxY(_textField.frame)-5-5)];
        _markLine.backgroundColor = [UIColor orangeColor];
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
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)dealloc {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
