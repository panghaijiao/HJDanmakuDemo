//
//  HJDanmakuModel.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuModel.h"

@interface HJDanmakuModel ()

@property (nonatomic) HJDanmakuType danmakuType;

@end

@implementation HJDanmakuModel

- (instancetype)init {
    return [self initWithType:HJDanmakuTypeLR];
}

- (instancetype)initWithType:(HJDanmakuType)danmakuType {
    if (self = [super init]) {
        self.danmakuType = danmakuType;
    }
    return self;
}

@end
