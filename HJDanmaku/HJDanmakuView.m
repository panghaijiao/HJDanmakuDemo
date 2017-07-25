//
//  HJDanmakuView.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuView.h"
#import <libkern/OSAtomic.h>

@class HJDanmakuRetainer;

static const CGFloat HJFrameInterval = 0.2;

static inline void onMainThreadAsync(void (^block)()) {
    if ([NSThread isMainThread]) block();
    else dispatch_async(dispatch_get_main_queue(), block);
}

static inline void onGlobalThreadAsync(void (^block)()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

//_______________________________________________________________________________________________________________

@interface HJDanmakuAgent : NSObject

@property (nonatomic, strong) HJDanmakuModel *danmakuModel;
@property (nonatomic, strong) HJDanmakuCell  *danmakuCell;

@property (nonatomic, assign) BOOL force;

@property (nonatomic, assign) NSInteger toleranceCount;
@property (nonatomic, assign) CGFloat remainingTime;
@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, assign) CGFloat px;
@property (nonatomic, assign) CGFloat py;
@property (nonatomic, assign) CGSize size;

// the line of trajectory, default -1
@property (nonatomic, assign) NSInteger yIdx;

- (instancetype)initWithDanmakuModel:(HJDanmakuModel *)danmakuModel;

@end

@implementation HJDanmakuAgent

- (instancetype)initWithDanmakuModel:(HJDanmakuModel *)danmakuModel {
    if (self = [super init]) {
        self.danmakuModel = danmakuModel;
        self.yIdx = -1;
    }
    return self;
}

@end

//_______________________________________________________________________________________________________________

@interface HJDanmakuSource : NSObject {
    OSSpinLock _spinLock;
}

@property (nonatomic, strong) NSMutableArray <HJDanmakuAgent *> *danmakuAgents;

+ (HJDanmakuSource *)danmakuSourceWithMode:(HJDanmakuMode)mode;

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus completion:(void (^)(void))completion;
- (void)sendDanmaku:(HJDanmakuModel *)danmaku forceRender:(BOOL)force;
- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus;

- (NSArray *)fetchDanmakuAgentsForTime:(HJDanmakuTime)time;

@end

@implementation HJDanmakuSource

+ (HJDanmakuSource *)danmakuSourceWithMode:(HJDanmakuMode)mode {
    Class class = mode == HJDanmakuModeVideo ? NSClassFromString(@"HJDanmakuVideoSource"): NSClassFromString(@"HJDanmakuLiveSource");
    return [class new];
}

- (instancetype)init {
    if (self = [super init]) {
        _spinLock = OS_SPINLOCK_INIT;
        self.danmakuAgents = [NSMutableArray array];
    }
    return self;
}

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus completion:(void (^)(void))completion {
    NSAssert(NO, @"subClass implementation");
}

- (void)sendDanmaku:(HJDanmakuModel *)danmaku forceRender:(BOOL)force {
    NSAssert(NO, @"subClass implementation");
}

- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    NSAssert(NO, @"subClass implementation");
}

- (NSArray *)fetchDanmakuAgentsForTime:(HJDanmakuTime)time {
    NSAssert(NO, @"subClass implementation");
    return nil;
}

@end

//______________________________

@interface HJDanmakuVideoSource : HJDanmakuSource

@end

@implementation HJDanmakuVideoSource

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus completion:(void (^)(void))completion {
    onGlobalThreadAsync(^{
        NSArray *sortDanmakus = [danmakus sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *agents = [NSMutableArray arrayWithCapacity:sortDanmakus.count];
        [sortDanmakus enumerateObjectsUsingBlock:^(HJDanmakuModel *danmaku, NSUInteger idx, BOOL *stop) {
            HJDanmakuAgent *agent = [[HJDanmakuAgent alloc] initWithDanmakuModel:danmaku];
            [agents addObject:agent];
        }];
        self.danmakuAgents = agents;
        if (completion) {
            completion();
        }
    });
}

- (void)sendDanmaku:(HJDanmakuModel *)danmaku forceRender:(BOOL)force {
    HJDanmakuAgent *agent = [[HJDanmakuAgent alloc] initWithDanmakuModel:danmaku];
    agent.force = force;
    OSSpinLockLock(&_spinLock);
    [self.danmakuAgents addObject:agent];
    OSSpinLockUnlock(&_spinLock);
}

- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    onGlobalThreadAsync(^{
        u_int interval = 100;
        NSMutableArray *agents = [NSMutableArray arrayWithCapacity:interval];
        NSUInteger lastIndex = danmakus.count - 1;
        [danmakus enumerateObjectsUsingBlock:^(HJDanmakuModel *danmaku, NSUInteger idx, BOOL *stop) {
            HJDanmakuAgent *agent = [[HJDanmakuAgent alloc] initWithDanmakuModel:danmaku];
            [agents addObject:agent];
            if (idx == lastIndex || agents.count % interval == 0) {
                OSSpinLockLock(&_spinLock);
                [self.danmakuAgents addObjectsFromArray:agents];
                OSSpinLockUnlock(&_spinLock);
                [agents removeAllObjects];
            }
        }];
    });
}

