//
//  PLVideoPlayerController.h
//  PLPlayerKit
//
//  Created by 0day on 14/11/24.
//  Copyright (c) 2014年 qgenius. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * NOT ready to use!!!
 */

@class PLVideoPlayerController;
@protocol PLVideoPlayerControllerDelegate <NSObject>

- (void)videoPlayerControllerDidBeginPlaying:(PLVideoPlayerController *)videoPlayerController;
- (void)videoPlayerControllerDidStopPlaying:(PLVideoPlayerController *)videoPlayerController;

@end

typedef NS_ENUM(NSUInteger, PLContentMode) {
    PLContentModeScaleAspectFit,
    PLContentModeScaleAspectFill,
    PLContentModeScaleAspectDefault = PLContentModeScaleAspectFit
};

@interface PLVideoPlayerController : NSObject

@property (nonatomic, weak) id<PLVideoPlayerControllerDelegate> delegate;

@property (nonatomic, copy) NSURL *contentURL;
@property (nonatomic, assign) PLContentMode contentMode;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, readonly) UIView  *view;

- (instancetype)initWithContentURL:(NSURL *)url parameters:(NSDictionary *)parameters;

- (void)play;
- (void)pause;

@end
