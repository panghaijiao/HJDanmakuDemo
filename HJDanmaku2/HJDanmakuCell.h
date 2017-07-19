//
//  HJDanmakuCell.h
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJDanmakuCell : UIView

@property (nonatomic) NSUInteger zIndex; // Default LR 0  FT/FB 10

@property (nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, readonly) NSString *reuseIdentifier;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)prepareForReuse;

@end