- (NSArray *)fetchDanmakuAgentsForTime:(HJDanmakuTime)time {
    return nil;
}

@end

//______________________________

@interface HJDanmakuLiveSource : HJDanmakuSource

@end

@implementation HJDanmakuLiveSource

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus completion:(void (^)(void))completion {
    onGlobalThreadAsync(^{
        NSMutableArray *agents = [NSMutableArray arrayWithCapacity:danmakus.count];
        [danmakus enumerateObjectsUsingBlock:^(HJDanmakuModel *danmaku, NSUInteger idx, BOOL *stop) {
            HJDanmakuAgent *agent = [[HJDanmakuAgent alloc] initWithDanmakuModel:danmaku];
            [agents addObject:agent];
        }];
        self.danmakuAgents = agents;
        if (completion) {
            completion();
        }
    });
}

- (void)sendDanmaku:(HJDanmakuModel *)danmaku forceRender:(BOOL)force {
    HJDanmakuAgent *agent = [[HJDanmakuAgent alloc] initWithDanmakuModel:danmaku];
    agent.force = force;
    OSSpinLockLock(&_spinLock);
    [self.danmakuAgents addObject:agent];
    OSSpinLockUnlock(&_spinLock);
}

- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    onGlobalThreadAsync(^{
        u_int interval = 100;
        NSMutableArray *agents = [NSMutableArray arrayWithCapacity:interval];
        NSUInteger lastIndex = danmakus.count - 1;
        [danmakus enumerateObjectsUsingBlock:^(HJDanmakuModel *danmaku, NSUInteger idx, BOOL *stop) {
            HJDanmakuAgent *agent = [[HJDanmakuAgent alloc] initWithDanmakuModel:danmaku];
            [agents addObject:agent];
            if (idx == lastIndex || agents.count % interval == 0) {
                OSSpinLockLock(&_spinLock);
                [self.danmakuAgents addObjectsFromArray:agents];
                OSSpinLockUnlock(&_spinLock);
                [agents removeAllObjects];
            }
        }];
    });
}

- (NSArray *)fetchDanmakuAgentsForTime:(HJDanmakuTime)time {
    OSSpinLockLock(&_spinLock);
    NSArray *danmakuAgents = [self.danmakuAgents copy];
    [self.danmakuAgents removeAllObjects];
    OSSpinLockUnlock(&_spinLock);
    return danmakuAgents;
}

@end

//_______________________________________________________________________________________________________________

#if OS_OBJECT_USE_OBJC
#define HJDispatchQueueRelease(__v)
#else
#define HJDispatchQueueRelease(__v) (dispatch_release(__v));
#endif

@interface HJDanmakuView () {
    OSSpinLock _reuseLock;
    dispatch_queue_t _renderQueue;
}

@property (nonatomic, strong) HJDanmakuConfiguration *configuration;
@property (nonatomic, assign) NSUInteger toleranceCount;

@property (nonatomic, strong) HJDanmakuSource *danmakuSource;
@property (nonatomic, strong) NSOperationQueue *sourceQueue;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) HJDanmakuTime playTime;

@property (atomic, assign) BOOL isPrepared;
@property (atomic, assign) BOOL isPlaying;

@property (nonatomic, strong) NSMutableDictionary *cellClassInfo;
@property (nonatomic, strong) NSMutableDictionary *cellReusePool;

