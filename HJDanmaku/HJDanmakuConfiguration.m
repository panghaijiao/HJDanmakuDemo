//
//  HJDanmakuConfiguration.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuConfiguration.h"

@interface HJDanmakuConfiguration ()

@property (nonatomic) HJDanmakuMode danmakuMode;

@end

@implementation HJDanmakuConfiguration

- (instancetype)init {
    return [self initWithDanmakuMode:HJDanmakuModeVideo];
}

- (instancetype)initWithDanmakuMode:(HJDanmakuMode)danmakuMode {
    if (self = [super init]) {
        self.danmakuMode = danmakuMode;
        self.duration = 5.0;
        self.tolerance = 2.0f;
        self.cellHeight = 30.0f;
    }
    return self;
}

@end
