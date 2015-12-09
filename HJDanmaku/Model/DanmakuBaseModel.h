//
//  DanmakuBaseModel.h
//  DanmakuDemo
//
//  Created by Haijiao on 15/2/28.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DanmakuRetainer;
@class DanmakuLabel;

typedef NS_ENUM (NSUInteger, DanmakuType) {
    DanmakuTypeLR = 0,
    DanmakuTypeFT = 1,
    DanmakuTypeFB = 2,
};

typedef NS_ENUM (NSUInteger, DanmakuFont) {
    DanmakuFontNormal = 0,
    DanmakuFontLarge =1,
};

@interface DanmakuBaseModel : NSObject

@property (nonatomic, assign) DanmakuType danmakuType;

@property (nonatomic, assign) float time;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float remainTime;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor  *textColor;
@property (nonatomic, assign) float     textSize;

@property (nonatomic, assign) float  px;
@property (nonatomic, assign) float  py;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL   isMeasured;

@property (nonatomic, assign) BOOL   isShowing;
@property (nonatomic, strong) DanmakuLabel  *label;
@property (nonatomic, weak) DanmakuRetainer *retainer;

@property (nonatomic, assign) BOOL isSelfID;

- (void)measureSizeWithPaintHeight:(CGFloat)paintHeight;
- (void)layoutWithScreenWidth:(float)width;
- (float)pxWithScreenWidth:(float)width RemainTime:(float)remainTime;

- (BOOL)isDraw:(float)curTime;
- (BOOL)isLate:(float)curTime;

@end

@interface DanmakuLRModel : DanmakuBaseModel

@end

@interface DanmakuFTModel : DanmakuBaseModel

@end

@interface DanmakuFBModel : DanmakuFTModel

@end

@interface DanmakuLabel : UILabel

@property (nonatomic, assign) BOOL underLineEnable;

@end
