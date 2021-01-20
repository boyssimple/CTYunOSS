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

#import "OOSTransferUtility.h"
#import "OOSPreSignedURL.h"
#import "OOSService.h"
#import "OOSSynchronizedMutableDictionary.h"
#import "OOSXMLDictionary.h"
#import "OOSTransferUtilityTasks.h"
#import "OOSBolts.h"

// Public constants
NSString *const OOSTransferUtilityErrorDomain = @"cn.ctyun.OOSTransferUtilityErrorDomain";
NSString *const OOSTransferUtilityURLSessionDidBecomeInvalidNotification = @"cn.ctyun.OOSTransferUtility.OOSTransferUtilityURLSessionDidBecomeInvalidNotification";


// Private constants
static NSString *const OOSTransferUtilityIdentifier = @"cn.ctyun.OOSTransferUtility.Identifier";
static NSTimeInterval const OOSTransferUtilityTimeoutIntervalForResource = 50 * 60; // 50 minutes
static NSString *const OOSTransferUtilityUserAgent = @"transfer-utility";
static NSString *const OOSInfoTransferUtility = @"S3TransferUtility";
static NSString *const OOSTransferUtilityRetryExceeded = @"OOSTransferUtilityRetryExceeded";
static NSString *const OOSTransferUtilityRetrySucceeded = @"OOSTransferUtilityRetrySucceeded";
static NSUInteger const OOSTransferUtilityMultiPartSize = 5 * 1024 * 1024;
static NSString *const OOSTransferUtiltityRequestTimeoutErrorCode = @"RequestTimeout";
static int const OOSTransferUtilityMultiPartDefaultConcurrencyLimit = 5;


#pragma mark - Private classes

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

@interface OOSTransferUtility() <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) OOSServiceConfiguration *configuration;
@property (strong, nonatomic) OOSTransferUtilityConfiguration *transferUtilityConfiguration;
@property (strong, nonatomic) OOSPreSignedURLBuilder *preSignedURLBuilder;
@property (strong, nonatomic) OOS *s3;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *sessionIdentifier;
@property (strong, nonatomic) NSString *cacheDirectoryPath;
@property (strong, nonatomic) OOSSynchronizedMutableDictionary *taskDictionary;
@property (strong, nonatomic) OOSSynchronizedMutableDictionary *completedTaskDictionary;
@property (copy, nonatomic) void (^backgroundURLSessionCompletionHandler)(void);
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

@interface OOSTransferUtilityDownloadTask()

@property (strong, nonatomic) OOSTransferUtilityDownloadExpression *expression;
@property BOOL cancelled;
@property NSString *responseData;
@end

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

@interface OOSPreSignedURLBuilder()

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration;

@end


@interface OOS()

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration;

@end

@interface OOSGetPreSignedURLRequest()
@property NSString *uploadID;
@property NSNumber *partNumber;
@end

@interface OOSTransferUtility (Validation)
- (OOSTask *) validateParameters: (NSString * )bucket fileURL:(NSURL *)fileURL accelerationModeEnabled: (BOOL) accelerationModeEnabled;
@end

@interface OOSTransferUtility (HeaderHelper)
-(void) propagateHeaderInformation: (OOSCreateMultipartUploadRequest *) uploadRequest
                        expression: (OOSTransferUtilityMultiPartUploadExpression *) expression;

-(void) filterAndAssignHeaders:(NSDictionary<NSString *, NSString *> *) requestHeaders
        getPresignedURLRequest:(OOSGetPreSignedURLRequest *) getPresignedURLRequest
                    URLRequest: (NSMutableURLRequest *) URLRequest;
@end



#pragma mark - OOSTransferUtility

@implementation OOSTransferUtility

static OOSSynchronizedMutableDictionary *_serviceClients = nil;
static OOSTransferUtility *_defaultS3TransferUtility = nil;

#pragma mark - Initialization methods

+ (instancetype)defaultS3TransferUtility {
    return [self defaultS3TransferUtility:nil];
}

+ (instancetype)defaultS3TransferUtility:(void (^)(NSError *_Nullable error)) completionHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OOSServiceConfiguration *serviceConfiguration = [[OOSServiceManager defaultServiceManager] defaultServiceConfiguration];
        OOSTransferUtilityConfiguration *transferUtilityConfiguration = [OOSTransferUtilityConfiguration new];
        OOSServiceInfo *serviceInfo = [[OOSInfo defaultOOSInfo] defaultServiceInfo:OOSInfoTransferUtility];
       
        if (serviceInfo) {
            NSNumber *accelerateModeEnabled = [serviceInfo.infoDictionary valueForKey:@"AccelerateModeEnabled"];
            NSString *bucketName = [serviceInfo.infoDictionary valueForKey:@"Bucket"];
            transferUtilityConfiguration.bucket = bucketName;
            transferUtilityConfiguration.accelerateModeEnabled = [accelerateModeEnabled boolValue];
        }
        
        if (!serviceConfiguration) {
            serviceConfiguration = [OOSServiceManager defaultServiceManager].defaultServiceConfiguration;
        }
        
        if (!serviceConfiguration) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The service configuration is `nil`. You need to configure `Info.plist` or set `defaultServiceConfiguration` before using this method."
                                         userInfo:nil];
        }
        
        _defaultS3TransferUtility = [[OOSTransferUtility alloc] initWithConfiguration:serviceConfiguration
                                                           transferUtilityConfiguration:transferUtilityConfiguration
                                                                             identifier:nil
                                                                      completionHandler:completionHandler];
    });
    
    return _defaultS3TransferUtility;
}

+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key {
    [self registerS3TransferUtilityWithConfiguration:configuration
                        transferUtilityConfiguration:[OOSTransferUtilityConfiguration new]
                                              forKey:key];
}

+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                                            forKey:(NSString *)key
                                 completionHandler:(nullable void (^)(NSError *_Nullable error)) completionHandler{
    [self registerS3TransferUtilityWithConfiguration:configuration
                        transferUtilityConfiguration:[OOSTransferUtilityConfiguration new]
                                              forKey:key
                                   completionHandler:completionHandler];
}

+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                      transferUtilityConfiguration:(OOSTransferUtilityConfiguration *)transferUtilityConfiguration
                                            forKey:(NSString *)key {
    [self registerS3TransferUtilityWithConfiguration:configuration transferUtilityConfiguration:transferUtilityConfiguration forKey:key completionHandler:nil];
}

+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                      transferUtilityConfiguration:(OOSTransferUtilityConfiguration *)transferUtilityConfiguration
                                            forKey:(NSString *)key
                                 completionHandler:(nullable void (^)(NSError *_Nullable error)) completionHandler{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [OOSSynchronizedMutableDictionary new];
    });
    
    OOSTransferUtility *s3TransferUtility = [[OOSTransferUtility alloc] initWithConfiguration:configuration
                                                                     transferUtilityConfiguration:transferUtilityConfiguration
                                                                                       identifier:[NSString stringWithFormat:@"%@.%@", OOSTransferUtilityIdentifier, key]
                                                                                completionHandler: completionHandler];
    [_serviceClients setObject:s3TransferUtility
                        forKey:key];
}

+ (instancetype)S3TransferUtilityForKey:(NSString *)key {
    @synchronized(self) {
        OOSTransferUtility *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }
        
        OOSServiceInfo *serviceInfo = [[OOSInfo defaultOOSInfo] serviceInfo:OOSInfoTransferUtility
                                                                     forKey:key];
        if (serviceInfo) {
            OOSServiceConfiguration *serviceConfiguration = [[OOSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                                    credentialsProvider:nil];
            
            NSNumber *accelerateModeEnabled = [serviceInfo.infoDictionary valueForKey:@"AccelerateModeEnabled"];
            OOSTransferUtilityConfiguration *transferUtilityConfiguration = [OOSTransferUtilityConfiguration new];
            transferUtilityConfiguration.accelerateModeEnabled = [accelerateModeEnabled boolValue];
            
            [OOSTransferUtility registerS3TransferUtilityWithConfiguration:serviceConfiguration
                                                transferUtilityConfiguration:transferUtilityConfiguration
                                                                      forKey:key];
        }
        
        return [_serviceClients objectForKey:key];
    }
}

+ (void)removeS3TransferUtilityForKey:(NSString *)key {
    OOSTransferUtility *transferUtility = [self S3TransferUtilityForKey:key];
    if (transferUtility) {
        [transferUtility.session invalidateAndCancel];
    }
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultS3TransferUtility` or `+ S3TransferUtilityForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)serviceConfiguration
         transferUtilityConfiguration:(OOSTransferUtilityConfiguration *)transferUtilityConfiguration
                           identifier:(NSString *)identifier
                    completionHandler: (void (^)(NSError *_Nullable error)) completionHandler{
    if (self = [super init]) {
        _configuration = [serviceConfiguration copy];
        [_configuration addUserAgentProductToken:OOSTransferUtilityUserAgent];
       
        if (transferUtilityConfiguration  ) {
            _transferUtilityConfiguration = [transferUtilityConfiguration copy];
        }
        else {
            _transferUtilityConfiguration = [OOSTransferUtilityConfiguration new];
        }
        
        _preSignedURLBuilder = [[OOSPreSignedURLBuilder alloc] initWithConfiguration:_configuration];
        _s3 = [[OOS alloc] initWithConfiguration:_configuration];
        
        if (identifier) {
            _sessionIdentifier = identifier;
        }
        else {
             NSString *uuid = [[NSUUID UUID] UUIDString];
            _sessionIdentifier = [OOSTransferUtilityIdentifier stringByAppendingString:uuid];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_sessionIdentifier];
        configuration.allowsCellularAccess = serviceConfiguration.allowsCellularAccess;
        configuration.timeoutIntervalForResource = _transferUtilityConfiguration.timeoutIntervalForResource;
        
        if(serviceConfiguration.timeoutIntervalForRequest > 0){
            configuration.timeoutIntervalForRequest = serviceConfiguration.timeoutIntervalForRequest;
        }
        configuration.sharedContainerIdentifier = serviceConfiguration.sharedContainerIdentifier;
        
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:self
                                            delegateQueue:nil];
        
        _taskDictionary = [OOSSynchronizedMutableDictionary new];
        _completedTaskDictionary = [OOSSynchronizedMutableDictionary new];
        
        // Creates a temporary directory for data uploads in the caches directory
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        
        _cacheDirectoryPath = [cachePath stringByAppendingPathComponent:OOSInfoTransferUtility];
		
        NSURL *directoryURL = [NSURL fileURLWithPath:_cacheDirectoryPath];
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&error];
        if (!result) {
            OOSDDLogError(@"Failed to create a temporary directory: %@", error);
        }
		
        //Recover the state from the previous time this was instantiated
        [self recover:completionHandler];
    }
    return self;
}

#pragma mark - recovery methods

- (void) recover: (void (^)(NSError *_Nullable error)) completionHandler {
   
    OOSDDLogInfo(@"In Recovery for TU Session [%@]", _sessionIdentifier);
    //Create temporary datastructures to hold the database records.
    
    //This dictionary will contain the master level info for a multipart transfer
    NSMutableDictionary *tempMultiPartMasterTaskDictionary = [NSMutableDictionary new];
    //This dictionary will contain details of indvidual transfers ( upload, downloads and subtasks)
    NSMutableDictionary *tempTransferDictionary = [NSMutableDictionary new];
    
    //Link Transfers to NSURL Session.
    [self linkTransfersToNSURLSession:tempMultiPartMasterTaskDictionary tempTransferDictionary:tempTransferDictionary completionHandler:completionHandler];
}

