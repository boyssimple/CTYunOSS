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


#import <Foundation/Foundation.h>
#import "OOSTransferUtilityTasks.h"
#import "OOSPreSignedURL.h"


@interface OOSTransferUtilityExpression()
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestHeaders;

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestParameters;

- (void)assignRequestParameters:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;
- (void)assignRequestHeaders:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;
@end

@interface OOSTransferUtilityUploadExpression()
@property (copy, atomic) OOSTransferUtilityUploadCompletionHandlerBlock completionHandler;
@end

@interface OOSTransferUtilityMultiPartUploadExpression()
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestHeaders;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *internalRequestParameters;
- (void)assignRequestParameters:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;
@property (copy, atomic) OOSTransferUtilityMultiPartUploadCompletionHandlerBlock completionHandler;
@end


@interface OOSTransferUtilityDownloadExpression()
@property (copy, atomic) OOSTransferUtilityDownloadCompletionHandlerBlock completionHandler;
@end


@interface OOSTransferUtilityTask()

@property (strong, nonatomic) NSURLSessionTask *sessionTask;
@property (strong, nonatomic) NSString *transferID;
@property (strong, nonatomic) NSString *bucket;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSURL *location;
@property (strong, nonatomic) NSError *error;
@property int retryCount;
@property NSString *nsURLSessionID;
@property NSString *file;
@property NSString *transferType;
@property OOSTransferUtilityTransferStatusType status;
@end

@interface OOSTransferUtilityUploadTask()

@property (strong, nonatomic) OOSTransferUtilityUploadExpression *expression;
@property NSString *responseData;
@property (atomic) BOOL cancelled;
@property BOOL temporaryFileCreated;
@end

@interface OOSTransferUtilityMultiPartUploadTask()

@property (strong, nonatomic) OOSTransferUtilityMultiPartUploadExpression *expression;
@property NSString * uploadID;
@property BOOL cancelled;
@property BOOL temporaryFileCreated;
@property NSMutableDictionary <NSNumber *, OOSTransferUtilityUploadSubTask *> *waitingPartsDictionary;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, OOSTransferUtilityUploadSubTask *> *completedPartsDictionary;
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, OOSTransferUtilityUploadSubTask *> *inProgressPartsDictionary;
@property int retryCount;
@property int partNumber;
@property NSString *file;
@property NSString *transferType;
@property NSString *nsURLSessionID;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSString *bucket;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *transferID;
@property OOSTransferUtilityTransferStatusType status;
@property NSNumber *contentLength;
@end

@interface OOSTransferUtilityUploadSubTask()
@property (strong, nonatomic) NSURLSessionTask *sessionTask;
@property (strong, nonatomic) NSNumber *partNumber;
@property (readwrite) NSUInteger taskIdentifier;
@property (strong, nonatomic) NSString *eTag;
@property int64_t totalBytesExpectedToSend;
@property int64_t totalBytesSent;
@property NSString *responseData;
@property NSString *file;
@property NSString *transferType;
@property NSString *transferID;
@property OOSTransferUtilityTransferStatusType status;
@property NSString *uploadID;

@end

@interface OOSTransferUtilityDownloadTask()

@property (strong, nonatomic) OOSTransferUtilityDownloadExpression *expression;
@property BOOL cancelled;
@property NSString *responseData;
@end

#pragma mark - OOSTransferUtilityTasks

@implementation OOSTransferUtilityTask

- (instancetype)init {
    if (self = [super init]) {
        _progress = [NSProgress new];
        _progress.completedUnitCount = 0;
    }
    
    return self;
}

- (NSUInteger)taskIdentifier {
    return self.sessionTask.taskIdentifier;
}

- (void)cancel {
}

- (void)resume {
    if (self.status != OOSTransferUtilityTransferStatusPaused) {
        //Resume called on a transfer that is not paused. No op
        return;
    }
    
    [self.sessionTask resume];
    self.status = OOSTransferUtilityTransferStatusInProgress;
}

