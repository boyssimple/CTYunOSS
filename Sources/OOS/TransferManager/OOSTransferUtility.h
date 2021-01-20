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


#import <UIKit/UIKit.h>
#import "OOSService.h"
#import "OOSTransferUtilityTasks.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const OOSTransferUtilityErrorDomain;
typedef NS_ENUM(NSInteger, OOSTransferUtilityErrorType) {
    OOSTransferUtilityErrorUnknown,
    OOSTransferUtilityErrorRedirection,
    OOSTransferUtilityErrorClientError,
    OOSTransferUtilityErrorServerError,
    OOSTransferUtilityErrorLocalFileNotFound
};



FOUNDATION_EXPORT NSString *const OOSTransferUtilityURLSessionDidBecomeInvalidNotification;

@class OOSTransferUtilityConfiguration;
@class OOSTransferUtilityTask;
@class OOSTransferUtilityUploadTask;
@class OOSTransferUtilityMultiPartUploadTask;
@class OOSTransferUtilityDownloadTask;
@class OOSTransferUtilityExpression;
@class OOSTransferUtilityUploadExpression;
@class OOSTransferUtilityMultiPartUploadExpression;
@class OOSTransferUtilityDownloadExpression;

#pragma mark - OOSTransferUtility

/**
 A high-level utility for managing background uploads and downloads. The transfers continue even when the app is suspended. You must call `+ application:handleEventsForBackgroundURLSession:completionHandler:` in the `- application:handleEventsForBackgroundURLSession:completionHandler:` application delegate in order for the background transfer callback to work.
 */
@interface OOSTransferUtility : CoreService

/**
 The service configuration used to instantiate this service client.

 @warning Once the client is instantiated, do not modify the configuration object. It may cause unspecified behaviors.
 */
