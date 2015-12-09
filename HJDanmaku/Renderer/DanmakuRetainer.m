//
//  DanmakuRetainer.m
//  DanmakuDemo
//
//  Created by Haijiao on 15/3/3.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import "DanmakuRetainer.h"
#import "DanmakuBaseModel.h"

@interface DanmakuRetainer ()

@property (nonatomic, strong) NSMutableDictionary *hitDanmakus;
@property (nonatomic, assign) NSInteger maxPyIndex;

@end

@implementation DanmakuRetainer

- (instancetype)init
{
    if (self = [super init]) {
        _hitDanmakus = [[NSMutableDictionary alloc] initWithCapacity:self.configuration.maxShowCount+5];;
    }
    return self;
}

- (void)setCanvasSize:(CGSize)canvasSize
{
    _canvasSize = canvasSize;
    self.maxPyIndex = canvasSize.height/self.configuration.paintHeight;
}

- (void)clearVisibleDanmaku:(DanmakuBaseModel *)danmaku
{
    u_int8_t pyIndex = danmaku.py/self.configuration.paintHeight;
    id key = @(pyIndex);
    DanmakuBaseModel *hitDanmaku = self.hitDanmakus[key];
    if (hitDanmaku==danmaku) {
        [self.hitDanmakus removeObjectForKey:key];
    }
}

- (float)layoutPyForDanmaku:(DanmakuBaseModel *)danmaku
{
    float py = -self.configuration.paintHeight;
    DanmakuBaseModel *tempDanmaku = nil;
    for (u_int8_t index = 0; index<_maxPyIndex; index++) {
        tempDanmaku = self.hitDanmakus[@(index)];
        if (!tempDanmaku) {
            self.hitDanmakus[@(index)] = danmaku;
            py = [self getpyDicForType:danmaku.danmakuType Index:index];
            break;
        }
        if (![self checkIsWillHitWithWidth:_canvasSize.width DanmakuL:tempDanmaku DanmakuR:danmaku]) {
            self.hitDanmakus[@(index)] = danmaku;
            py = [self getpyDicForType:danmaku.danmakuType Index:index];
            break;
        }
    }
    return py;
}

- (float )getpyDicForType:(DanmakuType)type Index:(u_int8_t)index
{
    return index*self.configuration.paintHeight;
}

- (BOOL)checkIsWillHitWithWidth:(float)width DanmakuL:(DanmakuBaseModel *)danmakuL DanmakuR:(DanmakuBaseModel *)danmakuR
{
    if (danmakuL.remainTime<=0) {
        return NO;
    }
    if (danmakuL.px+danmakuL.size.width>danmakuR.px) {
        return YES;
    }
    float minRemainTime = MIN(danmakuL.remainTime, danmakuR.remainTime);
    float px1 = [danmakuL pxWithScreenWidth:width RemainTime:(danmakuL.remainTime-minRemainTime)];
    float px2 = [danmakuR pxWithScreenWidth:width RemainTime:(danmakuR.remainTime-minRemainTime)];
    if (px1+danmakuL.size.width>px2) {
        return YES;
    }
    return NO;
}

- (void)clear
{
    [_hitDanmakus removeAllObjects];
}

@end

@implementation DanmakuFTRetainer

- (void)setCanvasSize:(CGSize)canvasSize
{
    [super setCanvasSize:canvasSize];
    self.maxPyIndex /=2;
}

- (BOOL)checkIsWillHitWithWidth:(float)width DanmakuL:(DanmakuBaseModel *)danmakuL DanmakuR:(DanmakuBaseModel *)danmakuR
{
    if (danmakuL.remainTime<=0) {
        return NO;
    }
    return YES;
}

@end

@implementation DanmakuFBRetainer

- (float )getpyDicForType:(DanmakuType)type Index:(u_int8_t)index
{
    return self.canvasSize.height-self.configuration.paintHeight*(index+1);
}

@end
