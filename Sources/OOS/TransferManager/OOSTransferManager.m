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


#import "OOSTransferManager.h"
#import "OOS.h"
#import "OOSBolts.h"
#import "OOSCategory.h"
#import "OOSTMCache.h"
#import "OOSSynchronizedMutableDictionary.h"
#import "OOSMTLModel+NSCoding.h"

static NSString *const OOSInfoTransferManager = @"TransferManager";

// Private constants
NSUInteger const OOSTransferManagerMinimumPartSize = 5 * 1024 * 1024; // 5MB
NSString *const OOSTransferManagerCacheName = @"cn.ctyun.OOSTransferManager.CacheName";
NSString *const OOSTransferManagerErrorDomain = @"cn.ctyun.OOSTransferManagerErrorDomain";
NSUInteger const OOSTransferManagerByteLimitDefault = 5 * 1024 * 1024; // 5MB
NSTimeInterval const OOSTransferManagerAgeLimitDefault = 0.0; // Keeps the data indefinitely unless it hits the size limit.
NSString *const OOSTransferManagerUserAgentPrefix = @"transfer-manager";

@interface OOSTransferManager()

@property (nonatomic, strong) OOS *client;
@property (nonatomic, strong) OOSTMCache *cache;

@end

@interface OOSTransferManagerUploadRequest ()

@property (nonatomic, assign) OOSTransferManagerRequestState state;
@property (nonatomic, assign) NSUInteger currentUploadingPartNumber;
@property (nonatomic, strong) NSMutableArray *completedPartsArray;
@property (nonatomic, strong) NSString *uploadId;
@property (atomic, strong) OOSUploadPartRequest *currentUploadingPart;

@property (atomic, assign) int64_t totalSuccessfullySentPartsDataLength;
@end

@interface OOSTransferManagerDownloadRequest ()

@property (nonatomic, strong) NSURL *temporaryFileURL;
@property (nonatomic, strong) NSURL *originalFileURL;
@property (nonatomic, assign) OOSTransferManagerRequestState state;
@property (nonatomic, strong) NSString *cacheIdentifier;

@end

@interface OOS()

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration;

@end

@implementation OOSTransferManager

static OOSSynchronizedMutableDictionary *_serviceClients = nil;

+ (instancetype)defaultTransferManager {
    static OOSTransferManager *_defaultTransferManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OOSServiceConfiguration *serviceConfiguration = [OOSServiceManager defaultServiceManager].defaultServiceConfiguration;

        if (!serviceConfiguration) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The service configuration is `nil`. You need to configure `Info.plist` or set `defaultServiceConfiguration` before using this method."
                                         userInfo:nil];
        }

        _defaultTransferManager = [[OOSTransferManager alloc] initWithConfiguration:serviceConfiguration
                                                                              cacheName:OOSTransferManagerCacheName];
    });

    return _defaultTransferManager;
}

+ (void)registerTransferManagerWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [OOSSynchronizedMutableDictionary new];
    });

    OOSTransferManager *TransferManager = [[OOSTransferManager alloc] initWithConfiguration:configuration
                                                                                        cacheName:[NSString stringWithFormat:@"%@.%@", OOSTransferManagerCacheName, key]];
    [_serviceClients setObject:TransferManager
                        forKey:key];
}

+ (instancetype)TransferManagerForKey:(NSString *)key {
    @synchronized(self) {
        OOSTransferManager *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }

        OOSServiceInfo *serviceInfo = [[OOSInfo defaultOOSInfo] serviceInfo:OOSInfoTransferManager
                                                                     forKey:key];
        if (serviceInfo) {
            OOSServiceConfiguration *serviceConfiguration = [[OOSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                                                        credentialsProvider:nil];
            [OOSTransferManager registerTransferManagerWithConfiguration:serviceConfiguration
                                                                      forKey:key];
        }

        return [_serviceClients objectForKey:key];
    }
}

