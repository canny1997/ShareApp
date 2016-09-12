//
//  ZHActionSheet.h
//  ZHActionSheet
//
//  Created by wangzhaohui on 16/4/28.
//  Copyright © 2016年 wangzhaohui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZHActionSheet;

@protocol ZHActionSheetDelegate <NSObject>

@optional
/**
 *  Delegate
 *
 *  @param actionSheet action
 *  @param index       index
 */
- (void)initWithActionSheet:(ZHActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)index;

@end

@interface ZHActionSheet : UIView

@property (nonatomic, strong) id<ZHActionSheetDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate cancelButtonTitle:(NSString *)cancleTitle otherButtonTitles:(NSArray *)otherButtonTitles;

+ (instancetype)showActionSheetWithDelegate:(id)delegate cancelButtonTitle:(NSString *)cancleTitle otherButtonTitles:(NSArray *)otherButtonTitles;

- (void)show;

@end

@interface UIView (ZHActionSheet)

@property (assign, nonatomic) CGFloat av_x;
@property (assign, nonatomic) CGFloat av_y;
@property (assign, nonatomic) CGFloat av_w;
@property (assign, nonatomic) CGFloat av_h;
@property (assign, nonatomic) CGFloat av_centerX;
@property (assign, nonatomic) CGFloat av_centerY;
@property (assign, nonatomic) CGSize  av_size;
@property (assign, nonatomic) CGPoint av_origin;

@end

@interface UIColor (ZHActionSheet)
+ (instancetype)randomColor;
+ (instancetype)colorWithHex:(NSUInteger)hexColor;

@end