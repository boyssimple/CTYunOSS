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


#import "OOSNetworking.h"
#import <UIKit/UIKit.h>
#import "OOSURLSessionManager.h"
#import "OOSTask.h"

NSString *const OOSNetworkingErrorDomain = @"cn.ctyun.OOSNetworkingErrorDomain";

#pragma mark - OOSHTTPMethod

@implementation NSString (OOSHTTPMethod)

+ (instancetype)oos_stringWithHTTPMethod:(OOSHTTPMethod)HTTPMethod {
    NSString *string = nil;
    switch (HTTPMethod) {
        case OOSHTTPMethodGET:
            string = @"GET";
            break;
        case OOSHTTPMethodHEAD:
            string = @"HEAD";
            break;
        case OOSHTTPMethodPOST:
            string = @"POST";
            break;
        case OOSHTTPMethodPUT:
            string = @"PUT";
            break;
        case OOSHTTPMethodPATCH:
            string = @"PATCH";
            break;
        case OOSHTTPMethodDELETE:
            string = @"DELETE";
            break;

        default:
            break;
    }

    return string;
}

@end

#pragma mark - OOSNetworking

@interface OOSNetworking()

@property (nonatomic, strong) OOSURLSessionManager *networkManager;

@end

@implementation OOSNetworking

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `- initWithConfiguration` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(OOSNetworkingConfiguration *)configuration {
    if (self = [super init]) {
        _networkManager = [[OOSURLSessionManager alloc] initWithConfiguration:configuration];
    }

    return self;
}

- (OOSTask *)sendRequest:(OOSNetworkingRequest *)request {
    return [self.networkManager dataTaskWithRequest:request];
}
@end

#pragma mark - OOSNetworkingConfiguration

@implementation OOSNetworkingConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _maxRetryCount = 3;
        _allowsCellularAccess = YES;
    }
    return self;
}

- (NSURL *)URL {
    // You can overwrite the URL by providing a full URL in URLString.
    NSURL *fullURL = [NSURL URLWithString:self.URLString];
    if ([fullURL.scheme isEqualToString:@"http"]
        || [fullURL.scheme isEqualToString:@"https"]) {
        NSMutableDictionary *headers = [self.headers mutableCopy];
        headers[@"Host"] = [fullURL host];
        self.headers = headers;
        return fullURL;
    }

    if (!self.URLString) {
        return self.baseURL;
    }

    return [NSURL URLWithString:self.URLString
                  relativeToURL:self.baseURL];
}

- (void)setMaxRetryCount:(uint32_t)maxRetryCount {
    // the max maxRetryCount is 10. If set to higher than that, it becomes 10.
    if (maxRetryCount > 10) {
        _maxRetryCount = 10;
    } else {
        _maxRetryCount = maxRetryCount;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    OOSNetworkingConfiguration *configuration = nil;
    configuration = [[[self class] allocWithZone:zone] init];
    
    configuration.baseURL = [self.baseURL copy];
    configuration.URLString = [self.URLString copy];
    configuration.HTTPMethod = self.HTTPMethod;
    configuration.headers = [self.headers copy];
    configuration.allowsCellularAccess = self.allowsCellularAccess;
    configuration.sharedContainerIdentifier = self.sharedContainerIdentifier;
    
    configuration.requestSerializer = self.requestSerializer;
    configuration.requestInterceptors = [self.requestInterceptors copy];
    configuration.responseSerializer = self.responseSerializer;
    configuration.responseInterceptors = [self.responseInterceptors copy];
    configuration.retryHandler = self.retryHandler;
    configuration.maxRetryCount = self.maxRetryCount;
    configuration.timeoutIntervalForRequest = self.timeoutIntervalForRequest;
    configuration.timeoutIntervalForResource = self.timeoutIntervalForResource;

    return configuration;
}

@end

#pragma mark - OOSNetworkingRequest

@interface OOSNetworkingRequest()

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;

@end

@implementation OOSNetworkingRequest

- (void)assignProperties:(OOSNetworkingConfiguration *)configuration {
    if (!self.baseURL) {
        self.baseURL = configuration.baseURL;
    }

    if (!self.URLString) {
        self.URLString = configuration.URLString;
    }

    if (!self.HTTPMethod) {
        self.HTTPMethod = configuration.HTTPMethod;
    }

    if (configuration.headers) {
        NSMutableDictionary *mutableCopy = [configuration.headers mutableCopy];
        [self.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [mutableCopy setObject:obj forKey:key];
        }];
        self.headers = mutableCopy;
    }

    if (!self.requestSerializer) {
        self.requestSerializer = configuration.requestSerializer;
    }

    if (configuration.requestInterceptors) {
        self.requestInterceptors = configuration.requestInterceptors;
    }

    if (!self.responseSerializer) {
        self.responseSerializer = configuration.responseSerializer;
    }

    if (configuration.responseInterceptors) {
        self.responseInterceptors = configuration.responseInterceptors;
    }

    if (!self.retryHandler) {
        self.retryHandler = configuration.retryHandler;
    }
}

- (void)setTask:(NSURLSessionTask *)task {
    @synchronized(self) {
        if (!_cancelled) {
            _task = task;
        } else {
            _task = nil;
        }
    }
}

- (BOOL)isCancelled {
    @synchronized(self) {
        return _cancelled;
    }
}

- (void)cancel {
    @synchronized(self) {
        if (!_cancelled) {
            _cancelled = YES;
            [self.task cancel];
        }
    }
}

- (void)pause {
    @synchronized(self) {
        [self.task cancel];
    }
}

@end

@interface OOSRequest()

@property (nonatomic, assign) NSNumber *shouldWriteDirectly;

@end

@implementation OOSRequest

- (instancetype)init {
    if (self = [super init]) {
        _internalRequest = [OOSNetworkingRequest new];
    }

    return self;
}

- (void)setUploadProgress:(OOSNetworkingUploadProgressBlock)uploadProgress {
    self.internalRequest.uploadProgress = uploadProgress;
}

- (void)setDownloadProgress:(OOSNetworkingDownloadProgressBlock)downloadProgress {
    self.internalRequest.downloadProgress = downloadProgress;
}

- (BOOL)isCancelled {
    return [self.internalRequest isCancelled];
}

- (OOSTask *)cancel {
    [self.internalRequest cancel];
    return [OOSTask taskWithResult:nil];
}

- (OOSTask *)pause {
    [self.internalRequest pause];
    return [OOSTask taskWithResult:nil];
}

- (NSDictionary *)dictionaryValue {
    NSDictionary *dictionaryValue = [super dictionaryValue];
    NSMutableDictionary *mutableDictionaryValue = [dictionaryValue mutableCopy];

    [dictionaryValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"internalRequest"]) {
            [mutableDictionaryValue removeObjectForKey:key];
        }
    }];

    return mutableDictionaryValue;
}

@end

@interface OOSNetworkingRequestInterceptor()

@property (nonatomic, strong) NSString *userAgent;

@end

@implementation OOSNetworkingRequestInterceptor

- (instancetype)init {
    if (self = [super init]) {
        _userAgent = @"";
    }

    return self;
}

- (instancetype)initWithUserAgent:(NSString *)userAgent {
    if (self = [super init]) {
        _userAgent = userAgent;
    }

    return self;
}

- (OOSTask *)interceptRequest:(NSMutableURLRequest *)request {
    [request setValue:self.userAgent
   forHTTPHeaderField:@"User-Agent"];
    
    return [OOSTask taskWithResult:nil];
}

@end
