//
//  HJDanmakuView.h
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJDanmakuConfiguration.h"
#import "HJDanmakuModel.h"
#import "HJDanmakuCell.h"

@class HJDanmakuView;
@protocol HJDanmakuViewDelegate <NSObject>

@optional

// preparate completed. you can start render after callback
- (void)perpareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView;

// called before render. return NO will ignore danmaku
- (BOOL)danmakuView:(HJDanmakuView *)danmakuView shouldRenderDanmaku:(HJDanmakuModel *)danmaku;

// Display customization
- (void)danmakuView:(HJDanmakuView *)danmakuView willDisplayCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku;
- (void)danmakuView:(HJDanmakuView *)danmakuView didEndDisplayCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku;

@end

//_______________________________________________________________________________________________________________

@protocol HJDanmakuViewDateSource;
@interface HJDanmakuView : UIView

@property (nonatomic, weak) id <HJDanmakuViewDateSource> dataSource;
@property (nonatomic, weak) id <HJDanmakuViewDelegate> delegate;

@property (nonatomic, readonly) HJDanmakuConfiguration *configuration;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame configuration:(HJDanmakuConfiguration *)configuration;

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (HJDanmakuCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

// you can prepare with nil when liveModel
- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus;
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

- (void)sendDanmaku:(HJDanmakuModel *)danmaku;
- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus;

@end

//_______________________________________________________________________________________________________________

@protocol HJDanmakuViewDateSource <NSObject>

@required

// cell display. implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku;

@optional

// current play time, unit second, must implementation when videoModel
- (float)playTimeWithDanmakuView:(HJDanmakuView *)danmakuView;

// play buffer status, when YES, stop render new danmaku, rendered danmaku in screen will continue anim until disappears, only valid when videoModel
- (BOOL)bufferingWithDanmakuView:(HJDanmakuView *)danmakuView;

@end
