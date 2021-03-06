//
//  ZHActionSheet.m
//  ZHActionSheet
//
//  Created by wangzhaohui on 16/4/28.
//  Copyright © 2016年 wangzhaohui. All rights reserved.
//

#import "ZHActionSheet.h"

#define ZHActionSheetCancelTag 9999
#define ZHActionSheetCancelBaseTag 1000
#define ZHActionSheetBaseHeight 44
#define ZHActionSheetBaseAnimationDuration 0.25
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface ZHActionSheet ()
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *actionSheet;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *dividerArray;
@property (nonatomic, strong) ZHActionSheet *ZHActionSheet;
@end




@implementation ZHActionSheet

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [[NSMutableArray alloc] init];
    }
    return _btnArray;
}

- (NSMutableArray *)dividerArray{
    if (!_dividerArray) {
        _dividerArray = [[NSMutableArray alloc] init];
    }
    return _dividerArray;
}


- (instancetype)initWithDelegate:(id)delegate cancelButtonTitle:(NSString *)cancleTitle otherButtonTitles:(NSArray *)otherButtonTitles{
    if (self = [super init]) {
        
        self.btnArray = nil;
        self.dividerArray = nil;
        
        
        self.backgroundColor = [UIColor clearColor];
        self.ZHActionSheet = [ZHActionSheet new];
        self.ZHActionSheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.delegate = delegate;
        [self addSubview:self.ZHActionSheet];
        
        // 遮盖
        UIView *coverView = [UIButton buttonWithType:UIButtonTypeCustom];
        coverView.backgroundColor = [UIColor clearColor];
        [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewDidClick)]];
        self.coverView = coverView;
        [self.ZHActionSheet addSubview:coverView];
        
        
        // 底部弹窗
        UIView *actionSheet = [UIView new];
        actionSheet.backgroundColor = [UIColor clearColor];
        self.actionSheet = actionSheet;
        [self.coverView addSubview:actionSheet];
        
        // 操作action
        for (int i = 0; i < otherButtonTitles.count; i++) {
            [self createBtnWithTitle:otherButtonTitles[i] backgroundColor:[UIColor colorWithWhite:1 alpha:1] titleColor:[UIColor blackColor] tagIndex:i + ZHActionSheetCancelBaseTag];
        }
        
        
        // 取消action
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.tag = ZHActionSheetCancelTag;
        cancelBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [cancelBtn setTitle:cancleTitle forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(actionSheetClickedButtonAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelBtn = cancelBtn;
        [self.actionSheet addSubview:cancelBtn];
    }
    return self;
    
}


+ (instancetype)showActionSheetWithDelegate:(id)delegate cancelButtonTitle:(NSString *)cancleTitle otherButtonTitles:(NSArray *)otherButtonTitles{
    return [[self alloc] initWithDelegate:delegate cancelButtonTitle:cancleTitle otherButtonTitles:otherButtonTitles];
}