@property (nonatomic, strong) NSMutableArray <HJDanmakuAgent *> *danmakuQueuePool;
@property (nonatomic, strong) NSMutableArray <HJDanmakuAgent *> *renderingDanmakus;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, HJDanmakuAgent *> *LRRetainer;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, HJDanmakuAgent *> *FTRetainer;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, HJDanmakuAgent *> *FBRetainer;

@end

@implementation HJDanmakuView

- (void)dealloc {
    NSLog(@">>> dealloc");
    HJDispatchQueueRelease(_renderQueue);
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(HJDanmakuConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.configuration = configuration;
        self.toleranceCount = (NSUInteger)(fabs(self.configuration.tolerance) / HJFrameInterval);
        self.toleranceCount = MAX(self.toleranceCount, 1);
        self.cellClassInfo = [NSMutableDictionary dictionary];
        self.cellReusePool = [NSMutableDictionary dictionary];
        self.danmakuQueuePool = [NSMutableArray array];
        self.renderingDanmakus = [NSMutableArray array];
        self.LRRetainer = [NSMutableDictionary dictionary];
        self.FTRetainer = [NSMutableDictionary dictionary];
        self.FBRetainer = [NSMutableDictionary dictionary];
        self.danmakuSource = [HJDanmakuSource danmakuSourceWithMode:configuration.danmakuMode];
        
        self.sourceQueue = [NSOperationQueue new];
        self.sourceQueue.name = @"com.olinone.danmaku.sourceQueue";
        self.sourceQueue.maxConcurrentOperationCount = 1;
        
        _reuseLock = OS_SPINLOCK_INIT;
        _renderQueue = dispatch_queue_create("com.olinone.danmaku.renderQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_renderQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        NSLog(@">>> init");
    }
    return self;
}

#pragma mark -

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    if (!identifier) {
        return;
    }
    self.cellClassInfo[identifier] = cellClass;
}

- (HJDanmakuCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    NSMutableArray *cells = self.cellReusePool[identifier];
    if (cells.count == 0) {
        Class cellClass = self.cellClassInfo[identifier];
        return cellClass ? [[cellClass alloc] initWithReuseIdentifier:identifier]: nil;
    }
    OSSpinLockLock(&_reuseLock);
    HJDanmakuCell *cell = cells.lastObject;
    [cells removeLastObject];
    OSSpinLockUnlock(&_reuseLock);
    cell.zIndex = 0;
    [cell prepareForReuse];
    return cell;
}

- (void)recycleCellToReusePool:(HJDanmakuCell *)danmakuCell {
    NSString *identifier = danmakuCell.reuseIdentifier;
    if (!identifier) {
        return;
    }
    OSSpinLockLock(&_reuseLock);
    NSMutableArray *cells = self.cellReusePool[identifier];
    if (!cells) {
        cells = [NSMutableArray array];
        self.cellReusePool[identifier] = cells;
    }
    [cells addObject:danmakuCell];
    OSSpinLockUnlock(&_reuseLock);
}

#pragma mark -

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    self.isPrepared = NO;
    [self stop];
    
    if (danmakus.count == 0) {
        self.isPrepared = YES;
        onMainThreadAsync(^{
            if ([self.delegate respondsToSelector:@selector(prepareCompletedWithDanmakuView:)]) {
                [self.delegate prepareCompletedWithDanmakuView:self];
            }
        });
        return;
    }
    
    [self.danmakuSource prepareDanmakus:danmakus completion:^{
        self.isPrepared = YES;
        onMainThreadAsync(^{
            if ([self.delegate respondsToSelector:@selector(prepareCompletedWithDanmakuView:)]) {
                [self.delegate prepareCompletedWithDanmakuView:self];
            }
        });
    }];
}

- (void)play {
    if (!self.configuration || self.configuration.duration <= 0) {
        NSAssert(NO, @"configuration nil or duration <= 0");
        return;
    }
    if (!self.isPrepared) {
        NSAssert(NO, @"isPrepared is NO!");
        return;
    }
    if (self.isPlaying) {
        return;
    }
    self.isPlaying = YES;
    [self resumeDisplayingDanmakus];
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        self.displayLink.frameInterval = 60.0 * HJFrameInterval;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    self.displayLink.paused = NO;
}

- (void)pause {
    if (!self.isPlaying) {
        return;
    }
    self.isPlaying = NO;
    self.displayLink.paused = YES;
    [self pauseDisplayingDanmakus];
}

