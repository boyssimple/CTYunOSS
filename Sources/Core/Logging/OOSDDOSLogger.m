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

#import "OOSDDOSLogger.h"
#import <os/log.h>

@implementation OOSDDOSLogger

static OOSDDOSLogger *sharedInstance;

+ (instancetype)sharedInstance {
    static dispatch_once_t OOSDDOSLoggerOnceToken;

    dispatch_once(&OOSDDOSLoggerOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
    if (sharedInstance != nil) {
        return nil;
    }

    if (self = [super init]) {
        return self;
    }

    return nil;
}

- (void)logMessage:(OOSDDLogMessage *)logMessage {
    // Skip captured log messages
    if ([logMessage->_fileName isEqualToString:@"OOSDDASLLogCapture"]) {
        return;
    }
    
    NSString * message = _logFormatter ? [_logFormatter formatLogMessage:logMessage] : logMessage->_message;
    
    if (message) {
        const char *msg = [message UTF8String];
        
        switch (logMessage->_flag) {
            case OOSDDLogFlagError     :
                os_log_error(OS_LOG_DEFAULT, "%{public}s", msg);
                break;
            case OOSDDLogFlagWarning   :
            case OOSDDLogFlagInfo      :
                os_log_info(OS_LOG_DEFAULT, "%{public}s", msg);
                break;
            case OOSDDLogFlagDebug     :
            case OOSDDLogFlagVerbose   :
            default                 :
                os_log_debug(OS_LOG_DEFAULT, "%{public}s", msg);
                break;
        }
    }
}

- (NSString *)loggerName {
    return @"cocoa.lumberjack.osLogger";
}

@end
