//
//  DanmakuView.m
//  DanmakuView
//
//  Created by Haijiao on 15/3/12.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import "DanmakuView.h"
#import "DanmakuFactory.h"
#import "DanmakuFilter.h"
#import "DanmakuRenderer.h"
#import "DanmakuTime.h"

#define DanmakuFilterInterval     5

@implementation DanmakuConfiguration

@end

//_______________________________________________________________________________________________________________

@implementation DanmakuSource

+ (instancetype)createWithP:(NSString *)p M:(NSString *)m {
    DanmakuSource *danmakuSource = [[DanmakuSource alloc] init];
    danmakuSource.p = p;
    danmakuSource.m = m;
    return danmakuSource;
}

@end

@interface DanmakuView () {
    CADisplayLink *_displayLink;
    float _timeCount;
    
    float _frameInterval;
    DanmakuTime *_danmakuTime;
}

@property (nonatomic, strong) DanmakuConfiguration *configuration;

@property (nonatomic, assign) BOOL isPrepared;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPreFilter;

@property (nonatomic, strong) NSArray  *danmakus;
@property (nonatomic, strong) NSArray  *curDanmakus;

@property (nonatomic, strong) DanmakuFilter   *danmakuFilter;
@property (nonatomic, strong) DanmakuRenderer *danmakuRenderer;

@end

@implementation DanmakuView

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(DanmakuConfiguration *)configuration; {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        self.configuration = configuration;
        _frameInterval = 0.5;
        _danmakuTime = [[DanmakuTime alloc] init];
        self.danmakuFilter = [[DanmakuFilter alloc] init];
        self.danmakuRenderer = [[DanmakuRenderer alloc] initWithCanvas:self configuration:configuration];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        [_danmakuRenderer updateCanvasFrame];
    }
}

#pragma mark - Interface

- (void)prepareDanmakus:(NSArray <NSDictionary *> *)danmakus {
    self.isPrepared = NO;
    self.danmakus = nil;
    self.curDanmakus = nil;
    NSArray *items = danmakus;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *danmakus = [NSMutableArray arrayWithCapacity:items.count];
        for (NSDictionary *dic in items.objectEnumerator) {
            if ([dic isKindOfClass:[NSDictionary class]]) {
                NSString *pString = dic[@"p"];
                NSString *mString = dic[@"m"];
                DanmakuSource *danmakuSource = [DanmakuSource createWithP:pString M:mString];
                DanmakuBaseModel *danmaku = [DanmakuFactory createDanmakuWithDanmakuSource:danmakuSource
                                                                             configuration:self.configuration];
                if (danmaku) {
                    [danmakus addObject:danmaku];
                }
            }
        }
        
        [danmakus sortUsingComparator:^NSComparisonResult(DanmakuBaseModel *obj1, DanmakuBaseModel *obj2) {
            return obj1.time < obj2.time ? NSOrderedAscending: NSOrderedDescending;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.danmakus = danmakus;
            self.isPrepared = YES;
            self.isPreFilter = YES;
            if ([self.delegate respondsToSelector:@selector(danmakuViewPerpareComplete:)]) {
                [self.delegate danmakuViewPerpareComplete:self];
            }
        });
    });
}

- (void)prepareDanmakuSources:(NSArray *)danmakuSources {
    self.isPrepared = NO;
    self.danmakus = nil;
    self.curDanmakus = nil;
    NSArray *items = danmakuSources;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *danmakus = [NSMutableArray arrayWithCapacity:items.count];
        for (DanmakuSource *danmakuSource in items.objectEnumerator) {
            if ([danmakuSource isKindOfClass:[DanmakuSource class]]) {
                DanmakuBaseModel *danmaku = [DanmakuFactory createDanmakuWithDanmakuSource:danmakuSource
                                                                             configuration:self.configuration];
                if (danmaku) {
                    [danmakus addObject:danmaku];
                }
            }
        }
        
        [danmakus sortUsingComparator:^NSComparisonResult(DanmakuBaseModel *obj1, DanmakuBaseModel *obj2) {
            return obj1.time < obj2.time ? NSOrderedAscending: NSOrderedDescending;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.danmakus = danmakus;
            self.isPrepared = YES;
            self.isPreFilter = YES;
            if ([self.delegate respondsToSelector:@selector(danmakuViewPerpareComplete:)]) {
                [self.delegate danmakuViewPerpareComplete:self];
            }
        });
    });
}

- (void)start {
    if (!self.delegate) {
        return;
    }
    [self resume];
}

- (void)resume {
    if (self.isPlaying || !self.isPrepared) {
        return;
    }
    self.isPlaying = YES;
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimeCount)];
        _displayLink.preferredFramesPerSecond = 1.0 / _frameInterval;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    _displayLink.paused = NO;
}

- (void)pause {
    BOOL isBuffering = [self.delegate danmakuViewIsBuffering:self];
    if (!self.isPlaying || isBuffering) {
        return;
    }
    self.isPlaying = NO;
    _displayLink.paused = YES;
    [self.danmakuRenderer pauseRenderer];
}

- (void)stop {
    self.isPlaying = NO;
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    [self.danmakuRenderer stopRenderer];
}

#pragma mark - Draw

- (void)onTimeCount {
    float playTime = [self.delegate danmakuViewGetPlayTime:self];
    if (playTime <= 0) {
        return;
    }
    
    float interval = playTime -_danmakuTime.time;
    _danmakuTime.time = playTime;
    _danmakuTime.interval = _frameInterval;
    
    if (self.isPreFilter || interval<0 || interval > DanmakuFilterInterval) {
        self.isPreFilter = NO;
        self.curDanmakus = [self.danmakuFilter filterDanmakus:self.danmakus time:_danmakuTime];
    }
    
    BOOL isBuffering = [self.delegate danmakuViewIsBuffering:self];
    [self.danmakuRenderer drawDanmakus:self.curDanmakus time:_danmakuTime isBuffering:isBuffering];
    
    _timeCount += _frameInterval;
    if (_timeCount > DanmakuFilterInterval) {
        _timeCount = 0;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *filterArray = [self.danmakuFilter filterDanmakus:self.danmakus time:self->_danmakuTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.curDanmakus = filterArray;
            });
        });
    }
}

#pragma mark - Send

- (void)sendDanmakuSource:(DanmakuSource *)danmakuSource {
    __block DanmakuBaseModel *sendDanmaku = [DanmakuFactory createDanmakuWithDanmakuSource:danmakuSource
                                                                             configuration:self.configuration];
    if (!sendDanmaku) {
        return;
    }
    
    sendDanmaku.isSelfID = self.configuration.isShowLineWhenSelf;
    
    __block NSMutableArray *newDanmakus = [NSMutableArray arrayWithArray:self.danmakus];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        DanmakuBaseModel *lastDanmaku = newDanmakus.lastObject;
        if (newDanmakus.count < 1 || sendDanmaku.time > lastDanmaku.time) {
            [newDanmakus addObject:sendDanmaku];
        } else {
            DanmakuBaseModel *tempDanmaku = nil;
            for (NSInteger index = 0; index < newDanmakus.count; index++) {
                tempDanmaku = newDanmakus[index];
                if (sendDanmaku.time < tempDanmaku.time) {
                    [newDanmakus insertObject:sendDanmaku atIndex:index];
                    break;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.danmakus = newDanmakus;
            self.isPreFilter = YES;
        });
    });
}

@end
