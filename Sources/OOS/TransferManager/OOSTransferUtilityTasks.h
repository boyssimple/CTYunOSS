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


NS_ASSUME_NONNULL_BEGIN



@class OOSTransferUtilityTask;
@class OOSTransferUtilityUploadTask;
@class OOSTransferUtilityMultiPartUploadTask;
@class OOSTransferUtilityDownloadTask;
@class OOSTransferUtilityExpression;
@class OOSTransferUtilityUploadExpression;
@class OOSTransferUtilityMultiPartUploadExpression;
@class OOSTransferUtilityDownloadExpression;

typedef NS_ENUM(NSInteger, OOSTransferUtilityTransferStatusType) {
    OOSTransferUtilityTransferStatusUnknown,
    OOSTransferUtilityTransferStatusInProgress,
    OOSTransferUtilityTransferStatusPaused,
    OOSTransferUtilityTransferStatusCompleted,
    OOSTransferUtilityTransferStatusWaiting,
    OOSTransferUtilityTransferStatusError,
    OOSTransferUtilityTransferStatusCancelled
};

/**
 The upload completion handler.
 
 @param task  The upload task object.
 @param error Returns the error object when the download failed.
 */
typedef void (^OOSTransferUtilityUploadCompletionHandlerBlock) (OOSTransferUtilityUploadTask *task,
                                                                  NSError * _Nullable error);

/**
 The upload completion handler for MultiPart.
 
 @param task  The upload task object.
 @param error Returns the error object when the download failed.
 */
typedef void (^OOSTransferUtilityMultiPartUploadCompletionHandlerBlock) (OOSTransferUtilityMultiPartUploadTask *task,
                                                                           NSError * _Nullable error);

/**
 The download completion handler.
 
 @param task     The download task object.
 @param location When downloading an Amazon S3 object to a file, returns a file URL of the returned object. Otherwise, returns `nil`.
 @param data     When downloading an Amazon S3 object as an `NSData`, returns the returned object as an instance of `NSData`. Otherwise, returns `nil`.
 @param error    Returns the error object when the download failed. Returns `nil` on successful downlaod.
 */
typedef void (^OOSTransferUtilityDownloadCompletionHandlerBlock) (OOSTransferUtilityDownloadTask *task,
                                                                    NSURL * _Nullable location,
                                                                    NSData * _Nullable data,
                                                                    NSError * _Nullable error);

/**
 The transfer progress feedback block.
 
 @param task                     The upload task object.
 @param progress                 The progress object.
 
 @note Refer to `- URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:` in `NSURLSessionTaskDelegate` for more details on upload progress and `- URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:` in `NSURLSessionDownloadDelegate` for more details on download progress.
 */
typedef void (^OOSTransferUtilityProgressBlock) (OOSTransferUtilityTask *task,
                                                   NSProgress *progress);

/**
 The multi part transfer progress feedback block.
 
 @param task                     The upload task object.
 @param progress                 The progress object.
 */
typedef void (^OOSTransferUtilityMultiPartProgressBlock) (OOSTransferUtilityMultiPartUploadTask *task,
                                                            NSProgress *progress);


#pragma mark - OOSTransferUtilityTasks

/**
 The task object to represent a upload or download task.
 */
@interface OOSTransferUtilityTask : NSObject

/**
 An identifier uniquely identifies the transferID.
 */

@property (readonly) NSString *transferID;

/**
 An identifier uniquely identifies the task within a given `OOSTransferUtility` instance.
 */
@property (readonly) NSUInteger taskIdentifier;

/**
 The Amazon S3 bucket name associated with the transfer.
 */
@property (readonly) NSString *bucket;

/**
 The Amazon S3 object key name associated with the transfer.
 */
@property (readonly) NSString *key;

/**
 The transfer progress.
 */
@property (readonly) NSProgress *progress;

/**
 the status of the Transfer.
 */
@property (readonly) OOSTransferUtilityTransferStatusType status;

/**
 The underlying `NSURLSessionTask` object.
 */
@property (readonly) NSURLSessionTask *sessionTask;

/**
 The HTTP request object.
 */
@property (nullable, readonly) NSURLRequest *request;

/**
 The HTTP response object. May be nil if no response has been received.
 */
@property (nullable, readonly) NSHTTPURLResponse *response;

/**
 Cancels the task.
 */
- (void)cancel;

/**
 Resumes the task, if it is suspended.
 */
- (void)resume;

/**
 Temporarily suspends a task.
 */
- (void)suspend;

@end

/**
 The task object to represent a upload task.
 */
@interface OOSTransferUtilityUploadTask : OOSTransferUtilityTask

/**
 set completion handler for task
 **/

