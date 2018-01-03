//
//  VideoDemoViewController.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/14.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "VideoDemoViewController.h"
#import "HJDanmakuView.h"
#import "DemoDanmakuModel.h"
#import "DemoDanmakuCell.h"
#import "DanmakuFactory.h"

@interface VideoDemoViewController () <HJDanmakuViewDateSource, HJDanmakuViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UISlider *progressSlider;
@property (nonatomic, weak) IBOutlet UIButton *bufferBtn;

@property (nonatomic, strong) HJDanmakuView *danmakuView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation VideoDemoViewController

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
    HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeVideo];
    self.danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];
    self.danmakuView.dataSource = self;
    self.danmakuView.delegate = self;
    [self.danmakuView registerClass:[DemoDanmakuCell class] forCellReuseIdentifier:@"cell"];
    self.danmakuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.danmakuView aboveSubview:self.imageView];
    
    [self loadDanmakusFromFile];
}

- (void)loadDanmakusFromFile {
    NSString *danmakufile = [[NSBundle mainBundle] pathForResource:@"danmakufile" ofType:nil];
    NSArray *danmakus = [NSArray arrayWithContentsOfFile:danmakufile];
    NSMutableArray *danmakuModels = [NSMutableArray arrayWithCapacity:danmakus.count];
    for (NSDictionary *danmaku in danmakus) {
        NSArray *pArray = [danmaku[@"p"] componentsSeparatedByString:@","];
        HJDanmakuType type = [pArray[1] integerValue] % 3;
        DemoDanmakuModel *danmakuModel = [[DemoDanmakuModel alloc] initWithType:type];
        danmakuModel.time = [pArray[0] floatValue] / 1000.0f;
        danmakuModel.text = danmaku[@"m"];
        danmakuModel.textFont = [pArray[2] integerValue] == 1 ? [UIFont systemFontOfSize:20]: [UIFont systemFontOfSize:18];
        danmakuModel.textColor = [DanmakuFactory colorWithHexStr:pArray[3]];
        [danmakuModels addObject:danmakuModel];
    }
    [self.danmakuView prepareDanmakus:danmakuModels];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.danmakuView sizeToFit];
}

#pragma mark -

- (IBAction)onPlayBtnClick:(UIButton *)sender {
    if (self.danmakuView.isPrepared) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
        }
        [self.danmakuView play];
    }
}

- (void)onTimeCount {
    self.progressSlider.value += 0.1 / 120;
    if (self.progressSlider.value > 120.0) {
        self.progressSlider.value = 0;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%.0fs", self.progressSlider.value * 120.0];
}

- (IBAction)onPauseBtnClick:(id)sender {
    [self.danmakuView pause];
}

- (IBAction)onSendClick:(id)sender {
    HJDanmakuType type = arc4random() % 3;
    DemoDanmakuModel *danmakuModel = [[DemoDanmakuModel alloc] initWithType:type];
    danmakuModel.selfFlag = YES;
    danmakuModel.time = [self playTimeWithDanmakuView:self.danmakuView] + 0.5;
    danmakuModel.text = [NSString stringWithFormat:@"%.1f  😊😊olinone.com😊😊", danmakuModel.time];
    danmakuModel.textFont = [UIFont systemFontOfSize:20];
    danmakuModel.textColor = [UIColor blueColor];
    [self.danmakuView sendDanmaku:danmakuModel forceRender:YES];
}

- (IBAction)onBufferBtnClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

#pragma mark - delegate

- (void)prepareCompletedWithDanmakuView:(HJDanmakuView *)danmakuView {
    [self.danmakuView play];
}

#pragma mark - dataSource

- (BOOL)bufferingWithDanmakuView:(HJDanmakuView *)danmakuView {
    return self.bufferBtn.isSelected;
}

- (float)playTimeWithDanmakuView:(HJDanmakuView *)danmakuView {
    return self.progressSlider.value * 120.0;
}

- (CGFloat)danmakuView:(HJDanmakuView *)danmakuView widthForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    return [model.text sizeWithAttributes:@{NSFontAttributeName: model.textFont}].width + 1.0f;
}

- (HJDanmakuCell *)danmakuView:(HJDanmakuView *)danmakuView cellForDanmaku:(HJDanmakuModel *)danmaku {
    DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
    DemoDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
    if (model.selfFlag) {
        cell.zIndex = 30;
        cell.layer.borderWidth = 0.5;
        cell.layer.borderColor = [UIColor redColor].CGColor;
    }
    cell.textLabel.font = model.textFont;
    cell.textLabel.textColor = model.textColor;
    cell.textLabel.text = model.text;
    return cell;
}

@end
