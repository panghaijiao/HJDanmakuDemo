//
//  DanmakuFilter.h
//  olinone
//
//  Created by Haijiao on 15/3/5.
//
//

#import <Foundation/Foundation.h>
#import "DanmakuTime.h"

@interface DanmakuFilter : NSObject

- (NSArray *)filterDanmakus:(NSArray *)danmakus Time:(DanmakuTime *)time;

@end
