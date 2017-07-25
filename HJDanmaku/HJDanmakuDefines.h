//
//  HJDanmakuDefines.h
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#ifndef HJDanmakuDefines_h
#define HJDanmakuDefines_h

typedef NS_ENUM (NSUInteger, HJDanmakuMode) {
    HJDanmakuModeVideo,
    HJDanmakuModeLive
};

typedef NS_ENUM (NSUInteger, HJDanmakuType) {
    HJDanmakuTypeLR,
    HJDanmakuTypeFT,
    HJDanmakuTypeFB
};

typedef struct {
    CGFloat time;
    CGFloat interval;
} HJDanmakuTime;

NS_INLINE CGFloat HJMaxTime(HJDanmakuTime time) {
    return time.time + time.interval;
}

#endif /* HJDanmakuDefines_h */
