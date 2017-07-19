//
//  HJDanmakuView.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "HJDanmakuView.h"
#import <libkern/OSAtomic.h>

static const CGFloat HJFrameInterval = 0.5;

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
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) HJDanmakuConfiguration *configuration;
@property (nonatomic, assign) NSUInteger toleranceCount;

@property (nonatomic, assign) BOOL isPrepared;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) NSMutableDictionary *cellClassInfo;
@property (nonatomic, strong) NSMutableDictionary *cellReusePool;

@property (nonatomic, strong) NSMutableArray *danmakuQueuePool;
@property (nonatomic, strong) NSMutableArray *renderingDanmakus;

@property (nonatomic, strong) HJDanmakuSource *danmakuSource;

@end

@implementation HJDanmakuView

- (void)dealloc {
    HJDispatchQueueRelease(_queue);
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
        
        _reuseLock = OS_SPINLOCK_INIT;
        _queue = dispatch_queue_create("com.olinone.danmaku.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t dQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_set_target_queue(_queue, dQueue);
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
    return cell;
}

- (void)storeCellToReusePool:(HJDanmakuCell *)danmakuCell {
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
    [self stop];
    self.isPrepared = NO;
    dispatch_sync(_queue, ^{
        [self.danmakuQueuePool removeAllObjects];
        [self.renderingDanmakus removeAllObjects];
    });
    
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
}

#pragma mark - 

- (void)update {
    HJDanmakuTime playTime = {0, 0};
    if ([self.dataSource respondsToSelector:@selector(playTimeWithDanmakuView:)]) {
        playTime.time = [self.dataSource playTimeWithDanmakuView:self];
    }
    if (self.configuration.danmakuMode == HJDanmakuModeVideo && playTime.time <= 0) {
        return;
    }
    
    BOOL isBuffering = NO;
    if ([self.dataSource respondsToSelector:@selector(bufferingWithDanmakuView:)]) {
        isBuffering = [self.dataSource bufferingWithDanmakuView:self];
    }
    
    dispatch_async(_queue, ^{
        NSArray <HJDanmakuAgent *> *danmakuAgents = nil;
        if (!isBuffering) {
            danmakuAgents = [self.danmakuSource fetchDanmakuAgentsForTime:playTime];
        }
        if (danmakuAgents.count > 0) {
            
        }
    });
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

@end