+ (void)removeTransferManagerForKey:(NSString *)key {
    [_serviceClients removeObjectForKey:key];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultTransferManager` or `+ TransferManagerForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration
                           identifier:(NSString *)identifier {
    if (self = [self initWithConfiguration:configuration
                                 cacheName:[NSString stringWithFormat:@"%@.%@", OOSTransferManagerCacheName, identifier]]) {
    }

    return self;
}

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration
                            cacheName:(NSString *)cacheName {
    if (self = [super init]) {
        OOSServiceConfiguration *_configuration = [configuration copy];
        [_configuration addUserAgentProductToken:OOSTransferManagerUserAgentPrefix];
        _client = [[OOS alloc] initWithConfiguration:_configuration];

        _cache = [[OOSTMCache alloc] initWithName:cacheName
                                         rootPath:[NSTemporaryDirectory() stringByAppendingPathComponent:OOSTransferManagerCacheName]];
        _cache.diskCache.byteLimit = OOSTransferManagerByteLimitDefault;
        _cache.diskCache.ageLimit = OOSTransferManagerAgeLimitDefault;
    }
    return self;
}

- (OOSTask *)upload:(OOSTransferManagerUploadRequest *)uploadRequest {
    NSString *cacheKey = nil;
    if ([uploadRequest valueForKey:@"cacheIdentifier"]) {
        cacheKey = [uploadRequest valueForKey:@"cacheIdentifier"];
    } else {
        cacheKey = [[NSProcessInfo processInfo] globallyUniqueString];
        [uploadRequest setValue:cacheKey forKey:@"cacheIdentifier"];
    }

    return [self upload:uploadRequest cacheKey:cacheKey];
}

- (OOSTask *)upload:(OOSTransferManagerUploadRequest *)uploadRequest
          cacheKey:(NSString *)cacheKey {
    //validate input
    if ([uploadRequest.bucket length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'bucket' name can not be empty", nil)};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if ([uploadRequest.key length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'key' name can not be empty", nil)};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if (uploadRequest.body == nil) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'body' can not be nil", nil)};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];

    } else if ([uploadRequest.body isKindOfClass:[NSURL class]] == NO) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid 'body' Type, must be an instance of NSURL Class", nil)};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorInvalidParameters userInfo:userInfo]];
    }

    //Check if the task has already completed
    if (uploadRequest.state == OOSTransferManagerRequestStateCompleted) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a completed task", nil)]};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCompleted userInfo:userInfo]];
    } else if (uploadRequest.state == OOSTransferManagerRequestStateCanceling){
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a cancelled task.", nil)]};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCancelled userInfo:userInfo]];
    } else {
        //change state to running
        [uploadRequest setValue:[NSNumber numberWithInteger:OOSTransferManagerRequestStateRunning] forKey:@"state"];
    }

    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[uploadRequest.body path] stringByResolvingSymlinksInPath]
                                                                                error:&error];
    if (!attributes) {
        return [OOSTask taskWithError:error];
    }

    unsigned long long fileSize = [attributes fileSize];
    __weak OOSTransferManager *weakSelf = self;

    OOSTask *task = [OOSTask taskWithResult:nil];
    task = [[[task continueWithSuccessBlock:^id(OOSTask *task) {
        [weakSelf.cache setObject:uploadRequest
                           forKey:cacheKey];
        return nil;
    }] continueWithSuccessBlock:^id(OOSTask *task) {
        if (fileSize > OOSTransferManagerMinimumPartSize) {
            return [weakSelf multipartUpload:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        } else {
            return [weakSelf putObject:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        }
    }] continueWithBlock:^id(OOSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:NSURLErrorDomain]
                && task.error.code == NSURLErrorCancelled) {
                if (uploadRequest.state == OOSTransferManagerRequestStatePaused) {
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain
                                                                     code:OOSTransferManagerErrorPaused
                                                                 userInfo:task.error.userInfo]];
                } else {
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain
                                                                     code:OOSTransferManagerErrorCancelled
                                                                 userInfo:task.error.userInfo]];
                }
            } else {
                return [OOSTask taskWithError:task.error];
            }
        } else {
            uploadRequest.state = OOSTransferManagerRequestStateCompleted;
            [uploadRequest setValue:nil forKey:@"internalRequest"];
            return [OOSTask taskWithResult:task.result];
        }
    }];

    return task;
}

