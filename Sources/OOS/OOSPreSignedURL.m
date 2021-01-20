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


#import "OOSPreSignedURL.h"
#import "OOSCategory.h"
#import "OOSSignature.h"
#import "OOSTask.h"
#import "OOSSynchronizedMutableDictionary.h"
#import <CommonCrypto/CommonCrypto.h>

NSString *const OOSPresignedURLErrorDomain = @"cn.ctyun.OOSPresignedURLErrorDomain";

static NSString *const OOSPreSignedURLBuilderAcceleratedEndpoint = @"-accelerate.ctyun.cn";

static NSString *const OOSInfoPreSignedURLBuilder = @"PreSignedURLBuilder";
static NSString *const OOSPreSignedURLBuilderSDKVersion = @"2.6.32";

@interface OOSPreSignedURLBuilder()

@property (nonatomic, strong) OOSServiceConfiguration *configuration;

@end

@interface OOSServiceConfiguration()

@property (nonatomic, strong) OOSEndpoint *endpoint;

@end

@interface OOSEndpoint()

- (void) setRegion:(OOSRegionType)regionType;

@end

@interface OOSGetPreSignedURLRequest ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *internalRequestParameters;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *internalRequestHeaders;
@property NSString *uploadID;
@property NSNumber *partNumber;
@end

@implementation OOSPreSignedURLBuilder

static OOSSynchronizedMutableDictionary *_serviceClients = nil;

+ (void)initialize {
    [super initialize];

    if (![OOSiOSSDKVersion isEqualToString:OOSPreSignedURLBuilderSDKVersion]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"OOSCore and OOS versions need to match. Check your SDK installation. OOSCore: %@ OOS: %@", OOSiOSSDKVersion, OOSPreSignedURLBuilderSDKVersion]
                                     userInfo:nil];
    }
}

+ (instancetype)defaultPreSignedURLBuilder {
    static OOSPreSignedURLBuilder *_defaultPreSignedURLBuilder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OOSServiceConfiguration *serviceConfiguration = [OOSServiceManager defaultServiceManager].defaultServiceConfiguration;

        if (!serviceConfiguration) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The service configuration is `nil`. You need to configure `Info.plist` or set `defaultServiceConfiguration` before using this method."
                                         userInfo:nil];
        }

        _defaultPreSignedURLBuilder = [[OOSPreSignedURLBuilder alloc] initWithConfiguration:serviceConfiguration];
    });

    return _defaultPreSignedURLBuilder;
}

+ (void)registerPreSignedURLBuilderWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [OOSSynchronizedMutableDictionary new];
    });
    [_serviceClients setObject:[[OOSPreSignedURLBuilder alloc] initWithConfiguration:configuration]
                        forKey:key];
}

+ (instancetype)PreSignedURLBuilderForKey:(NSString *)key {
    @synchronized(self) {
        OOSPreSignedURLBuilder *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }

        OOSServiceInfo *serviceInfo = [[OOSInfo defaultOOSInfo] serviceInfo:OOSInfoPreSignedURLBuilder
                                                                     forKey:key];
        if (serviceInfo) {
            OOSServiceConfiguration *serviceConfiguration = [[OOSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                                                        credentialsProvider:nil];
            [OOSPreSignedURLBuilder registerPreSignedURLBuilderWithConfiguration:serviceConfiguration
                                                                              forKey:key];
        }

        return [_serviceClients objectForKey:key];
    }
}

+ (void)removePreSignedURLBuilderForKey:(NSString *)key {
    [_serviceClients removeObjectForKey:key];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultPreSignedURLBuilder` or `+ PreSignedURLBuilderForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = [configuration copy];
        
        if(!configuration.endpoint){
            _configuration.endpoint = [[OOSEndpoint alloc] initWithRegion:_configuration.regionType
                                                             useUnsafeURL:NO];
        }else{
            [_configuration.endpoint setRegion:_configuration.regionType];
        }
    }

    return self;
}

