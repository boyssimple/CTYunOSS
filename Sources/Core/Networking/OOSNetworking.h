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
#import "CoreModel.h"

FOUNDATION_EXPORT NSString *const OOSNetworkingErrorDomain;
typedef NS_ENUM(NSInteger, OOSNetworkingErrorType) {
    OOSNetworkingErrorUnknown,
    OOSNetworkingErrorCancelled = -999
};

typedef NS_ENUM(NSInteger, OOSNetworkingRetryType) {
    OOSNetworkingRetryTypeUnknown,
    OOSNetworkingRetryTypeShouldNotRetry,
    OOSNetworkingRetryTypeShouldRetry,
    OOSNetworkingRetryTypeShouldRefreshCredentialsAndRetry,
    OOSNetworkingRetryTypeShouldCorrectClockSkewAndRetry,
    OOSNetworkingRetryTypeResetStreamAndRetry
};

@class OOSNetworkingConfiguration;
@class OOSNetworkingRequest;
@class OOSTask<__covariant ResultType>;

typedef void (^OOSNetworkingUploadProgressBlock) (int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^OOSNetworkingDownloadProgressBlock) (int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

#pragma mark - OOSHTTPMethod

typedef NS_ENUM(NSInteger, OOSHTTPMethod) {
    OOSHTTPMethodUnknown,
    OOSHTTPMethodGET,
    OOSHTTPMethodHEAD,
    OOSHTTPMethodPOST,
    OOSHTTPMethodPUT,
    OOSHTTPMethodPATCH,
    OOSHTTPMethodDELETE
};

@interface NSString (OOSHTTPMethod)

+ (instancetype)oos_stringWithHTTPMethod:(OOSHTTPMethod)HTTPMethod;

@end

#pragma mark - OOSNetworking

@interface OOSNetworking : NSObject

- (instancetype)initWithConfiguration:(OOSNetworkingConfiguration *)configuration;

- (OOSTask *)sendRequest:(OOSNetworkingRequest *)request;

@end

#pragma mark - Protocols

@protocol OOSURLRequestSerializer <NSObject>

@required
- (OOSTask *)validateRequest:(NSURLRequest *)request;
- (OOSTask *)serializeRequest:(NSMutableURLRequest *)request
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters;

@end

@protocol OOSNetworkingRequestInterceptor <NSObject>

@required
- (OOSTask *)interceptRequest:(NSMutableURLRequest *)request;

@end

@protocol OOSNetworkingHTTPResponseInterceptor <NSObject>

@required
- (OOSTask *)interceptResponse:(NSHTTPURLResponse *)response
                         data:(id)data
              originalRequest:(NSURLRequest *)originalRequest
               currentRequest:(NSURLRequest *)currentRequest;

@end

@protocol OOSHTTPURLResponseSerializer <NSObject>

@required

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
             fromRequest:(NSURLRequest *)request
                    data:(id)data
                   error:(NSError *__autoreleasing *)error;
- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                originalRequest:(NSURLRequest *)originalRequest
                 currentRequest:(NSURLRequest *)currentRequest
                           data:(id)data
                          error:(NSError *__autoreleasing *)error;

@end

@protocol OOSURLRequestRetryHandler <NSObject>

@required

@property (nonatomic, assign) uint32_t maxRetryCount;

- (OOSNetworkingRetryType)shouldRetry:(uint32_t)currentRetryCount
                      originalRequest:(OOSNetworkingRequest *)originalRequest
                             response:(NSHTTPURLResponse *)response
                                 data:(NSData *)data
                                error:(NSError *)error;

- (NSTimeInterval)timeIntervalForRetry:(uint32_t)currentRetryCount
                              response:(NSHTTPURLResponse *)response
                                  data:(NSData *)data
                                 error:(NSError *)error;

@optional

- (NSDictionary *)resetParameters:(NSDictionary *)parameters;

@end


#pragma mark - OOSNetworkingConfiguration

@interface OOSNetworkingConfiguration : NSObject <NSCopying>

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, assign) OOSHTTPMethod HTTPMethod;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, assign) BOOL allowsCellularAccess;
@property (nonatomic, strong) NSString *sharedContainerIdentifier;

@property (nonatomic, strong) id<OOSURLRequestSerializer> requestSerializer;
@property (nonatomic, strong) NSArray<id<OOSNetworkingRequestInterceptor>> *requestInterceptors;
@property (nonatomic, strong) id<OOSHTTPURLResponseSerializer> responseSerializer;
@property (nonatomic, strong) NSArray<id<OOSNetworkingHTTPResponseInterceptor>> *responseInterceptors;
@property (nonatomic, strong) id<OOSURLRequestRetryHandler> retryHandler;

/**
 The maximum number of retries for failed requests. The value needs to be between 0 and 10 inclusive. If set to higher than 10, it becomes 10.
 */
@property (nonatomic, assign) uint32_t maxRetryCount;

/**
 The timeout interval to use when waiting for additional data.
 */
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForRequest;

/**
 The maximum amount of time that a resource request should be allowed to take.
 */
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForResource;

@end

#pragma mark - OOSNetworkingRequest

@interface OOSNetworkingRequest : OOSNetworkingConfiguration

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSURL *uploadingFileURL;
@property (nonatomic, strong) NSURL *downloadingFileURL;
@property (nonatomic, assign) BOOL shouldWriteDirectly;

@property (nonatomic, copy) OOSNetworkingUploadProgressBlock uploadProgress;
@property (nonatomic, copy) OOSNetworkingDownloadProgressBlock downloadProgress;

@property (readonly, nonatomic, strong) NSURLSessionTask *task;
@property (readonly, nonatomic, assign, getter = isCancelled) BOOL cancelled;

- (void)assignProperties:(OOSNetworkingConfiguration *)configuration;
- (void)cancel;
- (void)pause;

@end

@interface OOSRequest : CoreModel

@property (nonatomic, strong) OOSNetworkingRequest *internalRequest;
@property (nonatomic, copy) OOSNetworkingUploadProgressBlock uploadProgress;
@property (nonatomic, copy) OOSNetworkingDownloadProgressBlock downloadProgress;
@property (nonatomic, assign, readonly, getter = isCancelled) BOOL cancelled;
@property (nonatomic, strong) NSURL *downloadingFileURL;

- (OOSTask *)cancel;
- (OOSTask *)pause;

@end

@interface OOSNetworkingRequestInterceptor : NSObject <OOSNetworkingRequestInterceptor>

@property (nonatomic, readonly) NSString *userAgent;

- (instancetype)initWithUserAgent:(NSString *)userAgent;

@end
