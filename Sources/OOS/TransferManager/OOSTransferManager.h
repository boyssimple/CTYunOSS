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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const OOSTransferManagerErrorDomain;
typedef NS_ENUM(NSInteger, OOSTransferManagerErrorType) {
    OOSTransferManagerErrorUnknown,
    OOSTransferManagerErrorCancelled,
    OOSTransferManagerErrorPaused,
    OOSTransferManagerErrorCompleted,
    OOSTransferManagerErrorInternalInConsistency,
    OOSTransferManagerErrorMissingRequiredParameters,
    OOSTransferManagerErrorInvalidParameters,
};

typedef NS_ENUM(NSInteger, OOSTransferManagerRequestState) {
    OOSTransferManagerRequestStateNotStarted,
    OOSTransferManagerRequestStateRunning,
    OOSTransferManagerRequestStatePaused,
    OOSTransferManagerRequestStateCanceling,
    OOSTransferManagerRequestStateCompleted,
};

typedef void (^OOSTransferManagerResumeAllBlock) (OOSRequest *request);

@class OOS;
@class OOSTransferManagerUploadRequest;
@class OOSTransferManagerUploadOutput;
@class OOSTransferManagerDownloadRequest;
@class OOSTransferManagerDownloadOutput;

/**
 High level utility for managing transfers to Amazon . TransferManager provides a simple API for uploading and downloading content to Amazon , and makes extensive use of Amazon  multipart uploads to achieve enhanced throughput, performance and reliability.
 */
@interface OOSTransferManager : CoreService

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

     let TransferManager = OOSTransferManager.defaultTransferManager()

 *Objective-C*

     OOSTransferManager *TransferManager = [OOSTransferManager defaultTransferManager];

 @return The default service client.
 */
+ (instancetype)defaultTransferManager;

/**
 Creates a service client with the given service configuration and registers it for the key.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         OOSTransferManager.registerTransferManagerWithConfiguration(configuration, forKey: "USWest2TransferManager")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [OOSTransferManager registerTransferManagerWithConfiguration:configuration forKey:@"USWest2TransferManager"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let TransferManager = OOSTransferManager(forKey: "USWest2TransferManager")

 *Objective-C*

     OOSTransferManager *TransferManager = [OOSTransferManager TransferManagerForKey:@"USWest2TransferManager"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerTransferManagerWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerTransferManagerWithConfiguration:forKey:` before invoking this method.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         OOSTransferManager.registerTransferManagerWithConfiguration(configuration, forKey: "USWest2TransferManager")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [OOSTransferManager registerTransferManagerWithConfiguration:configuration forKey:@"USWest2TransferManager"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let TransferManager = OOSTransferManager(forKey: "USWest2TransferManager")

 *Objective-C*

     OOSTransferManager *TransferManager = [OOSTransferManager TransferManagerForKey:@"USWest2TransferManager"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)TransferManagerForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.

 @warning Before calling this method, make sure no method is running on this client.

 @param key A string to identify the service client.
 */
+ (void)removeTransferManagerForKey:(NSString *)key;

/**
 Schedules a new transfer to upload data to Amazon .

 @param uploadRequest The upload request.

 @return OOSTask.
 */
- (OOSTask *)upload:(OOSTransferManagerUploadRequest *)uploadRequest;

/**
 Schedules a new transfer to download data from Amazon  and save it to the specified file.

 @param downloadRequest The download request.

 @return OOSTask.
 */
- (OOSTask *)download:(OOSTransferManagerDownloadRequest *)downloadRequest;

/**
 Cancels all of the upload and download requests.

 @return OOSTask.
 */
- (OOSTask *)cancelAll;

/**
 Pauses all of the upload and download requests.

 @return OOSTask.
 */
- (OOSTask *)pauseAll;

/**
 Resumes all of the upload and download requests.

 @param block The block to optionally re-set the progress blocks to the requests.

 @return OOSTask.
 */
- (OOSTask *)resumeAll:(OOSTransferManagerResumeAllBlock)block;

/**
 Clears the local cache.

 @return OOSTask.
 */
- (OOSTask *)clearCache;

@end

@interface OOSTransferManagerUploadRequest : OOSPutObjectRequest

@property (nonatomic, assign, readonly) OOSTransferManagerRequestState state;
@property (nonatomic, strong) NSURL *body;
@property (nonatomic, strong) NSString *cacheIdentifier;

@end

@interface OOSTransferManagerUploadOutput : OOSPutObjectOutput

@end

@interface OOSTransferManagerDownloadRequest : OOSGetObjectRequest

@property (nonatomic, assign, readonly) OOSTransferManagerRequestState state;

@end

@interface OOSTransferManagerDownloadOutput : OOSGetObjectOutput

@end

NS_ASSUME_NONNULL_END
