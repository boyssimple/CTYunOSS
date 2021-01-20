/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "OOSURLSessionManager.h"
#import "OOSTask.h"
#import "OOSSynchronizedMutableDictionary.h"
#import "OOSTaskCompletionSource.h"
#import "OOSCategory.h"

#pragma mark - OOSURLSessionManagerDelegate

static NSString* const OOSMobileURLSessionManagerCacheDomain = @"cn.ctyun.OOSURLSessionManager";

typedef NS_ENUM(NSInteger, OOSURLSessionTaskType) {
    OOSURLSessionTaskTypeUnknown,
    OOSURLSessionTaskTypeData,
    OOSURLSessionTaskTypeDownload,
    OOSURLSessionTaskTypeUpload
};

@interface OOSURLSessionManagerDelegate : NSObject

@property (nonatomic, assign) OOSURLSessionTaskType taskType;
@property (nonatomic, strong) OOSTaskCompletionSource *taskCompletionSource;
@property (nonatomic, strong) OOSNetworkingRequest *request;
@property (nonatomic, strong) NSURL *uploadingFileURL;
@property (nonatomic, strong) NSURL *downloadingFileURL;

@property (nonatomic, assign) uint32_t currentRetryCount;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSFileHandle *responseFilehandle;
@property (nonatomic, strong) NSURL *tempDownloadedFileURL;
@property (nonatomic, assign) BOOL shouldWriteDirectly;
@property (nonatomic, assign) BOOL shouldWriteToFile;

@property (atomic, assign) int64_t lastTotalLengthOfChunkSignatureSent;
@property (atomic, assign) int64_t payloadTotalBytesWritten;

@end

@implementation OOSURLSessionManagerDelegate

- (instancetype)init {
    if (self = [super init]) {
        _taskType = OOSURLSessionTaskTypeUnknown;
    }

    return self;
}

@end

#pragma mark - OOSNetworkingRequest

@interface OOSNetworkingRequest()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

#pragma mark - OOSURLSessionManager

//const int64_t OOSMinimumDownloadTaskSize = 1000000;

@interface OOSURLSessionManager()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) OOSSynchronizedMutableDictionary *sessionManagerDelegates;

@end

@implementation OOSURLSessionManager

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `- initWithConfiguration` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(OOSNetworkingConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;


        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.URLCache = nil;
        if (configuration.timeoutIntervalForRequest > 0) {
            sessionConfiguration.timeoutIntervalForRequest = configuration.timeoutIntervalForRequest;
        }
        if (configuration.timeoutIntervalForResource > 0) {
            sessionConfiguration.timeoutIntervalForResource = configuration.timeoutIntervalForResource;
        }
        sessionConfiguration.allowsCellularAccess = configuration.allowsCellularAccess;
        sessionConfiguration.sharedContainerIdentifier = configuration.sharedContainerIdentifier;
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
        _sessionManagerDelegates = [OOSSynchronizedMutableDictionary new];
    }

    return self;
}

- (OOSTask *)dataTaskWithRequest:(OOSNetworkingRequest *)request {
    [request assignProperties:self.configuration];

    OOSURLSessionManagerDelegate *delegate = [OOSURLSessionManagerDelegate new];
    delegate.taskCompletionSource = [OOSTaskCompletionSource taskCompletionSource];
    delegate.request = request;
    delegate.taskType = OOSURLSessionTaskTypeData;
    delegate.downloadingFileURL = request.downloadingFileURL;
    delegate.uploadingFileURL = request.uploadingFileURL;
    delegate.shouldWriteDirectly = request.shouldWriteDirectly;

    [self taskWithDelegate:delegate];

    return delegate.taskCompletionSource.task;
}