- (OOSTask *)putObject:(OOSTransferManagerUploadRequest *)uploadRequest
             fileSize:(unsigned long long) fileSize
             cacheKey:(NSString *)cacheKey {
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
    OOSPutObjectRequest *putObjectRequest = [OOSPutObjectRequest new];
    [putObjectRequest OOS_copyPropertiesFromObject:uploadRequest];
    __weak OOSTransferManager *weakSelf = self;

    OOSTask *uploadTask = [[weakSelf.client putObject:putObjectRequest] continueWithBlock:^id(OOSTask *task) {

        //delete cached Object if state is not Paused
        if (uploadRequest.state != OOSTransferManagerRequestStatePaused) {
            [weakSelf.cache removeObjectForKey:cacheKey];
        }
        if (task.error) {
            return [OOSTask taskWithError:task.error];
        }

        OOSTransferManagerUploadOutput *uploadOutput = [OOSTransferManagerUploadOutput new];
        if (task.result) {
            OOSPutObjectOutput *putObjectOutput = task.result;
            [uploadOutput OOS_copyPropertiesFromObject:putObjectOutput];
        }

        return uploadOutput;
    }];

    return uploadTask;
}

- (OOSTask *)multipartUpload:(OOSTransferManagerUploadRequest *)uploadRequest
                   fileSize:(unsigned long long) fileSize
                   cacheKey:(NSString *)cacheKey {
    NSUInteger partCount = ceil((double)fileSize / OOSTransferManagerMinimumPartSize);

    OOSTask *initRequest = nil;
    __weak OOSTransferManager *weakSelf = self;

    //if it is a new request, Init multipart upload request
    if (uploadRequest.currentUploadingPartNumber == 0) {
        OOSCreateMultipartUploadRequest *createMultipartUploadRequest = [OOSCreateMultipartUploadRequest new];
        [createMultipartUploadRequest OOS_copyPropertiesFromObject:uploadRequest];
        [createMultipartUploadRequest setValue:[OOSNetworkingRequest new] forKey:@"internalRequest"]; //recreate a new internalRequest
        initRequest = [weakSelf.client createMultipartUpload:createMultipartUploadRequest];
        [uploadRequest setValue:[NSMutableArray arrayWithCapacity:partCount] forKey:@"completedPartsArray"];
    } else {
        //if it is a paused request, skip initMultipart Upload request.
        initRequest = [OOSTask taskWithResult:nil];
    }

    OOSCompleteMultipartUploadRequest *completeMultipartUploadRequest = [OOSCompleteMultipartUploadRequest new];
    [completeMultipartUploadRequest OOS_copyPropertiesFromObject:uploadRequest];
	// 上面的复制属性会把默认设置的contentType冲掉。必须重新赋值
	completeMultipartUploadRequest.contentType = @"application/xml";
    [completeMultipartUploadRequest setValue:[OOSNetworkingRequest new] forKey:@"internalRequest"]; //recreate a new internalRequest

    OOSTask *uploadTask = [[[initRequest continueWithSuccessBlock:^id(OOSTask *task) {
        OOSCreateMultipartUploadOutput *output = task.result;

        if (output.uploadId) {
            completeMultipartUploadRequest.uploadId = output.uploadId;
            uploadRequest.uploadId = output.uploadId; //pass uploadId to the request for reference.
        } else {
            completeMultipartUploadRequest.uploadId = uploadRequest.uploadId;
        }

        OOSTask *uploadPartsTask = [OOSTask taskWithResult:nil];
        NSUInteger c = uploadRequest.currentUploadingPartNumber;
        if (c == 0) {
            c = 1;
        }

        __block int64_t multiplePartsTotalBytesSent = 0;

        for (NSUInteger i = c; i < partCount + 1; i++) {
            uploadPartsTask = [uploadPartsTask continueWithSuccessBlock:^id(OOSTask *task) {

                //Cancel this task if state is canceling
                if (uploadRequest.state == OOSTransferManagerRequestStateCanceling) {
                    //return a error task
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@" MultipartUpload has been cancelled.", nil)]};
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCancelled userInfo:userInfo]];
                }
                //Pause this task if state is Paused
                if (uploadRequest.state == OOSTransferManagerRequestStatePaused) {

                    //return an error task
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@" MultipartUpload has been paused.", nil)]};
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorPaused userInfo:userInfo]];
                }

                NSUInteger dataLength = i == partCount ? (NSUInteger)fileSize - ((i - 1) * OOSTransferManagerMinimumPartSize) : OOSTransferManagerMinimumPartSize;

                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[uploadRequest.body path]];
                [fileHandle seekToFileOffset:(i - 1) * OOSTransferManagerMinimumPartSize];
                NSData *partData = [fileHandle readDataOfLength:dataLength];
                NSURL *tempURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
                [partData writeToURL:tempURL atomically:YES];
                partData = nil;
                [fileHandle closeFile];

                OOSUploadPartRequest *uploadPartRequest = [OOSUploadPartRequest new];
                uploadPartRequest.bucket = uploadRequest.bucket;
                uploadPartRequest.key = uploadRequest.key;
                uploadPartRequest.partNumber = @(i);
                uploadPartRequest.body = tempURL;
                uploadPartRequest.contentLength = @(dataLength);
                uploadPartRequest.uploadId = output.uploadId?output.uploadId:uploadRequest.uploadId;
                
                uploadRequest.currentUploadingPart = uploadPartRequest; //retain the current uploading parts for cancel/pause purpose

                //reprocess the progressFeed received from  client
                uploadPartRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {

                    OOSNetworkingRequest *internalRequest = [uploadRequest valueForKey:@"internalRequest"];
                    if (internalRequest.uploadProgress) {
                        int64_t previousSentDataLengh = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
                        if (multiplePartsTotalBytesSent == 0) {
                            multiplePartsTotalBytesSent += bytesSent;
                            multiplePartsTotalBytesSent += previousSentDataLengh;
                            internalRequest.uploadProgress(bytesSent,multiplePartsTotalBytesSent,fileSize);
                        } else {
                            multiplePartsTotalBytesSent += bytesSent;
                            internalRequest.uploadProgress(bytesSent,multiplePartsTotalBytesSent,fileSize);
                        }
                    }
                };

                return [[[weakSelf.client uploadPart:uploadPartRequest] continueWithSuccessBlock:^id(OOSTask *task) {
                    OOSUploadPartOutput *partOuput = task.result;

                    OOSCompletedPart *completedPart = [OOSCompletedPart new];
                    completedPart.partNumber = @(i);
                    completedPart.ETag = partOuput.ETag;

                    NSMutableArray *completedParts = [uploadRequest valueForKey:@"completedPartsArray"];

                    if (![completedParts containsObject:completedPart]) {
                        [completedParts addObject:completedPart];
                    }

                    int64_t totalSentLenght = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
                    totalSentLenght += dataLength;

                    [uploadRequest setValue:@(totalSentLenght) forKey:@"totalSuccessfullySentPartsDataLength"];

                    //set currentUploadingPartNumber to i+1 to prevent it be downloaded again if pause happened right after parts finished.
                    uploadRequest.currentUploadingPartNumber = i + 1;
                    [weakSelf.cache setObject:uploadRequest forKey:cacheKey];

                    return nil;
                }] continueWithBlock:^id(OOSTask *task) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtURL:tempURL
                                                              error:&error];
                    if (error) {
                        OOSDDLogError(@"Failed to delete a temporary file for part upload: [%@]", error);
                    }

                    if (task.error) {
                        return [OOSTask taskWithError:task.error];
                    } else {
                        return nil;
                    }
                }];
            }];
        }

        return uploadPartsTask;
    }] continueWithSuccessBlock:^id(OOSTask *task) {

        //If all parts upload succeed, send completeMultipartUpload request
        NSMutableArray *completedParts = [uploadRequest valueForKey:@"completedPartsArray"];
        if ([completedParts count] != partCount) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"completedParts count is not equal to totalPartCount. expect %lu but got %lu",(unsigned long)partCount,(unsigned long)[completedParts count]],@"completedParts":completedParts};
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain
                                                             code:OOSTransferManagerErrorUnknown
                                                         userInfo:userInfo]];
        }

        OOSCompletedMultipartUpload *completedMultipartUpload = [OOSCompletedMultipartUpload new];
        completedMultipartUpload.parts = completedParts;
        completeMultipartUploadRequest.multipartUpload = completedMultipartUpload;
		
        return [weakSelf.client completeMultipartUpload:completeMultipartUploadRequest];
    }] continueWithBlock:^id(OOSTask *task) {

        //delete cached Object if state is not Paused
        if (uploadRequest.state != OOSTransferManagerRequestStatePaused) {
            [weakSelf.cache removeObjectForKey:cacheKey];
        }

        if (uploadRequest.state == OOSTransferManagerRequestStateCanceling) {
            [weakSelf abortMultipartUploadsForRequest:uploadRequest];
        }

        if (task.error) {
            return [OOSTask taskWithError:task.error];
        }

        OOSTransferManagerUploadOutput *uploadOutput = [OOSTransferManagerUploadOutput new];
        if (task.result) {
            OOSCompleteMultipartUploadOutput *completeMultipartUploadOutput = task.result;
            [uploadOutput OOS_copyPropertiesFromObject:completeMultipartUploadOutput];
        }

        return uploadOutput;
    }];

    return uploadTask;
}

