//
//  PLAudioManager.h
//  PLPlayerKit
//
//  Created by 0day on 14/11/13
//  Copyright (c) 2014年 qgenius. All rights reserved.
//


#import <CoreFoundation/CoreFoundation.h>

typedef void (^PLAudioManagerOutputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);

@protocol PLAudioManagerProtocol <NSObject>

@property (readonly) UInt32             numOutputChannels;
@property (readonly) Float64            samplingRate;
@property (readonly) UInt32             numBytesPerSample;
@property (readonly) Float32            outputVolume;
@property (readonly) BOOL               playing;
@property (readonly, strong) NSString   *audioRoute;

@property (readwrite, copy) PLAudioManagerOutputBlock outputBlock;

- (BOOL) activateAudioSession;
- (void) deactivateAudioSession;
- (BOOL) play;
- (void) pause;

@end

@interface PLAudioManager : NSObject
+ (id<PLAudioManagerProtocol>) audioManager;
@end
