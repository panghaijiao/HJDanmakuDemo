//
//  DanmakuRenderer.m
//  DanmakuDemo
//
//  Created by Haijiao on 15/2/28.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import "DanmakuRenderer.h"
#import "DanmakuBaseModel.h"
#import "DanmakuRetainer.h"
#import "DanmakuTime.h"
#import "DanmakuView.h"

@interface DanmakuRenderer () {
    float _canvasWidth;
    NSMutableArray *_drawArray;
    NSMutableArray *_cacheLabels;
}

@property (nonatomic, weak) UIView *canvas;
@property (nonatomic, strong) DanmakuRetainer *danmakuLRRetainer;
@property (nonatomic, strong) DanmakuRetainer *danmakuFTRetainer;
@property (nonatomic, strong) DanmakuRetainer *danmakuFBRetainer;

@end

@implementation DanmakuRenderer

- (instancetype)initWithCanvas:(UIView *)canvas Configuration:(DanmakuConfiguration *)configuration
{
    if (self = [super init]) {
        _danmakuLRRetainer = [[DanmakuRetainer alloc] init];
        _danmakuFTRetainer = [[DanmakuFTRetainer alloc] init];
        _danmakuFBRetainer = [[DanmakuFBRetainer alloc] init];
        [self setConfiguration:configuration];
        self.canvas = canvas;
        [self setCanvasFrameSize];
    }
    return self;
}

- (void)setConfiguration:(DanmakuConfiguration *)configuration
{
    [self stopRenderer];
    NSInteger count = configuration.maxShowCount+5;
    _drawArray = [[NSMutableArray alloc] initWithCapacity:count];
    _cacheLabels = [[NSMutableArray alloc] initWithCapacity:count];
    _configuration = configuration;
    _danmakuLRRetainer.configuration = configuration;
    _danmakuFTRetainer.configuration = configuration;
    _danmakuFBRetainer.configuration = configuration;
}

- (void)setCanvasFrameSize
{
    _canvasWidth = CGRectGetWidth(self.canvas.frame);
    _danmakuLRRetainer.canvasSize = self.canvas.frame.size;
    _danmakuFTRetainer.canvasSize = self.canvas.frame.size;
    _danmakuFBRetainer.canvasSize = self.canvas.frame.size;
}

- (void)updateCanvasFrame
{
    [self setCanvasFrameSize];
    
    [self.danmakuFTRetainer clear];
    [self.danmakuFBRetainer clear];
    for (NSInteger index=0; index<_drawArray.count; index++) {
        DanmakuBaseModel *danmaku = _drawArray[index];
        if (danmaku.danmakuType!=DanmakuTypeLR) {
            danmaku.isShowing = NO;
            [self rendererDanmaku:danmaku];
        }
        
        if (CGRectGetMaxY(danmaku.label.frame)>CGRectGetHeight(self.canvas.frame)) {
            [self removeDanmaku:danmaku];
            [_drawArray removeObjectAtIndex:index];
        } else {
            danmaku.isShowing = YES;
        }
    }
}

#pragma mark - Label
- (void)removeLabelForDanmaku:(DanmakuBaseModel *)danmaku
{
    UILabel *cacheLabel = danmaku.label;
    if (cacheLabel) {
        [cacheLabel.layer removeAllAnimations];
        [_cacheLabels addObject:cacheLabel];
        danmaku.label = nil;
    }
}

- (void)createLabelForDanmaku:(DanmakuBaseModel *)danmaku
{
    if (danmaku.label) {
        return;
    }
    if (_cacheLabels.count<1) {
        danmaku.label = [[DanmakuLabel alloc] init];
        danmaku.label.backgroundColor = [UIColor clearColor];
    } else {
        danmaku.label = [_cacheLabels lastObject];
        [_cacheLabels removeLastObject];
    }
}