- (void) linkTransfersToNSURLSession:(NSMutableDictionary *) tempMultiPartMasterTaskDictionary
              tempTransferDictionary: (NSMutableDictionary *) tempTransferDictionary
                   completionHandler: (void (^)(NSError *_Nullable error)) completionHandler{
    //Get tasks from the NSURLSession and reattach to them.
    //getTasksWithCompletionHandler is an ansynchronous task, so the thread that is calling this method will not be blocked.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
 
        //Loop through all the upload Tasks.
        for( NSURLSessionUploadTask *task in uploadTasks ) {
            OOSDDLogInfo(@"Iterating through task Identifier [%lu]", (unsigned long)task.taskIdentifier);
            //Get the Task
            id obj = [tempTransferDictionary objectForKey:@(task.taskIdentifier)];
            
            if ([obj isKindOfClass:[OOSTransferUtilityUploadTask class]])
            {
                //Found a upload task.
                OOSTransferUtilityUploadTask *uploadTask = obj;
                uploadTask.sessionTask = task;
                [self.taskDictionary setObject:uploadTask forKey:@(uploadTask.taskIdentifier)];
                OOSDDLogInfo(@"Added Upload Transfer task %@ to task dictionary", @(uploadTask.taskIdentifier));
                OOSDDLogInfo(@"Status is %ld", (long)uploadTask.status);
                
                //Remove this object from the tempTransferDictionary list
                [tempTransferDictionary removeObjectForKey:@(task.taskIdentifier)];
                
                //Check if it is InProgress
                if (uploadTask.status == OOSTransferUtilityTransferStatusInProgress) {
                    //Check if the the underlying NSURLSession task is completed. If so, delete the record from the DB, clean up any temp files  and call the completion handler.
                    if ([task state] == NSURLSessionTaskStateCompleted) {
                        //Set progress to 100%
                        uploadTask.progress.completedUnitCount = uploadTask.progress.totalUnitCount;
                        uploadTask.status = OOSTransferUtilityTransferStatusCompleted;
                        [self.completedTaskDictionary setObject:uploadTask forKey:uploadTask.transferID];
                        [self.taskDictionary removeObjectForKey:@(uploadTask.taskIdentifier)];
                        if (uploadTask.temporaryFileCreated) {
                            [self removeFile:uploadTask.file];
                        }
                        continue;
                    }
                    //If it is in any other status than running, then we need to recover by retrying.
                    if ([task state] != NSURLSessionTaskStateRunning) {
                        //We think the task in IN_PROGRESS. The underlying task is not running.
                        //Recover the situation by retrying.
                        [self retryUpload:uploadTask];
                        continue;
                    }
                }
            }
            else if ([obj isKindOfClass:[OOSTransferUtilityUploadSubTask class]]) {
                //Found a upload subtask.
                OOSDDLogInfo(@"Looking at NSURLSession Upload SubTask [%lu]", (unsigned long)task.taskIdentifier);
                OOSTransferUtilityUploadSubTask *subTaskObj = obj;
                subTaskObj.sessionTask = task;
                OOSTransferUtilityMultiPartUploadTask *multiPartUploadTask = [tempMultiPartMasterTaskDictionary objectForKey:subTaskObj.uploadID];
                
                [self.taskDictionary setObject:multiPartUploadTask forKey:@(task.taskIdentifier)];
                OOSDDLogInfo(@"Added MP task[%@] for session ID: %@",multiPartUploadTask.uploadID, @(task.taskIdentifier));
                
                //Remove this object from the tempTransferDictionary
                [tempTransferDictionary removeObjectForKey:@(task.taskIdentifier)];
                
                //Add it to the InProgress list
                [multiPartUploadTask.inProgressPartsDictionary setObject:subTaskObj forKey:@(task.taskIdentifier)];
                
                //Check if it is in Paused status. If it is, there is nothing more to do.
                if (subTaskObj.status == OOSTransferUtilityTransferStatusPaused) {
                    continue;
                }
                
                //The only state that it can be now is in IN_PROGRESS. Check if the underlying NSURLSessionTask is Not running.
                if ([task state] != NSURLSessionTaskStateRunning) {
                    OOSDDLogInfo(@"SubTask %lu is in %ld status according to DB, but the underlying task is not running. Retrying", (unsigned long)subTaskObj.taskIdentifier,
                                  (long)subTaskObj.status);
                    //We think the task in IN_PROGRESS. The underlying task is not running.
                    //Recover the situation by retrying.
                    [self retryUploadSubTask:multiPartUploadTask subTask:subTaskObj startTransfer:YES];
                }
            }
            else {
                OOSDDLogInfo(@"NSURLSession task[%lu] is not found in the taskDictionary. Ignoring.",(unsigned long)task.taskIdentifier);
            }
        }
        
        //Loop through all the Download tasks
        for( NSURLSessionDownloadTask *task in downloadTasks ) {
            id obj = [tempTransferDictionary objectForKey:@(task.taskIdentifier)];
            OOSDDLogInfo(@"Looking at NSURLSession Download Task [%lu]", (unsigned long)task.taskIdentifier);
            if ([obj isKindOfClass:[OOSTransferUtilityDownloadTask class]])
            {
                //Found a download task
                OOSTransferUtilityDownloadTask *downloadTask = obj;
                downloadTask.sessionTask = task;
                [self.taskDictionary setObject:downloadTask forKey:@(downloadTask.taskIdentifier)];
                OOSDDLogInfo(@"Added Download Transfer task %@ to task dictionary", @(downloadTask.taskIdentifier));
                OOSDDLogInfo(@"Status is %ld", (long)downloadTask.status);
                
                //Remove this request from the transferRequests list.
                [tempTransferDictionary removeObjectForKey:@(task.taskIdentifier)];
                
                //Check if this is in progress
                if (downloadTask.status == OOSTransferUtilityTransferStatusInProgress) {
                    if ([task state] == NSURLSessionTaskStateCompleted) {
                        //Set progress to 100%
                        downloadTask.progress.completedUnitCount = downloadTask.progress.totalUnitCount;
                        downloadTask.status = OOSTransferUtilityTransferStatusCompleted;
                        [self.completedTaskDictionary setObject:downloadTask forKey:downloadTask.transferID];
                        [self.taskDictionary removeObjectForKey:@(downloadTask.taskIdentifier)];
                        continue;
                    }
                    //Check if the underlying task's status is not in Progress.
                    else if ([task state] != NSURLSessionTaskStateRunning) {
                        //We think the task in Progress. The underlying task is not in progress.
                        //Recover the situation by retrying
                        [self retryDownload:downloadTask];
                        continue;
                    }
                }
            }
            else {
                OOSDDLogInfo(@"Object not found in taskDictionary for %lu",(unsigned long)task.taskIdentifier);
            }
        }
        
        //We have run through all the Session Tasks and removed the matching records from the multiPartUploads and transferRequests dictionaries.
        //Handle any stragglers.
        [self handleUnlinkedTransfers:tempMultiPartMasterTaskDictionary tempTransferDictionary:tempTransferDictionary];
        
        //Call completion handler if one was provided.
        if (completionHandler) {
            completionHandler(nil);
        }
    }];
}


- (void) handleUnlinkedTransfers:(NSMutableDictionary *) tempMultiPartMasterTaskDictionary
                   tempTransferDictionary: (NSMutableDictionary *) tempTransferDictionary {
    //At this point, we have finished iterating through the tasks present in the NSURLSession and removed all the matching ones from the transferRequests dictionary.
    //If there are any left in the transferRequests list, it means that we think they are running, but NSURLSession doesn't know about them.
    for (id taskIdentifier in [tempTransferDictionary allKeys]) {
        OOSDDLogInfo(@"No sessionTask found for taskIdentifier %@",taskIdentifier);
        id obj = [tempTransferDictionary objectForKey:taskIdentifier];
        if ([obj isKindOfClass:[OOSTransferUtilityUploadTask class]])
        {
            OOSTransferUtilityUploadTask *transferUtilityUploadTask = obj;
            
            if (transferUtilityUploadTask.status == OOSTransferUtilityTransferStatusCompleted ) {
                [self.completedTaskDictionary setObject:transferUtilityUploadTask forKey:transferUtilityUploadTask.transferID];
            }
            //Check if the transfer is in a paused state and the input file for the transfer exists.
            else if ( [[NSFileManager defaultManager] fileExistsAtPath:transferUtilityUploadTask.file] &&
                     transferUtilityUploadTask.status ==  OOSTransferUtilityTransferStatusPaused) {
                //If the transfer was paused and the local file is still present, create another NSURLSession task and leave it in a paused state
                [ self createUploadTask:transferUtilityUploadTask startTransfer:NO];
            }
            else {
                //Transfer is in progress according to us, but not present in the NSURLSession. It may have been sucessfully completed. Do not retry.
                //Mark the status as unknown. The app developer should check to see if the S3 file was uploaded in the app logic and reinitate the transfer if required.
                transferUtilityUploadTask.status = OOSTransferUtilityTransferStatusUnknown;
                [self.completedTaskDictionary setObject:transferUtilityUploadTask forKey:transferUtilityUploadTask.transferID];
            }
        }
        else if([obj isKindOfClass:[OOSTransferUtilityUploadSubTask class]])
        {
            OOSTransferUtilityUploadSubTask *subTask = obj;
            if ( subTask.status == OOSTransferUtilityTransferStatusInProgress ) {
                //We think the subtask is in progress, but NSURLSession does not know about it. So lets retry.
                //An optimization here is to check if the part has been already uploaded by querying S3 and only retry if not already uploaded.
                OOSTransferUtilityMultiPartUploadTask *multiPartUploadTask = [tempMultiPartMasterTaskDictionary objectForKey:subTask.uploadID];
                [self retryUploadSubTask: multiPartUploadTask subTask:subTask startTransfer:YES];
            }
            else if (subTask.status == OOSTransferUtilityTransferStatusPaused){
                //We think the subtask is in progress, but NSURLSession does not know about it. So lets create a session task in a paused stated.
                OOSTransferUtilityMultiPartUploadTask *multiPartUploadTask = [tempMultiPartMasterTaskDictionary objectForKey:subTask.uploadID];
                [self retryUploadSubTask: multiPartUploadTask subTask:subTask startTransfer:NO];
            }
        }
        else if ([obj isKindOfClass:[OOSTransferUtilityDownloadTask class]]) {
            
            OOSTransferUtilityDownloadTask *downloadTask = obj;
            
            if (downloadTask.status == OOSTransferUtilityTransferStatusCompleted ) {
                [self.completedTaskDictionary setObject:downloadTask forKey:downloadTask.transferID];
            }
            else if (downloadTask.status == OOSTransferUtilityTransferStatusPaused) {
                //If the transfer was paused, create another NSURLSession task and leave it in an paused state
                [ self createDownloadTask:downloadTask startTransfer:NO];
            }
            else {
                //Transfer is in progress according to us, but not present in the NSURLSession. It may have been sucessfully completed. Do not retry.
                //Mark the status as unknown. The app developer should check to see if the S3 file was uploaded in the app logic and reinitate the transfer if required.
                
                downloadTask.status = OOSTransferUtilityTransferStatusUnknown;
                [self.completedTaskDictionary setObject:downloadTask forKey:downloadTask.transferID];
            }
        }
    }
    
    //Multipart transfer uses a relay style architecture. At any point in time, n parts are in progress and each part triggers the next part to start when it is finished.
    //During the recovery procees, it is possible for the multipart transfer to not have an adequate number of parts in progress.
    //This loop below will check and ensure that the correct number of concurrent transfers are in progress.
    for (id obj in [tempMultiPartMasterTaskDictionary allKeys]) {
        NSString *uploadID = obj;
        OOSTransferUtilityMultiPartUploadTask *multiPartUploadTask = [tempMultiPartMasterTaskDictionary objectForKey:uploadID];
        
        if (multiPartUploadTask.status == OOSTransferUtilityTransferStatusPaused) {
            continue;
        }
        
        long numberOfPartsInProgress = [multiPartUploadTask.inProgressPartsDictionary count];
        while (numberOfPartsInProgress < [self.transferUtilityConfiguration.multiPartConcurrencyLimit integerValue]) {
            if ([multiPartUploadTask.waitingPartsDictionary count] > 0) {
                //Get a part from the waitingList
                OOSTransferUtilityUploadSubTask *nextSubTask = [[multiPartUploadTask.waitingPartsDictionary allValues] objectAtIndex:0];
                
                //Remove it from the waitingList
                [multiPartUploadTask.waitingPartsDictionary removeObjectForKey:nextSubTask.partNumber];
                
                //Create the subtask and start the transfer
                NSError *error = [self createUploadSubTask:multiPartUploadTask subTask:nextSubTask];
                if (error) {
                    //Abort the request, so the server can clean up any partials.
                    [self callAbortMultiPartForUploadTask:multiPartUploadTask];
                    if (multiPartUploadTask.expression.completionHandler) {
                        multiPartUploadTask.expression.completionHandler(multiPartUploadTask, error);
                    }
                    multiPartUploadTask.status = OOSTransferUtilityTransferStatusError;
                    //Clean up.
                    [self cleanupForMultiPartUploadTask:multiPartUploadTask];
                    break;
                };
                numberOfPartsInProgress++;
            }
            else {
                break;
            }
        }
    }
}

