//
//  HJDanmakuModel.h
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJDanmakuDefines.h"

@interface HJDanmakuModel : NSObject

@property (readonly) HJDanmakuType danmakuType;

// unit second, ignore when liveModel
@property (nonatomic) CGFloat time;

- (instancetype)initWithType:(HJDanmakuType)danmakuType NS_DESIGNATED_INITIALIZER;

@end
