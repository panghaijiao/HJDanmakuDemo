//
//  DanmakuBaseModel.m
//  DanmakuDemo
//
//  Created by Haijiao on 15/2/28.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import "DanmakuBaseModel.h"
#import "DanmakuView.h"

@implementation DanmakuBaseModel

- (void)measureSizeWithPaintHeight:(CGFloat)paintHeight;
{
    if (self.isMeasured) {
        return;
    }
    self.size = CGSizeMake([self.text sizeWithFont:[UIFont systemFontOfSize:self.textSize]].width, paintHeight);
    self.isMeasured = YES;
}

- (void)layoutWithScreenWidth:(float)width;
{
    
}

- (float)pxWithScreenWidth:(float)width RemainTime:(float)remainTime
{
    return -self.size.width;
}

- (BOOL)isDraw:(float)curTime
{
    return self.time>=curTime;
}

- (BOOL)isLate:(float)curTime
{
    return (curTime+1)<self.time;
}

@end

@implementation DanmakuLRModel

- (void)layoutWithScreenWidth:(float)width;
{
    self.px = [self pxWithScreenWidth:width RemainTime:self.remainTime];
}

- (float)pxWithScreenWidth:(float)width RemainTime:(float)remainTime
{
    return -self.size.width+(width+self.size.width)/self.duration*remainTime;
}

@end

@implementation DanmakuFTModel

- (void)layoutWithScreenWidth:(float)width;
{
    self.px = (width-self.size.width)/2;
    float alpha = 0;
    if (self.remainTime>0 && self.remainTime<self.duration) {
        alpha= 1;
    }
    self.label.alpha = alpha;
}

@end

@implementation DanmakuFBModel

@end

@implementation DanmakuLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    [super drawTextInRect:rect];
    
    if (self.underLineEnable) {
        CGContextSetStrokeColorWithColor(c, [UIColor redColor].CGColor);
        CGContextSetLineWidth(c, 2.0f);
        CGPoint leftPoint = CGPointMake(0, self.frame.size.height);
        CGPoint rightPoint = CGPointMake(self.frame.size.width, self.frame.size.height);
        CGContextMoveToPoint(c, leftPoint.x, leftPoint.y);
        CGContextAddLineToPoint(c, rightPoint.x, rightPoint.y);
        CGContextStrokePath(c);
    }
}

@end