- (OOSTask *)download:(OOSTransferManagerDownloadRequest *)downloadRequest {
    NSString *cacheKey = nil;
    if ([downloadRequest valueForKey:@"cacheIdentifier"]) {
        cacheKey = [downloadRequest valueForKey:@"cacheIdentifier"];
    } else {
        cacheKey = [[NSProcessInfo processInfo] globallyUniqueString];
        [downloadRequest setValue:cacheKey forKey:@"cacheIdentifier"];
    }

    return [self download:downloadRequest cacheKey:cacheKey];
}

- (OOSTask *)download:(OOSTransferManagerDownloadRequest *)downloadRequest
            cacheKey:(NSString *)cacheKey {

    //validate input
    if ([downloadRequest.bucket length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'bucket' name can not be empty", nil)};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if ([downloadRequest.key length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'key' name can not be empty", nil)};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }


    //Check if the task has already completed
    if (downloadRequest.state == OOSTransferManagerRequestStateCompleted) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to download a completed task", nil)]};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCompleted userInfo:userInfo]];
    } else if (downloadRequest.state == OOSTransferManagerRequestStateCanceling){
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to download a cancelled task.", nil)]};
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCancelled userInfo:userInfo]];
    }

    //if it is a new request.
    if (downloadRequest.state != OOSTransferManagerRequestStatePaused) {

        //If downloadFileURL is nil, create a URL in temporary folder for user.
        if (downloadRequest.downloadingFileURL == nil) {
            NSString *adjustedKeyName = [[downloadRequest.key componentsSeparatedByString:@"/"] lastObject];
            NSString *generatedfileName = adjustedKeyName;


            //check if the file already exists, if yes, create another fileName;
            NSUInteger suffixCount = 2;
            while ([[NSFileManager defaultManager] fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:generatedfileName]]) {
                NSMutableArray *components = [[adjustedKeyName componentsSeparatedByString:@"."] mutableCopy];
                if ([components count] == 1) {
                    generatedfileName = [NSString stringWithFormat:@"%@ (%lu)",adjustedKeyName,(unsigned long)suffixCount];
                } else if ([components count] >= 2) {
                    NSString *modifiedFileName = [NSString stringWithFormat:@"%@ (%lu)",[components objectAtIndex:[components count]-2],(unsigned long)suffixCount];
                    [components replaceObjectAtIndex:[components count]-2 withObject:modifiedFileName];
                    generatedfileName = [components componentsJoinedByString:@"."];

                } else {
                    NSString *errorString = @"[generatedPath componentsSeparatedByString] returns empty array or nil, generatedfileName:%@";
                    OOSDDLogError(errorString, generatedfileName);
                    NSString *localizedErrorString = [NSString stringWithFormat:NSLocalizedString(errorString, @"[generatedPath componentsSeparatedByString] returns empty array or nil, generatedfileName:{Generated File Name}"), generatedfileName];
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: localizedErrorString};
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorInternalInConsistency userInfo:userInfo]];
                }
                suffixCount++;
            }

            downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:generatedfileName]];
        }
        
        //create a tempFileURL
        NSString *tempFileName = [[downloadRequest.downloadingFileURL lastPathComponent] stringByAppendingString:cacheKey];
        NSURL *tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName]];
        
        //save current downloadFileURL
        downloadRequest.originalFileURL = downloadRequest.downloadingFileURL;

        
        //save the tempFileURL
        downloadRequest.temporaryFileURL = tempFileURL;
    } else {
        //if the is a paused task, set the range
        NSURL *tempFileURL = downloadRequest.temporaryFileURL;
        if (tempFileURL) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempFileURL.path] == NO) {
                OOSDDLogError(@"tempfile is not exist, unable to resume");
            }
            NSError *error = nil;
            NSString *tempFilePath = tempFileURL.path;
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[tempFilePath stringByResolvingSymlinksInPath]
                                                                                        error:&error];
            if (error) {
                OOSDDLogError(@"Unable to resume download task: Failed to retrival tempFileURL. [%@]",error);
            }
            unsigned long long fileSize = [attributes fileSize];
            downloadRequest.range = [NSString stringWithFormat:@"bytes=%llu-",fileSize];

        }
    }

    //change state to running
    [downloadRequest setValue:[NSNumber numberWithInteger:OOSTransferManagerRequestStateRunning] forKey:@"state"];

    //set shouldWriteDirectly to YES
    [downloadRequest setValue:@YES forKey:@"shouldWriteDirectly"];

    __weak OOSTransferManager *weakSelf = self;

    OOSTask *task = [OOSTask taskWithResult:nil];
    task = [[task continueWithSuccessBlock:^id(OOSTask *task) {
        [weakSelf.cache setObject:downloadRequest forKey:cacheKey];
        return nil;
    }] continueWithSuccessBlock:^id(OOSTask *task) {
        return [weakSelf getObject:downloadRequest cacheKey:cacheKey];
    }];

    return task;
}

