//
//  PLVideoPlayerController.m
//  PLPlayerKit
//
//  Created by 0day on 14/11/24.
//  Copyright (c) 2014年 qgenius. All rights reserved.
//

#import "PLVideoPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "PLMovieDecoder.h"
#import "PLAudioManager.h"
#import "PLMovieGLView.h"
#import "PLLogger.h"

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

@interface PLVideoPlayerController ()

@property (nonatomic, strong) PLMovieDecoder    *decoder;
@property (nonatomic, assign) BOOL              interrupted;
@property (nonatomic, assign) BOOL              disableupateHUB;
@property (nonatomic, assign) NSTimeInterval    tickCorrectionTime;
@property (nonatomic, assign) NSTimeInterval    tickCorrectionPosition;
@property (nonatomic, assign) NSUInteger        tickCounter;
@property (nonatomic, assign) BOOL              decoding;
@property (nonatomic, strong) NSMutableArray    *videoFrames;
@property (nonatomic, strong) NSMutableArray    *audioFrames;
@property (nonatomic, assign) CGFloat           bufferedDuration;
@property (nonatomic, assign) CGFloat           maxBufferedDuration;
@property (nonatomic, strong) PLArtworkFrame    *artworkFrame;
@property (nonatomic, strong) NSData            *currentAudioFrame;
@property (nonatomic, assign) NSUInteger        currentAudioFramePos;
@property (nonatomic, assign) CGFloat           moviePosition;
@property (nonatomic, assign) CGFloat           minBufferedDuration;
@property (nonatomic, assign) BOOL              buffered;
@property (nonatomic, strong) dispatch_queue_t  dispatchQueue;
@property (nonatomic, assign) BOOL              disableUpdateHUD;
@property (nonatomic, strong) PLMovieGLView     *glView;
@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) UITapGestureRecognizer    *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer    *doubleTapGestureRecognizer;
@property (nonatomic, assign) BOOL              hiddenHUD;
@property (nonatomic, strong) NSDictionary      *parameters;
@property (nonatomic, strong) UIView            *containerView;

#ifdef DEBUG
@property (nonatomic, assign) NSTimeInterval    debugStartTime;
@property (nonatomic, assign) NSUInteger        debugAudioStatus;
@property (nonatomic, strong) NSDate            *debugAudioStatusTS;
#endif

@end

@implementation PLVideoPlayerController

#pragma mark - Property

- (UIView *)view {
    if (!self.containerView) {
        CGRect bounds = [[UIScreen mainScreen] applicationFrame];
        
        self.containerView = [[UIView alloc] initWithFrame:bounds];
        self.containerView.backgroundColor = [UIColor blackColor];
        self.containerView.tintColor = [UIColor blackColor];
        
        if (_decoder) {
            [self setupPresentView];
        }
    }
    
    return self.containerView;
}

- (void)setContentMode:(PLContentMode)contentMode {
    UIViewContentMode viewContentMode = UIViewContentModeScaleAspectFit;
    if (PLContentModeScaleAspectFill == contentMode) {
        _contentMode = contentMode;
        viewContentMode = UIViewContentModeScaleAspectFill;
    } else {
        _contentMode = PLContentModeScaleAspectDefault;
        viewContentMode = UIViewContentModeScaleAspectFit;
    }
    
    UIView *view = [self frameView];
    view.contentMode = viewContentMode;
}

#pragma mark - Public

- (instancetype)initWithContentURL:(NSURL *)url parameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        id<PLAudioManagerProtocol> audioManager = [PLAudioManager audioManager];
        [audioManager activateAudioSession];
        
        _moviePosition = 0;
        
        self.parameters = parameters;
        
        __weak typeof(self) weakSelf = self;
        
        PLMovieDecoder *decoder = [[PLMovieDecoder alloc] init];
        decoder.interruptCallback = ^BOOL() {
            __strong typeof(self) strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] : YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSError *error = nil;
            [decoder openFile:url.absoluteString error:&error];
            
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];
                });
            }
        });
        
        self.contentURL = url;
    }
    
    return self;
}

- (void)play {
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio){
        
        return;
    }
    
    if (_interrupted)
        return;
    
    _playing = YES;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    [self updatePlayButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    if (_decoder.validAudio) {
        [self enableAudio:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerControllerDidBeginPlaying:)]) {
        [self.delegate videoPlayerControllerDidBeginPlaying:self];
    }
    
    LoggerStream(1, @"play movie");
}

- (void)pause {
    if (!self.isPlaying)
        return;
    
    _playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    [self updatePlayButton];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerControllerDidStopPlaying:)]) {
        [self.delegate videoPlayerControllerDidStopPlaying:self];
    }
    
    LoggerStream(1, @"pause movie");
}

