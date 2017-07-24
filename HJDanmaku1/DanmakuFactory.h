//
//  DanmakuFactory.h
//  DanmakuDemo
//
//  Created by Haijiao on 15/2/28.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DanmakuBaseModel.h"
#import "DanmakuView.h"

@interface DanmakuFactory : NSObject

+ (DanmakuBaseModel *)createDanmakuWithDanmakuSource:(DanmakuSource *)danmakuSource
                                       configuration:(DanmakuConfiguration *)configuration;

+ (UIColor *)colorWithHexStr:(NSString *)str;

@end
