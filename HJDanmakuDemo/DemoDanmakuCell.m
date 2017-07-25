//
//  DemoDanmakuCell.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/14.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "DemoDanmakuCell.h"

@implementation DemoDanmakuCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.layer.borderWidth = 0;
}

@end