- (void)taskWithDelegate:(OOSURLSessionManagerDelegate *)delegate {
    if (delegate.downloadingFileURL) delegate.shouldWriteToFile = YES;
    delegate.responseData = nil;
    delegate.responseObject = nil;
    delegate.error = nil;
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:delegate.request.URL];
    mutableRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

    OOSNetworkingRequest *request = delegate.request;
    if (request.isCancelled) {
        delegate.taskCompletionSource.error = [NSError errorWithDomain:OOSNetworkingErrorDomain
                                                                  code:OOSNetworkingErrorCancelled
                                                              userInfo:nil];
        return;
    }

    mutableRequest.HTTPMethod = [NSString oos_stringWithHTTPMethod:delegate.request.HTTPMethod];

    OOSTask *task = [OOSTask taskWithResult:nil];

    if (request.requestSerializer) {
        task = [request.requestSerializer serializeRequest:mutableRequest
                                                   headers:request.headers
                                                parameters:request.parameters];
    }

    for(id<OOSNetworkingRequestInterceptor>interceptor in request.requestInterceptors) {
        task = [task continueWithSuccessBlock:^id(OOSTask *task) {
            return [interceptor interceptRequest:mutableRequest];
        }];
    }

    [[[task continueWithSuccessBlock:^id _Nullable(OOSTask * _Nonnull task) {
        OOSNetworkingRequest *request = delegate.request;
        return [request.requestSerializer validateRequest:mutableRequest];
    }] continueWithSuccessBlock:^id _Nullable(OOSTask * _Nonnull task) {
        switch (delegate.taskType) {
            case OOSURLSessionTaskTypeData:
                delegate.request.task = [self.session dataTaskWithRequest:mutableRequest];
                break;

            default:
                break;
        }

        if (delegate.request.task) {
            [self.sessionManagerDelegates setObject:delegate
                                             forKey:@(((NSURLSessionTask *)delegate.request.task).taskIdentifier)];

            [self printHTTPHeadersAndBodyForRequest:delegate.request.task.originalRequest];

            [delegate.request.task resume];
        } else {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSNetworkingErrorDomain
                                                              code:OOSNetworkingErrorUnknown
                                                          userInfo:@{NSLocalizedDescriptionKey: @"Invalid OOSURLSessionTaskType."}]];
        }

        return nil;
    }] continueWithBlock:^id(OOSTask *task) {
        if (task.error) {
            NSError *error = task.error;
            delegate.taskCompletionSource.error = error;
        }
        return nil;
    }];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error {
    if (error) {
        OOSDDLogError(@"Session task failed with error: %@", error);
    }

    [self printHTTPHeadersForResponse:sessionTask.response];

    [[[OOSTask taskWithResult:nil] continueWithSuccessBlock:^id(OOSTask *task) {
        OOSURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(sessionTask.taskIdentifier)];

        if (delegate.responseFilehandle) {
            [delegate.responseFilehandle closeFile];
        }

        if (!delegate.error) {
            delegate.error = error;
        }

        //delete temporary file if the task contains error (e.g. has been canceled)
        if (error && delegate.tempDownloadedFileURL) {
            [[NSFileManager defaultManager] removeItemAtPath:delegate.tempDownloadedFileURL.path error:nil];
        }


        if (!delegate.error
            && [sessionTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)sessionTask.response;

            if (delegate.shouldWriteToFile) {
                NSError *error = nil;
                //move the downloaded file to user specified location if tempDownloadFileURL and downloadFileURL are different.
                if (delegate.tempDownloadedFileURL && delegate.downloadingFileURL && [delegate.tempDownloadedFileURL isEqual:delegate.downloadingFileURL] == NO) {

                    if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.downloadingFileURL.path]) {
                        OOSDDLogWarn(@"Warn : target file already exists, will be overwritten at the file path: %@",delegate.downloadingFileURL);
                        [[NSFileManager defaultManager] removeItemAtPath:delegate.downloadingFileURL.path error:&error];
                    }
                    if (error) {
                        OOSDDLogError(@"Delete File Error: [%@]",error);
                    }
                    error = nil;
                    [[NSFileManager defaultManager] moveItemAtURL:delegate.tempDownloadedFileURL
                                                            toURL:delegate.downloadingFileURL
                                                            error:&error];
                }
                if (error) {
                    delegate.error = error;
                } else {
                    if ([delegate.request.responseSerializer respondsToSelector:@selector(responseObjectForResponse:originalRequest:currentRequest:data:error:)]) {
                        NSError *error = nil;
                        delegate.responseObject = [delegate.request.responseSerializer responseObjectForResponse:httpResponse
                                                                                                 originalRequest:sessionTask.originalRequest
                                                                                                  currentRequest:sessionTask.currentRequest
                                                                                                            data:delegate.downloadingFileURL
                                                                                                           error:&error];
                        if (error) {
                            delegate.error = error;
                        }
                    }
                    else {
                        delegate.responseObject = delegate.downloadingFileURL;
                    }
                }
            } else if (!delegate.error) {
                // need to call responseSerializer if there is no client-side error.
                if ([delegate.request.responseSerializer respondsToSelector:@selector(responseObjectForResponse:originalRequest:currentRequest:data:error:)]) {
                    NSError *error = nil;
                    delegate.responseObject = [delegate.request.responseSerializer responseObjectForResponse:httpResponse
                                                                                             originalRequest:sessionTask.originalRequest
                                                                                              currentRequest:sessionTask.currentRequest
                                                                                                        data:delegate.responseData
                                                                                                       error:&error];
                    if (error) {
                        delegate.error = error;
                    }
                }
                else {
                    delegate.responseObject = delegate.responseData;
                }
            }
        }

        if (delegate.error
            && ([sessionTask.response isKindOfClass:[NSHTTPURLResponse class]] || sessionTask.response == nil)
            && delegate.request.retryHandler) {
            OOSNetworkingRetryType retryType = [delegate.request.retryHandler shouldRetry:delegate.currentRetryCount
                                                                          originalRequest:delegate.request
                                                                                 response:(NSHTTPURLResponse *)sessionTask.response
                                                                                     data:delegate.responseData
                                                                                    error:delegate.error];
            switch (retryType) {
                case OOSNetworkingRetryTypeShouldCorrectClockSkewAndRetry: {
                    //Correct Clock Skew
                    if ([sessionTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)sessionTask.response;
                        NSString *dateStr = [[httpResponse allHeaderFields] objectForKey:@"Date"];
                        if ([dateStr length] > 0) {
                            NSDate *serverTime = [NSDate OOS_dateFromString:dateStr];
                            NSDate *deviceTime = [NSDate date];
                            NSTimeInterval skewTime = [deviceTime timeIntervalSinceDate:serverTime];
                            [NSDate OOS_setRuntimeClockSkew:skewTime];
                        } else {
                            // The response header does not have the 'Date' field.
                            // This should not happen.
                            OOSDDLogDebug(@"Date header does not exist. Not able to fix the clock skew.");
                        }
                    }
                }
                    // Keep going to the next 'case' statement.

                case OOSNetworkingRetryTypeShouldRefreshCredentialsAndRetry: {

                }
                    // keep going to the next 'case' statement
                case OOSNetworkingRetryTypeResetStreamAndRetry: {
                    id retryHandler = delegate.request.retryHandler;
                    if([retryHandler respondsToSelector:@selector(resetParameters:)]) {
                        delegate.request.parameters = [delegate.request.retryHandler resetParameters:delegate.request.parameters];
                    }
                }
                    // Keep going to the next 'case' statement.
                case OOSNetworkingRetryTypeShouldRetry: {
                    NSTimeInterval timeIntervalToSleep = [delegate.request.retryHandler timeIntervalForRetry:delegate.currentRetryCount
                                                                                                    response:(NSHTTPURLResponse *)sessionTask.response
                                                                                                        data:delegate.responseData
                                                                                                       error:delegate.error];
                    [NSThread sleepForTimeInterval:timeIntervalToSleep];
                    delegate.currentRetryCount++;
                    [self taskWithDelegate:delegate];
                }
                    break;

                case OOSNetworkingRetryTypeShouldNotRetry: {
                    if (delegate.error) {
                        NSError *error = delegate.error;
                        delegate.taskCompletionSource.error = error;
                    } else if (delegate.responseObject) {
                        id result = delegate.responseObject;
                        delegate.taskCompletionSource.result = result;
                    }
                }
                    break;

                default:
                    NSAssert(NO, @"Unknown retry type. This should not happen.");
                    break;
            }
        } else {
            //reset isClockSkewRetried flag for that Service if request went through
            id retryHandler = delegate.request.retryHandler;
            if ([[retryHandler valueForKey:@"isClockSkewRetried"] boolValue]) {
                [retryHandler setValue:@NO forKey:@"isClockSkewRetried"];
            }

            if (delegate.error) {
                NSError *error = delegate.error;
                delegate.taskCompletionSource.error = error;
            } else if (delegate.responseObject) {
                id result = delegate.responseObject;
                delegate.taskCompletionSource.result = result;
            }
        }
        return nil;
    }] continueWithBlock:^id(OOSTask *task) {
        [self.sessionManagerDelegates removeObjectForKey:@(sessionTask.taskIdentifier)];
        return nil;
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    OOSURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(task.taskIdentifier)];
    OOSNetworkingUploadProgressBlock uploadProgress = delegate.request.uploadProgress;
    
    if (uploadProgress) {
		uploadProgress(bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    OOSURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(dataTask.taskIdentifier)];
    
    //If the response code is not 2xx, avoid write data to disk
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            // status is good, we can keep value of shouldWriteToFile
        } else {
            // got error status code, avoid write data to disk
            delegate.shouldWriteToFile = NO;
        }
    }
    
    @try {
        if (delegate.shouldWriteToFile) {

            if (delegate.shouldWriteDirectly) {
                //If set (e..g by S3 Transfer Manager), downloaded data will be wrote to the downloadingFileURL directly, if the file already exists, it will appended to the end.

                NSError *error = nil;
                if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.downloadingFileURL.path]) {
                    OOSDDLogDebug(@"target file already exists, will be appended at the file path: %@",delegate.downloadingFileURL);
                    delegate.responseFilehandle = [NSFileHandle fileHandleForUpdatingURL:delegate.downloadingFileURL error:&error];
                    if (error) {
                        OOSDDLogError(@"Error: [%@]", error);
                    }
                    [delegate.responseFilehandle seekToEndOfFile];

                } else {
                    //Create the file
                    if (![[NSFileManager defaultManager] createFileAtPath:delegate.downloadingFileURL.path contents:nil attributes:nil]) {
                        OOSDDLogError(@"Error: Can not create file with file path:%@",delegate.downloadingFileURL.path);
                    }
                    error = nil;
                    delegate.responseFilehandle = [NSFileHandle fileHandleForWritingToURL:delegate.downloadingFileURL error:&error];
                    if (error) {
                        OOSDDLogError(@"Error: [%@]", error);
                    }
                }

            } else {
                NSError *error = nil;
                //This is the normal case. downloaded data will be saved in a temporay folder and then moved to downloadingFileURL after downloading complete.
                NSString *tempFileName = [NSString stringWithFormat:@"%@.%@",OOSMobileURLSessionManagerCacheDomain,[[NSProcessInfo processInfo] globallyUniqueString]];
                NSString *tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fileCache",OOSMobileURLSessionManagerCacheDomain]];

                //Create temp folder if not exist
                [[NSFileManager defaultManager] createDirectoryAtPath:tempDirPath withIntermediateDirectories:NO attributes:nil error:nil];

                delegate.tempDownloadedFileURL  = [NSURL fileURLWithPath:[tempDirPath stringByAppendingPathComponent:tempFileName]];

                //Remove temp file if it has already exists
                if ([[NSFileManager defaultManager] fileExistsAtPath:delegate.tempDownloadedFileURL.path]) {
                    OOSDDLogWarn(@"Warn: target file already exists, will be overwritten at the file path: %@",delegate.tempDownloadedFileURL);
                    [[NSFileManager defaultManager] removeItemAtPath:delegate.tempDownloadedFileURL.path error:&error];
                }
                if (error) {
                    OOSDDLogError(@"Error: [%@]", error);
                }

                //Create new temp file
                if (![[NSFileManager defaultManager] createFileAtPath:delegate.tempDownloadedFileURL.path contents:nil attributes:nil]) {
                    OOSDDLogError(@"Error: Can not create file with file path:%@",delegate.tempDownloadedFileURL.path);
                }
                error = nil;
                delegate.responseFilehandle = [NSFileHandle fileHandleForWritingToURL:delegate.tempDownloadedFileURL error:&error];
                if (error) {
                    OOSDDLogError(@"Error: [%@]", error);
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSString *desc = [NSString stringWithFormat:@"Failed to write data: %@", exception];
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey:  desc
                                   };
        OOSDDLogError(@"Error: [%@]", exception);
        delegate.error = [NSError errorWithDomain:OOSNetworkingErrorDomain code:OOSNetworkingErrorUnknown userInfo: userInfo];
    }
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    OOSURLSessionManagerDelegate *delegate = [self.sessionManagerDelegates objectForKey:@(dataTask.taskIdentifier)];
    
    if (delegate.responseFilehandle) {
        @try{
            [delegate.responseFilehandle writeData:data];
        }
        @catch (NSException *exception) {
            NSString *desc = [NSString stringWithFormat:@"Failed to write data: %@", exception];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey:  desc
                                       };
            OOSDDLogError(@"Error: [%@]", exception);
            delegate.error = [NSError errorWithDomain:OOSNetworkingErrorDomain code:OOSNetworkingErrorUnknown userInfo: userInfo];
            [dataTask cancel];
        }
    } else {
        if (!delegate.responseData) {
            delegate.responseData = [NSMutableData dataWithData:data];
        } else if ([delegate.responseData isKindOfClass:[NSMutableData class]]) {
            [delegate.responseData appendData:data];
        }
    }
    
    OOSNetworkingDownloadProgressBlock downloadProgress = delegate.request.downloadProgress;
    if (downloadProgress) {

        int64_t bytesWritten = [data length];
        delegate.payloadTotalBytesWritten += bytesWritten;
        int64_t byteRangeStartPosition = 0;
        int64_t totalBytesExpectedToWrite = dataTask.response.expectedContentLength;
        if ([dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)dataTask.response;
            NSString *contentRangeString = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
            int64_t trueContentLength = [[[contentRangeString componentsSeparatedByString:@"/"] lastObject] longLongValue];
            if (trueContentLength) {
                byteRangeStartPosition = trueContentLength - dataTask.response.expectedContentLength;
                totalBytesExpectedToWrite = trueContentLength;
            }
        }
        downloadProgress(bytesWritten,delegate.payloadTotalBytesWritten + byteRangeStartPosition,totalBytesExpectedToWrite);
    }
    
}

