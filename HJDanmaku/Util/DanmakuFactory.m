//
//  DanmakuFactory.m
//  DanmakuDemo
//
//  Created by Haijiao on 15/2/28.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import "DanmakuFactory.h"

@implementation DanmakuFactory

+ (DanmakuBaseModel *)createDanmakuWithDanmakuType:(DanmakuType)type
                                     Configuration:(DanmakuConfiguration *)configuration
{
    DanmakuBaseModel *danmaku = nil;
    switch (type) {
        case DanmakuTypeLR:
            danmaku = [[DanmakuLRModel alloc] init];
            danmaku.danmakuType = DanmakuTypeLR;
            break;
        case DanmakuTypeFT:
            danmaku = [[DanmakuFTModel alloc] init];
            danmaku.danmakuType = DanmakuTypeFT;
            break;
        case DanmakuTypeFB:
            danmaku = [[DanmakuFBModel alloc] init];
            danmaku.danmakuType = DanmakuTypeFB;
            break;
    }
    danmaku.duration = configuration.duration;
    return danmaku;
}

+ (DanmakuBaseModel *)createDanmakuWithDanmakuSource:(DanmakuSource *)danmakuSource
                                       Configuration:(DanmakuConfiguration *)configuration
{
    NSString *pString = danmakuSource.p;
    NSString *mString = danmakuSource.m;
    if (pString.length<1 || mString.length<1) {
        return nil;
    }
    NSArray *pArray = [pString componentsSeparatedByString:@","];
    if (pArray.count<5) {
        return  nil;
    }
    
    DanmakuType type = [pArray[1] integerValue]%3;
    DanmakuFont fontSize = [pArray[2] integerValue]%2;
    
    DanmakuBaseModel *danmaku = [DanmakuFactory createDanmakuWithDanmakuType:type
                                                               Configuration:configuration];
    danmaku.time = [pArray[0] floatValue]/1000.0;
    danmaku.text = mString;
    danmaku.textSize = fontSize==DanmakuFontLarge?configuration.largeFontSize:configuration.fontSize;
    danmaku.textColor = [self colorWithHexStr:pArray[3]];
    return danmaku;
}

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
+ (UIColor *)colorWithHexStr:(NSString *)str
{
    int i = 0;
    if ([str characterAtIndex:0] == '#')
        i = 1;
    
    if (i + 6 > [str length])
        return [UIColor blackColor];
    
    return RGBCOLOR([self intWithC1:[str characterAtIndex:i]
                                 C2:[str characterAtIndex:i + 1]],
                    [self intWithC1:[str characterAtIndex:i + 2]
                                 C2:[str characterAtIndex:i + 3]],
                    [self intWithC1:[str characterAtIndex:i + 4]
                                 C2:[str characterAtIndex:i + 5]]);
}

+ (int)intWithC1:(char)c1 C2:(char)c2
{
    int s = [self intWithChar:c1] * 16 + [self intWithChar:c2];
    return s;
}

+ (int)intWithChar:(char) c
{
    int r = 0;
    if (c >= '0' && c <= '9')
        r = c - '0';
    else if (c >= 'a' && c <= 'z')
        r = c - 'a' + 10;
    else if (c >= 'A' && c <= 'Z')
        r = c - 'A' + 10;
    return r;
}

@end
