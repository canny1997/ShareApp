//
//  WKNavigationBar.h
//  WkShow
//
//  Created by TOPTEAM on 16/7/27.
//  Copyright © 2016年 TOPTEAM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKNavigationBar : UINavigationBar

@property (strong, nonatomic) IBInspectable UIColor *color;

-(void)setNavigationBarWithColor:(UIColor *)color;
-(void)setNavigationBarWithColors:(NSArray *)colours;
@end