#pragma mark - Helper methods

- (void)printHTTPHeadersAndBodyForRequest:(NSURLRequest *)request {
    if([OOSDDLog sharedInstance].logLevel & OOSDDLogFlagDebug){
        if(request.HTTPBody) {
            NSMutableString *bodyString = [[NSMutableString alloc] initWithData:request.HTTPBody
                                                                       encoding:NSUTF8StringEncoding];
            if (bodyString.length <= 100 * 1024) {
                OOSDDLogDebug(@"Request body:\n%@", bodyString);
            } else {
                OOSDDLogDebug(@"Request body (Partial data. The first 100KB is displayed.):\n%@", [bodyString substringWithRange:NSMakeRange(0, 100 * 1024)]);
            }
        }
		if (request.allHTTPHeaderFields) {
			OOSDDLogDebug(@"Request headers:\n%@", request.allHTTPHeaderFields);
		}
		OOSDDLogDebug(@"Request URI: %@", request.URL);
    }
}

- (void)printHTTPHeadersForResponse:(NSURLResponse *)response {
    if([OOSDDLog sharedInstance].logLevel & OOSDDLogFlagDebug){
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            OOSDDLogDebug(@"Response headers:\n%@", ((NSHTTPURLResponse *)response).allHeaderFields);
        }
    }
}

@end
