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

@property (readonly) HJDanmakuMode danmakuModel;

// unit second
@property (nonatomic) CGFloat duration;
@property (nonatomic) CGFloat paintHeight;

@property (nonatomic) CGFloat maxLRShowCount;
@property (nonatomic) CGFloat maxShowCount;

// default 0, full screen
@property (nonatomic) NSInteger numberOfLines;

- (instancetype)initWithDanmakuModel:(HJDanmakuMode)danmakuModel NS_DESIGNATED_INITIALIZER;

@end
