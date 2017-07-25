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

// unit second, greater than zero, default 5.0s
@property (nonatomic) CGFloat duration;

// setting a tolerance for a danmaku render later than the time, unit second, default 2.0s
@property (nonatomic) CGFloat tolerance;

// default 0, full screen
@property (nonatomic) NSInteger numberOfLines;

// height of single line cell, avoid modify after initialization, default 30.0f
@property (nonatomic) CGFloat cellHeight;

// the maximum number of danmakus at the same time, default 0, adapt to the height of screen
@property (nonatomic) NSUInteger maxShowCount;

- (instancetype)initWithDanmakuMode:(HJDanmakuMode)danmakuMode NS_DESIGNATED_INITIALIZER;

@end