- (void)createBtnWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroudColor titleColor:(UIColor *)textColor tagIndex:(NSInteger)tagIndex{
    UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    actionBtn.tag = tagIndex;
    actionBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    actionBtn.backgroundColor = backgroudColor;
    actionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [actionBtn setTitle:title forState:UIControlStateNormal];
    [actionBtn setTitleColor:textColor forState:UIControlStateNormal];
    [actionBtn addTarget:self action:@selector(actionSheetClickedButtonAtIndex:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionSheet addSubview:actionBtn];
    [self.btnArray addObject:actionBtn];
    
    
    UIView *divider = [UIView new];
    divider.backgroundColor = [UIColor colorWithHex:0xebebeb];
    [actionBtn addSubview:divider];
    [self.dividerArray addObject:divider];
    
}



- (void)layoutSubviews{
    [super layoutSubviews];
}


#pragma mark - 事件处理
// 点击遮盖
- (void)coverViewDidClick{
    [self dismiss];
}

// 点击action按钮
- (void)actionSheetClickedButtonAtIndex:(UIButton *)actionBtn{
    if (actionBtn.tag != ZHActionSheetCancelTag) {
        if ([self.delegate respondsToSelector:@selector(initWithActionSheet:didClickedButtonAtIndex:)]) {
            [self.delegate initWithActionSheet:self didClickedButtonAtIndex:actionBtn.tag - ZHActionSheetCancelBaseTag];
            [self dismiss];
        }
    }else{ // 取消按钮
        [self dismiss];
    }
}



- (void)show{
    if (self.superview != nil) return;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = keyWindow.bounds;
    [keyWindow addSubview:self];
    
    
    self.ZHActionSheet.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.coverView.frame = self.ZHActionSheet.bounds;
    
    CGFloat actionHeight = (self.btnArray.count + 1) * ZHActionSheetBaseHeight + 5;
    self.actionSheet.frame = CGRectMake(0, self.av_h, SCREEN_WIDTH, actionHeight);
    
    
    self.cancelBtn.frame = CGRectMake(0, actionHeight - ZHActionSheetBaseHeight,self.av_w, ZHActionSheetBaseHeight);
    
    
    CGFloat btnW = self.av_w;
    CGFloat btnH = ZHActionSheetBaseHeight;
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    for (int i = 0; i < self.btnArray.count; i++) {
        UIButton *btn = self.btnArray[i];
        UIView *divider = self.dividerArray[i];
        btnY = ZHActionSheetBaseHeight * i;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        divider.frame = CGRectMake(btnX, btnH - 1, btnW, 1);
    }
    
    
    
    
    [UIView animateWithDuration:ZHActionSheetBaseAnimationDuration animations:^{
        self.actionSheet.av_y = self.av_h - self.actionSheet.av_h;
    }];
    
}

- (void)dismiss{
    [UIView animateWithDuration:ZHActionSheetBaseAnimationDuration animations:^{
        self.actionSheet.av_y = self.av_h;
    } completion:^(BOOL finished) {
        if (self.superview != nil) {
            [self removeFromSuperview];
        }
    }];
}


@end

@implementation UIView (ZHActionSheet)

- (void)setAv_x:(CGFloat)av_x{
    CGRect frame = self.frame;
    frame.origin.x = av_x;
    self.frame = frame;
}
- (CGFloat)av_x{
    return self.frame.origin.x;
}
- (void)setAv_y:(CGFloat)av_y{
    CGRect frame = self.frame;
    frame.origin.y = av_y;
    self.frame = frame;
}
- (CGFloat)av_y{
    return self.frame.origin.y;
}
- (void)setAv_centerX:(CGFloat)av_centerX{
    CGPoint center = self.center;
    center.x = av_centerX;
    self.center = center;
}
- (CGFloat)av_centerX{
    return self.center.x;
}

- (void)setAv_centerY:(CGFloat)av_centerY{
    CGPoint center = self.center;
    center.y = av_centerY;
    self.center = center;
}
- (CGFloat)av_centerY{
    return self.center.y;
}

- (void)setAv_w:(CGFloat)av_w{
    CGRect frame = self.frame;
    frame.size.width = av_w;
    self.frame = frame;
}
- (CGFloat)av_w{
    return self.frame.size.width;
}

- (void)setAv_h:(CGFloat)av_h{
    CGRect frame = self.frame;
    frame.size.height = av_h;
    self.frame = frame;
}

- (CGFloat)av_h{
    return self.frame.size.height;
}
- (void)setAv_size:(CGSize)av_size{
    CGRect frame = self.frame;
    frame.size = av_size;
    self.frame = frame;
}
- (CGSize)av_size{
    return self.frame.size;
}
- (void)setAv_origin:(CGPoint)av_origin{
    CGRect frame = self.frame;
    frame.origin = av_origin;
    self.frame = frame;
}
- (CGPoint)av_origin{
    return self.frame.origin;
}
@end



@implementation UIColor (ZHActionSheet)

+ (instancetype)randomColor{
    return [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
}

+ (instancetype)lightBlueColor {
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

+ (instancetype) colorWithHex:(NSUInteger)hexColor {
    return [UIColor colorWithHex:hexColor alpha:1.];
}

+ (instancetype)colorWithHex:(NSUInteger)hexColor alpha:(CGFloat)opacity {
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end
