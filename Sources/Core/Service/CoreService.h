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
#import "OOSNetworking.h"
#import "OOSCredentialsProvider.h"
#import "OOSServiceEnum.h"

FOUNDATION_EXPORT NSString *const OOSiOSSDKVersion;

FOUNDATION_EXPORT NSString *const OOSServiceErrorDomain;

typedef NS_ENUM(NSInteger, OOSServiceErrorType) {
    OOSServiceErrorUnknown,
    OOSServiceErrorRequestTimeTooSkewed,
    OOSServiceErrorInvalidSignatureException,
    OOSServiceErrorSignatureDoesNotMatch,
    OOSServiceErrorRequestExpired,
    OOSServiceErrorAuthFailure,
    OOSServiceErrorAccessDeniedException,
    OOSServiceErrorUnrecognizedClientException,
    OOSServiceErrorIncompleteSignature,
    OOSServiceErrorInvalidClientTokenId,
    OOSServiceErrorMissingAuthenticationToken,
    OOSServiceErrorAccessDenied,
    OOSServiceErrorExpiredToken,
    OOSServiceErrorInvalidAccessKeyId,
    OOSServiceErrorInvalidToken,
    OOSServiceErrorTokenRefreshRequired,
    OOSServiceErrorAccessFailure,
    OOSServiceErrorAuthMissingFailure,
    OOSServiceErrorThrottling,
    OOSServiceErrorThrottlingException,
};


#pragma mark - CoreService

@class OOSEndpoint;

/**
 An abstract representation of OOS services.
 */
@interface CoreService : NSObject

+ (NSDictionary<NSString *, NSNumber *> *)errorCodeDictionary;

@end

#pragma mark - OOSServiceManager

@class OOSServiceConfiguration;

/**
 The service manager class that manages the default service configuration.
 */
@interface OOSServiceManager : NSObject

/**
 The default service configuration object. This property can be set only once, and any subsequent setters are ignored.
 */
@property (nonatomic, copy) OOSServiceConfiguration *defaultServiceConfiguration;

/**
 Returns a default singleton object. You should use this singleton method instead of creating an instance of the service manager.
 
 @return The default service manager. This is a singleton object.
 */
+ (instancetype)defaultServiceManager;

@end

#pragma mark - OOSServiceConfiguration

/**
 A service configuration object.
 */
@interface OOSServiceConfiguration : OOSNetworkingConfiguration

@property (nonatomic, assign, readonly) OOSRegionType regionType;
@property (nonatomic, strong, readonly) id<OOSCredentialsProvider> credentialsProvider;
@property (nonatomic, strong, readonly) OOSEndpoint *endpoint;
@property (nonatomic, readonly) NSString *userAgent;
@property (nonatomic, assign) BOOL useV4Signer;	// 是否使用V4签名，默认YES

+ (NSString *)baseUserAgent;

+ (void)addGlobalUserAgentProductToken:(NSString *)productToken;

- (instancetype)initWithRegion:(OOSRegionType)regionType
		   credentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider;

- (instancetype)initWithRegion:(OOSRegionType)regionType
					  endpoint:(OOSEndpoint *)endpoint
		   credentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider;

- (void)addUserAgentProductToken:(NSString *)productToken;

@end


#pragma mark - OOSEndpoint

@interface OOSEndpoint : NSObject

@property (nonatomic, readonly) OOSRegionType regionType;
@property (nonatomic, readonly) NSString *regionName;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSURL *IAMURL;
@property (nonatomic, readonly) NSString *hostName;
@property (nonatomic, readonly) BOOL useUnsafeURL;
@property (nonatomic, strong) NSString *serviceName;	// 可以更改。现支持s3 / sts 两种
@property (nonatomic, assign) BOOL useV6Version;	// 是否使用V6版本的API，默认YES

- (instancetype)initWithRegion:(OOSRegionType)regionType;

- (instancetype)initWithRegion:(OOSRegionType)regionType
                  useUnsafeURL:(BOOL)useUnsafeURL;

- (instancetype)initWithRegion:(OOSRegionType)regionType
                           URL:(NSURL *)URL;

- (instancetype)initWithURL:(NSURL *)URL;

- (instancetype)initWithURLString:(NSString *)URLString;

@end