#pragma mark - gesture recognizer

- (void)handleTap: (UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        
        if (sender == _tapGestureRecognizer){
            
            [self showHUD:_hiddenHUD];
            
        } else if (sender == _doubleTapGestureRecognizer){
            if (PLContentModeScaleAspectFill == self.contentMode) {
                self.contentMode = PLContentModeScaleAspectFit;
            } else {
                self.contentMode = PLContentModeScaleAspectFill;
            }
        }
    }
}

#pragma mark - Private

- (void)setMovieDecoder:(PLMovieDecoder *)decoder
              withError:(NSError *)error
{
    LoggerStream(2, @"setMovieDecoder");
    
    if (!error && decoder){
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("PLMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
//        if (_decoder.subtitleStreamsCount){
//            _subtitles = [NSMutableArray array];
//        }
        
        if (_decoder.isNetwork){
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if (_parameters.count){
            
            id val;
            
            val = [_parameters valueForKey: PLMovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: PLMovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: PLMovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        LoggerStream(2, @"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.containerView) {
            [self setupPresentView];
        }
    } else {
        if (!_interrupted) {
            [self handleDecoderMovieError:error];
        }
    }
}

- (BOOL)interruptDecoder {
    return _interrupted;
}

- (void)showHUD: (BOOL)show
{
    _hiddenHUD = !show;
//    _panGestureRecognizer.enabled = _hiddenHUD;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_hiddenHUD];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         CGFloat alpha = _hiddenHUD ? 0 : 1;
//                         _topBar.alpha = alpha;
//                         _topHUD.alpha = alpha;
//                         _bottomBar.alpha = alpha;
                     }
                     completion:nil];
    
}

- (UIView *)frameView {
    return _glView ? _glView : _imageView;
}

- (void)setupUserInteraction {
    UIView * view = [self frameView];
    view.userInteractionEnabled = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    [_tapGestureRecognizer requireGestureRecognizerToFail: _doubleTapGestureRecognizer];
    
    [view addGestureRecognizer:_doubleTapGestureRecognizer];
    [view addGestureRecognizer:_tapGestureRecognizer];
    
    //    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //    _panGestureRecognizer.enabled = NO;
    //
    //    [view addGestureRecognizer:_panGestureRecognizer];
}

- (void)setupPresentView
{
    CGRect bounds = self.containerView.bounds;
    
    if (_decoder.validVideo){
        _glView = [[PLMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
    }
    
    if (!_glView){
        
        LoggerVideo(0, @"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:PLVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:bounds];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    
    UIView *frameView = [self frameView];
    frameView.contentMode = UIViewContentModeScaleAspectFit;
    frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.containerView insertSubview:frameView atIndex:0];
    
    if (_decoder.validVideo) {
        [self setupUserInteraction];
        
    } else {
        _imageView.image = [UIImage imageNamed:@"PLmovie.bundle/music_icon.png"];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.containerView.backgroundColor = [UIColor clearColor];
    
//    if (_decoder.duration == MAXFLOAT){
//        
//        _leftLabel.text = @"\u221E"; // infinity
//        _leftLabel.font = [UIFont systemFontOfSize:14];
//        
//        CGRect frame;
//        
//        frame = _leftLabel.frame;
//        frame.origin.x += 40;
//        frame.size.width -= 40;
//        _leftLabel.frame = frame;
//        
//        frame =_progressSlider.frame;
//        frame.size.width += 40;
//        _progressSlider.frame = frame;
//        
//    } else {
//        
//        [_progressSlider addTarget:self
//                            action:@selector(progressDidChange:)
//                  forControlEvents:UIControlEventValueChanged];
//    }
    
//    if (_decoder.subtitleStreamsCount){
//        
//        CGSize size = self.view.bounds.size;
//        
//        _subtitlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height, size.width, 0)];
//        _subtitlesLabel.numberOfLines = 0;
//        _subtitlesLabel.backgroundColor = [UIColor clearColor];
//        _subtitlesLabel.opaque = NO;
//        _subtitlesLabel.adjustsFontSizeToFitWidth = NO;
//        _subtitlesLabel.textAlignment = NSTextAlignmentCenter;
//        _subtitlesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _subtitlesLabel.textColor = [UIColor whiteColor];
//        _subtitlesLabel.font = [UIFont systemFontOfSize:16];
//        _subtitlesLabel.hidden = YES;
//        
//        [self.view addSubview:_subtitlesLabel];
//    }
}

- (void)asyncDecodeFrames {
    if (self.decoding)
        return;
    
    __weak typeof(self) weakSelf = self;
    __weak PLMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf.isPlaying) {
            return;
        }
        
        BOOL good = YES;
        while (good){
            good = NO;
            
            @autoreleasepool {
                __strong PLMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)){
                    
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count && strongSelf) {
                        good = [strongSelf addFrames:frames];
                    }
                }
            }
        }
        
        if (strongSelf) {
            strongSelf.decoding = NO;
        }
    });
}

