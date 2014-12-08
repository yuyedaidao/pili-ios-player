//
//  PLLogger.h
//  PLPlayerKit
//
//  Created by 0day on 14/11/13.
//
//

#ifndef PLPlayerKit_PLLogger_h
#define PLPlayerKit_PLLogger_h

//#define DUMP_AUDIO_DATA

#ifdef DEBUG
#ifdef USE_NSLOGGER

#    import "NSLogger.h"
#    define LoggerStream(level, ...)   LogMessageF(__FILE__, __LINE__, __FUNCTION__, @"Stream", level, __VA_ARGS__)
#    define LoggerVideo(level, ...)    LogMessageF(__FILE__, __LINE__, __FUNCTION__, @"Video",  level, __VA_ARGS__)
#    define LoggerAudio(level, ...)    LogMessageF(__FILE__, __LINE__, __FUNCTION__, @"Audio",  level, __VA_ARGS__)

#else

#    define LoggerStream(level, ...)   NSLog(__VA_ARGS__)
#    define LoggerVideo(level, ...)    NSLog(__VA_ARGS__)
#    define LoggerAudio(level, ...)    NSLog(__VA_ARGS__)

#endif
#else

#    define LoggerStream(...)          while(0) {}
#    define LoggerVideo(...)           while(0) {}
#    define LoggerAudio(...)           while(0) {}

#endif

#endif