- (void)stop {
    self.isPlaying = NO;
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.playTime = (HJDanmakuTime){0, HJFrameInterval};
    dispatch_async(_renderQueue, ^{
        [self.danmakuQueuePool removeAllObjects];
    });
    [self clearScreen];
}

- (void)clearScreen {
    [self recycleDanmakuAgents:[self.renderingDanmakus copy]];
    dispatch_async(_renderQueue, ^{
        [self.renderingDanmakus removeAllObjects];
        [self.LRRetainer removeAllObjects];
        [self.FTRetainer removeAllObjects];
        [self.FBRetainer removeAllObjects];
    });
}

#pragma mark -

- (void)pauseDisplayingDanmakus {
    NSArray *danmakuAgents = [self visibleDanmakuAgents];
    onMainThreadAsync(^{
        for (HJDanmakuAgent *danmakuAgent in danmakuAgents) {
            if (danmakuAgent.danmakuModel.danmakuType == HJDanmakuTypeLR) {
                CALayer *layer = danmakuAgent.danmakuCell.layer;
                danmakuAgent.danmakuCell.frame = ((CALayer *)layer.presentationLayer).frame;
                [danmakuAgent.danmakuCell.layer removeAllAnimations];
            }
        }
    });
}

- (void)resumeDisplayingDanmakus {
    NSArray *danmakuAgents = [self visibleDanmakuAgents];
    onMainThreadAsync(^{
        for (HJDanmakuAgent *danmakuAgent in danmakuAgents) {
            if (danmakuAgent.danmakuModel.danmakuType == HJDanmakuTypeLR) {
                [UIView animateWithDuration:danmakuAgent.remainingTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    danmakuAgent.danmakuCell.frame = (CGRect){CGPointMake(-danmakuAgent.size.width, danmakuAgent.py), danmakuAgent.size};
                } completion:nil];
            }
        }
    });
}

#pragma mark - Render

- (void)update {
    HJDanmakuTime time = {0, HJFrameInterval};
    if ([self.dataSource respondsToSelector:@selector(playTimeWithDanmakuView:)]) {
        time.time = [self.dataSource playTimeWithDanmakuView:self];
    }
    if (self.configuration.danmakuMode == HJDanmakuModeVideo && time.time <= 0) {
        return;
    }
    BOOL isBuffering = NO;
    if ([self.dataSource respondsToSelector:@selector(bufferingWithDanmakuView:)]) {
        isBuffering = [self.dataSource bufferingWithDanmakuView:self];
    }
    if (!isBuffering) {
        [self loadDanmakusFromSourceForTime:time];
    }
    [self renderDanmakusForTime:time buffering:isBuffering];
}

- (void)loadDanmakusFromSourceForTime:(HJDanmakuTime)time {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSArray <HJDanmakuAgent *> *danmakuAgents = [self.danmakuSource fetchDanmakuAgentsForTime:(HJDanmakuTime){NSMaxTime(time), time.interval}];
        if (danmakuAgents.count > 0) {
            [danmakuAgents enumerateObjectsUsingBlock:^(HJDanmakuAgent *danmakuAgent, NSUInteger idx, BOOL *stop) {
                danmakuAgent.remainingTime = self.configuration.duration;
                danmakuAgent.toleranceCount = self.toleranceCount;
            }];
            dispatch_async(_renderQueue, ^{
                if (time.time < self.playTime.time || time.time > self.playTime.time + self.configuration.tolerance) {
                    [self.danmakuQueuePool removeAllObjects];
                }
                [self.danmakuQueuePool insertObjects:danmakuAgents atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, danmakuAgents.count)]];
                self.playTime = time;
            });
        }
    }];
    [self.sourceQueue cancelAllOperations];
    [self.sourceQueue addOperation:operation];
}

- (void)renderDanmakusForTime:(HJDanmakuTime)time buffering:(BOOL)isBuffering {
    dispatch_async(_renderQueue, ^{
        [self renderDisplayingDanmakusForTime:time];
        if (!isBuffering) {
            [self renderNewDanmakusForTime:time];
            [self removeExpiredDanmakusForTime:time];
        }
    });
}

