//
//  HJDanmakuView.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuView.h"
#import <libkern/OSAtomic.h>

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

@property (nonatomic, assign) CGFloat px;
@property (nonatomic, assign) CGFloat py;
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithDanmakuModel:(HJDanmakuModel *)danmakuModel;

@end

@implementation HJDanmakuAgent

- (instancetype)initWithDanmakuModel:(HJDanmakuModel *)danmakuModel {
    if (self = [super init]) {
        self.danmakuModel = danmakuModel;
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

@end

//______________________________

@interface HJDanmakuLiveSource : HJDanmakuSource

@end

@implementation HJDanmakuLiveSource

- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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

@property (nonatomic, assign) BOOL isPrepared;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) NSMutableDictionary *cellClassInfo;
@property (nonatomic, strong) NSMutableDictionary *cellReusePool;

@property (nonatomic, strong) NSMutableArray <HJDanmakuAgent *> *danmakuQueuePool;
@property (nonatomic, strong) NSMutableArray <HJDanmakuAgent *> *renderingDanmakus;

@end

@implementation HJDanmakuView

- (void)dealloc {
    NSLog(@">>> dealloc");
    HJDispatchQueueRelease(_renderQueue);
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(HJDanmakuConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        self.configuration = configuration;
        self.toleranceCount = (NSUInteger)(fabs(self.configuration.tolerance) / HJFrameInterval);
        self.toleranceCount = MAX(self.toleranceCount, 1);
        self.cellClassInfo = [NSMutableDictionary dictionary];
        self.cellReusePool = [NSMutableDictionary dictionary];
        self.danmakuQueuePool = [NSMutableArray array];
        self.renderingDanmakus = [NSMutableArray array];
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
    if (!self.configuration) {
        NSAssert(NO, @"configuration nil");
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
}

- (void)stop {
    self.isPlaying = NO;
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.playTime = (HJDanmakuTime){0, HJFrameInterval};
    [self recycleDanmakuAgents:[self.renderingDanmakus copy]];
    dispatch_async(_renderQueue, ^{
        [self.danmakuQueuePool removeAllObjects];
        [self.renderingDanmakus removeAllObjects];
    });
}

#pragma mark - 

- (void)update {
    HJDanmakuTime time = {0, HJFrameInterval};
    if ([self.dataSource respondsToSelector:@selector(playTimeWithDanmakuView:)]) {
        time.time = [self.dataSource playTimeWithDanmakuView:self];
    }
    if (self.configuration.danmakuMode == HJDanmakuModeVideo && time.time <= 0) {
        return;
    }
    [self loadDanmakusFromSourceForTime:time];
    [self renderDanmakusForTime:time];
}

- (void)loadDanmakusFromSourceForTime:(HJDanmakuTime)time {
    BOOL isBuffering = NO;
    if ([self.dataSource respondsToSelector:@selector(bufferingWithDanmakuView:)]) {
        isBuffering = [self.dataSource bufferingWithDanmakuView:self];
    }
    if (isBuffering) {
        return;
    }
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSArray <HJDanmakuAgent *> *danmakuAgents = [self.danmakuSource fetchDanmakuAgentsForTime:time];
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

- (void)renderDanmakusForTime:(HJDanmakuTime)time {
    dispatch_async(_renderQueue, ^{
        [self renderDisplayingDanmakusForTime:time];
        [self renderNewDanmakusForTime:time];
        [self removeExpiredDanmakusForTime:time];
    });
}

- (void)renderDisplayingDanmakusForTime:(HJDanmakuTime)time {
    NSMutableArray *disAppearDanmakuAgens = [NSMutableArray arrayWithCapacity:self.renderingDanmakus.count];
    [self.renderingDanmakus enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HJDanmakuAgent *danmakuAgent, NSUInteger idx, BOOL *stop) {
        danmakuAgent.remainingTime -= time.interval;
        if (danmakuAgent.remainingTime <= 0) {
            [disAppearDanmakuAgens addObject:danmakuAgent];
            [self.renderingDanmakus removeObjectAtIndex:idx];
        }
    }];
    [self recycleDanmakuAgents:disAppearDanmakuAgens];
}

- (void)recycleDanmakuAgents:(NSArray *)danmakuAgents {
    onMainThreadAsync(^{
        for (HJDanmakuAgent *danmakuAgent in danmakuAgents) {
            [danmakuAgent.danmakuCell.layer removeAllAnimations];
            [danmakuAgent.danmakuCell removeFromSuperview];
            [self recycleCellToReusePool:danmakuAgent.danmakuCell];
            if ([self.delegate respondsToSelector:@selector(danmakuView:didEndDisplayCell:danmaku:)]) {
                [self.delegate danmakuView:self didEndDisplayCell:danmakuAgent.danmakuCell danmaku:danmakuAgent.danmakuModel];
            }
        }
    });
}

- (void)renderNewDanmakusForTime:(HJDanmakuTime)time {
    for (HJDanmakuAgent *danmakuAgent in self.danmakuQueuePool) {
        BOOL shouldRender = YES;
        if ([self.delegate respondsToSelector:@selector(danmakuView:shouldRenderDanmaku:)]) {
            shouldRender = [self.delegate danmakuView:self shouldRenderDanmaku:danmakuAgent.danmakuModel];
        }
        if (!shouldRender) {
            danmakuAgent.toleranceCount = 0;
            continue;
        }
        
        [self renderNewDanmaku:danmakuAgent forTime:time];
        danmakuAgent.toleranceCount = 0;
    }
}

- (void)renderNewDanmaku:(HJDanmakuAgent *)danmakuAgent forTime:(HJDanmakuTime)time {
    [self.renderingDanmakus addObject:danmakuAgent];
    danmakuAgent.px = CGRectGetWidth(self.bounds);
    danmakuAgent.py = 0;
    CGFloat width = [self.dataSource danmakuView:self widthForDanmaku:danmakuAgent.danmakuModel];
    danmakuAgent.size = CGSizeMake(width, self.configuration.cellHeight);
    NSUInteger zIndex = danmakuAgent.danmakuModel.danmakuType == HJDanmakuTypeLR ? 0: 10;
    onMainThreadAsync(^{
        danmakuAgent.danmakuCell = ({
            HJDanmakuCell *cell = [self.dataSource danmakuView:self cellForDanmaku:danmakuAgent.danmakuModel];
            cell.frame = (CGRect){CGPointMake(danmakuAgent.px, danmakuAgent.py), danmakuAgent.size};
            cell.zIndex = cell.zIndex > 0 ? cell.zIndex: zIndex;
            cell;
        });
        if ([self.delegate respondsToSelector:@selector(danmakuView:willDisplayCell:danmaku:)]) {
            [self.delegate danmakuView:self willDisplayCell:danmakuAgent.danmakuCell danmaku:danmakuAgent.danmakuModel];
        }
        [self insertSubview:danmakuAgent.danmakuCell atIndex:danmakuAgent.danmakuCell.zIndex];
        [UIView animateWithDuration:danmakuAgent.remainingTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            danmakuAgent.danmakuCell.frame = (CGRect){CGPointMake(-danmakuAgent.size.width, danmakuAgent.py), danmakuAgent.size};
        } completion:nil];
    });
}

- (void)removeExpiredDanmakusForTime:(HJDanmakuTime)time {
    [self.danmakuQueuePool enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(HJDanmakuAgent *danmakuAgent, NSUInteger idx, BOOL *stop) {
        danmakuAgent.toleranceCount --;
        if (danmakuAgent.toleranceCount <= 0) {
            [self.danmakuQueuePool removeObjectAtIndex:idx];
        }
    }];
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
    NSArray *renderingDanmakus = [NSArray arrayWithArray:self.renderingDanmakus];
    for (HJDanmakuAgent *danmakuAgent in renderingDanmakus) {
        if (danmakuAgent.danmakuCell == danmakuCell) {
            return danmakuAgent.danmakuModel;
        }
    }
    return nil;
}

- (NSArray *)visibleCells {
    return [self.renderingDanmakus valueForKey:@"danmakuCell"];
}

@end