- (void)tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration)|| _decoder.isEOF)){
        
        _tickCorrectionTime = 0;
        _buffered = NO;
//        [_activityIndicatorView stopAnimating];
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing){
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0)+
        (_decoder.validAudio ? _audioFrames.count : 0);
        
        if (0 == leftFrames){
            
            if (_decoder.isEOF){
                
                [self pause];
                [self updateHUD];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered){
                
                _buffered = YES;
//                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)){
            
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
    
    if ((_tickCounter++ % 3)== 0){
        [self updateHUD];
    }
}

- (void)handleDecoderMovieError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (CGFloat)tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime){
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200)== 0)
    //    LoggerStream(1, @"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f){
        
        LoggerStream(1, @"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat)presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo){
        
        PLVideoFrame *frame;
        
        @synchronized(_videoFrames){
            
            if (_videoFrames.count > 0){
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame) {
            interval = [self presentVideoFrame:frame];
        }
        
    } else if (_decoder.validAudio) {
//        if (self.artworkFrame) {
//            _imageView.image = [self.artworkFrame asImage];
//            self.artworkFrame = nil;
//        }
    }
    
//    if (_decoder.validSubtitles)
//        [self presentSubtitles];
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
}

- (CGFloat)presentVideoFrame: (PLVideoFrame *)frame
{
    if (_glView){
        [_glView render:frame];
    } else {
        PLVideoFrameRGB *rgbFrame = (PLVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (BOOL)addFrames:(NSArray *)frames {
    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            for (PLMovieFrame *frame in frames)
                if (frame.type == PLMovieFrameTypeVideo){
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (PLMovieFrame *frame in frames) {
                if (frame.type == PLMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo) {
                        _bufferedDuration += frame.duration;
                    }
                }
            }
        }
        
        if (!_decoder.validVideo) {
            for (PLMovieFrame *frame in frames) {
                if (frame.type == PLMovieFrameTypeArtwork) {
                    self.artworkFrame = (PLArtworkFrame *)frame;
                }
            }
        }
    }
    
//    if (_decoder.validSubtitles) {
//        @synchronized(_subtitles) {
//            for (PLMovieFrame *frame in frames) {
//                if (frame.type == PLMovieFrameTypeSubtitle){
//                    [_subtitles addObject:frame];
//                }
//            }
//        }
//    }
    
    return self.isPlaying && _bufferedDuration < _maxBufferedDuration;
}

- (void)updatePlayButton {}

- (void)updateHUD {
//    if (_disableUpdateHUD)
//        return;
//    
//    const CGFloat duration = _decoder.duration;
//    const CGFloat position = _moviePosition -_decoder.startTime;
//    
//    if (_progressSlider.state == UIControlStateNormal)
//        _progressSlider.value = position / duration;
//    _progressLabel.text = formatTimeInterval(position, NO);
//    
//    if (_decoder.duration != MAXFLOAT)
//        _leftLabel.text = formatTimeInterval(duration - position, YES);
}

- (void)audioCallbackFillData: (float *)outData
                    numFrames: (UInt32)numFrames
                  numChannels: (UInt32)numChannels {
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        while (numFrames > 0) {
            if (!_currentAudioFrame) {
                @synchronized(_audioFrames) {
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        PLAudioFrame *frame = _audioFrames[0];
                        
#ifdef DUMP_AUDIO_DATA
                        LoggerAudio(2, @"Audio frame position: %f", frame.position);
#endif
                        if (_decoder.validVideo){
                            
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -0.1){
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (outrun)wait %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 1;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 0.1 && count > 1){
                                
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (lags)skip %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 2;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame){
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //LoggerStream(1, @"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void)enableAudio:(BOOL)on {
    id<PLAudioManagerProtocol> audioManager = [PLAudioManager audioManager];
    
    if (on && _decoder.validAudio){
        
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels){
            [self audioCallbackFillData:outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        LoggerAudio(2, @"audio device smr: %d fmt: %d chn: %d",
                    (int)audioManager.samplingRate,
                    (int)audioManager.numBytesPerSample,
                    (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

@end