- (OOSTask<NSURL *> *)getPreSignedURL:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest {
    //retrive parameters from request;
    NSString *bucketName = getPreSignedURLRequest.bucket;
    NSString *keyName = getPreSignedURLRequest.key;
	NSNumber *limitrate = getPreSignedURLRequest.limitrate;
    OOSHTTPMethod httpMethod = getPreSignedURLRequest.HTTPMethod;
    OOSServiceConfiguration *configuration = self.configuration;
    id<OOSCredentialsProvider>credentialsProvider = configuration.credentialsProvider;
    OOSEndpoint *endpoint = self.configuration.endpoint;
    BOOL isAccelerateModeEnabled = getPreSignedURLRequest.isAccelerateModeEnabled;

    NSDate *expires = getPreSignedURLRequest.expires;

    return [[[OOSTask taskWithResult:nil] continueWithBlock:^id(OOSTask *task) {

        //validate additionalParams
        for (id key in getPreSignedURLRequest.requestParameters) {
            id value = getPreSignedURLRequest.requestParameters[key];
            if (![key isKindOfClass:[NSString class]]
                || ![value isKindOfClass:[NSString class]]) {
                return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                                  code:OOSPresignedURLErrorInvalidRequestParameters
                                                              userInfo:@{NSLocalizedDescriptionKey: @"requestParameters can only contain key-value pairs in NSString type."}]
                        ];
            }
        }

        //validate endpoint
        if (!endpoint) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorEndpointIsNil
                                                          userInfo:@{NSLocalizedDescriptionKey: @"endpoint in configuration can not be nil"}]
                    ];
        }

        //validate credentialsProvider
        if (!credentialsProvider) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPreSignedURLErrorCredentialProviderIsNil
                                                          userInfo:@{NSLocalizedDescriptionKey: @"credentialsProvider in configuration can not be nil"}]
                    ];
        }

        //validate bucketName
        if (!bucketName || [bucketName length] < 1) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorBucketNameIsNil
                                                          userInfo:@{NSLocalizedDescriptionKey: @" bucket can not be nil or empty"}]];
        }

        // Validates the buket name for transfer acceleration.
        if (isAccelerateModeEnabled && ![bucketName OOS_isVirtualHostedStyleCompliant]) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorInvalidBucketNameForAccelerateModeEnabled
                                                          userInfo:@{
                                                                     NSLocalizedDescriptionKey: @"For your bucket to work with transfer acceleration, the bucket name must conform to DNS naming requirements and must not contain periods."}]];
        }

        //validate keyName
        if (!keyName || [keyName length] < 1) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorKeyNameIsNil
                                                          userInfo:@{NSLocalizedDescriptionKey: @" key can not be nil or empty"}]
                    ];
        }

        //validate expires Date
        if (!expires) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorInvalidExpiresDate
                                                          userInfo:@{NSLocalizedDescriptionKey: @"expires can not be nil"}]
                    ];
        }else if ([expires timeIntervalSinceNow] < 0.0) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorInvalidExpiresDate
                                                          userInfo:@{NSLocalizedDescriptionKey: @"expires can not be in past"}]
                    ];
        }

        //validate httpMethod
        switch (httpMethod) {
            case OOSHTTPMethodGET:
            case OOSHTTPMethodPUT:
            case OOSHTTPMethodHEAD:
            case OOSHTTPMethodDELETE:
                break;
            default:
                return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                                  code:OOSPresignedURLErrorUnsupportedHTTPVerbs
                                                              userInfo:@{NSLocalizedDescriptionKey: @"unsupported HTTP Method, currently only support OOSHTTPMethodGET, OOSHTTPMethodPUT, OOSHTTPMethodHEAD, OOSHTTPMethodDELETE"}]
                        ];
                break;
        }
		
		if (limitrate != nil && [limitrate integerValue] > 0) {
			[getPreSignedURLRequest setValue:[limitrate stringValue] forRequestParameter:@"x-amz-limitrate"];
		}

        return [[credentialsProvider credentials] continueWithSuccessBlock:^id _Nullable(OOSTask<OOSCredentials *> * _Nonnull task) {
            return credentialsProvider;
        }];
    }] continueWithSuccessBlock:^id _Nullable(OOSTask * _Nonnull task) {
        //generate baseURL String (use virtualHostStyle if possible)
        //base url is not url encoded.
        NSString *keyPath = nil;
        if (bucketName == nil || [bucketName OOS_isVirtualHostedStyleCompliant]) {
            keyPath = (keyName == nil ? @"" : [NSString stringWithFormat:@"%@", [keyName OOS_stringWithURLEncodingPath]]);
        } else {
            keyPath = (keyName == nil ? [NSString stringWithFormat:@"%@", bucketName] : [NSString stringWithFormat:@"%@/%@", bucketName, [keyName OOS_stringWithURLEncodingPath]]);
        }

        //generate correct hostName (use virtualHostStyle if possible)
        NSString *host = nil;
        if (bucketName && [bucketName OOS_isVirtualHostedStyleCompliant]) {
            if (isAccelerateModeEnabled) {
                host = [NSString stringWithFormat:@"%@.%@", bucketName, OOSPreSignedURLBuilderAcceleratedEndpoint];
            } else {
                host = [NSString stringWithFormat:@"%@.%@", bucketName, endpoint.hostName];
            }
        } else {
            host = endpoint.hostName;
        }
        [getPreSignedURLRequest setValue:host forRequestHeader:@"host"];
        
        //If this is a presigned request for a multipart upload, set the uploadID and partNumber on the request.
        if (getPreSignedURLRequest.uploadID
            && getPreSignedURLRequest.partNumber) {
            
            [getPreSignedURLRequest setValue:getPreSignedURLRequest.uploadID
                         forRequestParameter:@"uploadId"];
            
            [getPreSignedURLRequest setValue:[NSString stringWithFormat:@"%@", getPreSignedURLRequest.partNumber]
                         forRequestParameter:@"partNumber"];
        }
        
        OOSEndpoint *newEndpoint = [[OOSEndpoint alloc]initWithRegion:configuration.regionType URL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", endpoint.useUnsafeURL?@"http":@"https", host]]];
        
        int32_t expireDuration = [expires timeIntervalSinceNow];
        if (expireDuration > 604800) {
            return [OOSTask taskWithError:[NSError errorWithDomain:OOSPresignedURLErrorDomain
                                                              code:OOSPresignedURLErrorInvalidExpiresDate
                                                          userInfo:@{NSLocalizedDescriptionKey: @"Invalid ExpiresDate, must be less than seven days in future"}]
                    ];
        }

		return [OOSSignatureV4Signer  generateQueryStringForSignatureV4WithCredentialProvider:task.result
																				   httpMethod:httpMethod
																			   expireDuration:expireDuration
																					 endpoint:newEndpoint
																					  keyPath:keyPath
																			   requestHeaders:getPreSignedURLRequest.requestHeaders
																			requestParameters:getPreSignedURLRequest.requestParameters
																					 signBody:NO];
    }];
}