#pragma mark - Draw
- (void)drawDanmakus:(NSArray *)danmakus Time:(DanmakuTime *)time IsBuffering:(BOOL)isBuffering
{
    int LRShowCount = 0;
    for (NSInteger index=0; index<_drawArray.count;) {
        DanmakuBaseModel *danmaku = _drawArray[index];
        danmaku.remainTime -= time.interval;
        if (danmaku.remainTime<0) {
            [self removeDanmaku:danmaku];
            [_drawArray removeObjectAtIndex:index];
            continue;
        }
        if (danmaku.danmakuType==DanmakuTypeLR) {
            LRShowCount++;
        }
        [self rendererDanmaku:danmaku];
        index++;
    }
    if (isBuffering) {
        return;
    }
    for (DanmakuBaseModel *danmaku in [danmakus objectEnumerator]) {
        if ([danmaku isLate:time.time]) {
            break;
        }
        if (_drawArray.count>=self.configuration.maxShowCount && !danmaku.isSelfID) {
            break;
        }
        if (danmaku.isShowing) {
            continue;
        }
        if (![danmaku isDraw:time.time]) {
            continue;
        }
        if (danmaku.danmakuType==DanmakuTypeLR) {
            if (LRShowCount>self.configuration.maxLRShowCount && !danmaku.isSelfID) {
                continue;
            } else {
                LRShowCount++;
            }
        }
        [self createLabelForDanmaku:danmaku];
        [self rendererDanmakuLabel:danmaku];
        [_drawArray addObject:danmaku];
        danmaku.remainTime = danmaku.time-time.time+danmaku.duration;
        danmaku.retainer = [self getHitDicForType:danmaku.danmakuType];
        [self rendererDanmaku:danmaku];
        if (danmaku.py>=0) {
            NSInteger zIndex = danmaku.danmakuType==DanmakuTypeLR?0:10;
            [self.canvas insertSubview:danmaku.label atIndex:zIndex];
            danmaku.isShowing = YES;
        }
    }
}

- (void)removeDanmaku:(DanmakuBaseModel *)danmaku
{
    [danmaku.retainer clearVisibleDanmaku:danmaku];
    danmaku.retainer = nil;
    [danmaku.label removeFromSuperview];
    danmaku.isShowing = NO;
    [self removeLabelForDanmaku:danmaku];
}

- (DanmakuRetainer *)getHitDicForType:(DanmakuType)type
{
    switch (type) {
        case DanmakuTypeLR:return _danmakuLRRetainer;
        case DanmakuTypeFT:return _danmakuFTRetainer;
        case DanmakuTypeFB:return _danmakuFBRetainer;
    }
}

#pragma mark - Renderer
- (void)rendererDanmakuLabel:(DanmakuBaseModel *)danmaku
{
    [danmaku measureSizeWithPaintHeight:self.configuration.paintHeight];
    danmaku.label.alpha = 1;
    danmaku.label.font = [UIFont systemFontOfSize:danmaku.textSize];
    danmaku.label.text = danmaku.text;
    danmaku.label.textColor = danmaku.textColor;
    danmaku.label.underLineEnable = danmaku.isSelfID;
}

- (void)rendererDanmaku:(DanmakuBaseModel *)danmaku
{
    [danmaku layoutWithScreenWidth:_canvasWidth];
    if (!danmaku.isShowing) {
        float py = [danmaku.retainer layoutPyForDanmaku:danmaku];
        if (py<0) {
            if (danmaku.isSelfID) {
                py = danmaku.danmakuType!=DanmakuTypeFB?0:(CGRectGetHeight(self.canvas.frame)-self.configuration.paintHeight);
            } else {
                danmaku.remainTime = -1;
            }
        }
        danmaku.py = py;
    } else if (danmaku.danmakuType!=DanmakuTypeLR) {
        return;
    }
    if (danmaku.isShowing) {
        [UIView animateWithDuration:danmaku.remainTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            danmaku.label.frame = CGRectMake(-danmaku.size.width, danmaku.py, danmaku.size.width, danmaku.size.height);
        } completion:nil];
    } else {
        danmaku.label.frame = CGRectMake(danmaku.px, danmaku.py, danmaku.size.width, danmaku.size.height);
    }
}

#pragma mark -
- (void)pauseRenderer
{
    for (DanmakuBaseModel *danmaku in _drawArray.objectEnumerator) {
        if (danmaku.danmakuType!=DanmakuTypeLR) {
            continue;
        }
        CALayer *layer = danmaku.label.layer;
        CGRect rect = danmaku.label.frame;
        if (layer.presentationLayer) {
            rect = ((CALayer *)layer.presentationLayer).frame;
            rect.origin.x-=1;
        }
        danmaku.label.frame = rect;
        [danmaku.label.layer removeAllAnimations];
    }
}

- (void)stopRenderer
{
    for (DanmakuBaseModel *danmaku in _drawArray.objectEnumerator) {
        [danmaku.label removeFromSuperview];
        [self removeLabelForDanmaku:danmaku];
        danmaku.remainTime = -1;
        danmaku.isShowing = NO;
        danmaku.retainer = nil;
    }
    [_drawArray removeAllObjects];
    [self.danmakuLRRetainer clear];
    [self.danmakuFTRetainer clear];
    [self.danmakuFBRetainer clear];
}

@end
