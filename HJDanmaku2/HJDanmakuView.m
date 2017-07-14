//
//  HJDanmakuView.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuView.h"

@interface HJDanmakuUnit : NSObject

@property (nonatomic, strong) HJDanmakuModel *danmakuModel;

- (instancetype)initWithDanmaKuModel:(HJDanmakuModel *)danmakuModel;

@end

@implementation HJDanmakuUnit

- (instancetype)initWithDanmaKuModel:(HJDanmakuModel *)danmakuModel {
    if (self = [super init]) {
        self.danmakuModel = danmakuModel;
    }
    return self;
}

@end

//_______________________________________________________________________________________________________________

@interface HJDanmakuView ()

@property (nonatomic, strong) HJDanmakuConfiguration *configuration;
@property (nonatomic, assign) BOOL isPrepared;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) NSMutableDictionary *cellClassInfo;
@property (nonatomic, strong) NSMutableDictionary *cellReusePool;

@end

@implementation HJDanmakuView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(HJDanmakuConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        self.configuration = configuration;
        self.cellClassInfo = [NSMutableDictionary dictionary];
        self.cellReusePool = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    if (identifier.length < 1) {
        return;
    }
    self.cellClassInfo[identifier] = cellClass;
}

- (HJDanmakuCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    return nil;
}

#pragma mark -

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    
}

- (void)start {
    if (!self.configuration) {
        NSAssert(NO, @"configuration nil");
        return;
    }
    
    
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    
}

#pragma mark -

- (void)sendDanmaku:(HJDanmakuModel *)danmaku {
    if (!danmaku) {
        return;
    }
    [self sendDanmakus:@[danmaku]];
}

- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    
}

@end
