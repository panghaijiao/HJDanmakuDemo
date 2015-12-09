//
//  DanmakuView.h
//  DanmakuView
//
//  Created by Haijiao on 15/3/12.
//  Copyright (c) 2015年 olinone. All rights reserved.
//  http://www.olinone.com

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DanmakuConfiguration : NSObject

@property (nonatomic) CGFloat duration;
@property (nonatomic) CGFloat paintHeight;

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat largeFontSize;

@property (nonatomic) CGFloat maxLRShowCount;
@property (nonatomic) CGFloat maxShowCount;

//发送弹幕是否显示下划线
@property (nonatomic) BOOL    isShowLineWhenSelf;

@end

//_______________________________________________________________________________________________________________

// 时间(毫秒),类型(0:向左滚动 1:顶部 2底部),字体大小(0:中字体 1:大字体),颜色(16进制),用户ID
// "p": "25,1,0,FFFFFF,0",
// "m": "olinone.com"
@interface DanmakuSource : NSObject

@property (nonatomic, strong) NSString *p;
@property (nonatomic, strong) NSString *m;

+ (instancetype)createWithP:(NSString *)p M:(NSString *)m;

@end

//_______________________________________________________________________________________________________________

@protocol DanmakuDelegate;
@interface DanmakuView : UIView

@property (nonatomic, weak) id<DanmakuDelegate> delegate;
@property (nonatomic, readonly) BOOL isPrepared;
@property (nonatomic, readonly) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame Configuration:(DanmakuConfiguration *)configuration;

// DanmakuSource组成的数组
- (void)prepareDanmakuSources:(NSArray *)danmakuSources;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

- (void)sendDanmakuSource:(DanmakuSource *)danmakuSource;

@end

@interface DanmakuView (Deprecated)

// 字典组成的数组，已弃用，推荐prepareDanmakuSources
// "p": "25,1,0,FFFFFF,0",
// "m": "olinone.com"
- (void)prepareDanmakus:(NSArray *)danmakus;

@end

//_______________________________________________________________________________________________________________

@protocol DanmakuDelegate <NSObject>

@required
// 视频播放进度，单位秒
- (float)danmakuViewGetPlayTime:(DanmakuView *)danmakuView;

// 视频播放缓冲状态，如果设为YES，不会绘制新弹幕，已绘制弹幕会继续动画直至消失
- (BOOL)danmakuViewIsBuffering:(DanmakuView *)danmakuView;

@optional
// 弹幕初始化完成
- (void)danmakuViewPerpareComplete:(DanmakuView *)danmakuView;

@end
