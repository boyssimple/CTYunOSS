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
#import "OOSModel.h"
#import "OOSResources.h"
#import "OOSNetworking.h"
#import "OOSCategory.h"
#import "OOSSignature.h"
#import "CoreService.h"
#import "OOSTask.h"
#import "OOSServiceEnum.h"
#import "OOSInfo.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const OOSPresignedURLVersionID = @"versionId";
static NSString *const OOSPresignedURLTorrent = @"torrent";

static NSString *const OOSPresignedURLServerSideEncryption = @"x-amz-server-side-encryption";
static NSString *const OOSPresignedURLServerSideEncryptionCustomerAlgorithm = @"x-amz-server-side-encryption-customer-algorithm";
static NSString *const OOSPresignedURLServerSideEncryptionCustomerKey = @"x-amz-server-side-encryption-customer-key";
static NSString *const OOSPresignedURLServerSdieEncryptionCustomerKeyMD5 = @"x-amz-server-side-encryption-customer-key-MD5";


FOUNDATION_EXPORT NSString *const OOSPresignedURLErrorDomain;
typedef NS_ENUM(NSInteger, OOSPresignedURLErrorType) {
    OOSPresignedURLErrorUnknown,
    OOSPresignedURLErrorAccessKeyIsNil,
    OOSPresignedURLErrorSecretKeyIsNil,
    OOSPresignedURLErrorBucketNameIsNil,
    OOSPresignedURLErrorKeyNameIsNil,
    OOSPresignedURLErrorInvalidExpiresDate,
    OOSPresignedURLErrorUnsupportedHTTPVerbs,
    OOSPresignedURLErrorEndpointIsNil,
    OOSPresignedURLErrorInvalidServiceType,
    OOSPreSignedURLErrorCredentialProviderIsNil,
    OOSPreSignedURLErrorInternalError,
    OOSPresignedURLErrorInvalidRequestParameters,
    OOSPresignedURLErrorInvalidBucketName,
    OOSPresignedURLErrorInvalidBucketNameForAccelerateModeEnabled,
};

@class OOSGetPreSignedURLRequest;

@interface OOSPreSignedURLBuilder : CoreService

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[OOSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
         OOSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
          OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                          identityPoolId:@"YourIdentityPoolId"];
          OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSEast1
                                                                               credentialsProvider:credentialsProvider];
          [OOSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

          return YES;
      }

 Then call the following to get the default service client:

 *Swift*

     let PreSignedURLBuilder = OOSPreSignedURLBuilder.defaultPreSignedURLBuilder()

 *Objective-C*

     OOSPreSignedURLBuilder *PreSignedURLBuilder = [OOSPreSignedURLBuilder defaultPreSignedURLBuilder];

 @return The default service client.
 */
+ (instancetype)defaultPreSignedURLBuilder;

/**
 Creates a service client with the given service configuration and registers it for the key.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         OOSPreSignedURLBuilder.registerPreSignedURLBuilderWithConfiguration(configuration, forKey: "USWest2PreSignedURLBuilder")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [OOSPreSignedURLBuilder registerPreSignedURLBuilderWithConfiguration:configuration forKey:@"USWest2PreSignedURLBuilder"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let PreSignedURLBuilder = OOSPreSignedURLBuilder(forKey: "USWest2PreSignedURLBuilder")

 *Objective-C*

     OOSPreSignedURLBuilder *PreSignedURLBuilder = [OOSPreSignedURLBuilder PreSignedURLBuilderForKey:@"USWest2PreSignedURLBuilder"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerPreSignedURLBuilderWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerPreSignedURLBuilderWithConfiguration:forKey:` before invoking this method.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         OOSPreSignedURLBuilder.registerPreSignedURLBuilderWithConfiguration(configuration, forKey: "USWest2PreSignedURLBuilder")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [OOSPreSignedURLBuilder registerPreSignedURLBuilderWithConfiguration:configuration forKey:@"USWest2PreSignedURLBuilder"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let PreSignedURLBuilder = OOSPreSignedURLBuilder(forKey: "USWest2PreSignedURLBuilder")

 *Objective-C*

     OOSPreSignedURLBuilder *PreSignedURLBuilder = [OOSPreSignedURLBuilder PreSignedURLBuilderForKey:@"USWest2PreSignedURLBuilder"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)PreSignedURLBuilderForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.

 @warning Before calling this method, make sure no method is running on this client.

 @param key A string to identify the service client.
 */