- (OOSTask *)getObject:(OOSTransferManagerDownloadRequest *)downloadRequest
             cacheKey:(NSString *)cacheKey {
    OOSGetObjectRequest *getObjectRequest = [OOSGetObjectRequest new];
    [getObjectRequest OOS_copyPropertiesFromObject:downloadRequest];

    //set the downloadURL to use this tempURL instead.
    getObjectRequest.downloadingFileURL = downloadRequest.temporaryFileURL;
    
    __weak OOSTransferManager *weakSelf = self;

    OOSTask *downloadTask = [[[weakSelf.client getObject:getObjectRequest] continueWithBlock:^id(OOSTask *task) {

        //delete cached Object if state is not Paused
        if (downloadRequest.state != OOSTransferManagerRequestStatePaused) {
            [weakSelf.cache removeObjectForKey:cacheKey];
        }
        
        NSURL *tempFileURL = downloadRequest.temporaryFileURL;
        NSURL *originalFileURL = downloadRequest.originalFileURL;
        
        if (task.error) {
            //download got error, check if tempFile has been created.
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempFileURL.path]) {
                OOSDDLogError(@"tempFile has not been created yet.");
            }
            
            return [OOSTask taskWithError:task.error];
        }
        
        //If task complete without error, move the completed file to originalFileURL
        BOOL isTempFileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempFileURL.path];
        if (isTempFileExists && originalFileURL) {
            NSError *error = nil;
            //delete the orginalFileURL if it already exists
            if ([[NSFileManager defaultManager] fileExistsAtPath:originalFileURL.path]) {
                [[NSFileManager defaultManager] removeItemAtPath:originalFileURL.path error:nil];
            }
            [[NSFileManager defaultManager] moveItemAtURL:tempFileURL
                                                    toURL:originalFileURL
                                                    error:&error];
            if (error) {
                //got error when try to move completed file.
                return [OOSTask taskWithError:error];
            }
        }
        
        OOSTransferManagerDownloadOutput *downloadOutput = [OOSTransferManagerDownloadOutput new];
        if (task.result) {
            OOSGetObjectOutput *getObjectOutput = task.result;
            
            [downloadOutput OOS_copyPropertiesFromObject:getObjectOutput];
            
            //set the body to originalFileURL only if tempFileExists(file has been downloaded successfully)
            if (isTempFileExists) {
                downloadOutput.body = downloadRequest.originalFileURL;
            }

        }
        
        downloadRequest.state = OOSTransferManagerRequestStateCompleted;
        [downloadRequest setValue:nil forKey:@"internalRequest"];
        return downloadOutput;

    }] continueWithBlock:^id(OOSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:NSURLErrorDomain]
                && task.error.code == NSURLErrorCancelled) {
                if (downloadRequest.state == OOSTransferManagerRequestStatePaused) {
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain
                                                                     code:OOSTransferManagerErrorPaused
                                                                 userInfo:task.error.userInfo]];
                } else {
                    return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain
                                                                     code:OOSTransferManagerErrorCancelled
                                                                 userInfo:task.error.userInfo]];
                }

            } else {
                return [OOSTask taskWithError:task.error];
            }
        } else {
            return [OOSTask taskWithResult:task.result];
        }
    }];

    return downloadTask;
}