- (void)renderDisplayingDanmakusForTime:(HJDanmakuTime)time {
    NSMutableArray *disappearDanmakuAgens = [NSMutableArray arrayWithCapacity:self.renderingDanmakus.count];
    [self.renderingDanmakus enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HJDanmakuAgent *danmakuAgent, NSUInteger idx, BOOL *stop) {
        danmakuAgent.remainingTime -= time.interval;
        if (danmakuAgent.remainingTime <= 0) {
            [disappearDanmakuAgens addObject:danmakuAgent];
            [self.renderingDanmakus removeObjectAtIndex:idx];
        }
    }];
    [self recycleDanmakuAgents:disappearDanmakuAgens];
}

- (void)recycleDanmakuAgents:(NSArray *)danmakuAgents {
    if (danmakuAgents.count == 0) {
        return;
    }
    onMainThreadAsync(^{
        for (HJDanmakuAgent *danmakuAgent in danmakuAgents) {
            [danmakuAgent.danmakuCell.layer removeAllAnimations];
            [danmakuAgent.danmakuCell removeFromSuperview];
            danmakuAgent.yIdx = -1;
            danmakuAgent.isShowing = NO;
            [self recycleCellToReusePool:danmakuAgent.danmakuCell];
            if ([self.delegate respondsToSelector:@selector(danmakuView:didEndDisplayCell:danmaku:)]) {
                [self.delegate danmakuView:self didEndDisplayCell:danmakuAgent.danmakuCell danmaku:danmakuAgent.danmakuModel];
            }
        }
    });
}

- (void)renderNewDanmakusForTime:(HJDanmakuTime)time {
    NSUInteger maxShowCount = self.configuration.maxShowCount > 0 ? self.configuration.maxShowCount : NSUIntegerMax;
    NSMutableDictionary *renderResult = [NSMutableDictionary dictionary];
    for (HJDanmakuAgent *danmakuAgent in self.danmakuQueuePool) {
        NSNumber *retainKey = @(danmakuAgent.danmakuModel.danmakuType);
        if (!danmakuAgent.force) {
            if (self.renderingDanmakus.count > maxShowCount) {
                break;
            }
            if (renderResult[@(HJDanmakuTypeLR)] && renderResult[@(HJDanmakuTypeFT)] && renderResult[@(HJDanmakuTypeFB)]) {
                break;
            }
            if (renderResult[retainKey]) {
                continue;
            }
        }
        BOOL shouldRender = YES;
        if ([self.delegate respondsToSelector:@selector(danmakuView:shouldRenderDanmaku:)]) {
            shouldRender = [self.delegate danmakuView:self shouldRenderDanmaku:danmakuAgent.danmakuModel];
        }
        if (!shouldRender) {
            continue;
        }
        if (![self renderNewDanmaku:danmakuAgent forTime:time]) {
            renderResult[retainKey] = @(YES);
        }
    }
}

- (BOOL)renderNewDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    if (![self layoutNewDanmaku:danmakuAgent forTime:time]) {
        return NO;
    }
    [self.renderingDanmakus addObject:danmakuAgent];
    danmakuAgent.toleranceCount = 0;
    onMainThreadAsync(^{
        danmakuAgent.isShowing = YES;
        danmakuAgent.danmakuCell = ({
            HJDanmakuCell *cell = [self.dataSource danmakuView:self cellForDanmaku:danmakuAgent.danmakuModel];
            cell.frame = (CGRect){CGPointMake(danmakuAgent.px, danmakuAgent.py), danmakuAgent.size};
            cell.zIndex = cell.zIndex > 0 ? cell.zIndex: (danmakuAgent.danmakuModel.danmakuType == HJDanmakuTypeLR ? 0: 10);
            cell;
        });
        if ([self.delegate respondsToSelector:@selector(danmakuView:willDisplayCell:danmaku:)]) {
            [self.delegate danmakuView:self willDisplayCell:danmakuAgent.danmakuCell danmaku:danmakuAgent.danmakuModel];
        }
        [self insertSubview:danmakuAgent.danmakuCell atIndex:danmakuAgent.danmakuCell.zIndex];
        if (danmakuAgent.danmakuModel.danmakuType == HJDanmakuTypeLR) {
            [UIView animateWithDuration:danmakuAgent.remainingTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                danmakuAgent.danmakuCell.frame = (CGRect){CGPointMake(-danmakuAgent.size.width, danmakuAgent.py), danmakuAgent.size};
            } completion:nil];
        }
    });
    return YES;
}

