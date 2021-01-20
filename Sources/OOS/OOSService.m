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

#import "OOSService.h"
#import "OOSNetworking.h"
#import "OOSCategory.h"
#import "OOSSignature.h"
#import "CoreService.h"
#import "OOSInfo.h"
#import "OOSURLRequestSerialization.h"
#import "OOSURLResponseSerialization.h"
#import "OOSURLRequestRetryHandler.h"
#import "OOSSynchronizedMutableDictionary.h"
#import "OOSResources.h"
#import "OOSRequestRetryHandler.h"
#import "OOSSerializer.h"
#import "OOSModel.h"
#import "OOSTask.h"

static NSString *const OOSInfoString = @"OOS";
static NSString *const OOSSDKVersion = @"2.6.32";

@interface OOS()

@property (nonatomic, strong) OOSNetworking *networking;
@property (nonatomic, strong) OOSServiceConfiguration *configuration;

@end

@interface OOSServiceConfiguration()

@property (nonatomic, strong) OOSEndpoint *endpoint;

@end

@interface OOSEndpoint()

- (void) setRegion:(OOSRegionType)regionType;

@end

@implementation OOS

+ (void)initialize {
    [super initialize];

    if (![OOSiOSSDKVersion isEqualToString:OOSSDKVersion]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"OOSCore and OOS versions need to match. Check your SDK installation. OOSCore: %@ OOS: %@", OOSiOSSDKVersion, OOSSDKVersion]
                                     userInfo:nil];
    }
}

#pragma mark - Setup

static OOSSynchronizedMutableDictionary *_serviceClients = nil;

+ (instancetype)defaultOOS {
    static OOS *_default = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OOSServiceConfiguration *serviceConfiguration = [OOSServiceManager defaultServiceManager].defaultServiceConfiguration;

        if (!serviceConfiguration) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The service configuration is `nil`. You need to configure `OOSconfiguration.json`, `Info.plist` or set `defaultServiceConfiguration` before using this method."
                                         userInfo:nil];
        }
        _default = [[OOS alloc] initWithConfiguration:serviceConfiguration];
    });

    return _default;
}

+ (void)registerWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [OOSSynchronizedMutableDictionary new];
    });
    [_serviceClients setObject:[[OOS alloc] initWithConfiguration:configuration]
                        forKey:key];
}

+ (instancetype)ForKey:(NSString *)key {
    @synchronized(self) {
        OOS *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }

        OOSServiceInfo *serviceInfo = [[OOSInfo defaultOOSInfo] serviceInfo:OOSInfoString
                                                                     forKey:key];
        if (serviceInfo) {
            OOSServiceConfiguration *serviceConfiguration = [[OOSServiceConfiguration alloc] initWithRegion:serviceInfo.region credentialsProvider:nil];
            [OOS registerWithConfiguration:serviceConfiguration forKey:key];
        }

        return [_serviceClients objectForKey:key];
    }
}