- (OOSTask *)cancelAll {
    NSMutableArray *keys = [NSMutableArray new];
    [self.cache.diskCache enumerateObjectsWithBlock:^(OOSTMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [keys addObject:key];
    }];

    NSMutableArray *tasks = [NSMutableArray new];
    for (NSString *key in keys) {
        OOSRequest *cachedObject = [self.cache objectForKey:key];
        if ([cachedObject isKindOfClass:[OOSTransferManagerUploadRequest class]]
            || [cachedObject isKindOfClass:[OOSTransferManagerDownloadRequest class]]) {
            [tasks addObject:[cachedObject cancel]];
        }
    }

    return [OOSTask taskForCompletionOfAllTasks:tasks];
}

- (OOSTask *)pauseAll {
    NSMutableArray *keys = [NSMutableArray new];
    [self.cache.diskCache enumerateObjectsWithBlock:^(OOSTMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [keys addObject:key];
    }];

    NSMutableArray *tasks = [NSMutableArray new];
    for (NSString *key in keys) {
        OOSRequest *cachedObject = [self.cache objectForKey:key];
        if ([cachedObject isKindOfClass:[OOSTransferManagerUploadRequest class]]
            || [cachedObject isKindOfClass:[OOSTransferManagerDownloadRequest class]]) {
            [tasks addObject:[cachedObject pause]];
        }
    }

    return [OOSTask taskForCompletionOfAllTasks:tasks];
}

