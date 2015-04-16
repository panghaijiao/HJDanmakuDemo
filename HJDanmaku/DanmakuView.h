//
//  DanmakuView.h
//  DanmakuView
//
//  Created by Haijiao on 15/3/12.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DanmakuConfiguration : NSObject

@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat paintHeight;

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat largeFontSize;

@property (nonatomic, assign) CGFloat maxLRShowCount;
@property (nonatomic, assign) CGFloat maxShowCount;

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

- (void)prepareDanmakus:(NSArray *)danmakus;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

- (void)sendDanmakuSource:(DanmakuSource *)danmakuSource;

@end

//_______________________________________________________________________________________________________________

@protocol DanmakuDelegate <NSObject>

@required
- (float)danmakuViewGetPlayTime:(DanmakuView *)danmakuView;
- (BOOL)danmakuViewIsBuffering:(DanmakuView *)danmakuView;

@optional
- (void)danmakuViewPerpareComplete:(DanmakuView *)danmakuView;

@end
