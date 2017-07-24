//
//  LiveDemoViewController.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/14.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "LiveDemoViewController.h"
#import "HJDanmakuView.h"
#import "DemoDanmakuModel.h"
#import "DemoDanmakuCell.h"

@interface LiveDemoViewController () <HJDanmakuViewDateSource, HJDanmakuViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) HJDanmakuView *danmakuView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LiveDemoViewController

- (void)dealloc {
    [self.danmakuView stop];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeLive];
    config.duration = 5.0f;
    config.cellHeight = 40.0f;
    self.danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];
    self.danmakuView.dataSource = self;
    self.danmakuView.delegate = self;
    [self.danmakuView registerClass:[DemoDanmakuCell class] forCellReuseIdentifier:@"cell"];
    self.danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.danmakuView aboveSubview:self.imageView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.danmakuView.isPrepared) {
        [self.danmakuView prepareDanmakus:nil];
    }
}

#pragma mark - 

- (IBAction)onPlayBtnClick:(UIButton *)sender {
    if (self.danmakuView.isPrepared) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(randomSendNewDanmaku) userInfo:nil repeats:YES];
        }
        [self.danmakuView play];
    }
}

- (void)randomSendNewDanmaku {
    DemoDanmakuModel *danmaku = [[DemoDanmakuModel alloc] initWithType:HJDanmakuTypeLR];
    danmaku.text = @"<<<================>>>";
    danmaku.textFont = [UIFont systemFontOfSize:20];
    danmaku.textColor = [UIColor redColor];
    [self.danmakuView sendDanmaku:danmaku forceRender:NO];
}

- (IBAction)onPauseBtnClick:(id)sender {
    [self.danmakuView pause];
}

- (IBAction)onSendClick:(id)sender {
    DemoDanmakuModel *danmaku = [[DemoDanmakuModel alloc] initWithType:HJDanmakuTypeLR];
    danmaku.selfFlag = YES;
    danmaku.text = @"😊😊olinone.com😊😊";
    danmaku.textFont = [UIFont systemFontOfSize:20];
    danmaku.textColor = [UIColor blueColor];
    [self.danmakuView sendDanmaku:danmaku forceRender:YES];
}

#pragma mark - delegate

- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView {
    [self.danmakuView play];
}

#pragma mark - dataSource

- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    return [model.text sizeWithAttributes:@{NSFontAttributeName: model.textFont}].width + 1.0f;
}

- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    DemoDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
    if (model.selfFlag) {
        cell.zIndex = 30;
    }
    cell.textLabel.font = model.textFont;
    cell.textLabel.textColor = model.textColor;
    cell.textLabel.text = model.text;
    return cell;
}

@end