- (OOSTask *)resumeAll:(OOSTransferManagerResumeAllBlock)block {
    NSMutableArray *keys = [NSMutableArray new];
    [self.cache.diskCache enumerateObjectsWithBlock:^(OOSTMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [keys addObject:key];
    }];

    NSMutableArray *tasks = [NSMutableArray new];
    NSMutableArray *results = [NSMutableArray new];

    __weak OOSTransferManager *weakSelf = self;

    for (NSString *key in keys) {
        id cachedObject = [self.cache objectForKey:key];
        if (block) {
            if ([cachedObject isKindOfClass:[OOSRequest class]]) {
                block(cachedObject);
            }
        }

        if ([cachedObject isKindOfClass:[OOSTransferManagerUploadRequest class]]) {
            [tasks addObject:[[weakSelf upload:cachedObject cacheKey:key] continueWithSuccessBlock:^id(OOSTask *task) {
                [results addObject:task.result];
                return nil;
            }]];
        }
        if ([cachedObject isKindOfClass:[OOSTransferManagerDownloadRequest class]]) {
            [tasks addObject:[[weakSelf download:cachedObject cacheKey:key] continueWithSuccessBlock:^id(OOSTask *task){
                [results addObject:task.result];
                return nil;
            }]];
        }

        //remove Resumed Object
        [weakSelf.cache removeObjectForKey:key];
    }

    return [[OOSTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(OOSTask *task) {
        if (task.error) {
            return [OOSTask taskWithError:task.error];
        }

        return [OOSTask taskWithResult:results];
    }];
}

- (OOSTask *)clearCache {
    OOSTaskCompletionSource *taskCompletionSource = [OOSTaskCompletionSource new];
    [self.cache removeAllObjects:^(OOSTMCache *cache) {
        taskCompletionSource.result = nil;
    }];

    return taskCompletionSource.task;
}

- (void)abortMultipartUploadsForRequest:(OOSTransferManagerUploadRequest *)uploadRequest{
    OOSAbortMultipartUploadRequest *abortMultipartUploadRequest = [OOSAbortMultipartUploadRequest new];
    abortMultipartUploadRequest.bucket = uploadRequest.bucket;
    abortMultipartUploadRequest.key = uploadRequest.key;
    abortMultipartUploadRequest.uploadId = uploadRequest.uploadId;

    __weak OOSTransferManager *weakSelf = self;

    [[weakSelf.client abortMultipartUpload:abortMultipartUploadRequest] continueWithBlock:^id(OOSTask *task) {
        if (task.error) {
            OOSDDLogError(@"Received response for abortMultipartUpload with Error:%@",task.error);
        } else {
            OOSDDLogError(@"Received response for abortMultipartUpload.");
        }
        return nil;
    }];
}

@end

@implementation OOSTransferManagerUploadRequest
@dynamic body;

- (instancetype)init {
    if (self = [super init]) {
        _state = OOSTransferManagerRequestStateNotStarted;
    }

    return self;
}

- (OOSTask *)cancel {
    if (self.state != OOSTransferManagerRequestStateCompleted) {
        self.state = OOSTransferManagerRequestStateCanceling;

        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self.body path] stringByResolvingSymlinksInPath]
                                                                                    error:nil];
        unsigned long long fileSize = [attributes fileSize];
        if (fileSize > OOSTransferManagerMinimumPartSize) {
            //If using multipart upload, need to cancel current parts upload and send AbortMultiPartUpload Request.
            [self.currentUploadingPart cancel];

        } else {
            //Otherwise, just call super to cancel current task.
            return [super cancel];
        }
    }
    return [OOSTask taskWithResult:nil];
}

