//
//  FirstVersionViewController.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/21.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "FirstVersionViewController.h"
#import "DanmakuView.h"

@interface FirstVersionViewController () <DanmakuDelegate> {
    IBOutlet UIImageView *_imgView;
    IBOutlet UILabel *_curTime;
    IBOutlet UISlider *_slider;
    
    DanmakuView *_danmakuView;
    NSDate *_startDate;
    NSTimer *_timer;
}

@end

@implementation FirstVersionViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_danmakuView stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];    
    DanmakuConfiguration *configuration = [[DanmakuConfiguration alloc] init];
    configuration.duration = 5;
    configuration.paintHeight = 21;
    configuration.fontSize = 17;
    configuration.largeFontSize = 19;
    configuration.maxLRShowCount = 30;
    configuration.maxShowCount = 45;
    _danmakuView = [[DanmakuView alloc] initWithFrame:self.view.bounds configuration:configuration];
    _danmakuView.delegate = self;
    [self.view insertSubview:_danmakuView aboveSubview:_imgView];
    _danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *danmakufile = [[NSBundle mainBundle] pathForResource:@"danmakufile" ofType:nil];
    NSArray *danmakus = [NSArray arrayWithContentsOfFile:danmakufile];
    [_danmakuView prepareDanmakus:danmakus]; // 新版本推荐 prepareDanmakuSources
}

- (void)onTimeCount {
    _slider.value += 0.1 / 120;
    if (_slider.value > 120.0) {
        _slider.value = 0;
    }
    [self onTimeChange:nil];
}

- (IBAction)onTimeChange:(id)sender {
    _curTime.text = [NSString stringWithFormat:@"%.0fs", _slider.value * 120.0];
}

- (IBAction)onStartClick:(id)sender {
    if (_danmakuView.isPrepared) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
        }
        [_danmakuView start];
    }
}

- (IBAction)onPauseClick:(id)sender {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_danmakuView pause];
}

- (IBAction)onSendClick:(id)sender {
    int time = ([self danmakuViewGetPlayTime:nil] + 1) * 1000;
    int type = rand() % 3;
    NSString *pString = [NSString stringWithFormat:@"%d,%d,1,00EBFF,125", time, type];
    NSString *mString = @"😊😊olinone.com😊😊";
    DanmakuSource *danmakuSource = [DanmakuSource createWithP:pString M:mString];
    [_danmakuView sendDanmakuSource:danmakuSource];
}

#pragma mark -

- (float)danmakuViewGetPlayTime:(DanmakuView *)danmakuView {
    return _slider.value * 120.0;
}

- (BOOL)danmakuViewIsBuffering:(DanmakuView *)danmakuView {
    return NO;
}

- (void)danmakuViewPerpareComplete:(DanmakuView *)danmakuView {
    [_danmakuView start];
}

@end
