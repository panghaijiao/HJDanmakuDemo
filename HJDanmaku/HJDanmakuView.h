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
- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView;

// called before render. return NO will ignore danmaku
- (BOOL)danmakuView:(HJDanmakuView *)danmakuView shouldRenderDanmaku:(HJDanmakuModel *)danmaku;

// display customization
- (void)danmakuView:(HJDanmakuView *)danmakuView willDisplayCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku;
- (void)danmakuView:(HJDanmakuView *)danmakuView didEndDisplayCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku;

// selection customization
- (BOOL)danmakuView:(HJDanmakuView *)danmakuView shouldSelectCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku;
- (void)danmakuView:(HJDanmakuView *)danmakuView didSelectCell:(HJDanmakuCell *)cell danmaku:(HJDanmakuModel *)danmaku;

@end

//_______________________________________________________________________________________________________________

@protocol HJDanmakuViewDateSource;
@interface HJDanmakuView : UIView

@property (nonatomic, weak) id <HJDanmakuViewDateSource> dataSource;
@property (nonatomic, weak) id <HJDanmakuViewDelegate> delegate;

@property (readonly) HJDanmakuConfiguration *configuration;
@property (readonly) BOOL isPrepared;
@property (readonly) BOOL isPlaying;

// traverse touches outside of the danmaku view, default NO
@property (nonatomic, assign) BOOL traverseTouches;

- (instancetype)initWithFrame:(CGRect)frame configuration:(HJDanmakuConfiguration *)configuration;

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (__kindof HJDanmakuCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (__kindof HJDanmakuModel *)danmakuForVisibleCell:(HJDanmakuCell *)danmakuCell; // returns nil if cell is not visible
@property (nonatomic, readonly) NSArray<__kindof HJDanmakuCell *> *visibleCells;

// you can prepare with nil when liveModel
- (void)prepareDanmakus:(NSArray<HJDanmakuModel *> *)danmakus;

// be sure to call -prepareDanmakus before -play, when isPrepared is NO, call will be invalid
- (void)play;
- (void)pause;
- (void)stop;

// reset and clear all danmakus, must call -prepareDanmakus before -play once again
- (void)reset;
- (void)clearScreen;


/* send customization. when force, renderer will draw the danmaku immediately and ignore the maximum quantity limit.
   you should call -sendDanmakus: instead of -sendDanmaku:forceRender: to send the danmakus from a remote servers
 */
- (void)sendDanmaku:(HJDanmakuModel *)danmaku forceRender:(BOOL)force;
- (void)sendDanmakus:(NSArray<HJDanmakuModel *> *)danmakus;

@end

//_______________________________________________________________________________________________________________

@protocol HJDanmakuViewDateSource <NSObject>

@required

// variable cell width support
- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku;

// cell display. implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku;

@optional

// current play time, unit second, must implementation when videoModel
- (float)playTimeWithDanmakuView:(HJDanmakuView *)danmakuView;

// play buffer status, when YES, stop render new danmaku, rendered danmaku in screen will continue anim until disappears, only valid when videoModel
- (BOOL)bufferingWithDanmakuView:(HJDanmakuView *)danmakuView;

@end
