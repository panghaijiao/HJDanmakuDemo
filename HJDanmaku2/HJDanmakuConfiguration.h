//
//  HJDanmakuConfiguration.h
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJDanmakuDefines.h"

@interface HJDanmakuConfiguration : NSObject

@property (readonly) HJDanmakuMode danmakuMode;

// unit second
@property (nonatomic) CGFloat duration;
@property (nonatomic) CGFloat cellHeight;

// setting a tolerance for a danmaku render later than the time, unit second, default 2.0s
@property (nonatomic) CGFloat tolerance;

@property (nonatomic) CGFloat maxLRShowCount;
@property (nonatomic) CGFloat maxShowCount;

// default 0, full screen
@property (nonatomic) NSInteger numberOfLines;

- (instancetype)initWithDanmakuMode:(HJDanmakuMode)danmakuMode NS_DESIGNATED_INITIALIZER;

@end
