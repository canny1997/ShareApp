//
//  WKNavigationBar.m
//  WkShow
//
//  Created by TOPTEAM on 16/7/27.
//  Copyright © 2016年 TOPTEAM. All rights reserved.
//

#import "WKNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
@implementation WKNavigationBar
static CGFloat kEndPoint = 1.5;
//awakeFromNib 从xib或者storyboard加载完毕就会调用
//initWithCoder: 只要对象是从文件解析来的，就会调用
//同时存在会先调用initWithCoder:


//initWithCoder：使用文件加载的对象调用（如从xib或stroyboard中创建）
//initWithFrame：使用代码加载的对象调用（使用纯代码创建）
//注意：所以为了同时兼顾从文件和从代码解析的对象初始化，要同时在initWithCoder: 和 initWithFrame: 中进行初始化

-(void)awakeFromNib
{
    [super awakeFromNib];
    if (self.color) {
        [self setNavigationBarWithColor:self.color];
    } else {
        [self setNavigationBarWithColor:[UIColor whiteColor]];
    }
}

/*
 - (id)initWithCoder:(NSCoder *)aDecoder {
 
 self = [super initWithCoder:aDecoder];
 
 if (self) {
 if (self.color) {
 [self setNavigationBarWithColor:self.color];
 } else {
 [self setNavigationBarWithColor:[UIColor whiteColor]];
 }
 
 return self;
 }
 
 -(id)initWithFrame:(CGRect)frame
 {
 self = [super initWithFrame:frame];
 
 if (self) {
 if (self.color) {
 [self setNavigationBarWithColor:self.color];
 } else {
 [self setNavigationBarWithColor:[UIColor whiteColor]];
 }
 }
 
 return self;
 }
 */
void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(rect.size.width/2, 0);
    CGPoint endPoint = CGPointMake(rect.size.width/2, rect.size.height/kEndPoint);
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithGradients:(NSArray *)colours
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * beginColor = [colours objectAtIndex:0];
    UIColor * endColor = [colours objectAtIndex:1];
    drawLinearGradient(context, rect, beginColor.CGColor, endColor.CGColor);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setNavigationBarWithColor:(UIColor *)color
{
    UIImage *image = [self imageWithColor:color];
    
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self setBarStyle:UIBarStyleDefault];
    [self setShadowImage:[UIImage new]];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self setTintColor:[UIColor whiteColor]];
    [self setTranslucent:YES];
}

- (void)setNavigationBarWithColors:(NSArray *)colours
{
    UIImage *image = [self imageWithGradients:colours];
    
    [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [self setBarStyle:UIBarStyleDefault];
    [self setShadowImage:[UIImage new]];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self setTintColor:[UIColor whiteColor]];
    [self setTranslucent:YES];
}


@end
