- (void)removeExpiredDanmakusForTime:(HJDanmakuTime)time {
    [self.danmakuQueuePool enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HJDanmakuAgent *danmakuAgent, NSUInteger idx, BOOL *stop) {
        danmakuAgent.toleranceCount --;
        if (danmakuAgent.toleranceCount <= 0) {
            [self.danmakuQueuePool removeObjectAtIndex:idx];
        }
    }];
}

#pragma mark - Retainer

- (BOOL)layoutNewDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    CGFloat width = [self.dataSource danmakuView:self widthForDanmaku:danmakuAgent.danmakuModel];
    danmakuAgent.size = CGSizeMake(width, self.configuration.cellHeight);
    CGFloat py = [self layoutPyWithNewDanmaku:danmakuAgent forTime:time];
    if (py < 0) {
        return NO;
    }
    danmakuAgent.py = py;
    danmakuAgent.px = danmakuAgent.danmakuModel.danmakuType == HJDanmakuTypeLR ? CGRectGetWidth(self.bounds): (CGRectGetMidX(self.bounds) - danmakuAgent.size.width / 2);
    return YES;
}

- (CGFloat)layoutPyWithNewDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    switch (danmakuAgent.danmakuModel.danmakuType) {
        case HJDanmakuTypeLR:
            return [self layoutPyWithLRDanmaku:danmakuAgent forTime:time];
        case HJDanmakuTypeFT:
            return [self layoutPyWithFTDanmaku:danmakuAgent forTime:time];
        case HJDanmakuTypeFB:
            return [self layoutPyWithFBDanmaku:danmakuAgent forTime:time];
    }
}

// LR
- (CGFloat)layoutPyWithLRDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    u_int8_t maxPyIndex = self.configuration.numberOfLines > 0 ? self.configuration.numberOfLines: (CGRectGetHeight(self.bounds) / self.configuration.cellHeight);
    NSMutableDictionary *retainer = [self retainerWithType:danmakuAgent.danmakuModel.danmakuType];
    for (u_int8_t index = 0; index < maxPyIndex; index++) {
        NSNumber *key = @(index);
        HJDanmakuAgent *tempAgent = retainer[key];
        if (!tempAgent) {
            danmakuAgent.yIdx = index;
            retainer[key] = danmakuAgent;
            return self.configuration.cellHeight * index;
        }
        if (![self checkLRIsWillHitWithPreDanmaku:tempAgent danmaku:danmakuAgent]) {
            danmakuAgent.yIdx = index;
            retainer[key] = danmakuAgent;
            return self.configuration.cellHeight * index;
        }
    }
    if (danmakuAgent.force) {
        u_int8_t index = arc4random() % maxPyIndex;
        danmakuAgent.yIdx = index;
        retainer[@(index)] = danmakuAgent;
        return self.configuration.cellHeight * index;
    }
    return -1;
}

- (BOOL)checkLRIsWillHitWithPreDanmaku:(HJDanmakuAgent *)preDanmakuAgent danmaku:(HJDanmakuAgent *)danmakuAgent {
    if (preDanmakuAgent.remainingTime <= 0) {
        return NO;
    }
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat preDanmakuSpeed = (width + preDanmakuAgent.size.width) / self.configuration.duration;
    if (preDanmakuSpeed * (self.configuration.duration - preDanmakuAgent.remainingTime) < preDanmakuAgent.size.width) {
        return YES;
    }
    CGFloat curDanmakuSpeed = (width + danmakuAgent.size.width) / self.configuration.duration;
    if (curDanmakuSpeed * preDanmakuAgent.remainingTime > width) {
        return YES;
    }
    return NO;
}

