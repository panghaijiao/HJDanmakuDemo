# HJDanmaku

![](https://img.shields.io/badge/build-passing-brightgreen.svg)
![](https://img.shields.io/badge/Cocoapods-v1.1.1-blue.svg)
![](https://img.shields.io/badge/language-objc-5787e5.svg)
![](https://img.shields.io/badge/license-MIT-brightgreen.svg)  

A high performance danmaku engine for iOS. For more details please click [here](http://www.olinone.com/?p=186)

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the [Get Started](http://cocoapods.org/#get_started) section for more details.

## Podfile

```
pod 'HJDanmaku', :git => 'https://github.com/panghaijiao/HJDanmakuDemo.git'
```

## Usage

#### Live Mode

```
// init config with mode HJDanmakuModeLive
HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeLive];
HJDanmakuView *danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];

// configure dataSource of danmakuView
danmakuView.dataSource = self;
```

#### Video Mode (developing)

```
// init config with mode HJDanmakuModeVideo
HJDanmakuConfiguration *config = [[HJDanmakuConfiguration alloc] initWithDanmakuMode:HJDanmakuModeVideo];
HJDanmakuView *danmakuView = [[HJDanmakuView alloc] initWithFrame:self.view.bounds configuration:config];

// configure dataSource of danmakuView
danmakuView.dataSource = self;
```

## License:  

HJDanmakuDemo is released under the MIT license. See LICENSE for details.
Copyright (c) 2015 olinone