@end

@implementation OOSGetPreSignedURLRequest

- (instancetype)init {
    if ( self = [super init] ) {
        _accelerateModeEnabled = NO;
        _minimumCredentialsExpirationInterval = 50 * 60;
        _internalRequestParameters = [NSMutableDictionary<NSString *, NSString *> new];
        _internalRequestHeaders = [NSMutableDictionary<NSString *, NSString *> new];
    }
    return self;
}

- (NSDictionary<NSString *, NSString *> *)requestHeaders {
    return [NSDictionary dictionaryWithDictionary:self.internalRequestHeaders];
}

- (NSDictionary<NSString *, NSString *> *)requestParameters {
    return [NSDictionary dictionaryWithDictionary:self.internalRequestParameters];
}

- (NSString *)contentType {
    return [self.internalRequestHeaders objectForKey:@"Content-Type"];
}

- (void)setContentType:(NSString *)contentType {
    [self setValue:contentType forRequestHeader:@"Content-Type"];
}

- (NSString *)contentMD5 {
    return [self.internalRequestHeaders objectForKey:@"Content-MD5"];
}

- (void)setContentMD5:(NSString *)contentMD5 {
    [self setValue:contentMD5 forRequestHeader:@"Content-MD5"];
}

- (void)setValue:(NSString * _Nullable)value forRequestHeader:(NSString *)requestHeader {
    [self.internalRequestHeaders setValue:value forKey:requestHeader];
}

- (void)setValue:(NSString * _Nullable)value forRequestParameter:(NSString *)requestParameter {
    [self.internalRequestParameters setValue:value forKey:requestParameter];
}

@end