@property (readonly) OOSServiceConfiguration *configuration;

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[OOSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
         OOSServiceManager.default().defaultServiceConfiguration = configuration

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

     let S3TransferUtility = OOSTransferUtility.default()

 *Objective-C*

     OOSTransferUtility *S3TransferUtility = [OOSTransferUtility defaultS3TransferUtility];

 @return The default service client.
 */
+ (instancetype)defaultS3TransferUtility;

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[OOSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Swift*
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
 let configuration = OOSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
 OOSServiceManager.default().defaultServiceConfiguration = configuration
 
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
 
 let S3TransferUtility = OOSTransferUtility.default() { (error) in
 
 }
 
 *Objective-C*
 
 OOSTransferUtility *S3TransferUtility = [OOSTransferUtility defaultS3TransferUtility:^(NSError * _Nullable error) {
 
 }];
 
 @param completionHandler The completion handler to call when the TransferUtility finishes loading transfers from prior sessions.
 @return The default service client.
 */
+ (instancetype)defaultS3TransferUtility:(nullable void (^)(NSError *_Nullable error)) completionHandler
  NS_SWIFT_NAME(default(completionHandler:));


/**
 Creates a service client with the given service configuration and registers it for the key.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         OOSTransferUtility.register(with: configuration!, forKey: "USWest2S3TransferUtility")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

 [OOSTransferUtility registerS3TransferUtilityWithConfiguration:configuration forKey:@"USWest2S3TransferUtility" completionHandler:^(NSError * _Nullable error) {
 
 }];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let S3TransferUtility = OOSTransferUtility(forKey: "USWest2S3TransferUtility")

 *Objective-C*

     OOSTransferUtility *S3TransferUtility = [OOSTransferUtility S3TransferUtilityForKey:@"USWest2S3TransferUtility"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                                            forKey:(NSString *)key;

/**
 Creates a service client with the given service configuration and registers it for the key.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Swift*
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
 let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
 OOSTransferUtility.register(with: configuration!, forKey: "USWest2S3TransferUtility"){ (error) in
 
 }
 
 return true
 }
 
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
 identityPoolId:@"YourIdentityPoolId"];
 OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
 credentialsProvider:credentialsProvider];
 
 [OOSTransferUtility registerS3TransferUtilityWithConfiguration:configuration forKey:@"USWest2S3TransferUtility" completionHandler:^(NSError * _Nullable error) {
 
 }];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 *Swift*
 
 let S3TransferUtility = OOSTransferUtility(forKey: "USWest2S3TransferUtility")
 
 *Objective-C*
 
 OOSTransferUtility *S3TransferUtility = [OOSTransferUtility S3TransferUtilityForKey:@"USWest2S3TransferUtility"];
 
 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
 
 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 @param completionHandler The completion handler to call when the TransferUtility finishes loading transfers from prior sessions.
 */
+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                                            forKey:(NSString *)key
                                 completionHandler:(nullable void (^)(NSError *_Nullable error)) completionHandler;

/**
 Creates a service client with the given service configuration and registers it for the key.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         OOSTransferUtility.register(with: configuration!, transferUtilityConfiguration: nil, forKey: "USWest2S3TransferUtility") { (error) in
 
         }
         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [OOSTransferUtility registerS3TransferUtilityWithConfiguration:configuration transferUtilityConfiguration:nil forKey:@"USWest2S3TransferUtility"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let S3TransferUtility = OOSTransferUtility(forKey: "USWest2S3TransferUtility")

 *Objective-C*

     OOSTransferUtility *S3TransferUtility = [OOSTransferUtility S3TransferUtilityForKey:@"USWest2S3TransferUtility"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param transferUtilityConfiguration An S3 transfer utility configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                      transferUtilityConfiguration:(nullable OOSTransferUtilityConfiguration *)transferUtilityConfiguration
                                            forKey:(NSString *)key;

/**
 Creates a service client with the given service configuration and registers it for the key.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Swift*
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
 let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
 OOSTransferUtility.register(with: configuration!, transferUtilityConfiguration: nil, forKey: "USWest2S3TransferUtility") { (error) in
 
 }
 
 return true
 }
 
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
 identityPoolId:@"YourIdentityPoolId"];
 OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
 credentialsProvider:credentialsProvider];
 
 [OOSTransferUtility registerS3TransferUtilityWithConfiguration:configuration transferUtilityConfiguration:nil forKey:@"USWest2S3TransferUtility" completionHandler:^(NSError * _Nullable error) {
 
 }];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 *Swift*
 
 let S3TransferUtility = OOSTransferUtility(forKey: "USWest2S3TransferUtility")
 
 *Objective-C*
 
 OOSTransferUtility *S3TransferUtility = [OOSTransferUtility S3TransferUtilityForKey:@"USWest2S3TransferUtility"];
 
 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
 
 @param configuration A service configuration object.
 @param transferUtilityConfiguration An S3 transfer utility configuration object.
 @param key           A string to identify the service client.
 @param completionHandler The completion handler to call when the TransferUtility finishes loading transfers from prior sessions.
 */
+ (void)registerS3TransferUtilityWithConfiguration:(OOSServiceConfiguration *)configuration
                      transferUtilityConfiguration:(nullable OOSTransferUtilityConfiguration *)transferUtilityConfiguration
                                            forKey:(NSString *)key
                                 completionHandler:(nullable void (^)(NSError *_Nullable error)) completionHandler;
/**
 Retrieves the service client associated with the key. You need to call `+ registerS3TransferUtilityWithConfiguration:forKey:` before invoking this method.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [OOSCognitoCredentialsProvider credentialsWithRegionType:OOSRegionUSEast1 identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2 credentialsProvider:credentialsProvider];

         [OOSTransferUtility registerS3TransferUtilityWithConfiguration:configuration forKey:@"USWest2S3TransferUtility"];

         return YES;
     }

 Then call the following to get the service client:

     OOSTransferUtility *S3TransferUtility = [OOSTransferUtility S3ForKey:@"USWest2S3TransferUtility"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)S3TransferUtilityForKey:(NSString *)key;



/**
 Removes the service client associated with the key and release it.

 The underlying NSURLSession is invalidated, and after the invalidation has completed the transfer is utility removed.

 Observe the OOSTransferUtilityURLSessionDidBecomeInvalidNotification to be informed when this has occurred.

 @warning Before calling this method, make sure no method is running on this client.

 @param key A string to identify the service client.
 */
+ (void)removeS3TransferUtilityForKey:(NSString *)key;

/**
 Tells `OOSTransferUtility` that events related to a URL session are waiting to be processed. This method needs to be called in the `- application:handleEventsForBackgroundURLSession:completionHandler:` application delegate for `OOSTransferUtility` to work.

 @param application       The singleton app object.
 @param identifier        The identifier of the URL session requiring attention.
 @param completionHandler The completion handler to call when you finish processing the events.
 */
+ (void)interceptApplication:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
           completionHandler:(void (^)(void))completionHandler;


/**
 Saves the `NSData` to a temporary directory and uploads it to the configured Amazon S3 bucket in `OOSTransferUtilityConfiguration`.
 
 @param data              The data to upload.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the data.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityUploadTask`.
 */
- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadData:(NSData *)data
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Saves the `NSData` to a temporary directory and uploads it to the specified Amazon S3 bucket.

 @param data              The data to upload.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the data.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.

 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityUploadTask`.
 */
- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadData:(NSData *)data
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Uploads the file to the configured Amazon S3 bucket in `OOSTransferUtilityConfiguration`.
 
 @param fileURL           The file URL of the file to upload.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the file.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityUploadTask`.
 */
- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadFile:(NSURL *)fileURL
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Uploads the file to the specified Amazon S3 bucket.

 @param fileURL           The file URL of the file to upload.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the file.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.

 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityUploadTask`.
 */
- (OOSTask<OOSTransferUtilityUploadTask *> *)uploadFile:(NSURL *)fileURL
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Saves the `NSData` to a temporary directory and uploads it to the configured Amazon S3 bucket in `OOSTransferUtilityConfiguration` using Multipart.
 
 @param data              The data to upload.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the data.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityMultiPartUploadTask`.
 */
- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadDataUsingMultiPart:(NSData *)data
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityMultiPartUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler
                                        NS_SWIFT_NAME(uploadUsingMultiPart(data:key:contentType:expression:completionHandler:));

/**
 Saves the `NSData` to a temporary directory and uploads it to the specified Amazon S3 bucket using Multipart.
 
 @param data              The data to upload.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the data.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityMultiPartUploadTask`.
 */
- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadDataUsingMultiPart:(NSData *)data
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityMultiPartUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler
                                        NS_SWIFT_NAME(uploadUsingMultiPart(data:bucket:key:contentType:expression:completionHandler:));

/**
 Uploads the file to the configured Amazon S3 bucket in `OOSTransferUtilityConfiguration` using MultiPart.
 
 @param fileURL           The file URL of the file to upload.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the file.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityMultiPartUploadTask`.
 */
- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadFileUsingMultiPart:(NSURL *)fileURL
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityMultiPartUploadExpression *)expression
                                            completionHandler:(nullable OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler
                                        NS_SWIFT_NAME(uploadUsingMultiPart(fileURL:key:contentType:expression:completionHandler:));


/**
 Uploads the file to the specified Amazon S3 bucket using MultiPart.
 
 @param fileURL           The file URL of the file to upload.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the file.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion handler when the upload completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityMultiPartUploadTask`.
 */
- (OOSTask<OOSTransferUtilityMultiPartUploadTask *> *)uploadFileUsingMultiPart:(NSURL *)fileURL
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable OOSTransferUtilityMultiPartUploadExpression *)expression
                                        completionHandler:(nullable OOSTransferUtilityMultiPartUploadCompletionHandlerBlock)completionHandler
                                        NS_SWIFT_NAME(uploadUsingMultiPart(fileURL:bucket:key:contentType:expression:completionHandler:));



/**
 Downloads the specified Amazon S3 object as `NSData` from the bucket configured in `OOSTransferUtilityConfiguration`.
 
 @param key               The Amazon S3 object key name.
 @param expression        The container object to configure the download request.
 @param completionHandler The completion handler when the download completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityDownloadTask`.
 */
- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadDataForKey:(NSString *)key
                                                         expression:(nullable OOSTransferUtilityDownloadExpression *)expression
                                                  completionHandler:(nullable OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler;

/**
 Downloads the specified Amazon S3 object as `NSData`.

 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param expression        The container object to configure the download request.
 @param completionHandler The completion handler when the download completes.

 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityDownloadTask`.
 */
- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadDataFromBucket:(NSString *)bucket
                                                                    key:(NSString *)key
                                                             expression:(nullable OOSTransferUtilityDownloadExpression *)expression
                                                      completionHandler:(nullable OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler;

/**
 Downloads the specified Amazon S3 object to a file URL from the bucket configured in `OOSTransferUtilityConfiguration`.
 
 @param fileURL           The file URL to download the object to.
 @param key               The Amazon S3 object key name.
 @param expression        The container object to configure the download request.
 @param completionHandler The completion handler when the download completes.
 
 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityDownloadTask`.
 */
- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadToURL:(NSURL *)fileURL
                                                           key:(NSString *)key
                                                    expression:(nullable OOSTransferUtilityDownloadExpression *)expression
                                             completionHandler:(nullable OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler;

/**
 Downloads the specified Amazon S3 object to a file URL.

 @param fileURL           The file URL to download the object to.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param expression        The container object to configure the download request.
 @param completionHandler The completion handler when the download completes.

 @return Returns an instance of `OOSTask`. On successful initialization, `task.result` contains an instance of `OOSTransferUtilityDownloadTask`.
 */
- (OOSTask<OOSTransferUtilityDownloadTask *> *)downloadToURL:(NSURL *)fileURL
                                                        bucket:(NSString *)bucket
                                                           key:(NSString *)key
                                                    expression:(nullable OOSTransferUtilityDownloadExpression *)expression
                                             completionHandler:(nullable OOSTransferUtilityDownloadCompletionHandlerBlock)completionHandler;

/**
 Assigns progress feedback and completion handler blocks. This method should be called when the app was suspended while the transfer is still happening.

 @param uploadBlocksAssigner   The block for assigning the upload progress feedback and completion handler blocks.
 @param downloadBlocksAssigner The block for assigning the download progress feedback and completion handler blocks.
 */
- (void)enumerateToAssignBlocksForUploadTask:(nullable void (^)(OOSTransferUtilityUploadTask *uploadTask,
                                                                _Nullable OOSTransferUtilityProgressBlock * _Nullable uploadProgressBlockReference,
                                                                _Nullable OOSTransferUtilityUploadCompletionHandlerBlock * _Nullable completionHandlerReference))uploadBlocksAssigner
                                downloadTask:(nullable void (^)(OOSTransferUtilityDownloadTask *downloadTask,
                                                                _Nullable OOSTransferUtilityProgressBlock * _Nullable downloadProgressBlockReference,
                                                                _Nullable OOSTransferUtilityDownloadCompletionHandlerBlock * _Nullable completionHandlerReference))downloadBlocksAssigner;

/**
 Assigns progress feedback and completion handler blocks. This method should be called when the app was suspended while the transfer is still happening.
 
 @param uploadBlocksAssigner   The block for assigning the upload progress feedback and completion handler blocks.
 @param multiPartUploadBlocksAssigner The block for assigning the multipart upload progress feedback and completion handler blocks.
 @param downloadBlocksAssigner The block for assigning the download progress feedback and completion handler blocks.
 */
-(void)enumerateToAssignBlocksForUploadTask:(void (^)(OOSTransferUtilityUploadTask *uploadTask,
                                                      OOSTransferUtilityProgressBlock _Nullable * _Nullable uploadProgressBlockReference,
                                                      OOSTransferUtilityUploadCompletionHandlerBlock _Nullable * _Nullable completionHandlerReference))uploadBlocksAssigner
              multiPartUploadBlocksAssigner: (void (^) (OOSTransferUtilityMultiPartUploadTask *multiPartUploadTask,
                                                        OOSTransferUtilityMultiPartProgressBlock _Nullable * _Nullable multiPartUploadProgressBlockReference,
                                                        OOSTransferUtilityMultiPartUploadCompletionHandlerBlock _Nullable * _Nullable completionHandlerReference)) multiPartUploadBlocksAssigner
                     downloadBlocksAssigner:(void (^)(OOSTransferUtilityDownloadTask *downloadTask,
                                                      OOSTransferUtilityProgressBlock _Nullable * _Nullable downloadProgressBlockReference,
                                                      OOSTransferUtilityDownloadCompletionHandlerBlock _Nullable * _Nullable completionHandlerReference))downloadBlocksAssigner;

/**
 Retrieves all running tasks.
 @deprecated Use `getUploadTasks:, getMultiPartUploadTasks: and getDownloadTasks:` methods instead.
 @return An array of containing `OOSTransferUtilityUploadTask` and `OOSTransferUtilityDownloadTask` objects.
 */
- (OOSTask<NSArray<__kindof OOSTransferUtilityTask *> *> *)getAllTasks __attribute((deprecated));

/**
 Retrieves all running upload tasks.

 @return An array of `OOSTransferUtilityUploadTask`.
 */
- (OOSTask<NSArray<OOSTransferUtilityUploadTask *> *> *)getUploadTasks;

/**
 Retrieves all running MultiPart upload tasks.
 
 @return An array of `OOSTransferUtilityMultiPartUploadTask`.
 */
- (OOSTask<NSArray<OOSTransferUtilityMultiPartUploadTask *> *> *)getMultiPartUploadTasks;

/**
 Retrieves all running download tasks.

 @return An array of `OOSTransferUtilityDownloadTask`.
 */
- (OOSTask<NSArray<OOSTransferUtilityDownloadTask *> *> *)getDownloadTasks;

@end

#pragma mark - OOSTransferUtilityConfiguration

@interface OOSTransferUtilityConfiguration : NSObject <NSCopying>

@property (nonatomic, assign, getter=isAccelerateModeEnabled) BOOL accelerateModeEnabled;

@property (nonatomic, nullable, copy) NSString *bucket;

@property NSInteger retryLimit;

@property (nonatomic, nullable) NSNumber *multiPartConcurrencyLimit;

@property NSInteger timeoutIntervalForResource;

@end

NS_ASSUME_NONNULL_END
