//
//  DanmakuFilter.m
//  olinone
//
//  Created by Haijiao on 15/3/5.
//
//

#import "DanmakuFilter.h"
#import "DanmakuBaseModel.h"

@implementation DanmakuFilter

- (NSArray *)filterDanmakus:(NSArray *)danmakus Time:(DanmakuTime *)time
{
    if (danmakus.count<1) {
        return nil;
    }
    DanmakuBaseModel *lastDanmaku = danmakus.lastObject;
    if (![lastDanmaku isDraw:time.time]) {
        return nil;
    }
    DanmakuBaseModel *firstDanmaku = danmakus.firstObject;
    if ([firstDanmaku isDraw:time.time]) {
        return danmakus;
    }
    return [self cutWithDanmakus:danmakus Time:time];
}

- (NSArray *)cutWithDanmakus:(NSArray *)danmakus Time:(DanmakuTime *)time
{
    NSUInteger count = danmakus.count;
    NSUInteger index, minIndex=0, maxIndex = count-1;
    DanmakuBaseModel *danmaku = nil;
    while (maxIndex-minIndex>1) {
        index = (maxIndex+minIndex)/2;
        danmaku = danmakus[index];
        if ([danmaku isDraw:time.time]) {
            maxIndex = index;
        } else {
            minIndex = index;
        }
    }
    return [danmakus subarrayWithRange:NSMakeRange(maxIndex, count-maxIndex)];
}

@end