- (OOSTask *)pause {
    switch (self.state) {
        case OOSTransferManagerRequestStateCompleted: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a completed task.", nil)]};
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCompleted userInfo:userInfo]];
        }
            break;
        case OOSTransferManagerRequestStateCanceling: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a cancelled task.", nil)]};
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCancelled userInfo:userInfo]];
        }
            break;
        default: {
            //change state to Paused
            self.state = OOSTransferManagerRequestStatePaused;
            //pause the current uploadTask
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self.body path] stringByResolvingSymlinksInPath]
                                                                                        error:nil];
            unsigned long long fileSize = [attributes fileSize];
            if (fileSize > OOSTransferManagerMinimumPartSize) {
                //If using multipart upload, need to check state flag and then pause the current parts upload and save the current status.
                [self.currentUploadingPart pause];
            } else {
                //otherwise, pause the current task. (cancel without set isCancelled flag)
                [super pause];
            }

            return [OOSTask taskWithResult:nil];
        }
            break;
    }
}

@end

@implementation OOSTransferManagerUploadOutput

@end

@implementation OOSTransferManagerDownloadRequest

- (instancetype)init {
    if (self = [super init]) {
        _state = OOSTransferManagerRequestStateNotStarted;
    }

    return self;
}

- (OOSTask *)cancel {
    if (self.state != OOSTransferManagerRequestStateCompleted) {
        self.state = OOSTransferManagerRequestStateCanceling;
        return [super cancel];
    }
    return [OOSTask taskWithResult:nil];
}

- (OOSTask *)pause {
    switch (self.state) {
        case OOSTransferManagerRequestStateCompleted: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a completed task.", nil)]};
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCompleted userInfo:userInfo]];
        }
            break;
        case OOSTransferManagerRequestStateCanceling: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can not pause a cancelled task.", nil)]};
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSTransferManagerErrorDomain code:OOSTransferManagerErrorCancelled userInfo:userInfo]];
        }
            break;
        default: {
            //change state to Paused
            self.state = OOSTransferManagerRequestStatePaused;
            //pause the current download task (i.e. cancel without set the isCancelled flag)
            [super pause];
            return [OOSTask taskWithResult:nil];
        }
            break;
    }
}

@end

@implementation OOSTransferManagerDownloadOutput

@end
