//
//  DanmakuRetainer.h
//  DanmakuDemo
//
//  Created by Haijiao on 15/3/3.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DanmakuView.h"
@class DanmakuBaseModel;

@interface DanmakuRetainer : NSObject

@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, weak) DanmakuConfiguration *configuration;

- (void)clearVisibleDanmaku:(DanmakuBaseModel *)danmaku;
- (float)layoutPyForDanmaku:(DanmakuBaseModel *)danmaku;
- (void)clear;

@end

@interface DanmakuFTRetainer : DanmakuRetainer

@end

@interface DanmakuFBRetainer : DanmakuFTRetainer

@end
