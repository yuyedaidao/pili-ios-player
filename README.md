# PLPlayerKit

PLPlayerKit 是为 **pili.io** 流媒体云服务提供的一套播放直播流的 SDK, 旨在解决 iOS 端快速、轻松实现 iOS 设备播放直播流，便于 **pili.io** 的开发者专注于产品业务本身，而不必在技术细节上花费不必要的时间。


## 内容摘要

- [1 快速开始](#1-快速开始)
	- [1.1 配置工程](#1.1-配置工程)
		- [1.1.1 二进制包方式](#1.1.1-二进制包方式)
		- [1.1.2 源码方式](#1.1.2-源码方式)
	- [1.2 示例代码](#1.2-示例代码)
- [2 第三方库](#2-第三方库)
- [3 系统要求](#3-系统要求)
- [4 版本历史](#4-版本历史)

## 1 快速开始

### 1.1 配置工程
#### 1.1.1 二进制包方式

- 下载 PLPlayerKit 的 release zip 文件；
- 解压后得到 libPLPlayerKit.a 和 其 include 头文件；
- 将 libPLPlayerKit.a 和 include 头文件选中并拖拽到自己的 Xcode 工程中；
- 添加 ffmpeg
- 添加其他依赖库：
	- libiconv.dylib 
	- libz.dylib
	- UIKit.framework
	- Foundation.framework
	- CoreGraphics.framework
	- MediaPlayer.framework
	- CoreAudio.framework
	- AudioToolbox.framework
	- Accelerate.framework
	- QuartzCore.framework
	- OpenGLES.framework
- 添加 search path
	- 在工程的 Build Settings / Header Search Paths 下添加 PLPlayerKit 的 inclue 目录 和 ffmpeg 头文件目录的相对路径
- 编译并开始你的工作吧

#### 1.1.2 源码方式

- 添加 PLPlayerKit 为你的项目 submodule

```shell
git submodule add https://github.com/pili-io/pili-ios-player.git /Vendor/pili-ios-player.git
``` 
	
- 添加 PLPlayerKit.xcodeproj 为你的 iOS 工程的子工程
- 在 Build Phases / Target Dependecies 中添加 PLPlayerKit-Universal
- 在 Build Phases / Link Binary With Libraries 中添加以下依赖库
	- libPLPlayerKit.a
	- libiconv.dylib 
	- libz.dylib
	- UIKit.framework
	- Foundation.framework
	- CoreGraphics.framework
	- MediaPlayer.framework
	- CoreAudio.framework
	- AudioToolbox.framework
	- Accelerate.framework
	- QuartzCore.framework
	- OpenGLES.framework
- 在功成中添加 ffmpeg，并在 Build Settings / Header Search Paths 中添加 ffmpeg 头文件目录的相对路径
- 编译并开始你的工作吧

### 1.2 示例代码

在需要的地方添加

```Objective-C
#import <PLPlayerKit/PLPlayerKit.h>
```

初始化

```Objective-C
	// 初始化 VideoPlayerViewController
	PLVideoPlayerViewController *viewPlayerViewController = [PLVideoPlayerViewController videoPlayerViewControllerWithContentURL:url parameters:parameters];
	
	// 展示播放界面
	[self presentViewController:viewPlayerViewController animated:YES completion:nil];
```

参数配置

```Objective-C
	NSMutableDictionary *parameters = [@{} mutableCopy];
	
	// 对于 iPhone 建议关闭逐行扫描，默认是开启的
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		parameters[PLMovieParameterDisableDeinterlacing] = @(YES);
	}
```

播放操作，PLVideoPlayerViewController 会在展示时自动开始播放，当然，如果你需要自己在代码中控制播放逻辑，也可以调用以下方法轻松开始／暂停
```Objective-C
	// 播放
	[viewPlayerViewController play];
	
	// 停止
	[viewPlayerViewController pause];
```

如果你想自定义播放界面，那么你需要隐藏原有的播放控制，你可以这么做到

```Objective-C
	viewPlayerViewController.controlMode = PLVideoPlayerControlModeNone;
```

## 2 第三方库

- ffmpeg

## 3 系统要求

- iOS Target : >= iOS 7

## 4 版本历史

- 1.0.0
	- 完成基本的 RTMP/HLS 流播放播放器