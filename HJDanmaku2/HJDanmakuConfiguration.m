//
//  HJDanmakuConfiguration.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuConfiguration.h"

@interface HJDanmakuConfiguration ()

@property (nonatomic) HJDanmakuMode danmakuModel;

@end

@implementation HJDanmakuConfiguration

- (instancetype)init {
    return [self initWithDanmakuModel:HJDanmakuModeVideo];
}

- (instancetype)initWithDanmakuModel:(HJDanmakuMode)danmakuModel {
    if (self = [super init]) {
        self.danmakuModel = danmakuModel;
    }
    return self;
}

@end