+ (void)removeForKey:(NSString *)key {
    [_serviceClients removeObjectForKey:key];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultOOS` or `+ ForKey:` instead."
                                 userInfo:nil];
    return nil;
}

#pragma mark -

- (instancetype)initWithConfiguration:(OOSServiceConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = [configuration copy];
       	
        if(!configuration.endpoint){
            _configuration.endpoint = [[OOSEndpoint alloc] initWithRegion:_configuration.regionType
                                                         useUnsafeURL:NO];
        }else{
            [_configuration.endpoint setRegion:_configuration.regionType];
        }
       	

		id<OOSNetworkingRequestInterceptor> signer;
		if (_configuration.useV4Signer) {
			signer = [[OOSSignatureV4Signer alloc] initWithCredentialsProvider:_configuration.credentialsProvider
																							endpoint:_configuration.endpoint];
		} else {
			signer = [[OOSSignatureV2Signer alloc] initWithCredentialsProvider:_configuration.credentialsProvider
																							endpoint:_configuration.endpoint];
		}
		
        OOSNetworkingRequestInterceptor *baseInterceptor = [[OOSNetworkingRequestInterceptor alloc] initWithUserAgent:_configuration.userAgent];
        _configuration.requestInterceptors = @[baseInterceptor, signer];

        _configuration.baseURL = _configuration.endpoint.URL;
        _configuration.retryHandler = [[OOSRequestRetryHandler alloc] initWithMaximumRetryCount:_configuration.maxRetryCount];
		
        _networking = [[OOSNetworking alloc] initWithConfiguration:_configuration];
    }
    
    return self;
}

- (OOSTask *)invokeRequest:(OOSRequest *)request
               HTTPMethod:(OOSHTTPMethod)HTTPMethod
                URLString:(NSString *) URLString
			   hostPrefix:(NSString *)hostPrefix
            operationName:(NSString *)operationName
              outputClass:(Class)outputClass {
    
    @autoreleasepool {
        if (!request) {
            request = [OOSRequest new];
        }

        OOSNetworkingRequest *networkingRequest = request.internalRequest;
        if (request) {
            networkingRequest.parameters = [[OOSMTLJSONAdapter JSONDictionaryFromModel:request] OOS_removeNullValues];
        } else {
            networkingRequest.parameters = @{};
        }
        networkingRequest.shouldWriteDirectly = [[request valueForKey:@"shouldWriteDirectly"] boolValue];
        networkingRequest.downloadingFileURL = request.downloadingFileURL;

		if (hostPrefix && ![hostPrefix isEqualToString:@""]) {
			NSURL *baseURL = _configuration.baseURL;
			if (baseURL != nil) {
				NSString *newHost = [NSString stringWithFormat:@"%@.%@", hostPrefix, baseURL.host];
				NSString *baseURLString = [baseURL.absoluteString stringByReplacingOccurrencesOfString:baseURL.host withString:newHost];
				networkingRequest.baseURL = [NSURL URLWithString:baseURLString];
			}
		} else if ([operationName isEqualToString:@"CreateAccessKey"] ||
				   [operationName isEqualToString:@"UpdateAccessKey"] ||
				   [operationName isEqualToString:@"ListAccessKey"] ||
				   [operationName isEqualToString:@"DeleteAccessKey"]) {
			_configuration.endpoint.serviceName = @"sts";
			networkingRequest.baseURL = _configuration.endpoint.IAMURL;
		}
		
        networkingRequest.HTTPMethod = HTTPMethod;
		networkingRequest.requestSerializer = [[OOSRequestSerializer alloc] initWithJSONDefinition:[[OOSResources sharedInstance] JSONObject]
		 															     actionName:operationName];
        networkingRequest.responseSerializer = [[OOSResponseSerializer alloc] initWithJSONDefinition:[[OOSResources sharedInstance] JSONObject]
                                                                                             actionName:operationName
                                                                                            outputClass:outputClass];
        
        return [self.networking sendRequest:networkingRequest];
    }
}

#pragma mark - Service method

- (OOSTask<OOSAbortMultipartUploadOutput *> *)abortMultipartUpload:(OOSAbortMultipartUploadRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"AbortMultipartUpload"
                   outputClass:[OOSAbortMultipartUploadOutput class]];
}

- (void)abortMultipartUpload:(OOSAbortMultipartUploadRequest *)request
     completionHandler:(void (^)(OOSAbortMultipartUploadOutput *response, NSError *error))completionHandler {
    [[self abortMultipartUpload:request] continueWithBlock:^id _Nullable(OOSTask<OOSAbortMultipartUploadOutput *> * _Nonnull task) {
        OOSAbortMultipartUploadOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSCompleteMultipartUploadOutput *> *)completeMultipartUpload:(OOSCompleteMultipartUploadRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPOST
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"CompleteMultipartUpload"
                   outputClass:[OOSCompleteMultipartUploadOutput class]];
}

- (void)completeMultipartUpload:(OOSCompleteMultipartUploadRequest *)request
     completionHandler:(void (^)(OOSCompleteMultipartUploadOutput *response, NSError *error))completionHandler {
    [[self completeMultipartUpload:request] continueWithBlock:^id _Nullable(OOSTask<OOSCompleteMultipartUploadOutput *> * _Nonnull task) {
        OOSCompleteMultipartUploadOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSCreateBucketOutput *> *)createBucket:(OOSCreateBucketRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/"
                  	hostPrefix:request.bucket
                 operationName:@"CreateBucket"
                   outputClass:[OOSCreateBucketOutput class]];
}

- (void)createBucket:(OOSCreateBucketRequest *)request
     completionHandler:(void (^)(OOSCreateBucketOutput *response, NSError *error))completionHandler {
    [[self createBucket:request] continueWithBlock:^id _Nullable(OOSTask<OOSCreateBucketOutput *> * _Nonnull task) {
        OOSCreateBucketOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSCreateMultipartUploadOutput *> *)createMultipartUpload:(OOSCreateMultipartUploadRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPOST
                     URLString:@"/{Bucket}/{Key+}?uploads"
                  hostPrefix:@""
                 operationName:@"CreateMultipartUpload"
                   outputClass:[OOSCreateMultipartUploadOutput class]];
}

- (void)createMultipartUpload:(OOSCreateMultipartUploadRequest *)request
     completionHandler:(void (^)(OOSCreateMultipartUploadOutput *response, NSError *error))completionHandler {
    [[self createMultipartUpload:request] continueWithBlock:^id _Nullable(OOSTask<OOSCreateMultipartUploadOutput *> * _Nonnull task) {
        OOSCreateMultipartUploadOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask *)deleteBucket:(OOSDeleteBucketRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}"
                  hostPrefix:@""
                 operationName:@"DeleteBucket"
                   outputClass:nil];
}

- (void)deleteBucket:(OOSDeleteBucketRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self deleteBucket:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)deleteBucketCors:(OOSDeleteBucketCorsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}?cors"
                  hostPrefix:@""
                 operationName:@"DeleteBucketCors"
                   outputClass:nil];
}

- (void)deleteBucketCors:(OOSDeleteBucketCorsRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self deleteBucketCors:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)deleteBucketLifecycle:(OOSDeleteBucketLifecycleRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}?lifecycle"
                  hostPrefix:@""
                 operationName:@"DeleteBucketLifecycle"
                   outputClass:nil];
}

- (void)deleteBucketLifecycle:(OOSDeleteBucketLifecycleRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self deleteBucketLifecycle:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)deleteBucketPolicy:(OOSDeleteBucketPolicyRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}?policy"
                  hostPrefix:@""
                 operationName:@"DeleteBucketPolicy"
                   outputClass:nil];
}

- (void)deleteBucketPolicy:(OOSDeleteBucketPolicyRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self deleteBucketPolicy:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)deleteBucketWebsite:(OOSDeleteBucketWebsiteRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}?website"
                  hostPrefix:@""
                 operationName:@"DeleteBucketWebsite"
                   outputClass:nil];
}

- (void)deleteBucketWebsite:(OOSDeleteBucketWebsiteRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self deleteBucketWebsite:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask<OOSDeleteObjectOutput *> *)deleteObject:(OOSDeleteObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodDELETE
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"DeleteObject"
                   outputClass:[OOSDeleteObjectOutput class]];
}

- (void)deleteObject:(OOSDeleteObjectRequest *)request
     completionHandler:(void (^)(OOSDeleteObjectOutput *response, NSError *error))completionHandler {
    [[self deleteObject:request] continueWithBlock:^id _Nullable(OOSTask<OOSDeleteObjectOutput *> * _Nonnull task) {
        OOSDeleteObjectOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSDeleteObjectsOutput *> *)deleteObjects:(OOSDeleteObjectsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPOST
                     URLString:@"/{Bucket}/?delete"
                  hostPrefix:@""
                 operationName:@"DeleteObjects"
                   outputClass:[OOSDeleteObjectsOutput class]];
}

- (void)deleteObjects:(OOSDeleteObjectsRequest *)request
     completionHandler:(void (^)(OOSDeleteObjectsOutput *response, NSError *error))completionHandler {
    [[self deleteObjects:request] continueWithBlock:^id _Nullable(OOSTask<OOSDeleteObjectsOutput *> * _Nonnull task) {
        OOSDeleteObjectsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketAclOutput *> *)getBucketAcl:(OOSGetBucketAclRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?acl"
                  hostPrefix:@""
                 operationName:@"GetBucketAcl"
                   outputClass:[OOSGetBucketAclOutput class]];
}

- (void)getBucketAcl:(OOSGetBucketAclRequest *)request
     completionHandler:(void (^)(OOSGetBucketAclOutput *response, NSError *error))completionHandler {
    [[self getBucketAcl:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketAclOutput *> * _Nonnull task) {
        OOSGetBucketAclOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketCorsOutput *> *)getBucketCors:(OOSGetBucketCorsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?cors"
                  hostPrefix:@""
                 operationName:@"GetBucketCors"
                   outputClass:[OOSGetBucketCorsOutput class]];
}

- (void)getBucketCors:(OOSGetBucketCorsRequest *)request
     completionHandler:(void (^)(OOSGetBucketCorsOutput *response, NSError *error))completionHandler {
    [[self getBucketCors:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketCorsOutput *> * _Nonnull task) {
        OOSGetBucketCorsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketLifecycleOutput *> *)getBucketLifecycle:(OOSGetBucketLifecycleRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?lifecycle"
                  hostPrefix:@""
                 operationName:@"GetBucketLifecycle"
                   outputClass:[OOSGetBucketLifecycleOutput class]];
}

- (void)getBucketLifecycle:(OOSGetBucketLifecycleRequest *)request
     completionHandler:(void (^)(OOSGetBucketLifecycleOutput *response, NSError *error))completionHandler {
    [[self getBucketLifecycle:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketLifecycleOutput *> * _Nonnull task) {
        OOSGetBucketLifecycleOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketLifecycleConfigurationOutput *> *)getBucketLifecycleConfiguration:(OOSGetBucketLifecycleConfigurationRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?lifecycle"
                  hostPrefix:@""
                 operationName:@"GetBucketLifecycleConfiguration"
                   outputClass:[OOSGetBucketLifecycleConfigurationOutput class]];
}

- (void)getBucketLifecycleConfiguration:(OOSGetBucketLifecycleConfigurationRequest *)request
     completionHandler:(void (^)(OOSGetBucketLifecycleConfigurationOutput *response, NSError *error))completionHandler {
    [[self getBucketLifecycleConfiguration:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketLifecycleConfigurationOutput *> * _Nonnull task) {
        OOSGetBucketLifecycleConfigurationOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketLoggingOutput *> *)getBucketLogging:(OOSGetBucketLoggingRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?logging"
                  hostPrefix:@""
                 operationName:@"GetBucketLogging"
                   outputClass:[OOSGetBucketLoggingOutput class]];
}

- (void)getBucketLogging:(OOSGetBucketLoggingRequest *)request
     completionHandler:(void (^)(OOSGetBucketLoggingOutput *response, NSError *error))completionHandler {
    [[self getBucketLogging:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketLoggingOutput *> * _Nonnull task) {
        OOSGetBucketLoggingOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketPolicyOutput *> *)getBucketPolicy:(OOSGetBucketPolicyRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?policy"
                  hostPrefix:@""
                 operationName:@"GetBucketPolicy"
                   outputClass:[OOSGetBucketPolicyOutput class]];
}

- (void)getBucketPolicy:(OOSGetBucketPolicyRequest *)request
     completionHandler:(void (^)(OOSGetBucketPolicyOutput *response, NSError *error))completionHandler {
    [[self getBucketPolicy:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketPolicyOutput *> * _Nonnull task) {
        OOSGetBucketPolicyOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetBucketWebsiteOutput *> *)getBucketWebsite:(OOSGetBucketWebsiteRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?website"
                  hostPrefix:@""
                 operationName:@"GetBucketWebsite"
                   outputClass:[OOSGetBucketWebsiteOutput class]];
}

- (void)getBucketWebsite:(OOSGetBucketWebsiteRequest *)request
     completionHandler:(void (^)(OOSGetBucketWebsiteOutput *response, NSError *error))completionHandler {
    [[self getBucketWebsite:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketWebsiteOutput *> * _Nonnull task) {
        OOSGetBucketWebsiteOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSGetObjectOutput *> *)getObject:(OOSGetObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"GetObject"
                   outputClass:[OOSGetObjectOutput class]];
}

- (void)getObject:(OOSGetObjectRequest *)request
     completionHandler:(void (^)(OOSGetObjectOutput *response, NSError *error))completionHandler {
    [[self getObject:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetObjectOutput *> * _Nonnull task) {
        OOSGetObjectOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask *)headBucket:(OOSHeadBucketRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodHEAD
                     URLString:@"/{Bucket}"
                  hostPrefix:@""
                 operationName:@"HeadBucket"
                   outputClass:nil];
}

- (void)headBucket:(OOSHeadBucketRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self headBucket:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask<OOSListBucketsOutput *> *)listBuckets:(OOSRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@""
                  hostPrefix:@""
                 operationName:@"ListBuckets"
                   outputClass:[OOSListBucketsOutput class]];
}

- (void)listBuckets:(OOSRequest *)request
     completionHandler:(void (^)(OOSListBucketsOutput *response, NSError *error))completionHandler {
    [[self listBuckets:request] continueWithBlock:^id _Nullable(OOSTask<OOSListBucketsOutput *> * _Nonnull task) {
        OOSListBucketsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSListMultipartUploadsOutput *> *)listMultipartUploads:(OOSListMultipartUploadsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?uploads"
                  hostPrefix:@""
                 operationName:@"ListMultipartUploads"
                   outputClass:[OOSListMultipartUploadsOutput class]];
}

- (void)listMultipartUploads:(OOSListMultipartUploadsRequest *)request
     completionHandler:(void (^)(OOSListMultipartUploadsOutput *response, NSError *error))completionHandler {
    [[self listMultipartUploads:request] continueWithBlock:^id _Nullable(OOSTask<OOSListMultipartUploadsOutput *> * _Nonnull task) {
        OOSListMultipartUploadsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSListObjectVersionsOutput *> *)listObjectVersions:(OOSListObjectVersionsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}?versions"
                  hostPrefix:@""
                 operationName:@"ListObjectVersions"
                   outputClass:[OOSListObjectVersionsOutput class]];
}

- (void)listObjectVersions:(OOSListObjectVersionsRequest *)request
     completionHandler:(void (^)(OOSListObjectVersionsOutput *response, NSError *error))completionHandler {
    [[self listObjectVersions:request] continueWithBlock:^id _Nullable(OOSTask<OOSListObjectVersionsOutput *> * _Nonnull task) {
        OOSListObjectVersionsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSListObjectsOutput *> *)listObjects:(OOSListObjectsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}"
                  hostPrefix:@""
                 operationName:@"ListObjects"
                   outputClass:[OOSListObjectsOutput class]];
}

- (void)listObjects:(OOSListObjectsRequest *)request
     completionHandler:(void (^)(OOSListObjectsOutput *response, NSError *error))completionHandler {
    [[self listObjects:request] continueWithBlock:^id _Nullable(OOSTask<OOSListObjectsOutput *> * _Nonnull task) {
        OOSListObjectsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSListPartsOutput *> *)listParts:(OOSListPartsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodGET
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"ListParts"
                   outputClass:[OOSListPartsOutput class]];
}

- (void)listParts:(OOSListPartsRequest *)request
     completionHandler:(void (^)(OOSListPartsOutput *response, NSError *error))completionHandler {
    [[self listParts:request] continueWithBlock:^id _Nullable(OOSTask<OOSListPartsOutput *> * _Nonnull task) {
        OOSListPartsOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketAcl:(OOSPutBucketAclRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?acl"
                  hostPrefix:@""
                 operationName:@"PutBucketAcl"
                   outputClass:nil];
}

- (void)putBucketAcl:(OOSPutBucketAclRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketAcl:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketCors:(OOSPutBucketCorsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?cors"
                  hostPrefix:@""
                 operationName:@"PutBucketCors"
                   outputClass:nil];
}

- (void)putBucketCors:(OOSPutBucketCorsRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketCors:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketLifecycle:(OOSPutBucketLifecycleRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?lifecycle"
                  hostPrefix:@""
                 operationName:@"PutBucketLifecycle"
                   outputClass:nil];
}

- (void)putBucketLifecycle:(OOSPutBucketLifecycleRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketLifecycle:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketLifecycleConfiguration:(OOSPutBucketLifecycleConfigurationRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?lifecycle"
                  hostPrefix:@""
                 operationName:@"PutBucketLifecycleConfiguration"
                   outputClass:nil];
}

- (void)putBucketLifecycleConfiguration:(OOSPutBucketLifecycleConfigurationRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketLifecycleConfiguration:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketLogging:(OOSPutBucketLoggingRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?logging"
                  hostPrefix:@""
                 operationName:@"PutBucketLogging"
                   outputClass:nil];
}

- (void)putBucketLogging:(OOSPutBucketLoggingRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketLogging:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketPolicy:(OOSPutBucketPolicyRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?policy"
                  hostPrefix:@""
                 operationName:@"PutBucketPolicy"
                   outputClass:nil];
}

- (void)putBucketPolicy:(OOSPutBucketPolicyRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketPolicy:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask *)putBucketWebsite:(OOSPutBucketWebsiteRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}?website"
                  hostPrefix:@""
                 operationName:@"PutBucketWebsite"
                   outputClass:nil];
}

- (void)putBucketWebsite:(OOSPutBucketWebsiteRequest *)request
     completionHandler:(void (^)(NSError *error))completionHandler {
    [[self putBucketWebsite:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(error);
        }

        return nil;
    }];
}

- (OOSTask<OOSPutObjectOutput *> *)putObject:(OOSPutObjectRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"PutObject"
                   outputClass:[OOSPutObjectOutput class]];
}

- (void)putObject:(OOSPutObjectRequest *)request
     completionHandler:(void (^)(OOSPutObjectOutput *response, NSError *error))completionHandler {
    [[self putObject:request] continueWithBlock:^id _Nullable(OOSTask<OOSPutObjectOutput *> * _Nonnull task) {
        OOSPutObjectOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSUploadPartOutput *> *)uploadPart:(OOSUploadPartRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"UploadPart"
                   outputClass:[OOSUploadPartOutput class]];
}

- (void)uploadPart:(OOSUploadPartRequest *)request
     completionHandler:(void (^)(OOSUploadPartOutput *response, NSError *error))completionHandler {
    [[self uploadPart:request] continueWithBlock:^id _Nullable(OOSTask<OOSUploadPartOutput *> * _Nonnull task) {
        OOSUploadPartOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSUploadPartCopyOutput *> *)uploadPartCopy:(OOSUploadPartCopyRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:OOSHTTPMethodPUT
                     URLString:@"/{Bucket}/{Key+}"
                  hostPrefix:@""
                 operationName:@"UploadPartCopy"
                   outputClass:[OOSUploadPartCopyOutput class]];
}

- (void)uploadPartCopy:(OOSUploadPartCopyRequest *)request
     completionHandler:(void (^)(OOSUploadPartCopyOutput *response, NSError *error))completionHandler {
    [[self uploadPartCopy:request] continueWithBlock:^id _Nullable(OOSTask<OOSUploadPartCopyOutput *> * _Nonnull task) {
        OOSUploadPartCopyOutput *result = task.result;
        NSError *error = task.error;

        if (completionHandler) {
            completionHandler(result, error);
        }

        return nil;
    }];
}

- (OOSTask<OOSCopyObjectOutput *> *)copyObject:(OOSCopyObjectRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodPUT
					 URLString:@"/{Bucket}/{Key+}"
				    hostPrefix:@""
				 operationName:@"CopyObject"
				   outputClass:[OOSCopyObjectOutput class]];
}

- (void)copyObject:(OOSCopyObjectRequest *)request
	  completionHandler:(void (^)(OOSCopyObjectOutput *response, NSError *error))completionHandler {
	[[self copyObject:request] continueWithBlock:^id _Nullable(OOSTask<OOSCopyObjectOutput *> * _Nonnull task) {
		OOSCopyObjectOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

#pragma mark AccessKey

- (OOSTask *)createAccessKey:(OOSCreateAccessKeyRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodPOST
					 URLString:@"/"
					hostPrefix:@""
				 operationName:@"CreateAccessKey"
				   outputClass:[OOSCreateAccessKeyOutput class]];
}

- (void)createAccessKey:(OOSCreateAccessKeyRequest *)request
	  completionHandler:(void (^ _Nullable)(OOSCreateAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler {
	[[self createAccessKey:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
		OOSCreateAccessKeyOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

- (OOSTask *)deleteAccessKey:(OOSDeleteAccessKeyRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodPOST
					 URLString:@"/"
					hostPrefix:@""
				 operationName:@"DeleteAccessKey"
				   outputClass:[OOSDeleteAccessKeyOutput class]];
}

- (void)deleteAccessKey:(OOSDeleteAccessKeyRequest *)request
	  completionHandler:(void (^ _Nullable)(OOSDeleteAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler {
	[[self deleteAccessKey:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
		OOSDeleteAccessKeyOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

- (OOSTask *)updateAccessKey:(OOSUpdateAccessKeyRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodPOST
					 URLString:@"/"
					hostPrefix:@""
				 operationName:@"UpdateAccessKey"
				   outputClass:[OOSUpdateAccessKeyOutput class]];
}

- (void)updateAccessKey:(OOSUpdateAccessKeyRequest *)request
	  completionHandler:(void (^ _Nullable)(OOSUpdateAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler {
	[[self updateAccessKey:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
		OOSUpdateAccessKeyOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

- (OOSTask *)listAccessKey:(OOSListAccessKeyRequest *)request {
//	return [self invokeRequest:request
//					HTTPMethod:OOSHTTPMethodPOST
//					 URLString:@"/?Action=ListAccessKey"
//					hostPrefix:@""
//				 operationName:@"ListAccessKey"
//				   outputClass:[OOSListAccessKeyOutput class]];
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodPOST
					 URLString:@"/"
					hostPrefix:@""
				 operationName:@"ListAccessKey"
				   outputClass:[OOSListAccessKeyOutput class]];
}

- (void)listAccessKey:(OOSListAccessKeyRequest *)request
	completionHandler:(void (^ _Nullable)(OOSListAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler {
	[[self listAccessKey:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
		OOSListAccessKeyOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

- (OOSTask<OOSGetRegionsOutput *> *)getRegions:(OOSGetRegionsRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodGET
					 URLString:@"/?regions"
					hostPrefix:@""
				 operationName:@"GetRegions"
				   outputClass:[OOSGetRegionsOutput class]];
}

- (void)getRegions:(OOSGetRegionsRequest *)request
		completionHandler:(void (^)(OOSGetRegionsOutput *response, NSError *error))completionHandler {
	[[self getRegions:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetRegionsOutput *> * _Nonnull task) {
		OOSGetRegionsOutput *result = task.result;
		NSError *error = task.error;

		if (completionHandler) {
			completionHandler(result, error);
		}

		return nil;
	}];
}

- (OOSTask<OOSGetBucketLocationOutput *> *)getBucketLocation:(OOSGetBucketLocationRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodGET
					 URLString:@"/{Bucket}?location"
				  	hostPrefix:@""
				 operationName:@"GetBucketLocation"
				   outputClass:[OOSGetBucketLocationOutput class]];
}

- (void)getBucketLocation:(OOSGetBucketLocationRequest *)request
		completionHandler:(void (^)(OOSGetBucketLocationOutput *response, NSError *error))completionHandler {
	[[self getBucketLocation:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketLocationOutput *> * _Nonnull task) {
		OOSGetBucketLocationOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

- (OOSTask<OOSGetBucketAccelerateConfigurationOutput *> *)getBucketAccelerateConfiguration:(OOSGetBucketAccelerateConfigurationRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodGET
					 URLString:@"/{Bucket}?accelerate"
				  hostPrefix:@""
				 operationName:@"GetBucketAccelerateConfiguration"
				   outputClass:[OOSGetBucketAccelerateConfigurationOutput class]];
}

- (void)getBucketAccelerateConfiguration:(OOSGetBucketAccelerateConfigurationRequest *)request
					   completionHandler:(void (^)(OOSGetBucketAccelerateConfigurationOutput *response, NSError *error))completionHandler {
	[[self getBucketAccelerateConfiguration:request] continueWithBlock:^id _Nullable(OOSTask<OOSGetBucketAccelerateConfigurationOutput *> * _Nonnull task) {
		OOSGetBucketAccelerateConfigurationOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

- (OOSTask *)putBucketAccelerateConfiguration:(OOSPutBucketAccelerateConfigurationRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodPUT
					 URLString:@"/{Bucket}?accelerate"
				  hostPrefix:@""
				 operationName:@"PutBucketAccelerateConfiguration"
				   outputClass:nil];
}

- (void)putBucketAccelerateConfiguration:(OOSPutBucketAccelerateConfigurationRequest *)request
					   completionHandler:(void (^)(NSError *error))completionHandler {
	[[self putBucketAccelerateConfiguration:request] continueWithBlock:^id _Nullable(OOSTask * _Nonnull task) {
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(error);
		}
		
		return nil;
	}];
}

- (OOSTask<OOSHeadObjectOutput *> *)headObject:(OOSHeadObjectRequest *)request {
	return [self invokeRequest:request
					HTTPMethod:OOSHTTPMethodHEAD
					 URLString:@"/{Bucket}/{Key+}"
				  hostPrefix:@""
				 operationName:@"HeadObject"
				   outputClass:[OOSHeadObjectOutput class]];
}

- (void)headObject:(OOSHeadObjectRequest *)request
 completionHandler:(void (^)(OOSHeadObjectOutput *response, NSError *error))completionHandler {
	[[self headObject:request] continueWithBlock:^id _Nullable(OOSTask<OOSHeadObjectOutput *> * _Nonnull task) {
		OOSHeadObjectOutput *result = task.result;
		NSError *error = task.error;
		
		if (completionHandler) {
			completionHandler(result, error);
		}
		
		return nil;
	}];
}

@end