-(OOSTransferUtilityUploadTask *) hydrateUploadTask: (NSMutableDictionary *) task
                                    sessionIdentifier: (NSString *) sessionIdentifier
{
    OOSTransferUtilityUploadTask *transferUtilityUploadTask = [OOSTransferUtilityUploadTask new];
    transferUtilityUploadTask.nsURLSessionID = sessionIdentifier;
    transferUtilityUploadTask.transferType = [task objectForKey:@"transfer_type"];
    transferUtilityUploadTask.bucket = [task objectForKey:@"bucket_name"];
    transferUtilityUploadTask.key = [task objectForKey:@"key"];
    transferUtilityUploadTask.expression = [OOSTransferUtilityUploadExpression new];
    transferUtilityUploadTask.transferID = [task objectForKey:@"transfer_id"];
    transferUtilityUploadTask.file = [task objectForKey:@"file"];
    transferUtilityUploadTask.cancelled = NO;
    transferUtilityUploadTask.retryCount = [[task objectForKey:@"retry_count"] intValue];
    transferUtilityUploadTask.temporaryFileCreated = [[task objectForKey:@"temporary_file_created"] boolValue];
    NSNumber *statusValue = [task objectForKey:@"status"];
    transferUtilityUploadTask.status = [statusValue intValue];
    return transferUtilityUploadTask;
}


- (OOSTransferUtilityDownloadTask *) hydrateDownloadTask: (NSMutableDictionary *) task
                                         sessionIdentifier: (NSString *) sessionIdentifier
{
    OOSTransferUtilityDownloadTask *transferUtilityDownloadTask = [OOSTransferUtilityDownloadTask new];
    transferUtilityDownloadTask.nsURLSessionID = sessionIdentifier;
    transferUtilityDownloadTask.transferType = [task objectForKey:@"transfer_type"];
    transferUtilityDownloadTask.bucket = [task objectForKey:@"bucket_name"];
    transferUtilityDownloadTask.key = [task objectForKey:@"key"];
    transferUtilityDownloadTask.expression = [OOSTransferUtilityDownloadExpression new];
    transferUtilityDownloadTask.transferID = [task objectForKey:@"transfer_id"];
    transferUtilityDownloadTask.file = [task objectForKey:@"file"];
    transferUtilityDownloadTask.cancelled = NO;
    transferUtilityDownloadTask.retryCount = [[task objectForKey:@"retry_count"] intValue];
    NSNumber *statusValue = [task objectForKey:@"status"];
    transferUtilityDownloadTask.status = [statusValue intValue];
    return transferUtilityDownloadTask;
}


-( OOSTransferUtilityMultiPartUploadTask *) hydrateMultiPartUploadTask: (NSMutableDictionary *) task
                                                       sessionIdentifier: (NSString *) sessionIdentifier
{
    OOSTransferUtilityMultiPartUploadTask *transferUtilityMultiPartUploadTask = [OOSTransferUtilityMultiPartUploadTask new];
    transferUtilityMultiPartUploadTask.nsURLSessionID = sessionIdentifier;
    transferUtilityMultiPartUploadTask.transferType = [task objectForKey:@"transfer_type"];
    transferUtilityMultiPartUploadTask.bucket = [task objectForKey:@"bucket_name"];
    transferUtilityMultiPartUploadTask.key = [task objectForKey:@"key"];
    transferUtilityMultiPartUploadTask.expression = [OOSTransferUtilityMultiPartUploadExpression new];
    transferUtilityMultiPartUploadTask.transferID = [task objectForKey:@"transfer_id"];
    transferUtilityMultiPartUploadTask.file = [task objectForKey:@"file"];
    transferUtilityMultiPartUploadTask.temporaryFileCreated = [[task objectForKey:@"temporary_file_created"] boolValue];
    transferUtilityMultiPartUploadTask.contentLength = [task objectForKey:@"content_length"];
    transferUtilityMultiPartUploadTask.progress.totalUnitCount = [transferUtilityMultiPartUploadTask.contentLength longLongValue];
    transferUtilityMultiPartUploadTask.cancelled = NO;
    transferUtilityMultiPartUploadTask.retryCount = [[task objectForKey:@"retry_count"] intValue];
    transferUtilityMultiPartUploadTask.uploadID = [task objectForKey:@"multi_part_id"];
    NSNumber *statusValue = [task objectForKey:@"status"];
    transferUtilityMultiPartUploadTask.status = [statusValue intValue];
    return transferUtilityMultiPartUploadTask;
}

- (OOSTransferUtilityUploadSubTask * ) hydrateMultiPartUploadSubTask:(NSMutableDictionary *) task
                                                         sessionTaskID: (int) sessionTaskID
{
    OOSTransferUtilityUploadSubTask *subTask = [OOSTransferUtilityUploadSubTask new];
    subTask.taskIdentifier = sessionTaskID;
    subTask.transferType = [task objectForKey:@"transfer_type"];
    subTask.file = [task objectForKey:@"file"];
    subTask.partNumber = [task objectForKey:@"part_number"];
    subTask.eTag =[task objectForKey:@"etag"];
    subTask.uploadID = [task objectForKey:@"multi_part_id"];
    subTask.transferID = [task objectForKey:@"transfer_id"];
    subTask.totalBytesExpectedToSend = [[task objectForKey:@"content_length"] integerValue];
    
    NSNumber *statusValue = [task objectForKey:@"status"];
    subTask.status = [statusValue intValue];
    return subTask;
}


#pragma mark - Upload methods

- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadData:(NSData *)data
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler {
    return [self uploadData:data
                     bucket:self.transferUtilityConfiguration.bucket
                        key:key
                contentType:contentType
                 expression:expression
          completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadData:(NSData *)data
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler {
    
    // Saves the data as a file in the temporary directory.
    NSString *fileName = [NSString stringWithFormat:@"%@.tmp", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *filePath = [self.cacheDirectoryPath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    BOOL result = [data writeToURL:fileURL
                           options:NSDataWritingAtomic
                             error:&error];
    if (!result) {
        if (completionHandler) {
            OOSTransferUtilityUploadTask *uploadTask = [OOSTransferUtilityUploadTask new];
            uploadTask.bucket = bucket;
            uploadTask.key = key;
            completionHandler(uploadTask,error);
        }
        return [OOSTask taskWithError:error];
    }
    
    return [self internalUploadFile:fileURL
                     bucket:bucket
                        key:key
                contentType:contentType
                 expression:expression
       temporaryFileCreated:YES
          completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadFile:(NSURL *)fileURL
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler {
    return [self uploadFile:fileURL
                     bucket:self.transferUtilityConfiguration.bucket
                        key:key
                contentType:contentType
                 expression:expression
          completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadFile:(NSURL *)fileURL
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler {
    return [self internalUploadFile:fileURL
                             bucket:bucket
                             key:key
                     contentType:contentType
                      expression:expression
            temporaryFileCreated:NO
               completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityUploadTask *> *)internalUploadFile:(NSURL *)fileURL
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityUploadExpression *)expression
                                     temporaryFileCreated: (BOOL) temporaryFileCreated
                                        completionHandler:(OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler {
    //Validate input parameters.
    OOSTask *error = [self validateParameters:bucket fileURL:fileURL accelerationModeEnabled:self.transferUtilityConfiguration.isAccelerateModeEnabled];
    if (error) {
        if (temporaryFileCreated) {
            [self removeFile:[fileURL path]];
        }
        return error;
    }
    
    //Create Expression if required and set it up
    if (!expression) {
        expression = [OOSTransferUtilityUploadExpression new];
    }
    [expression setValue:contentType forRequestHeader:@"Content-Type"];
    expression.completionHandler = completionHandler;
    
    //Create TransferUtility Upload Task
    OOSTransferUtilityUploadTask *transferUtilityUploadTask = [OOSTransferUtilityUploadTask new];
    transferUtilityUploadTask.nsURLSessionID = self.sessionIdentifier;
    transferUtilityUploadTask.transferType = @"UPLOAD";
    transferUtilityUploadTask.bucket = bucket;
    transferUtilityUploadTask.key = key;
    transferUtilityUploadTask.retryCount = 0;
    transferUtilityUploadTask.expression = expression;
    transferUtilityUploadTask.transferID = [[NSUUID UUID] UUIDString];
    transferUtilityUploadTask.file = [fileURL path];
    transferUtilityUploadTask.cancelled = NO;
    transferUtilityUploadTask.temporaryFileCreated = temporaryFileCreated;
    transferUtilityUploadTask.responseData = @"";
    transferUtilityUploadTask.status = OOSTransferUtilityTransferStatusInProgress;
	
    return [self createUploadTask:transferUtilityUploadTask];
}

-(OOSTask<OOSTransferUtilityUploadTask *> *) createUploadTask: (OOSTransferUtilityUploadTask *) transferUtilityUploadTask {
    return [self createUploadTask:transferUtilityUploadTask startTransfer:YES];
}


-(OOSTask<OOSTransferUtilityUploadTask *> *) createUploadTask: (OOSTransferUtilityUploadTask *) transferUtilityUploadTask startTransfer:(BOOL) startTransfer {
    //Create PreSigned URL Request
    OOSGetPreSignedURLRequest *getPreSignedURLRequest = [OOSGetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = transferUtilityUploadTask.bucket;
    getPreSignedURLRequest.key = transferUtilityUploadTask.key;
    getPreSignedURLRequest.HTTPMethod = OOSHTTPMethodPUT;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:_transferUtilityConfiguration.timeoutIntervalForResource];
    getPreSignedURLRequest.minimumCredentialsExpirationInterval = _transferUtilityConfiguration.timeoutIntervalForResource;
    getPreSignedURLRequest.accelerateModeEnabled = self.transferUtilityConfiguration.isAccelerateModeEnabled;
    
    [transferUtilityUploadTask.expression assignRequestHeaders:getPreSignedURLRequest];
    [transferUtilityUploadTask.expression assignRequestParameters:getPreSignedURLRequest];
    
    return [[self.preSignedURLBuilder getPreSignedURL:getPreSignedURLRequest] continueWithBlock:^id(OOSTask *task) {
        NSURL *presignedURL = task.result;
        NSError *error = task.error;
        if ( error ) {
            OOSDDLogInfo(@"Error: %@", error);
            return [OOSTask taskWithError:error];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:presignedURL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        request.HTTPMethod = @"PUT";
        
        [request setValue:self.configuration.userAgent forHTTPHeaderField:@"User-Agent"];
        
        for (NSString *key in transferUtilityUploadTask.expression.requestHeaders) {
            [request setValue: transferUtilityUploadTask.expression.requestHeaders[key] forHTTPHeaderField:key];
        }
        OOSDDLogInfo(@"Request headers:\n%@", request.allHTTPHeaderFields);
        
        NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request
                                                                        fromFile:[NSURL fileURLWithPath:transferUtilityUploadTask.file]];
        transferUtilityUploadTask.sessionTask = uploadTask;
        if ( startTransfer) {
            transferUtilityUploadTask.status = OOSTransferUtilityTransferStatusInProgress;
        }
        else {
            transferUtilityUploadTask.status = OOSTransferUtilityTransferStatusPaused;
        }
        
        OOSDDLogInfo(@"Setting taskIdentifier to %@", @(transferUtilityUploadTask.sessionTask.taskIdentifier));
        
        //Add to task Dictionary
        [self.taskDictionary setObject:transferUtilityUploadTask forKey:@(transferUtilityUploadTask.sessionTask.taskIdentifier) ];
		
        if (startTransfer) {
            [uploadTask resume];
        }
        
        return [OOSTask taskWithResult:transferUtilityUploadTask];
    }];
}


- (void) retryUpload: (OOSTransferUtilityUploadTask *) transferUtilityUploadTask {
    //Remove from taskDictionary
    [self.taskDictionary removeObjectForKey:@(transferUtilityUploadTask.taskIdentifier)];
    
    OOSDDLogInfo(@"Removed object from key %@", @(transferUtilityUploadTask.taskIdentifier) );
    transferUtilityUploadTask.retryCount = transferUtilityUploadTask.retryCount + 1;
    
    //Check if the file to be uploaded still exists. Otherwise, fail the transfer and call the completion handler with the error.
    if (![[NSFileManager defaultManager] fileExistsAtPath:transferUtilityUploadTask.file]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Local file not found"
                                                             forKey:@"Message"];
        
        NSError *error = [NSError errorWithDomain:OOSTransferUtilityErrorDomain
                                                          code:OOSTransferUtilityErrorLocalFileNotFound
                                                      userInfo:userInfo];
        
        if (transferUtilityUploadTask.expression.completionHandler) {
            transferUtilityUploadTask.expression.completionHandler(transferUtilityUploadTask, error);
        }
    }
    else {
        //This will update the OOSTransferUtilityUploadTask passed into it with a new URL Session
        //task and add it into the task Dictionary.
        [self createUploadTask:transferUtilityUploadTask];
    }
}

#pragma mark - MultiPart Upload methods

- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadDataUsingMultiPart:(NSData *)data
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityMultiPartUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler {
    return [self uploadDataUsingMultiPart:data
                     bucket:self.transferUtilityConfiguration.bucket
                        key:key
                contentType:contentType
                 expression:expression
          completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadDataUsingMultiPart:(NSData *)data
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityMultiPartUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler {
    
    // Saves the data as a file in the temporary directory.
    NSString *fileName = [NSString stringWithFormat:@"%@.tmp", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *filePath = [self.cacheDirectoryPath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    BOOL result = [data writeToURL:fileURL
                           options:NSDataWritingAtomic
                             error:&error];
    if (!result) {
        if (completionHandler) {
            OOSTransferUtilityMultiPartUploadTask *uploadTask = [OOSTransferUtilityMultiPartUploadTask new];
            uploadTask.bucket = bucket;
            uploadTask.key = key;
            completionHandler(uploadTask, error);
        }
        return [OOSTask taskWithError:error];
    }
    
    return [self internalUploadFileUsingMultiPart:fileURL
                     bucket:bucket
                        key:key
                contentType:contentType
                 expression:expression
                 temporaryFileCreated:YES
          completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadFileUsingMultiPart:(NSURL *)fileURL
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityMultiPartUploadExpression *)expression
                                        completionHandler:(OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler {
    return [self uploadFileUsingMultiPart:fileURL
                     bucket:self.transferUtilityConfiguration.bucket
                        key:key
                contentType:contentType
                    expression:expression
          completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadFileUsingMultiPart:(NSURL *)fileURL
                                                                          bucket:(NSString *)bucket
                                                                             key:(NSString *)key
                                                                     contentType:(NSString *)contentType
                                                                      expression:(OOSTransferUtilityMultiPartUploadExpression *)expression
                                                               completionHandler:(OOSTransferUtilityMultiPartUploadCompletionHandlerBlock) completionHandler
{
    return [self internalUploadFileUsingMultiPart:fileURL
                                           bucket:bucket
                                              key:key
                                      contentType:contentType
                                       expression:expression
                             temporaryFileCreated:NO
                                completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)internalUploadFileUsingMultiPart:(NSURL *)fileURL
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(OOSTransferUtilityMultiPartUploadExpression *)expression
                                     temporaryFileCreated: (BOOL) temporaryFileCreated
                                        completionHandler:(OOSTransferUtilityMultiPartUploadCompletionHandlerBlock) completionHandler {
    
    //Validate input parameters.
    OOSTask *error = [self validateParameters:bucket fileURL:fileURL accelerationModeEnabled:self.transferUtilityConfiguration.isAccelerateModeEnabled];
    if (error) {
        if (temporaryFileCreated) {
            [self removeFile:[fileURL path]];
        }
        return error;
    }
    
    //Create Expression if required and set values on the object
    if (!expression) {
        expression = [OOSTransferUtilityMultiPartUploadExpression new];
    }
    
    //Override the content type value set in the expression object with the passed in parameter value. 
    if (contentType) {
      [expression setValue:contentType forRequestHeader:@"Content-Type"];
    }
    
    expression.completionHandler = completionHandler;
    
    //Create TransferUtility Multipart Upload Task
    OOSTransferUtilityMultiPartUploadTask *transferUtilityMultiPartUploadTask = [OOSTransferUtilityMultiPartUploadTask new];
    transferUtilityMultiPartUploadTask.nsURLSessionID = self.sessionIdentifier;
    transferUtilityMultiPartUploadTask.transferType = @"MULTI_PART_UPLOAD";
    transferUtilityMultiPartUploadTask.bucket = bucket;
    transferUtilityMultiPartUploadTask.key = key;
    transferUtilityMultiPartUploadTask.expression = expression;
    transferUtilityMultiPartUploadTask.transferID = [[NSUUID UUID] UUIDString];
    transferUtilityMultiPartUploadTask.file = [fileURL path];
    transferUtilityMultiPartUploadTask.retryCount = 0;
    transferUtilityMultiPartUploadTask.temporaryFileCreated = temporaryFileCreated;
    transferUtilityMultiPartUploadTask.status = OOSTransferUtilityTransferStatusInProgress;
    
    //Get the size of the file and calculate the number of parts.
    NSError *nsError = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path]
                                                                error:&nsError];
    if (!attributes) {
        if (transferUtilityMultiPartUploadTask.temporaryFileCreated) {
            [self removeFile:transferUtilityMultiPartUploadTask.file];
        }
        return [OOSTask taskWithError:nsError];
    }
    unsigned long long fileSize = [attributes fileSize];
    OOSDDLogInfo(@"File size is %llu", fileSize);
    NSUInteger partCount = ceil((float)fileSize /(unsigned long) OOSTransferUtilityMultiPartSize);
    OOSDDLogInfo(@"Number of parts is %lu", (unsigned long) partCount);
    transferUtilityMultiPartUploadTask.progress.totalUnitCount = fileSize;
    transferUtilityMultiPartUploadTask.progress.completedUnitCount = (long long) 0;
    transferUtilityMultiPartUploadTask.cancelled = NO;
    transferUtilityMultiPartUploadTask.contentLength = [ [NSNumber alloc] initWithUnsignedLongLong:fileSize];
    
    //Create the initial request to start the multipart process.
    OOSCreateMultipartUploadRequest *uploadRequest = [OOSCreateMultipartUploadRequest new];
    uploadRequest.bucket = bucket;
    uploadRequest.key = key;

    [self propagateHeaderInformation:uploadRequest expression:transferUtilityMultiPartUploadTask.expression];
    
    //Initiate the multi part
    return [[self.s3 createMultipartUpload:uploadRequest] continueWithBlock:^id(OOSTask *task) {
        //Initiation of multi part failed.
        if (task.error) {
            if (transferUtilityMultiPartUploadTask.temporaryFileCreated) {
                [self removeFile:transferUtilityMultiPartUploadTask.file];
            }
            return [OOSTask taskWithError:task.error];
        }
        //Get the uploadID. This will be used with every part that we will upload.
        OOSCreateMultipartUploadOutput *output = task.result;
        transferUtilityMultiPartUploadTask.uploadID = output.uploadId;

        //Loop through the file and upload the parts one by one
        for (int32_t i = 1; i < partCount + 1; i++) {
            NSUInteger dataLength = OOSTransferUtilityMultiPartSize;
            if (i == partCount) {
                dataLength = fileSize - ( (i-1) * OOSTransferUtilityMultiPartSize);
            }
           
            OOSTransferUtilityUploadSubTask *subTask = [OOSTransferUtilityUploadSubTask new];
            subTask.transferID = transferUtilityMultiPartUploadTask.transferID;
            subTask.partNumber = @(i);
            subTask.transferType = @"MULTI_PART_UPLOAD_SUB_TASK";
            subTask.totalBytesExpectedToSend = dataLength;
            subTask.totalBytesSent = (long long) 0;
            subTask.responseData = @"";
            subTask.file = @"";
            subTask.eTag = @"";
            
            //Move to inProgress or Waiting based on concurrency limit
            if (i <= [self.transferUtilityConfiguration.multiPartConcurrencyLimit integerValue]) {
                subTask.status = OOSTransferUtilityTransferStatusInProgress;

                NSError *error = [self createUploadSubTask:transferUtilityMultiPartUploadTask subTask:subTask];
                if ( error) {
                    //Abort the request, so the server can clean up any partials.
                    [self callAbortMultiPartForUploadTask:transferUtilityMultiPartUploadTask];
                    transferUtilityMultiPartUploadTask.status = OOSTransferUtilityTransferStatusError;

                    //Clean up.
                    [self cleanupForMultiPartUploadTask:transferUtilityMultiPartUploadTask];
                    return [OOSTask taskWithError:error];
                };
            }
            else {
                subTask.status = OOSTransferUtilityTransferStatusWaiting;
                [transferUtilityMultiPartUploadTask.waitingPartsDictionary setObject:subTask forKey:subTask.partNumber];
            }
        }
        return [OOSTask taskWithResult:transferUtilityMultiPartUploadTask];
    }];
    return [OOSTask taskWithResult:transferUtilityMultiPartUploadTask];
}

-(NSString *) createTemporaryFileForPart: (NSString *) fileName
                              partNumber: (long) partNumber
                              dataLength: (NSUInteger) dataLength
                                   error: (NSError **) error{
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSString *errorMessage = [NSString stringWithFormat:@"Local file not found. Unable to process Part #: %ld", partNumber];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                             forKey:@"Message"];
        
        *error = [NSError errorWithDomain:OOSTransferUtilityErrorDomain
                                             code:OOSTransferUtilityErrorLocalFileNotFound
                                         userInfo:userInfo];
        return nil;
    }
    
    //Create a temporary file for this part.
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fileName];
    [fileHandle seekToFileOffset:(partNumber - 1) * OOSTransferUtilityMultiPartSize];
    NSData *partData = [fileHandle readDataOfLength:dataLength];
    NSString *partFile = [self.cacheDirectoryPath stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSURL *tempURL = [NSURL fileURLWithPath:partFile];
    [partData writeToURL:tempURL atomically:YES];
    partData = nil;
    [fileHandle closeFile];
    return partFile;
}

-(NSError *) createUploadSubTask:(OOSTransferUtilityMultiPartUploadTask *) transferUtilityMultiPartUploadTask
                         subTask: (OOSTransferUtilityUploadSubTask *) subTask

{
    return [self createUploadSubTask:transferUtilityMultiPartUploadTask subTask:subTask startTransfer:YES];
}

-(NSError *) createUploadSubTask:(OOSTransferUtilityMultiPartUploadTask *) transferUtilityMultiPartUploadTask
                    subTask: (OOSTransferUtilityUploadSubTask *) subTask
                   startTransfer: (BOOL) startTransfer
{
    //Create a temporary part file if required.
    if (!(subTask.file || [subTask.file isEqualToString:@""]) || ![[NSFileManager defaultManager] fileExistsAtPath:subTask.file]) {
        //Create a temporary file for this part.
        NSError *error = nil;
        NSString * partFileName = [self createTemporaryFileForPart:transferUtilityMultiPartUploadTask.file partNumber:[subTask.partNumber integerValue] dataLength:subTask.totalBytesExpectedToSend error:&error];
        if (partFileName == nil)  {
            //Unable to create partFile. Send back error object to indicate that createUploadSubtask failed.
            return error;
        }
        subTask.file = partFileName;
    }
    
    //Create a presignedURL for this part.
    OOSGetPreSignedURLRequest *request = [OOSGetPreSignedURLRequest new];
    request.bucket = transferUtilityMultiPartUploadTask.bucket;
    request.key = transferUtilityMultiPartUploadTask.key;
    request.partNumber = subTask.partNumber;
    request.uploadID = transferUtilityMultiPartUploadTask.uploadID;
    request.HTTPMethod = OOSHTTPMethodPUT;
    
    request.expires = [NSDate dateWithTimeIntervalSinceNow:_transferUtilityConfiguration.timeoutIntervalForResource];
    request.minimumCredentialsExpirationInterval = _transferUtilityConfiguration.timeoutIntervalForResource;
    request.accelerateModeEnabled = self.transferUtilityConfiguration.isAccelerateModeEnabled;
    [self filterAndAssignHeaders:transferUtilityMultiPartUploadTask.expression.requestHeaders getPresignedURLRequest:request
                      URLRequest:nil];
    
    [transferUtilityMultiPartUploadTask.expression assignRequestParameters:request];
   
    [[self.preSignedURLBuilder getPreSignedURL:request] continueWithSuccessBlock:^id(OOSTask *task) {
        NSURL *presignedURL = task.result;
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:presignedURL];
         urlRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
         urlRequest.HTTPMethod = @"PUT";
        [self filterAndAssignHeaders:transferUtilityMultiPartUploadTask.expression.requestHeaders
              getPresignedURLRequest:nil URLRequest: urlRequest];
        [ urlRequest setValue:[self.configuration.userAgent stringByAppendingString:@" MultiPart"] forHTTPHeaderField:@"User-Agent"];
        NSURLSessionUploadTask *nsURLUploadTask = [self->_session uploadTaskWithRequest:urlRequest
                                                                         fromFile:[NSURL fileURLWithPath:subTask.file]];
        //Create subtask to track this upload
        subTask.sessionTask = nsURLUploadTask;
        subTask.taskIdentifier = nsURLUploadTask.taskIdentifier;
        if (startTransfer) {
            subTask.status = OOSTransferUtilityTransferStatusInProgress;
        }
        else {
            subTask.status = OOSTransferUtilityTransferStatusPaused;
        }
       
        [transferUtilityMultiPartUploadTask.inProgressPartsDictionary setObject:subTask forKey:@(subTask.taskIdentifier)];
        //Also register transferUtilityMultiPartUploadTask into the taskDictionary for easy lookup in the NSURLCallback
        [self->_taskDictionary setObject:transferUtilityMultiPartUploadTask forKey:@(subTask.taskIdentifier)];
		
        if (startTransfer) {
            [nsURLUploadTask resume];
        }
        return nil;
    }];
    return nil;
}

-(void) retryUploadSubTask: (OOSTransferUtilityMultiPartUploadTask *) transferUtilityMultiPartUploadTask
                   subTask: (OOSTransferUtilityUploadSubTask *) subTask
             startTransfer: (BOOL) startTransfer {
    
    //Remove from TaskDictionary and inProgressPartsDictionary
    [self.taskDictionary removeObjectForKey:@(subTask.taskIdentifier)];
    [transferUtilityMultiPartUploadTask.inProgressPartsDictionary removeObjectForKey:@(subTask.taskIdentifier)];
    
    transferUtilityMultiPartUploadTask.retryCount = transferUtilityMultiPartUploadTask.retryCount + 1;
    
    //Check if the part file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:subTask.file]) {
        //Set it to nil. This will force the creatUploadSubTask to create the part from the main file
        subTask.file = nil;
    }
    
    NSError *error = [self createUploadSubTask:transferUtilityMultiPartUploadTask subTask:subTask startTransfer:startTransfer];
    if ( error ) {
        //cancel the multipart transfer
        [transferUtilityMultiPartUploadTask cancel];
        
        //Call the completion handler if one was present
        if (transferUtilityMultiPartUploadTask.expression.completionHandler) {
            transferUtilityMultiPartUploadTask.expression.completionHandler(transferUtilityMultiPartUploadTask, error);
        }
    }
}

#pragma mark - Download methods

- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadDataForKey:(NSString *)key
                                                             expression:(OOSTransferUtilityDownloadExpression *)expression
                                                      completionHandler:(OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    return [self internalDownloadToURL:nil
                                bucket:self.transferUtilityConfiguration.bucket
                                   key:key
                            expression:expression
                     completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadDataFromBucket:(NSString *)bucket
                                                                    key:(NSString *)key
                                                             expression:(OOSTransferUtilityDownloadExpression *)expression
                                                      completionHandler:(OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    return [self internalDownloadToURL:nil
                                bucket:bucket
                                   key:key
                            expression:expression
                     completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadToURL:(NSURL *)fileURL
                                                           key:(NSString *)key
                                                    expression:(OOSTransferUtilityDownloadExpression *)expression
                                             completionHandler:(OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    return [self internalDownloadToURL:fileURL
                                bucket:self.transferUtilityConfiguration.bucket
                                   key:key
                            expression:expression
                     completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadToURL:(NSURL *)fileURL
                                                        bucket:(NSString *)bucket
                                                           key:(NSString *)key
                                                    expression:(OOSTransferUtilityDownloadExpression *)expression
                                             completionHandler:(OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    return [self internalDownloadToURL:fileURL
                                bucket:bucket
                                   key:key
                            expression:expression
                     completionHandler:completionHandler];
}

- (OOSTask<OOSTransferUtilityDownloadTask *> *)internalDownloadToURL:(NSURL *)fileURL
                                                                bucket:(NSString *)bucket
                                                                   key:(NSString *)key
                                                            expression:(OOSTransferUtilityDownloadExpression *)expression
                                                     completionHandler:(OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    //Validate that bucket has been specified.
    if (!bucket || [bucket length] == 0) {
        NSInteger errorCode = (self.transferUtilityConfiguration.isAccelerateModeEnabled) ?
        OOSPresignedURLErrorInvalidBucketNameForAccelerateModeEnabled : OOSPresignedURLErrorInvalidBucketName;
        NSString *errorMessage = @"Invalid bucket specified. Please specify a bucket name or configure the bucket property in `OOSTransferUtilityConfiguration`.";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage
                                               forKey:NSLocalizedDescriptionKey];
        
        return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                          code:errorCode
                                                      userInfo:userInfo]];
    }
    
    //Create Expression if required and set completion Handler.
    if (!expression) {
        expression = [OOSTransferUtilityDownloadExpression new];
    }
    expression.completionHandler = completionHandler;
    
    //Create Download Task and set it up.
    OOSTransferUtilityDownloadTask *transferUtilityDownloadTask = [OOSTransferUtilityDownloadTask new];
    transferUtilityDownloadTask.nsURLSessionID = self.sessionIdentifier;
    transferUtilityDownloadTask.transferType = @"DOWNLOAD";
    transferUtilityDownloadTask.location = fileURL;
    transferUtilityDownloadTask.bucket = bucket;
    transferUtilityDownloadTask.key = key;
    transferUtilityDownloadTask.expression = expression;
    transferUtilityDownloadTask.transferID = [[NSUUID UUID] UUIDString];
    transferUtilityDownloadTask.file = [fileURL absoluteString];
    transferUtilityDownloadTask.cancelled = NO;
    transferUtilityDownloadTask.retryCount = 0;
    transferUtilityDownloadTask.responseData = @"";
    transferUtilityDownloadTask.status = OOSTransferUtilityTransferStatusInProgress;
	
    return [self createDownloadTask:transferUtilityDownloadTask];
}

-(OOSTask<OOSTransferUtilityDownloadTask *> *) createDownloadTask: (OOSTransferUtilityDownloadTask *) transferUtilityDownloadTask {
    return [self createDownloadTask:transferUtilityDownloadTask startTransfer:YES];
}

-(OOSTask<OOSTransferUtilityDownloadTask *> *) createDownloadTask: (OOSTransferUtilityDownloadTask *) transferUtilityDownloadTask
                                                      startTransfer: (BOOL) startTransfer {
    OOSGetPreSignedURLRequest *getPreSignedURLRequest = [OOSGetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = transferUtilityDownloadTask.bucket;
    getPreSignedURLRequest.key = transferUtilityDownloadTask.key;
    getPreSignedURLRequest.HTTPMethod = OOSHTTPMethodGET;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:_transferUtilityConfiguration.timeoutIntervalForResource];
    getPreSignedURLRequest.minimumCredentialsExpirationInterval = _transferUtilityConfiguration.timeoutIntervalForResource;
    getPreSignedURLRequest.accelerateModeEnabled = self.transferUtilityConfiguration.isAccelerateModeEnabled;
    
    [transferUtilityDownloadTask.expression assignRequestHeaders:getPreSignedURLRequest];
    [transferUtilityDownloadTask.expression assignRequestParameters:getPreSignedURLRequest];
    
    return [[self.preSignedURLBuilder getPreSignedURL:getPreSignedURLRequest] continueWithSuccessBlock:^id(OOSTask *task) {
        NSURL *presignedURL = task.result;
       
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:presignedURL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        request.HTTPMethod = @"GET";
        
        [request setValue:[OOSServiceConfiguration baseUserAgent] forHTTPHeaderField:@"User-Agent"];
        
        for (NSString *key in transferUtilityDownloadTask.expression.requestHeaders) {
            [request setValue:transferUtilityDownloadTask.expression.requestHeaders[key] forHTTPHeaderField:key];
        }
        
        OOSDDLogInfo(@"Request headers:\n%@", request.allHTTPHeaderFields);
        
        NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
        transferUtilityDownloadTask.sessionTask = downloadTask;
        if (startTransfer) {
            transferUtilityDownloadTask.status = OOSTransferUtilityTransferStatusInProgress;
        }
        else {
            transferUtilityDownloadTask.status = OOSTransferUtilityTransferStatusPaused;
        }
        OOSDDLogInfo(@"Setting taskIdentifier to %@", @(transferUtilityDownloadTask.sessionTask.taskIdentifier));
        
        //Add to taskDictionary
        [self.taskDictionary setObject:transferUtilityDownloadTask forKey:@(transferUtilityDownloadTask.sessionTask.taskIdentifier) ];
        
        if ( startTransfer) {
            [downloadTask resume];
        }
        return [OOSTask taskWithResult:transferUtilityDownloadTask];
    }];
}

- (void) retryDownload: (OOSTransferUtilityDownloadTask *) transferUtilityDownloadTask {
    
    //Remove from taskDictionary
    [self.taskDictionary removeObjectForKey:@(transferUtilityDownloadTask.sessionTask.taskIdentifier)];
    // OOSDDLogInfo(@"Removed object from key %@", @(transferUtilityDownloadTask.sessionTask.taskIdentifier) );
    transferUtilityDownloadTask.retryCount = transferUtilityDownloadTask.retryCount + 1;
    
    //This will update the OOSTransferUtilityDownloadTask passed into it with a new URL Session
    //task and add it into the task Dictionary.
    [self createDownloadTask:transferUtilityDownloadTask];
}

#pragma mark - Utility methods

- (void)enumerateToAssignBlocksForUploadTask:(void (^)(OOSTransferUtilityUploadTask *uploadTask,
                                                       OOSTransferUtilityProgressBlock *uploadProgressBlockReference,
                                                       OOSTransferUtilityUploadCompletionHandlerBlock *completionHandlerReference))uploadBlocksAssigner
                                downloadTask:(void (^)(OOSTransferUtilityDownloadTask *downloadTask,
                                                       OOSTransferUtilityProgressBlock *downloadProgressBlockReference,
                                                       OOSTransferUtilityDownloadCompletionHandlerBlock *completionHandlerReference))downloadBlocksAssigner {
    
    // Iterate through Tasks
    for (id key in [self.taskDictionary allKeys]) {
        id value = [self.taskDictionary objectForKey:key];
        if ([value isKindOfClass:[OOSTransferUtilityUploadTask class]]) {
            OOSTransferUtilityUploadTask *transferUtilityUploadTask = value;
            if (uploadBlocksAssigner) {
                OOSTransferUtilityProgressBlock progressBlock = nil;
                OOSTransferUtilityUploadCompletionHandlerBlock completionHandler = nil;
                
                uploadBlocksAssigner(transferUtilityUploadTask, &progressBlock, &completionHandler);
                
                if (progressBlock) {
                    transferUtilityUploadTask.expression.progressBlock = progressBlock;
                }
                if (completionHandler) {
                    transferUtilityUploadTask.expression.completionHandler = completionHandler;
                }
            }
        }
        else if ([value isKindOfClass:[OOSTransferUtilityDownloadTask class]]) {
            OOSTransferUtilityDownloadTask *transferUtilityDownloadTask = value;
            if (downloadBlocksAssigner) {
                OOSTransferUtilityProgressBlock progressBlock = nil;
                OOSTransferUtilityDownloadCompletionHandlerBlock completionHandler = nil;
                
                downloadBlocksAssigner(transferUtilityDownloadTask, &progressBlock, &completionHandler);
                
                if (progressBlock) {
                    transferUtilityDownloadTask.expression.progressBlock = progressBlock;
                }
                if (completionHandler) {
                    transferUtilityDownloadTask.expression.completionHandler = completionHandler;
                }
            }
        }
    }
}

-(void)enumerateToAssignBlocksForUploadTask:(void (^)(OOSTransferUtilityUploadTask *uploadTask,
                                                      OOSTransferUtilityProgressBlock *uploadProgressBlockReference,
                                                      OOSTransferUtilityUploadCompletionHandlerBlock *completionHandlerReference))uploadBlocksAssigner
              multiPartUploadBlocksAssigner: (void (^) (OOSTransferUtilityMultiPartUploadTask *multiPartUploadTask,
                                                        OOSTransferUtilityMultiPartProgressBlock *multiPartUploadProgressBlockReference,
                                                        OOSTransferUtilityMultiPartUploadCompletionHandlerBlock *completionHandlerReference)) multiPartUploadBlocksAssigner
                     downloadBlocksAssigner:(void (^)(OOSTransferUtilityDownloadTask *downloadTask,
                                                      OOSTransferUtilityProgressBlock *downloadProgressBlockReference,
                                                      OOSTransferUtilityDownloadCompletionHandlerBlock *completionHandlerReference))downloadBlocksAssigner {
   
    [self enumerateToAssignBlocksForUploadTask:uploadBlocksAssigner  downloadTask:downloadBlocksAssigner];
   
    // Iterate through MultiPartUploadTasks
    for (id key in [self.taskDictionary allKeys]) {
        id value = [self.taskDictionary objectForKey:key];
        if ([value isKindOfClass:[OOSTransferUtilityMultiPartUploadTask class]]) {
            OOSTransferUtilityMultiPartUploadTask *task = value;
            if (multiPartUploadBlocksAssigner) {
                OOSTransferUtilityMultiPartProgressBlock progressBlock = nil;
                OOSTransferUtilityMultiPartUploadCompletionHandlerBlock completionHandler = nil;
                multiPartUploadBlocksAssigner(task, &progressBlock, &completionHandler);
                if (progressBlock) {
                    task.expression.progressBlock = progressBlock;
                }
                if (completionHandler) {
                    task.expression.completionHandler = completionHandler;
                }
            }
        }
    }
}


- (OOSTask *)getAllTasks {
    OOSTaskCompletionSource *completionSource = [OOSTaskCompletionSource new];

    NSMutableArray *allTasks = [NSMutableArray new];
    [allTasks addObjectsFromArray:[self getUploadTasks].result];
    [allTasks addObjectsFromArray:[self getDownloadTasks].result];
    [completionSource setResult:allTasks];
    return completionSource.task;
}

- (OOSTask *)getUploadTasks {
    OOSTaskCompletionSource *completionSource = [OOSTaskCompletionSource new];
    NSMutableSet *transferIDs = [NSMutableSet new];
    NSString *className = NSStringFromClass(OOSTransferUtilityUploadTask.class);
    NSMutableArray *allTasks = [self getTasksHelper:self.completedTaskDictionary transferIDs:transferIDs className:className];
    [allTasks addObjectsFromArray:[self getTasksHelper:self.taskDictionary transferIDs:transferIDs className:className]];
    [completionSource setResult:allTasks];
    return completionSource.task;
}

- (OOSTask *)getDownloadTasks {
    OOSTaskCompletionSource *completionSource = [OOSTaskCompletionSource new];
    NSMutableSet *transferIDs = [NSMutableSet new];
    NSString *className = NSStringFromClass(OOSTransferUtilityDownloadTask.class);
    
    NSMutableArray *allTasks = [self getTasksHelper:self.completedTaskDictionary transferIDs:transferIDs className:className];
    [allTasks addObjectsFromArray:[self getTasksHelper:self.taskDictionary transferIDs:transferIDs className:className]];
    [completionSource setResult:allTasks];
    return completionSource.task;
}


- (OOSTask *)getMultiPartUploadTasks {
    OOSTaskCompletionSource *completionSource = [OOSTaskCompletionSource new];
    NSMutableSet *transferIDs = [NSMutableSet new];
    NSString *className = NSStringFromClass(OOSTransferUtilityMultiPartUploadTask.class);

    NSMutableArray *allTasks = [self getTasksHelper:self.completedTaskDictionary transferIDs:transferIDs className:className];
    [allTasks addObjectsFromArray:[self getTasksHelper:self.taskDictionary transferIDs:transferIDs className:className]];
    
    [completionSource setResult:allTasks];
    return completionSource.task;
}


- (NSMutableArray *) getTasksHelper:(OOSSynchronizedMutableDictionary *)dictionary
                             transferIDs:(NSMutableSet *) transferIDs
                               className: (NSString *) className {
    NSMutableArray *tasks = [NSMutableArray new];
    for (id key in [dictionary allKeys]) {
        id value = [dictionary objectForKey:key];
        NSString * taskClassName = NSStringFromClass([value class]);
        if ([className isEqualToString:taskClassName]) {
            OOSTransferUtilityTask *task = value;
            if ([transferIDs containsObject:task.transferID]) {
                continue;
            }
            [transferIDs addObject:task.transferID];
            [tasks addObject:value];
        }
    }
    return tasks;
}

#pragma mark - Internal helper methods

- (OOSTask *)callFinishMultiPartForUploadTask:(OOSTransferUtilityMultiPartUploadTask *)uploadTask {
    
    NSMutableArray *completedParts = [NSMutableArray arrayWithCapacity:[uploadTask.completedPartsDictionary count]];
    NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
    
    //Create a new Dictionary with the partNumber as the Key
    for(id key in uploadTask.completedPartsDictionary) {
        OOSTransferUtilityUploadSubTask *subTask = [uploadTask.completedPartsDictionary objectForKey:key];
        [tempDictionary setObject:subTask forKey:subTask.partNumber];
    }
    
    //Compose the request.
    for(int i = 1; i <= [uploadTask.completedPartsDictionary count]; i++) {
        OOSTransferUtilityUploadSubTask *subTask = [tempDictionary objectForKey: [NSNumber numberWithInt:i]];
        OOSCompletedPart *completedPart = [OOSCompletedPart new];
        completedPart.partNumber = subTask.partNumber;
        completedPart.ETag = subTask.eTag;
        [completedParts addObject:completedPart];
    }
    
    OOSCompleteMultipartUploadRequest *compReq = [OOSCompleteMultipartUploadRequest new];
    compReq.bucket = uploadTask.bucket;
    compReq.key = uploadTask.key;
    compReq.uploadId = uploadTask.uploadID;
	
    return [self.s3 completeMultipartUpload:compReq];
}

- (OOSTask *) callAbortMultiPartForUploadTask:(OOSTransferUtilityMultiPartUploadTask *) uploadTask {
    OOSAbortMultipartUploadRequest *abortReq = [OOSAbortMultipartUploadRequest new];
    abortReq.bucket = uploadTask.bucket;
    abortReq.uploadId = uploadTask.uploadID;
    abortReq.key = uploadTask.key;
    return [self.s3 abortMultipartUpload:abortReq];
}

- (OOSTransferUtilityUploadTask *)getUploadTask:(NSURLSessionUploadTask *)uploadTask {
    if (![uploadTask isKindOfClass:[NSURLSessionUploadTask class]]) {
        OOSDDLogInfo(@"uploadTask is not an instance of NSURLSessionUploadTask.");
        return nil;
    }
    return [self.taskDictionary objectForKey:@(uploadTask.taskIdentifier)];
}

- (OOSTransferUtilityDownloadTask *)getDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    if (![downloadTask isKindOfClass:[NSURLSessionDownloadTask class]]) {
        OOSDDLogInfo(@"downloadTask is not an instance of NSURLSessionDownloadTask.");
        return nil;
    }
    
    return [self.taskDictionary objectForKey:@(downloadTask.taskIdentifier)];
}

#pragma mark - UIApplicationDelegate interceptor

+ (void)interceptApplication:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
           completionHandler:(void (^)(void))completionHandler {
    OOSDDLogInfo(@"interceptApplication called for URLSession [%@]", identifier);
    
    // For the default service client
    if ([identifier isEqualToString:_defaultS3TransferUtility.sessionIdentifier]) {
        _defaultS3TransferUtility.backgroundURLSessionCompletionHandler = completionHandler;
    }
    
    // For the SDK managed service clients
    for (NSString *key in [_serviceClients allKeys]) {
        OOSTransferUtility *transferUtility = [_serviceClients objectForKey:key];
        if ([identifier isEqualToString:transferUtility.sessionIdentifier]) {
            OOSDDLogInfo(@"Setting completion handler for urlSession [%@]", identifier);
            
            transferUtility.backgroundURLSessionCompletionHandler = completionHandler;
        }
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    OOSDDLogInfo(@"URLSessionDidFinishEventsForBackgroundURLSession called for NSURLSession %@", _sessionIdentifier);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.backgroundURLSessionCompletionHandler) {
            self.backgroundURLSessionCompletionHandler();
        }
    });
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
     OOSDDLogInfo(@"didBecomeInvalidWithError called for NSURLSession %@", _sessionIdentifier);
    [[NSNotificationCenter defaultCenter] postNotificationName:OOSTransferUtilityURLSessionDidBecomeInvalidNotification object:self];
    
    [_serviceClients removeObject:self];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    OOSDDLogInfo(@"didCompleteWithError called for task %lu", (unsigned long)task.taskIdentifier);
    NSHTTPURLResponse *HTTPResponse = nil;
    NSMutableDictionary *userInfo = nil;
    
    if (!error) {
        if (![task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            error = [NSError errorWithDomain:OOSTransferUtilityErrorDomain code:OOSTransferUtilityErrorUnknown userInfo:nil];
        }
        else {
            HTTPResponse = (NSHTTPURLResponse *) task.response;
            userInfo = [NSMutableDictionary dictionaryWithDictionary:[HTTPResponse allHeaderFields]];
        }
    
        if (!error) {
            if (HTTPResponse.statusCode / 100 == 3
                && HTTPResponse.statusCode != 304) { // 304 Not Modified is a valid response.
                error = [NSError errorWithDomain:OOSTransferUtilityErrorDomain
                                            code:OOSTransferUtilityErrorRedirection
                                        userInfo:userInfo];
            }
            
            if (HTTPResponse.statusCode / 100 == 4) {
                error = [NSError errorWithDomain:OOSTransferUtilityErrorDomain
                                            code:OOSTransferUtilityErrorClientError
                                        userInfo:userInfo];
            }
            
            if (HTTPResponse.statusCode / 100 == 5) {
                error = [NSError errorWithDomain:OOSTransferUtilityErrorDomain
                                            code:OOSTransferUtilityErrorServerError
                                        userInfo:userInfo];
            }
        }
    }
    
    
    if( [task isKindOfClass:[NSURLSessionUploadTask class]]) {
        
        OOSTransferUtilityTask *transferUtilityTask = [self.taskDictionary objectForKey:@(task.taskIdentifier)];
        if (!transferUtilityTask) {
            OOSDDLogInfo(@"Unable to find information for task %lu in taskDictionary", (unsigned long)task.taskIdentifier);
            return;
        }
        if ([transferUtilityTask isKindOfClass:[OOSTransferUtilityUploadTask class]]) {
            OOSTransferUtilityUploadTask *uploadTask =[self.taskDictionary objectForKey:@(task.taskIdentifier)];

            //Check if the task was cancelled.
            if (uploadTask.cancelled) {
                [self cleanupForUploadTask:uploadTask];
                return;
            }
            
            uploadTask.error = error;
            if (error && HTTPResponse) {
                if ([self isErrorRetriable:HTTPResponse.statusCode responseFromServer:uploadTask.responseData] )  {
                    OOSDDLogInfo(@"Received a 500, 503 or 400 error. Response Data is [%@]", uploadTask.responseData );
                    if (uploadTask.retryCount < self.transferUtilityConfiguration.retryLimit) {
                        OOSDDLogInfo(@"Retry count is below limit and error is retriable. ");
                        [self retryUpload:uploadTask];
                        return;
                    }
                }
                
                if(uploadTask.responseData == nil ||  [uploadTask.responseData isEqualToString:@""]) {
                    [self handleS3Errors: [[NSString alloc] initWithData:[uploadTask data] encoding:NSASCIIStringEncoding]
                                userInfo: userInfo];
                } else {
                    [self handleS3Errors: [uploadTask responseData]
                                userInfo: userInfo];
                }
                NSError *updatedError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
                
                uploadTask.error = updatedError;
            }
            
            //Mark status as completed if there is no error.
            if (! uploadTask.error ) {
                uploadTask.status = OOSTransferUtilityTransferStatusCompleted;
                //Set progress to 100% and call the progress block
                uploadTask.progress.completedUnitCount = uploadTask.progress.totalUnitCount;
                if (uploadTask.expression.progressBlock) {
                    uploadTask.expression.progressBlock(uploadTask, uploadTask.progress);
                }
            }
            //Else mark as error.
            else {
                uploadTask.status = OOSTransferUtilityTransferStatusError;
            }

            [self cleanupForUploadTask:uploadTask];
            
            if(uploadTask.expression.completionHandler) {
                uploadTask.expression.completionHandler(uploadTask,uploadTask.error);
            }
            return;
        }
        else if ([transferUtilityTask isKindOfClass:[OOSTransferUtilityMultiPartUploadTask class]]) {
            
            //Get the multipart upload task
            OOSTransferUtilityMultiPartUploadTask *transferUtilityMultiPartUploadTask = [self.taskDictionary objectForKey:@(task.taskIdentifier)];
            if (!transferUtilityMultiPartUploadTask) {
                OOSDDLogInfo(@"Unable to find information for task %lu in taskDictionary", (unsigned long)task.taskIdentifier);
                return;
            }
            //Check if the task was cancelled.
            if (transferUtilityMultiPartUploadTask.cancelled) {
                //Abort the request, so the server can clean up any partials.
                [self callAbortMultiPartForUploadTask:transferUtilityMultiPartUploadTask];
                
                //Add it to list of completed Tasks
                [self.completedTaskDictionary setObject:transferUtilityMultiPartUploadTask forKey:transferUtilityMultiPartUploadTask.transferID];
                
                //Clean up.
                [self cleanupForMultiPartUploadTask:transferUtilityMultiPartUploadTask];
                return;
            }
            
            //Check if there was an error.
            if (error) {
                
                OOSTransferUtilityUploadSubTask *subTask = [transferUtilityMultiPartUploadTask.inProgressPartsDictionary objectForKey:@(task.taskIdentifier)];

                //Retrying if a 500, 503 or 400 RequestTimeout error occured.
                if  ([self isErrorRetriable:HTTPResponse.statusCode responseFromServer:subTask.responseData]) {
                    OOSDDLogInfo(@"Received a 500, 503 or 400 error. Response Data is [%@]", subTask.responseData);
                    if (transferUtilityMultiPartUploadTask.retryCount < self.transferUtilityConfiguration.retryLimit) {
                        OOSDDLogInfo(@"Retry count is below limit and error is retriable. ");
                        [self retryUploadSubTask:transferUtilityMultiPartUploadTask subTask:subTask startTransfer:YES];
                        return;
                    }
                }
                
                if(subTask.responseData != nil && [subTask.responseData isEqualToString:@""]) {
                    // Transfer's multi-part subtask does not have raw data access, so only check string based response data.
                    [self handleS3Errors: [subTask responseData]
                                userInfo: userInfo];
                }
                NSError *updatedError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
                
                //Error is not retriable.
                transferUtilityMultiPartUploadTask.error = updatedError;
                transferUtilityMultiPartUploadTask.status = OOSTransferUtilityTransferStatusError;
                
                //Execute call back if provided.
                if(transferUtilityMultiPartUploadTask.expression.completionHandler) {
                    transferUtilityMultiPartUploadTask.expression.completionHandler(transferUtilityMultiPartUploadTask, transferUtilityMultiPartUploadTask.error);
                }
                
                //Make sure all the parts are canceled.
                [transferUtilityMultiPartUploadTask cancel];
                
                //Abort the request, so the server can clean up any partials.
                [self callAbortMultiPartForUploadTask:transferUtilityMultiPartUploadTask];
                
                //clean up.
                [self cleanupForMultiPartUploadTask:transferUtilityMultiPartUploadTask];
                return;
            }
            
            //Get multipart upload sub task
            OOSTransferUtilityUploadSubTask *subTask = [transferUtilityMultiPartUploadTask.inProgressPartsDictionary objectForKey:@(task.taskIdentifier)];
          
            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *) task.response;
            subTask.eTag = (NSString *) HTTPResponse.allHeaderFields[@"ETAG"];
            
            //Add it to completed parts and remove it from remaining parts.
            [transferUtilityMultiPartUploadTask.completedPartsDictionary setObject:subTask forKey:@(subTask.taskIdentifier)];
            [transferUtilityMultiPartUploadTask.inProgressPartsDictionary removeObjectForKey:@(subTask.taskIdentifier)];
            //Update progress
            transferUtilityMultiPartUploadTask.progress.completedUnitCount = transferUtilityMultiPartUploadTask.progress.completedUnitCount - subTask.totalBytesSent + OOSTransferUtilityMultiPartSize;
            
            //Delete the temporary upload file for this subTask
            [self removeFile:subTask.file];
            subTask.status = OOSTransferUtilityTransferStatusCompleted;
            
            //If there are parts waiting to be uploaded, pick one from the list and move it to inProgress
            if ([transferUtilityMultiPartUploadTask.waitingPartsDictionary count] != 0) {
                //Get a part from the waitingList
                OOSTransferUtilityUploadSubTask *nextSubTask = [[transferUtilityMultiPartUploadTask.waitingPartsDictionary allValues] objectAtIndex:0];
                
                //Remove it from the waitingList
                [transferUtilityMultiPartUploadTask.waitingPartsDictionary removeObjectForKey:nextSubTask.partNumber];
                
                //Create the subtask and start the transfer
                NSError *error = [self createUploadSubTask:transferUtilityMultiPartUploadTask subTask:nextSubTask];
                if ( error ) {
                    transferUtilityMultiPartUploadTask.status = OOSTransferUtilityTransferStatusError;
                    //Add it to list of completed Tasks
                    [self.completedTaskDictionary setObject:transferUtilityMultiPartUploadTask forKey:transferUtilityMultiPartUploadTask.transferID];
                    
                    //cancel the multipart transfer
                    [transferUtilityMultiPartUploadTask cancel];
                    
                    //Call the completion handler if one was present
                    if (transferUtilityMultiPartUploadTask.expression.completionHandler) {
                        transferUtilityMultiPartUploadTask.expression.completionHandler(transferUtilityMultiPartUploadTask, error);
                    }
                }
            }
            //If there are no more inProgress parts, then we are done.
            else if ([transferUtilityMultiPartUploadTask.inProgressPartsDictionary count] == 0) {
                //Call the Multipart completion step here.
                [[ self callFinishMultiPartForUploadTask:transferUtilityMultiPartUploadTask] continueWithBlock:^id (OOSTask *task) {
                    if (task.error) {
                        OOSDDLogInfo(@"Error finishing up MultiPartForUpload Task[%@]", task.error);
                        transferUtilityMultiPartUploadTask.error = error;
                        transferUtilityMultiPartUploadTask.status = OOSTransferUtilityTransferStatusError;
                    }
                    else {
                        //Set progress to 100% and call progressBlock.
                        transferUtilityMultiPartUploadTask.progress.completedUnitCount = transferUtilityMultiPartUploadTask.progress.totalUnitCount;
                        if (transferUtilityMultiPartUploadTask.expression.progressBlock ) {
                            transferUtilityMultiPartUploadTask.expression.progressBlock(transferUtilityMultiPartUploadTask, transferUtilityMultiPartUploadTask.progress);
                        }
                    }
                    transferUtilityMultiPartUploadTask.status = OOSTransferUtilityTransferStatusCompleted;
                    
                    [self cleanupForMultiPartUploadTask:transferUtilityMultiPartUploadTask];
                    
                    //Call the callback function is specified.
                    if(transferUtilityMultiPartUploadTask.expression.completionHandler) {
                        transferUtilityMultiPartUploadTask.expression.completionHandler(transferUtilityMultiPartUploadTask,error);
                    }
                    return nil;
                }];
            }
        }
    }
    else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        OOSTransferUtilityDownloadTask *downloadTask = [self.taskDictionary objectForKey:@(task.taskIdentifier)];
        if (!downloadTask) {
            OOSDDLogInfo(@"Unable to find information for task %lu in taskDictionary", (unsigned long)task.taskIdentifier);
            return;
        }

        //Check if the task was cancelled.
        if (downloadTask.cancelled) {
            [self.completedTaskDictionary setObject:downloadTask forKey:downloadTask.transferID];
            [self.taskDictionary removeObjectForKey:@(downloadTask.sessionTask.taskIdentifier)];
            return;
        }
        
        downloadTask.error = error;
        if(!error ) {
            downloadTask.status = OOSTransferUtilityTransferStatusCompleted;
        }
        else {
            downloadTask.status = OOSTransferUtilityTransferStatusError;
        }
        
        if (error && HTTPResponse) {
            if ([self isErrorRetriable:HTTPResponse.statusCode responseFromServer:downloadTask.responseData])  {
                if (downloadTask.retryCount < self.transferUtilityConfiguration.retryLimit) {
                    OOSDDLogInfo(@"Retry count is below limit and error is retriable. ");
                    [self retryDownload:downloadTask];
                    return;
                }
            }
            
            if(downloadTask.responseData == nil ||  [downloadTask.responseData isEqualToString:@""]) {
                [self handleS3Errors: [[NSString alloc] initWithData:[downloadTask data] encoding:NSASCIIStringEncoding]
                            userInfo: userInfo];
            } else {
                [self handleS3Errors: [downloadTask responseData]
                            userInfo: userInfo];
            }
            NSError *updatedError = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfo];
            downloadTask.error = updatedError;
        }
        
        if (!downloadTask.error) {
            downloadTask.progress.completedUnitCount = downloadTask.progress.totalUnitCount;
            if (downloadTask.expression.progressBlock) {
                downloadTask.expression.progressBlock(downloadTask, downloadTask.progress);
            }
        }
        if (downloadTask.expression.completionHandler) {
            downloadTask.expression.completionHandler(downloadTask,
                                                      downloadTask.location,
                                                      downloadTask.data,
                                                      downloadTask.error);
        }
        [self.completedTaskDictionary setObject:downloadTask forKey:downloadTask.transferID];
        [self.taskDictionary removeObjectForKey:@(downloadTask.sessionTask.taskIdentifier)];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    OOSDDLogInfo(@"didSendBodyData called for task %lu", (unsigned long)task.taskIdentifier);
    //Check if the task is an uploadTask.
    if (![task isKindOfClass:[NSURLSessionUploadTask class]]) {
        return;
    }
    
    //Handle the update differently based on whether it is a single part or multipart upload.
    OOSTransferUtilityTask *transferUtilityTask = [self.taskDictionary objectForKey:@(task.taskIdentifier)];
    if ([transferUtilityTask isKindOfClass:[OOSTransferUtilityUploadTask class]]) {
        OOSTransferUtilityUploadTask *transferUtilityUploadTask = [self.taskDictionary objectForKey:@(task.taskIdentifier)];
        if (transferUtilityUploadTask.progress.totalUnitCount != totalBytesExpectedToSend) {
            transferUtilityUploadTask.progress.totalUnitCount = totalBytesExpectedToSend;
        }
     
        if (transferUtilityUploadTask.progress.completedUnitCount < totalBytesSent) {
            transferUtilityUploadTask.progress.completedUnitCount = totalBytesSent;
            
            if (transferUtilityUploadTask.expression.progressBlock) {
                transferUtilityUploadTask.expression.progressBlock(transferUtilityUploadTask, transferUtilityUploadTask.progress);
            }
        }
    }
    else if ([transferUtilityTask isKindOfClass:[OOSTransferUtilityMultiPartUploadTask class]]) {
        //Get the multipart upload task
        OOSTransferUtilityMultiPartUploadTask *transferUtilityMultiPartUploadTask = [self.taskDictionary objectForKey:@(task.taskIdentifier)];
        //Get multipart upload sub task
        OOSTransferUtilityUploadSubTask *subTask = [transferUtilityMultiPartUploadTask.inProgressPartsDictionary objectForKey:@(task.taskIdentifier)];
        transferUtilityMultiPartUploadTask.progress.totalUnitCount = [transferUtilityMultiPartUploadTask.contentLength longLongValue];
        if (subTask.totalBytesSent < totalBytesSent) {
            //Calculate and update the running total
            transferUtilityMultiPartUploadTask.progress.completedUnitCount = transferUtilityMultiPartUploadTask.progress.completedUnitCount - subTask.totalBytesSent + totalBytesSent;
            subTask.totalBytesSent = totalBytesSent;
     
            //execute the callback to the progressblock if present.
            if (transferUtilityMultiPartUploadTask.expression.progressBlock) {
                OOSDDLogInfo(@"Total %lld, ProgressSoFar %lld", transferUtilityMultiPartUploadTask.progress.totalUnitCount, transferUtilityMultiPartUploadTask.progress.completedUnitCount);
                transferUtilityMultiPartUploadTask.expression.progressBlock(transferUtilityMultiPartUploadTask, transferUtilityMultiPartUploadTask.progress);
            }
        }
    }
}

#pragma mark - Helper methods

- (void) cleanupForMultiPartUploadTask: (OOSTransferUtilityMultiPartUploadTask *) task  {
    
    //Add it to list of completed Tasks
    [self.completedTaskDictionary setObject:task forKey:task.transferID];
    
    //Remove all entries from taskDictionary.
    for ( OOSTransferUtilityUploadSubTask *subTask in [task.inProgressPartsDictionary allValues] ) {
        [self.taskDictionary removeObjectForKey:@(subTask.taskIdentifier)];
        [self removeFile:subTask.file];
    }
    
    //Remove temporary file if required.
    if (task.temporaryFileCreated) {
        [self removeFile:task.file];
    }
}

- (void) cleanupForUploadTask: (OOSTransferUtilityUploadTask *) uploadTask {
    //Add it to list of completed Tasks
    [self.completedTaskDictionary setObject:uploadTask forKey:uploadTask.transferID];
    
    //Remove entry from taskDictionary
    [self.taskDictionary removeObjectForKey:@(uploadTask.taskIdentifier)];
    
    //Remove temporary file if required.
    if (uploadTask.temporaryFileCreated) {
        [self removeFile:uploadTask.file];
    }
}

- (BOOL) isErrorRetriable:(NSInteger) HTTPStatusCode
       responseFromServer:(NSString *) responseFromServer {
    
    // See https://docs.OOS.amazon.com/AmazonS3/latest/API/ErrorResponses.html for S3 error responses
    
    //500 and 503 are retriable.
    if (HTTPStatusCode == 500 || HTTPStatusCode == 503) {
        return YES;
    }
    //If not 5XX or 400, error is not retriable.
    if (HTTPStatusCode != 400) {
        return NO;
    }
    
    //If we didn't get any more info from the server, error is retriable
    if (!responseFromServer ||[responseFromServer isEqualToString:@""]) {
        return YES;
    }
    
    if ([responseFromServer containsString:@"RequestTimeout"] ||
        [responseFromServer containsString:@"ExpiredToken"] ||
        [responseFromServer containsString:@"TokenRefreshRequired"]) {
        return YES;
    }
    return NO;
}

- (void)handleS3Errors:(NSString *)responseString
              userInfo:(NSMutableDictionary *)userInfo {
    if ([responseString rangeOfString:@"<Error>"].location != NSNotFound) {
        OOSXMLDictionaryParser *xmlParser = [OOSXMLDictionaryParser new];
        xmlParser.trimWhiteSpace = YES;
        xmlParser.stripEmptyNodes = NO;
        xmlParser.wrapRootNode = YES; //wrapRootNode for easy process
        xmlParser.nodeNameMode = OOSXMLDictionaryNodeNameModeNever; //do not need rootName anymore since rootNode is wrapped.
        
        NSDictionary *responseDict = [xmlParser dictionaryWithString: responseString];
        userInfo[@"Error"] = responseDict[@"Error"];
        OOSDDLogInfo(@"Error response received from S3: %@", responseDict);
    }
}

- (void) removeFile: (NSString *) absolutePath
{
    if (!absolutePath || ![[NSFileManager defaultManager ] fileExistsAtPath:absolutePath]) {
        return;
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:absolutePath error:&error];
    if (error) {
        OOSDDLogInfo(@"Error deleting file[%@]: [%@]", absolutePath, error);
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    OOSDDLogInfo(@"didFinishDownloadingToURL called for Download task %lu", (unsigned long)downloadTask.taskIdentifier);
    OOSTransferUtilityDownloadTask *transferUtilityTask = [self.taskDictionary objectForKey:@(downloadTask.taskIdentifier)];
    if (!transferUtilityTask) {
        OOSDDLogInfo(@"Unable to find information for task %lu in taskDictionary", (unsigned long)downloadTask.taskIdentifier);
        return;
    }
    if (transferUtilityTask.location) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[transferUtilityTask.location path]]) {
            NSError *error = nil;
            BOOL result = [[NSFileManager defaultManager] moveItemAtURL:location
                                                                  toURL:transferUtilityTask.location
                                                                  error:&error];
            if (!result) {
                transferUtilityTask.error = error;
            }
        }
    } else {
        NSError *error = nil;
        transferUtilityTask.data = [NSData dataWithContentsOfFile:location.path options:NSDataReadingMappedIfSafe error:&error];
        if (!transferUtilityTask.data) {
            transferUtilityTask.error = error;
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    OOSDDLogInfo(@"didWriteData called for download task %lu", (unsigned long)downloadTask.taskIdentifier);
    OOSTransferUtilityDownloadTask *transferUtilityDownloadTask =
        [self.taskDictionary objectForKey:@(downloadTask.taskIdentifier)];
   
    if (!transferUtilityDownloadTask) {
        OOSDDLogInfo(@"Unable to find information for task %lu in taskDictionary", (unsigned long)downloadTask.taskIdentifier);
        return;
    }
    
    if (transferUtilityDownloadTask.progress.totalUnitCount != totalBytesExpectedToWrite) {
        transferUtilityDownloadTask.progress.totalUnitCount = totalBytesExpectedToWrite;
    }
    if (transferUtilityDownloadTask.progress.completedUnitCount <= totalBytesWritten) {
        transferUtilityDownloadTask.progress.completedUnitCount = totalBytesWritten;

        if (transferUtilityDownloadTask.expression.progressBlock) {
            transferUtilityDownloadTask.expression.progressBlock(transferUtilityDownloadTask, transferUtilityDownloadTask.progress);
        }
    }
}

#pragma mark - NSURLSessionDataDelegate


@end

#pragma mark - OOSTransferUtilityConfiguration

@implementation OOSTransferUtilityConfiguration

- (instancetype)init {
    if (self = [super init]) {
        //set defaults.
        _accelerateModeEnabled = NO;
        _retryLimit = 0;
        _multiPartConcurrencyLimit = @(OOSTransferUtilityMultiPartDefaultConcurrencyLimit);
        _timeoutIntervalForResource = OOSTransferUtilityTimeoutIntervalForResource;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OOSTransferUtilityConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.accelerateModeEnabled = self.isAccelerateModeEnabled;
    configuration.bucket = self.bucket;
    configuration.retryLimit = self.retryLimit;
    configuration.multiPartConcurrencyLimit = self.multiPartConcurrencyLimit;
    configuration.timeoutIntervalForResource = self.timeoutIntervalForResource;
    return configuration;
}

@end