+ (void)removePreSignedURLBuilderForKey:(NSString *)key;

/**
 Build a time-limited pre-signed URL to get object from , return nil if build process failed.

 @param getPreSignedURLRequest The OOSPreSignedURLRequest that defines the parameters of the operation.
 @return A pre-signed NSURL for the resource. return nil if any errors occured.
 @see OOSGetPreSignedURLRequest
 */
- (OOSTask<NSURL *> *)getPreSignedURL:(OOSGetPreSignedURLRequest *)getPreSignedURLRequest;

@end

/** The GetPreSignedURLRequest contains the parameters used to create
 a pre signed URL.
 @see OOSPreSignedURLBuilder

 */
@interface OOSGetPreSignedURLRequest : NSObject
/**
 Returns whether the client has enabled accelerate mode for getting and putting objects. The default is `NO`.
 */
@property (nonatomic, assign, getter=isAccelerateModeEnabled) BOOL accelerateModeEnabled;

/**
 The name of the bucket
 */
@property (nonatomic, strong) NSString *bucket;

/**
 The name of the  object
 */
@property (nonatomic, strong) NSString *key;

/**
 Specifies the verb used in the pre-signed URL. accepted OOSHTTPMethodGET, OOSHTTPMethodPUT, OOSHTTPMethodHEAD.
 */
@property (nonatomic, assign) OOSHTTPMethod HTTPMethod;

/**
 The time when the signature expires, specified as an NSDate object.
 */
@property (nonatomic, strong) NSDate *expires;

/**
 OOSGetPreSignedURLRequest will automatically refresh temporary credential if expiration duration in less than minimumCredentialsExpirationInterval. Only applied for credential provider using temporary token (e.g. CognitoIdentityProvider). Default value is 3000 seconds.
 */
@property (nonatomic, assign) NSTimeInterval minimumCredentialsExpirationInterval;

/**
 Expected content-type of the request. If set, the content-type will be included in the signature and future requests must include the same content-type header value to access the presigned URL. This parameter is ignored unless OOSHTTPMethod is equal to OOSHTTPMethodPUT. Default is nil.
 */
@property (nonatomic) NSString * _Nullable contentType;

/**
 Expected content-md5 header of the request. If set, this header value will be included when calculating the signature and future requests must include the same content-md5 header value to access the presigned URL. This parameter is ignored unless HTTPMethod is equal to OOSHTTPMethodPUT. Default is nil.
 */
@property (nonatomic) NSString * _Nullable contentMD5;

/**
 This NSDictionary can contains additional request headers to be included in the pre-signed URL. Default is emtpy.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestHeaders;

/**
 This NSDictionary can contains additional request parameters to be included in the pre-signed URL. Adding additional request parameters enables more advanced pre-signed URLs, such as accessing Amazon 's torrent resource for an object, or for specifying a version ID when accessing an object. Default is emtpy.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestParameters;

/**
 限制下载速度, KB/s
 */
@property (nonatomic, strong) NSNumber *limitrate;

/**
 Set an additional request header to be included in the pre-signed URL.

 @param value The value of the request parameter being added. Set to nil if parameter doesn't contains value.
 @param requestHeader The name of the request header.
 */
- (void)setValue:(NSString * _Nullable)value forRequestHeader:(NSString *)requestHeader;

/**
 Set an additional request parameter to be included in the pre-signed URL. Adding additional request parameters enables more advanced pre-signed URLs, such as accessing Amazon 's torrent resource for an object, or for specifying a version ID when accessing an object.
 
 @param value The value of the request parameter being added. Set to nil if parameter doesn't contains value.
 @param requestParameter The name of the request parameter, as it appears in the URL's query string (e.g. OOSPresignedURLVersionID).
 */
- (void)setValue:(NSString * _Nullable)value forRequestParameter:(NSString *)requestParameter;

@end

NS_ASSUME_NONNULL_END