- (void) setCompletionHandler: (OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Set the progress Block
 */
- (void) setProgressBlock: (OOSTransferUtilityProgressBlock) progressBlock;

@end

/**
 The task object to represent a multipart upload task.
 */
@interface OOSTransferUtilityMultiPartUploadTask: NSObject

/**
 An identifier uniquely identifies the transferID.
 */
@property (readonly) NSString *transferID;

/**
 The Amazon S3 bucket name associated with the transfer.
 */
@property (readonly) NSString *bucket;

/**
 The Amazon S3 object key name associated with the transfer.
 */
@property (readonly) NSString *key;

/**
 The transfer progress.
 */
@property (readonly) NSProgress *progress;

/**
 the status of the Transfer.
 */
@property (readonly) OOSTransferUtilityTransferStatusType status;


/**
 Cancels the task.
 */
- (void)cancel;

/**
 Resumes the task, if it is suspended.
 */
- (void)resume;

/**
 Temporarily suspends a task.
 */
- (void)suspend;

/**
 set completion handler for task
 **/

- (void) setCompletionHandler: (OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler;

/**
 Set the progress Block
 */
- (void) setProgressBlock: (OOSTransferUtilityMultiPartProgressBlock) progressBlock;

@end


/**
 The task object to represent a download task.
 */
@interface OOSTransferUtilityDownloadTask : OOSTransferUtilityTask
/**
 set completion handler for task
 **/
- (void) setCompletionHandler: (OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler;

/**
 Set the progress Block
 */
- (void) setProgressBlock: (OOSTransferUtilityProgressBlock) progressBlock;

@end

@interface OOSTransferUtilityUploadSubTask: NSObject
@end

#pragma mark - OOSTransferUtilityExpressions

/**
 The expression object for configuring a upload or download task.
 */
@interface OOSTransferUtilityExpression : NSObject

/**
 This NSDictionary can contains additional request headers to be included in the pre-signed URL. Default is emtpy.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestHeaders;

/**
 This NSDictionary can contains additional request parameters to be included in the pre-signed URL. Adding additional request parameters enables more advanced pre-signed URLs, such as accessing Amazon S3's torrent resource for an object, or for specifying a version ID when accessing an object. Default is emtpy.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestParameters;

/**
 The progress feedback block.
 */
@property (copy, nonatomic, nullable) OOSTransferUtilityProgressBlock progressBlock;

/**
 Set an additional request header to be included in the pre-signed URL.
 
 @param value The value of the request parameter being added. Set to nil if parameter doesn't contains value.
 @param requestHeader The name of the request header.
 */
- (void)setValue:(nullable NSString *)value forRequestHeader:(NSString *)requestHeader;

/**
 Set an additional request parameter to be included in the pre-signed URL. Adding additional request parameters enables more advanced pre-signed URLs, such as accessing Amazon S3's torrent resource for an object, or for specifying a version ID when accessing an object.
 
 @param value The value of the request parameter being added. Set to nil if parameter doesn't contains value.
 @param requestParameter The name of the request parameter, as it appears in the URL's query string (e.g. OOSPresignedURLVersionID).
 */
- (void)setValue:(nullable NSString *)value forRequestParameter:(NSString *)requestParameter;

@end

/**
 The expression object for configuring a upload task.
 */
@interface OOSTransferUtilityUploadExpression : OOSTransferUtilityExpression

/**
 The upload request header for `Content-MD5`.
 */
@property (nonatomic, nullable) NSString *contentMD5;

@end


/**
 The expression object for configuring a Multipart upload task.
 */
@interface OOSTransferUtilityMultiPartUploadExpression : NSObject

/**
 This NSDictionary can contains additional request headers to be included in the pre-signed URL. Default is emtpy.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestHeaders;

/**
 This NSDictionary can contains additional request parameters to be included in the pre-signed URL. Adding additional request parameters enables more advanced pre-signed URLs, such as accessing Amazon S3's torrent resource for an object, or for specifying a version ID when accessing an object. Default is emtpy.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestParameters;

/**
 The progress feedback block.
 */
@property (copy, nonatomic, nullable) OOSTransferUtilityMultiPartProgressBlock progressBlock;

/**
 Set an additional request header to be included in the pre-signed URL.
 
 
 @param value The value of the request parameter being added. Set to nil if parameter doesn't contains value.
 @param requestHeader The name of the request header.
 */
- (void)setValue:(nullable NSString *)value forRequestHeader:(NSString *)requestHeader;

/**
 Set an additional request parameter to be included in the pre-signed URL. Adding additional request parameters enables more advanced pre-signed URLs, such as accessing Amazon S3's torrent resource for an object, or for specifying a version ID when accessing an object.
 
 @param value The value of the request parameter being added. Set to nil if parameter doesn't contains value.
 @param requestParameter The name of the request parameter, as it appears in the URL's query string (e.g. OOSPresignedURLVersionID).
 */
- (void)setValue:(nullable NSString *)value forRequestParameter:(NSString *)requestParameter;



@end

/**
 The expression object for configuring a download task.
 */
@interface OOSTransferUtilityDownloadExpression : OOSTransferUtilityExpression

@end

NS_ASSUME_NONNULL_END

