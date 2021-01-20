// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2016, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

// Disable legacy macros
#ifndef OOSDD_LEGACY_MACROS
    #define OOSDD_LEGACY_MACROS 0
#endif

#import "OOSDDLog.h"

/**
 * Whether async should be used by log messages, excluding error messages that are always sent sync.
 **/
#ifndef OOSDD_LOG_ASYNC_ENABLED
    #define OOSDD_LOG_ASYNC_ENABLED YES
#endif

/**
 * These are the two macros that all other macros below compile into.
 * These big multiline macros makes all the other macros easier to read.
 **/
#define OOSDD_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [OOSDDLog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

#define LOG_MACRO_TO_OOSDDLOG(ddlog, isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [ddlog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

/**
 * Define version of the macro that only execute if the log level is above the threshold.
 * The compiled versions essentially look like this:
 *
 * if (logFlagForThisLogMsg & ddLogLevel) { execute log message }
 *
 * When LOG_LEVEL_DEF is defined as ddLogLevel.
 *
 * As shown further below, Lumberjack actually uses a bitmask as opposed to primitive log levels.
 * This allows for a great amount of flexibility and some pretty advanced fine grained logging techniques.
 *
 * Note that when compiler optimizations are enabled (as they are for your release builds),
 * the log messages above your logging threshold will automatically be compiled out.
 *
 * (If the compiler sees LOG_LEVEL_DEF/ddLogLevel declared as a constant, the compiler simply checks to see
 *  if the 'if' statement would execute, and if not it strips it from the binary.)
 *
 * We also define shorthand versions for asynchronous and synchronous logging.
 **/
#define OOSDD_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { OOSDD_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define LOG_MAYBE_TO_OOSDDLOG(ddlog, async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { LOG_MACRO_TO_OOSDDLOG(ddlog, async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

/**
 * Ready to use log macros with no context or tag.
 **/
#define OOSDDLogError(frmt, ...)   OOSDD_LOG_MAYBE(NO,                [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogWarn(frmt, ...)    OOSDD_LOG_MAYBE(OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogInfo(frmt, ...)    OOSDD_LOG_MAYBE(OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogDebug(frmt, ...)   OOSDD_LOG_MAYBE(OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogVerbose(frmt, ...) OOSDD_LOG_MAYBE(OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define OOSDDLogErrorToOOSDDLog(ddlog, frmt, ...)   LOG_MAYBE_TO_OOSDDLOG(ddlog, NO,                [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogWarnToOOSDDLog(ddlog, frmt, ...)    LOG_MAYBE_TO_OOSDDLOG(ddlog, OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogInfoToOOSDDLog(ddlog, frmt, ...)    LOG_MAYBE_TO_OOSDDLOG(ddlog, OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogDebugToOOSDDLog(ddlog, frmt, ...)   LOG_MAYBE_TO_OOSDDLOG(ddlog, OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define OOSDDLogVerboseToOOSDDLog(ddlog, frmt, ...) LOG_MAYBE_TO_OOSDDLOG(ddlog, OOSDD_LOG_ASYNC_ENABLED, [OOSDDLog sharedInstance].logLevel, OOSDDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
