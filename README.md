![GitHub](http://7pum7o.com1.z0.glb.clouddn.com/HJDanmakuLogo.png)

![](https://img.shields.io/badge/build-passing-brightgreen.svg)
![](https://img.shields.io/badge/Cocoapods-v1.1.1-blue.svg)
![](https://img.shields.io/badge/language-objc-5787e5.svg)
![](https://img.shields.io/badge/license-MIT-brightgreen.svg)  

HJDanmaku is a high performance danmaku engine for iOS. For more details please click [here](http://www.olinone.com/?p=755)

## Overview

Compared to the version 1.0, HJDanmaku 2.0 has better performance, Such as high performance, large concurrent and better fluency. surely, you can customize the cell style according to product requirements. In version 2.0，it provides a new live mode to meet the live scene.

Get the version of swift at [here](https://github.com/panghaijiao/HJDanmaku-Swift) 

#### Fearture

*  `[Performance]` The average CPU usage for total is less than 5% .
*  `[Fluency]` The rendering frame rate (FPS) is stable at 60 frames.
*  `[Concurrency]` Off screen rendering ensures the stability of large concurrent data. 

#### Reference

Dimension | 1.0| 2.0
--------- | ------------- | -------------
Performance | ⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️
Fluency | ⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️
Accuracy | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️
Concurrency | ⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](http://cocoapods.org/#get_started) section for more details.

## Podfile

```
pod 'HJDanmaku', '~> 2.0'
```

## Usage

#### Live Mode

```
// init config with mode HJDanmakuModeLive
HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeLive];
HJDanmakuView *danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];
```

#### Video Mode

```
// init config with mode HJDanmakuModeVideo
HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeVideo];
HJDanmakuView *danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];
```


#### Send Danmaku

```
DemoDanmakuModel *danmaku = [[DemoDanmakuModel alloc] initWithType:HJDanmakuTypeLR];
danmaku.text = @"😊😊olinone.com😊😊";
[self.danmakuView sendDanmaku:danmaku forceRender:YES];
```

#### Custom style

```
// register cell class before dequeue
[self.danmakuView registerClass:[DemoDanmakuCell class] forCellReuseIdentifier:@"cell"];

// configure cell with custom style
DemoDanmakuCell *cell = [danmakuView dequeueReusableCellWithIdentifier:@"cell"];
DemoDanmakuModel *model = (DemoDanmakuModel *)danmaku;
cell.textLabel.font = model.textFont;
cell.textLabel.textColor = model.textColor;
cell.textLabel.text = model.text;
```

##  History Release

HJDanmaku 1.0 was first released in 2015, You can get it in the folder [HJDanmaku1](https://github.com/panghaijiao/HJDanmakuDemo/tree/master/HJDanmaku1). Surely, for better performance, we recommend the latest version 2.0.

## License

HJDanmakuDemo is released under the MIT license. See LICENSE for details.
Copyright (c) 2015 olinone.

## Sponsor

![GitHub](http://7pum7o.com1.z0.glb.clouddn.com/zfbwpay340.png)

