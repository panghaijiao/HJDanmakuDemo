//
//  HJDanmakuCell.h
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/6.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HJDanmakuCellSelectionStyle) {
    HJDanmakuCellSelectionStyleNone,     // no select.
    HJDanmakuCellSelectionStyleDefault,
};

@interface HJDanmakuCell : UIView

@property (nonatomic) NSUInteger zIndex; // default LR 0  FT/FB 10.

@property (nonatomic) HJDanmakuCellSelectionStyle selectionStyle; // default is HJDanmakuCellSelectionStyleNone.

@property (nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, readonly) NSString *reuseIdentifier;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)prepareForReuse;

@end