// FT
- (CGFloat)layoutPyWithFTDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    u_int8_t maxPyIndex = self.configuration.numberOfLines > 0 ? self.configuration.numberOfLines: (CGRectGetHeight(self.bounds) / 2.0 / self.configuration.cellHeight);
    NSMutableDictionary *retainer = [self retainerWithType:danmakuAgent.danmakuModel.danmakuType];
    for (u_int8_t index = 0; index < maxPyIndex; index++) {
        NSNumber *key = @(index);
        HJDanmakuAgent *tempAgent = retainer[key];
        if (!tempAgent) {
            danmakuAgent.yIdx = index;
            retainer[key] = danmakuAgent;
            return self.configuration.cellHeight * index;
        }
        if (![self checkFTIsWillHitWithPreDanmaku:tempAgent danmaku:danmakuAgent]) {
            danmakuAgent.yIdx = index;
            retainer[key] = danmakuAgent;
            return self.configuration.cellHeight * index;
        }
    }
    if (danmakuAgent.force) {
        u_int8_t index = arc4random() % maxPyIndex;
        danmakuAgent.yIdx = index;
        retainer[@(index)] = danmakuAgent;
        return self.configuration.cellHeight * index;
    }
    return -1;
}

- (BOOL)checkFTIsWillHitWithPreDanmaku:(HJDanmakuAgent *)preDanmakuAgent danmaku:(HJDanmakuAgent *)danmakuAgent {
    if (preDanmakuAgent.remainingTime <= 0) {
        return NO;
    }
    return YES;
}

// FB
- (CGFloat)layoutPyWithFBDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    u_int8_t maxPyIndex = self.configuration.numberOfLines > 0 ? self.configuration.numberOfLines: (CGRectGetHeight(self.bounds) / 2.0 / self.configuration.cellHeight);
    NSMutableDictionary *retainer = [self retainerWithType:danmakuAgent.danmakuModel.danmakuType];
    for (u_int8_t index = 0; index < maxPyIndex; index++) {
        NSNumber *key = @(index);
        HJDanmakuAgent *tempAgent = retainer[key];
        if (!tempAgent) {
            danmakuAgent.yIdx = index;
            retainer[key] = danmakuAgent;
            return CGRectGetHeight(self.bounds) - self.configuration.cellHeight * (index + 1);
        }
        if (![self checkFBIsWillHitWithPreDanmaku:tempAgent danmaku:danmakuAgent]) {
            danmakuAgent.yIdx = index;
            retainer[key] = danmakuAgent;
            return CGRectGetHeight(self.bounds) - self.configuration.cellHeight * (index + 1);
        }
    }
    if (danmakuAgent.force) {
        u_int8_t index = arc4random() % maxPyIndex;
        danmakuAgent.yIdx = index;
        retainer[@(index)] = danmakuAgent;
        return CGRectGetHeight(self.bounds) - self.configuration.cellHeight * (index + 1);
    }
    return -1;
}

- (BOOL)checkFBIsWillHitWithPreDanmaku:(HJDanmakuAgent *)preDanmakuAgent danmaku:(HJDanmakuAgent *)danmakuAgent {
    if (preDanmakuAgent.remainingTime <= 0) {
        return NO;
    }
    return YES;
}

- (NSMutableDictionary *)retainerWithType:(HJDanmakuType)danmakuType {
    switch (danmakuType) {
        case HJDanmakuTypeLR:return self.LRRetainer;
        case HJDanmakuTypeFT:return self.FTRetainer;
        case HJDanmakuTypeFB:return self.FBRetainer;
        default:return nil;
    }
}

#pragma mark -

- (void)sendDanmaku:(HJDanmakuModel *)danmaku forceRender:(BOOL)force {
    if (!danmaku) {
        return;
    }
    [self.danmakuSource sendDanmaku:danmaku forceRender:force];
}

- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus {
    if (danmakus.count == 0) {
        return;
    }
    [self.danmakuSource sendDanmakus:danmakus];
}

- (HJDanmakuModel *)danmakuForVisibleCell:(HJDanmakuCell *)danmakuCell {
    if (!danmakuCell) {
        return nil;
    }
    NSArray *danmakuAgents = [self visibleDanmakuAgents];
    for (HJDanmakuAgent *danmakuAgent in danmakuAgents) {
        if (danmakuAgent.danmakuCell == danmakuCell) {
            return danmakuAgent.danmakuModel;
        }
    }
    return nil;
}

- (NSArray *)visibleCells {
    return [[self visibleDanmakuAgents] valueForKey:@"danmakuCell"];
}

- (NSArray *)visibleDanmakuAgents {
    __block NSArray *renderingDanmakus = nil;
    dispatch_sync(_renderQueue, ^{
        renderingDanmakus = [NSArray arrayWithArray:self.renderingDanmakus];
    });
    return renderingDanmakus;
}

@end
