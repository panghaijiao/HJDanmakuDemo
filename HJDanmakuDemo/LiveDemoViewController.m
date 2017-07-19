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
    self.danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];
    self.danmakuView.dataSource = self;
    self.danmakuView.delegate = self;
    [self.danmakuView registerClass:[DemoDanmakuCell class] forCellReuseIdentifier:@"cell"];
    self.danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.danmakuView];
    [self.view sendSubviewToBack:self.danmakuView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.danmakuView.isPrepared) {
        [self.danmakuView prepareDanmakus:nil];
    }
}

- (void)randomSendNewDanmaku {
    DemoDanmakuModel *danmaku = [[DemoDanmakuModel alloc] initWithType:HJDanmakuTypeLR];
    danmaku.text = @"^^^";
    [self.danmakuView sendDanmaku:danmaku forceRender:YES];
}

#pragma mark - 

- (IBAction)onPlayBtnClick:(UIButton *)sender {
    if (self.danmakuView.isPlaying) {
        [self.danmakuView pause];
    } else {
        [self.danmakuView play];
    }
    NSString *title = self.danmakuView.isPlaying ? @"pause": @"play";
    [sender setTitle:title forState:UIControlStateNormal];
}

#pragma mark - delegate

- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView {
    [self.danmakuView play];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(randomSendNewDanmaku) userInfo:nil repeats:YES];
    [self randomSendNewDanmaku];
}

#pragma mark - dataSource

- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    DemoDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.font = model.textFont;
    cell.textLabel.textColor = model.textColor;
    cell.textLabel.text = model.text;
    return cell;
}

- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    return [model.text sizeWithAttributes:@{NSFontAttributeName:model.textFont}].width;
}

@end