- (void)suspend {
    if (self.status != OOSTransferUtilityTransferStatusInProgress ) {
        //Pause called on a transfer that is not in progress. No op.
        return;
    }
    
    [self.sessionTask suspend];
    self.status = OOSTransferUtilityTransferStatusPaused;
}

- (NSURLRequest *)request {
    return self.sessionTask.originalRequest;
}

- (NSHTTPURLResponse *)response {
    if ([self.sessionTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        return (NSHTTPURLResponse *)self.sessionTask.response;
    }
    return nil;
}

@end

@implementation OOSTransferUtilityUploadTask

- (OOSTransferUtilityUploadExpression *)expression {
    if (!_expression) {
        _expression = [OOSTransferUtilityUploadExpression new];
    }
    return _expression;
}

-(void) cancel {
    self.status = OOSTransferUtilityTransferStatusCancelled;
    self.cancelled = YES;
    [self.sessionTask cancel];
}

-(void) setCompletionHandler:(OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler {
    
    self.expression.completionHandler = completionHandler;
    //If the task has already completed successfully, call the completion handler
    if (self.status == OOSTransferUtilityTransferStatusCompleted ) {
        _expression.completionHandler(self, nil);
    }
    //If the task has completed with error, call the completion handler
    else if (self.error) {
        _expression.completionHandler(self, self.error);
    }
}

-(void) setProgressBlock:(OOSTransferUtilityProgressBlock)progressBlock {
    self.expression.progressBlock = progressBlock;
}

@end

@implementation OOSTransferUtilityMultiPartUploadTask

- (instancetype)init {
    if (self = [super init]) {
        _progress = [NSProgress new];
        _waitingPartsDictionary = [NSMutableDictionary new];
        _inProgressPartsDictionary = [NSMutableDictionary new];
        _completedPartsDictionary = [NSMutableDictionary new];
    }
    return self;
}

- (OOSTransferUtilityMultiPartUploadExpression *)expression {
    if (!_expression) {
        _expression = [OOSTransferUtilityMultiPartUploadExpression new];
    }
    return _expression;
}

- (void)cancel {
    self.cancelled = YES;
    self.status = OOSTransferUtilityTransferStatusCancelled;
    for (NSNumber *key in [self.inProgressPartsDictionary allKeys]) {
        OOSTransferUtilityUploadSubTask *subTask = [self.inProgressPartsDictionary objectForKey:key];
        [subTask.sessionTask cancel];
    }
}

- (void)resume {
    if (self.status != OOSTransferUtilityTransferStatusPaused ) {
        //Resume called on a transfer that hasn't been paused. No op.
        return;
    }
    
    for (NSNumber *key in [self.inProgressPartsDictionary allKeys]) {
        OOSTransferUtilityUploadSubTask *subTask = [self.inProgressPartsDictionary objectForKey:key];
        subTask.status = OOSTransferUtilityTransferStatusInProgress;
        [subTask.sessionTask resume];
    }
    self.status = OOSTransferUtilityTransferStatusInProgress;
}

- (void)suspend {
    if (self.status != OOSTransferUtilityTransferStatusInProgress) {
        //Pause called on a transfer that is not in progresss. No op.
        return;
    }
    
    for (NSNumber *key in [self.inProgressPartsDictionary allKeys]) {
        OOSTransferUtilityUploadSubTask *subTask = [self.inProgressPartsDictionary objectForKey:key];
        [subTask.sessionTask suspend];
        subTask.status = OOSTransferUtilityTransferStatusPaused;
    }
    self.status = OOSTransferUtilityTransferStatusPaused;
}

-(void) setCompletionHandler:(OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler {
    
    self.expression.completionHandler = completionHandler;
    //If the task has already completed successfully, call the completion handler
    if (self.status == OOSTransferUtilityTransferStatusCompleted) {
        _expression.completionHandler(self, nil);
    }
    //If the task has completed with error, call the completion handler
    else if (self.error ) {
        _expression.completionHandler(self, self.error);
    }
}

-(void) setProgressBlock:(OOSTransferUtilityMultiPartProgressBlock)progressBlock {
    self.expression.progressBlock = progressBlock;
}

@end

@implementation OOSTransferUtilityDownloadTask

- (OOSTransferUtilityDownloadExpression *)expression {
    if (!_expression) {
        _expression = [OOSTransferUtilityDownloadExpression new];
    }
    return _expression;
}

-(void) cancel {
    self.cancelled = YES;
    self.status = OOSTransferUtilityTransferStatusCancelled;
    [self.sessionTask cancel];
}

-(void) setCompletionHandler:(OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    
    self.expression.completionHandler = completionHandler;
    //If the task has already completed successfully, call the completion handler
    if (self.status == OOSTransferUtilityTransferStatusCompleted) {
        _expression.completionHandler(self, self.location, self.data, nil);
    }
    //If the task has completed with error, call the completion handler
    else if (self.error ) {
        _expression.completionHandler(self, self.location, self.data, self.error);
    }
}

-(void) setProgressBlock:(OOSTransferUtilityProgressBlock)progressBlock {
    self.expression.progressBlock = progressBlock;
}

@end

@implementation OOSTransferUtilityUploadSubTask
@end

#pragma mark - OOSTransferUtilityExpressions

@implementation OOSTransferUtilityExpression

- (instancetype)init {
    if (self = [super init]) {
        _internalRequestHeaders = [NSMutableDictionary new];
        _internalRequestParameters = [NSMutableDictionary new];
    }
    
    return self;
}

- (NSDictionary<NSString *, NSString *> *)requestHeaders {
    return [NSDictionary dictionaryWithDictionary:self.internalRequestHeaders];
}

- (NSDictionary<NSString *, NSString *> *)requestParameters {
    return [NSDictionary dictionaryWithDictionary:self.internalRequestParameters];
}

- (void)setValue:(NSString *)value forRequestHeader:(NSString *)requestHeader {
    [self.internalRequestHeaders setValue:value forKey:requestHeader];
}

- (void)setValue:(NSString *)value forRequestParameter:(NSString *)requestParameter {
    [self.internalRequestParameters setValue:value forKey:requestParameter];
}

- (void)assignRequestHeaders:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest {
    for (NSString *key in self.internalRequestHeaders) {
        [getPreSignedURLRequest setValue:self.internalRequestHeaders[key]
                        forRequestHeader:key];
    }
}

- (void)assignRequestParameters:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest {
    for (NSString *key in self.internalRequestParameters) {
        [getPreSignedURLRequest setValue:self.internalRequestParameters[key]
                     forRequestParameter:key];
    }
}

@end

@implementation OOSTransferUtilityUploadExpression
- (NSString *)contentMD5 {
    return [self.internalRequestHeaders valueForKey:@"Content-MD5"];
}

- (void)setContentMD5:(NSString *)contentMD5 {
    [self setValue:contentMD5 forRequestHeader:@"Content-MD5"];
}
@end

@implementation OOSTransferUtilityMultiPartUploadExpression

- (instancetype)init {
    if (self = [super init]) {
        _internalRequestHeaders = [NSMutableDictionary new];
        _internalRequestParameters = [NSMutableDictionary new];
    }
    return self;
}

- (NSDictionary<NSString *, NSString *> *)requestHeaders {
    return [NSDictionary dictionaryWithDictionary:self.internalRequestHeaders];
}

- (NSDictionary<NSString *, NSString *> *)requestParameters {
    return [NSDictionary dictionaryWithDictionary:self.internalRequestParameters];
}

- (void)setValue:(NSString *)value forRequestHeader:(NSString *)requestHeader {
    [self.internalRequestHeaders setValue:value forKey:requestHeader];
}

- (void)setValue:(NSString *)value forRequestParameter:(NSString *)requestParameter {
    [self.internalRequestParameters setValue:value forKey:requestParameter];
}

- (void)assignRequestParameters:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest {
    for (NSString *key in self.internalRequestParameters) {
        [getPreSignedURLRequest setValue:self.internalRequestParameters[key]
                     forRequestParameter:key];
    }
}

@end

@implementation OOSTransferUtilityDownloadExpression
@end
