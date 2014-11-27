//
//  PLMovieDecoder.h
//  PLPlayerKit
//
//  Created by 0day on 14/11/13
//  Copyright (c) 2014 qgenius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

extern NSString * PLPlayerKitErrorDomain;

typedef enum {
    
    PLMovieErrorNone,
    PLMovieErrorOpenFile,
    PLMovieErrorStreamInfoNotFound,
    PLMovieErrorStreamNotFound,
    PLMovieErrorCodecNotFound,
    PLMovieErrorOpenCodec,
    PLMovieErrorAllocateFrame,
    PLMovieErroSetupScaler,
    PLMovieErroReSampler,
    PLMovieErroUnsupported,
    
} PLMovieError;

typedef enum {
    
    PLMovieFrameTypeAudio,
    PLMovieFrameTypeVideo,
    PLMovieFrameTypeArtwork,
    PLMovieFrameTypeSubtitle,
    
} PLMovieFrameType;

typedef enum {
        
    PLVideoFrameFormatRGB,
    PLVideoFrameFormatYUV,
    
} PLVideoFrameFormat;

@interface PLMovieFrame : NSObject
@property (readonly, nonatomic) PLMovieFrameType type;
@property (readonly, nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@end

@interface PLAudioFrame : PLMovieFrame
@property (readonly, nonatomic, strong) NSData *samples;
@end

@interface PLVideoFrame : PLMovieFrame
@property (readonly, nonatomic) PLVideoFrameFormat format;
@property (readonly, nonatomic) NSUInteger width;
@property (readonly, nonatomic) NSUInteger height;
@end

@interface PLVideoFrameRGB : PLVideoFrame
@property (readonly, nonatomic) NSUInteger linesize;
@property (readonly, nonatomic, strong) NSData *rgb;
- (UIImage *) asImage;
@end

@interface PLVideoFrameYUV : PLVideoFrame
@property (readonly, nonatomic, strong) NSData *luma;
@property (readonly, nonatomic, strong) NSData *chromaB;
@property (readonly, nonatomic, strong) NSData *chromaR;
@end

@interface PLArtworkFrame : PLMovieFrame
@property (readonly, nonatomic, strong) NSData *picture;
- (UIImage *) asImage;
@end

@interface PLSubtitleFrame : PLMovieFrame
@property (readonly, nonatomic, strong) NSString *text;
@end

typedef BOOL(^PLMovieDecoderInterruptCallback)();

@interface PLMovieDecoder : NSObject

@property (readonly, nonatomic, strong) NSString *path;
@property (readonly, nonatomic) BOOL isEOF;
@property (readwrite,nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@property (readonly, nonatomic) CGFloat fps;
@property (readonly, nonatomic) CGFloat sampleRate;
@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;
@property (readonly, nonatomic) NSUInteger audioStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedAudioStream;
@property (readonly, nonatomic) NSUInteger subtitleStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedSubtitleStream;
@property (readonly, nonatomic) BOOL validVideo;
@property (readonly, nonatomic) BOOL validAudio;
@property (readonly, nonatomic) BOOL validSubtitles;
@property (readonly, nonatomic, strong) NSDictionary *info;
@property (readonly, nonatomic, strong) NSString *videoStreamFormatName;
@property (readonly, nonatomic) BOOL isNetwork;
@property (readonly, nonatomic) CGFloat startTime;
@property (readwrite, nonatomic) BOOL disableDeinterlacing;
@property (readwrite, nonatomic, strong) PLMovieDecoderInterruptCallback interruptCallback;

+ (id)movieDecoderWithContentPath:(NSString *)path
                            error:(NSError **)perror;

- (BOOL)openFile:(NSString *)path
           error:(NSError **)perror;

- (void)closeFile;

- (BOOL)setupVideoFrameFormat:(PLVideoFrameFormat)format;

- (NSArray *)decodeFrames:(CGFloat)minDuration;

@end

@interface PLMovieSubtitleASSParser : NSObject

+ (NSArray *)parseEvents:(NSString *)events;
+ (NSArray *)parseDialogue:(NSString *)dialogue
                 numFields:(NSUInteger)numFields;
+ (NSString *)removeCommandsFromEventText:(NSString *)text;

@end