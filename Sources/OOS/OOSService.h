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

NS_ASSUME_NONNULL_BEGIN

/**
 
 */
@interface OOS : CoreService

/**
 The service configuration used to instantiate this service client.
 
 @warning Once the client is instantiated, do not modify the configuration object. It may cause unspecified behaviors.
 */
@property (nonatomic, strong, readonly) OOSServiceConfiguration *configuration;

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[OOSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.

 Then call the following to get the default service client:

 *Swift*

     let  = OOS.default()

 *Objective-C*

     OOS * = [OOS defaultOOS];

 @return The default service client.
 */
+ (instancetype)defaultOOS;

/**
 Creates a service client with the given service configuration and registers it for the key.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let credentialProvider = OOSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
        let configuration = OOSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
        OOS.register(with: configuration!, forKey: "USWest2")
 
        return true
    }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         OOSCognitoCredentialsProvider *credentialsProvider = [[OOSCognitoCredentialsProvider alloc] initWithRegionType:OOSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:OOSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [OOS registerWithConfiguration:configuration forKey:@"USWest2"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let  = OOS(forKey: "USWest2")

 *Objective-C*

     OOS * = [OOS ForKey:@"USWest2"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerWithConfiguration:(OOSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerWithConfiguration:forKey:` before invoking this method.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 Then call the following to get the service client:

 *Swift*

     let  = OOS(forKey: "USWest2")

 *Objective-C*

     OOS * = [OOS ForKey:@"USWest2"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)ForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeForKey:(NSString *)key;

/**
 <p>Aborts a multipart upload.</p><p>To verify that all parts have been removed, so you don't get charged for the part storage, you should call the List Parts operation and ensure the parts list is empty.</p>
 
 @param request A container for the necessary parameters to execute the AbortMultipartUpload service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSAbortMultipartUploadOutput`. On failed execution, `task.error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchUpload`.
 
 @see OOSAbortMultipartUploadRequest
 @see OOSAbortMultipartUploadOutput
 */
- (OOSTask<OOSAbortMultipartUploadOutput *> *)abortMultipartUpload:(OOSAbortMultipartUploadRequest *)request;

/**
 <p>Aborts a multipart upload.</p><p>To verify that all parts have been removed, so you don't get charged for the part storage, you should call the List Parts operation and ensure the parts list is empty.</p>
 
 @param request A container for the necessary parameters to execute the AbortMultipartUpload service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful. On failed execution, `error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchUpload`.
 
 @see OOSAbortMultipartUploadRequest
 @see OOSAbortMultipartUploadOutput
 */
- (void)abortMultipartUpload:(OOSAbortMultipartUploadRequest *)request completionHandler:(void (^ _Nullable)(OOSAbortMultipartUploadOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Completes a multipart upload by assembling previously uploaded parts.
 
 @param request A container for the necessary parameters to execute the CompleteMultipartUpload service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSCompleteMultipartUploadOutput`.
 
 @see OOSCompleteMultipartUploadRequest
 @see OOSCompleteMultipartUploadOutput
 */
- (OOSTask<OOSCompleteMultipartUploadOutput *> *)completeMultipartUpload:(OOSCompleteMultipartUploadRequest *)request;

/**
 Completes a multipart upload by assembling previously uploaded parts.
 
 @param request A container for the necessary parameters to execute the CompleteMultipartUpload service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSCompleteMultipartUploadRequest
 @see OOSCompleteMultipartUploadOutput
 */
- (void)completeMultipartUpload:(OOSCompleteMultipartUploadRequest *)request completionHandler:(void (^ _Nullable)(OOSCompleteMultipartUploadOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Creates a new bucket.
 
 @param request A container for the necessary parameters to execute the CreateBucket service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSCreateBucketOutput`. On failed execution, `task.error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorBucketAlreadyExists`, `OOSErrorBucketAlreadyOwnedByYou`.
 
 @see OOSCreateBucketRequest
 @see OOSCreateBucketOutput
 */
- (OOSTask<OOSCreateBucketOutput *> *)createBucket:(OOSCreateBucketRequest *)request;

/**
 Creates a new bucket.
 
 @param request A container for the necessary parameters to execute the CreateBucket service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful. On failed execution, `error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorBucketAlreadyExists`, `OOSErrorBucketAlreadyOwnedByYou`.
 
 @see OOSCreateBucketRequest
 @see OOSCreateBucketOutput
 */
- (void)createBucket:(OOSCreateBucketRequest *)request completionHandler:(void (^ _Nullable)(OOSCreateBucketOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 <p>Initiates a multipart upload and returns an upload ID.</p><p><b>Note:</b> After you initiate multipart upload and upload one or more parts, you must either complete or abort multipart upload in order to stop getting charged for storage of the uploaded parts. Only after you either complete or abort multipart upload, Amazon  frees up the parts storage and stops charging you for the parts storage.</p>
 
 @param request A container for the necessary parameters to execute the CreateMultipartUpload service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSCreateMultipartUploadOutput`.
 
 @see OOSCreateMultipartUploadRequest
 @see OOSCreateMultipartUploadOutput
 */
- (OOSTask<OOSCreateMultipartUploadOutput *> *)createMultipartUpload:(OOSCreateMultipartUploadRequest *)request;

/**
 <p>Initiates a multipart upload and returns an upload ID.</p><p><b>Note:</b> After you initiate multipart upload and upload one or more parts, you must either complete or abort multipart upload in order to stop getting charged for storage of the uploaded parts. Only after you either complete or abort multipart upload, Amazon  frees up the parts storage and stops charging you for the parts storage.</p>
 
 @param request A container for the necessary parameters to execute the CreateMultipartUpload service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSCreateMultipartUploadRequest
 @see OOSCreateMultipartUploadOutput
 */
- (void)createMultipartUpload:(OOSCreateMultipartUploadRequest *)request completionHandler:(void (^ _Nullable)(OOSCreateMultipartUploadOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Deletes the bucket. All objects (including all object versions and Delete Markers) in the bucket must be deleted before the bucket itself can be deleted.
 
 @param request A container for the necessary parameters to execute the DeleteBucket service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSDeleteBucketRequest
 */
- (OOSTask *)deleteBucket:(OOSDeleteBucketRequest *)request;

/**
 Deletes the bucket. All objects (including all object versions and Delete Markers) in the bucket must be deleted before the bucket itself can be deleted.
 
 @param request A container for the necessary parameters to execute the DeleteBucket service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteBucketRequest
 */
- (void)deleteBucket:(OOSDeleteBucketRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Deletes the cors configuration information set for the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketCors service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSDeleteBucketCorsRequest
 */
- (OOSTask *)deleteBucketCors:(OOSDeleteBucketCorsRequest *)request;

/**
 Deletes the cors configuration information set for the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketCors service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteBucketCorsRequest
 */
- (void)deleteBucketCors:(OOSDeleteBucketCorsRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Deletes the lifecycle configuration from the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketLifecycle service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSDeleteBucketLifecycleRequest
 */
- (OOSTask *)deleteBucketLifecycle:(OOSDeleteBucketLifecycleRequest *)request;

/**
 Deletes the lifecycle configuration from the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketLifecycle service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteBucketLifecycleRequest
 */
- (void)deleteBucketLifecycle:(OOSDeleteBucketLifecycleRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Deletes the policy from the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketPolicy service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSDeleteBucketPolicyRequest
 */
- (OOSTask *)deleteBucketPolicy:(OOSDeleteBucketPolicyRequest *)request;

/**
 Deletes the policy from the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketPolicy service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteBucketPolicyRequest
 */
- (void)deleteBucketPolicy:(OOSDeleteBucketPolicyRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 This operation removes the website configuration from the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketWebsite service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSDeleteBucketWebsiteRequest
 */
- (OOSTask *)deleteBucketWebsite:(OOSDeleteBucketWebsiteRequest *)request;

/**
 This operation removes the website configuration from the bucket.
 
 @param request A container for the necessary parameters to execute the DeleteBucketWebsite service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteBucketWebsiteRequest
 */
- (void)deleteBucketWebsite:(OOSDeleteBucketWebsiteRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Removes the null version (if there is one) of an object and inserts a delete marker, which becomes the latest version of the object. If there isn't a null version, Amazon  does not remove any objects.
 
 @param request A container for the necessary parameters to execute the DeleteObject service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSDeleteObjectOutput`.
 
 @see OOSDeleteObjectRequest
 @see OOSDeleteObjectOutput
 */
- (OOSTask<OOSDeleteObjectOutput *> *)deleteObject:(OOSDeleteObjectRequest *)request;

/**
 Removes the null version (if there is one) of an object and inserts a delete marker, which becomes the latest version of the object. If there isn't a null version, Amazon  does not remove any objects.
 
 @param request A container for the necessary parameters to execute the DeleteObject service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteObjectRequest
 @see OOSDeleteObjectOutput
 */
- (void)deleteObject:(OOSDeleteObjectRequest *)request completionHandler:(void (^ _Nullable)(OOSDeleteObjectOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 This operation enables you to delete multiple objects from a bucket using a single HTTP request. You may specify up to 1000 keys.
 
 @param request A container for the necessary parameters to execute the DeleteObjects service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSDeleteObjectsOutput`.
 
 @see OOSDeleteObjectsRequest
 @see OOSDeleteObjectsOutput
 */
- (OOSTask<OOSDeleteObjectsOutput *> *)deleteObjects:(OOSDeleteObjectsRequest *)request;

/**
 This operation enables you to delete multiple objects from a bucket using a single HTTP request. You may specify up to 1000 keys.
 
 @param request A container for the necessary parameters to execute the DeleteObjects service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSDeleteObjectsRequest
 @see OOSDeleteObjectsOutput
 */
- (void)deleteObjects:(OOSDeleteObjectsRequest *)request completionHandler:(void (^ _Nullable)(OOSDeleteObjectsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Gets the access control policy for the bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketAcl service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketAclOutput`.
 
 @see OOSGetBucketAclRequest
 @see OOSGetBucketAclOutput
 */
- (OOSTask<OOSGetBucketAclOutput *> *)getBucketAcl:(OOSGetBucketAclRequest *)request;

/**
 Gets the access control policy for the bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketAcl service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketAclRequest
 @see OOSGetBucketAclOutput
 */
- (void)getBucketAcl:(OOSGetBucketAclRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketAclOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns the cors configuration for the bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketCors service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketCorsOutput`.
 
 @see OOSGetBucketCorsRequest
 @see OOSGetBucketCorsOutput
 */
- (OOSTask<OOSGetBucketCorsOutput *> *)getBucketCors:(OOSGetBucketCorsRequest *)request;

/**
 Returns the cors configuration for the bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketCors service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketCorsRequest
 @see OOSGetBucketCorsOutput
 */
- (void)getBucketCors:(OOSGetBucketCorsRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketCorsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Deprecated, see the GetBucketLifecycleConfiguration operation.
 
 @param request A container for the necessary parameters to execute the GetBucketLifecycle service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketLifecycleOutput`.
 
 @see OOSGetBucketLifecycleRequest
 @see OOSGetBucketLifecycleOutput
 */
- (OOSTask<OOSGetBucketLifecycleOutput *> *)getBucketLifecycle:(OOSGetBucketLifecycleRequest *)request;

/**
 Deprecated, see the GetBucketLifecycleConfiguration operation.
 
 @param request A container for the necessary parameters to execute the GetBucketLifecycle service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketLifecycleRequest
 @see OOSGetBucketLifecycleOutput
 */
- (void)getBucketLifecycle:(OOSGetBucketLifecycleRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketLifecycleOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns the lifecycle configuration information set on the bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketLifecycleConfiguration service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketLifecycleConfigurationOutput`.
 
 @see OOSGetBucketLifecycleConfigurationRequest
 @see OOSGetBucketLifecycleConfigurationOutput
 */
- (OOSTask<OOSGetBucketLifecycleConfigurationOutput *> *)getBucketLifecycleConfiguration:(OOSGetBucketLifecycleConfigurationRequest *)request;

/**
 Returns the lifecycle configuration information set on the bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketLifecycleConfiguration service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketLifecycleConfigurationRequest
 @see OOSGetBucketLifecycleConfigurationOutput
 */
- (void)getBucketLifecycleConfiguration:(OOSGetBucketLifecycleConfigurationRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketLifecycleConfigurationOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns the logging status of a bucket and the permissions users have to view and modify that status. To use GET, you must be the bucket owner.
 
 @param request A container for the necessary parameters to execute the GetBucketLogging service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketLoggingOutput`.
 
 @see OOSGetBucketLoggingRequest
 @see OOSGetBucketLoggingOutput
 */
- (OOSTask<OOSGetBucketLoggingOutput *> *)getBucketLogging:(OOSGetBucketLoggingRequest *)request;

/**
 Returns the logging status of a bucket and the permissions users have to view and modify that status. To use GET, you must be the bucket owner.
 
 @param request A container for the necessary parameters to execute the GetBucketLogging service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketLoggingRequest
 @see OOSGetBucketLoggingOutput
 */
- (void)getBucketLogging:(OOSGetBucketLoggingRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketLoggingOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns the policy of a specified bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketPolicy service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketPolicyOutput`.
 
 @see OOSGetBucketPolicyRequest
 @see OOSGetBucketPolicyOutput
 */
- (OOSTask<OOSGetBucketPolicyOutput *> *)getBucketPolicy:(OOSGetBucketPolicyRequest *)request;

/**
 Returns the policy of a specified bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketPolicy service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketPolicyRequest
 @see OOSGetBucketPolicyOutput
 */
- (void)getBucketPolicy:(OOSGetBucketPolicyRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketPolicyOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns the website configuration for a bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketWebsite service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetBucketWebsiteOutput`.
 
 @see OOSGetBucketWebsiteRequest
 @see OOSGetBucketWebsiteOutput
 */
- (OOSTask<OOSGetBucketWebsiteOutput *> *)getBucketWebsite:(OOSGetBucketWebsiteRequest *)request;

/**
 Returns the website configuration for a bucket.
 
 @param request A container for the necessary parameters to execute the GetBucketWebsite service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSGetBucketWebsiteRequest
 @see OOSGetBucketWebsiteOutput
 */
- (void)getBucketWebsite:(OOSGetBucketWebsiteRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketWebsiteOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Retrieves objects from Amazon .
 
 @param request A container for the necessary parameters to execute the GetObject service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSGetObjectOutput`. On failed execution, `task.error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchKey`.
 
 @see OOSGetObjectRequest
 @see OOSGetObjectOutput
 */
- (OOSTask<OOSGetObjectOutput *> *)getObject:(OOSGetObjectRequest *)request;

/**
 Retrieves objects from Amazon .
 
 @param request A container for the necessary parameters to execute the GetObject service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful. On failed execution, `error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchKey`.
 
 @see OOSGetObjectRequest
 @see OOSGetObjectOutput
 */
- (void)getObject:(OOSGetObjectRequest *)request completionHandler:(void (^ _Nullable)(OOSGetObjectOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 This operation is useful to determine if a bucket exists and you have permission to access it.
 
 @param request A container for the necessary parameters to execute the HeadBucket service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`. On failed execution, `task.error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchBucket`.
 
 @see OOSHeadBucketRequest
 */
- (OOSTask *)headBucket:(OOSHeadBucketRequest *)request;

/**
 This operation is useful to determine if a bucket exists and you have permission to access it.
 
 @param request A container for the necessary parameters to execute the HeadBucket service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful. On failed execution, `error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchBucket`.
 
 @see OOSHeadBucketRequest
 */
- (void)headBucket:(OOSHeadBucketRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Returns a list of all buckets owned by the authenticated sender of the request.
 
 @param request A container for the necessary parameters to execute the ListBuckets service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSListBucketsOutput`.
 
 @see OOSRequest
 @see OOSListBucketsOutput
 */
- (OOSTask<OOSListBucketsOutput *> *)listBuckets:(OOSRequest *)request;

/**
 Returns a list of all buckets owned by the authenticated sender of the request.
 
 @param request A container for the necessary parameters to execute the ListBuckets service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSRequest
 @see OOSListBucketsOutput
 */
- (void)listBuckets:(OOSRequest *)request completionHandler:(void (^ _Nullable)(OOSListBucketsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 This operation lists in-progress multipart uploads.
 
 @param request A container for the necessary parameters to execute the ListMultipartUploads service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSListMultipartUploadsOutput`.
 
 @see OOSListMultipartUploadsRequest
 @see OOSListMultipartUploadsOutput
 */
- (OOSTask<OOSListMultipartUploadsOutput *> *)listMultipartUploads:(OOSListMultipartUploadsRequest *)request;

/**
 This operation lists in-progress multipart uploads.
 
 @param request A container for the necessary parameters to execute the ListMultipartUploads service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSListMultipartUploadsRequest
 @see OOSListMultipartUploadsOutput
 */
- (void)listMultipartUploads:(OOSListMultipartUploadsRequest *)request completionHandler:(void (^ _Nullable)(OOSListMultipartUploadsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns metadata about all of the versions of objects in a bucket.
 
 @param request A container for the necessary parameters to execute the ListObjectVersions service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSListObjectVersionsOutput`.
 
 @see OOSListObjectVersionsRequest
 @see OOSListObjectVersionsOutput
 */
- (OOSTask<OOSListObjectVersionsOutput *> *)listObjectVersions:(OOSListObjectVersionsRequest *)request;

/**
 Returns metadata about all of the versions of objects in a bucket.
 
 @param request A container for the necessary parameters to execute the ListObjectVersions service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSListObjectVersionsRequest
 @see OOSListObjectVersionsOutput
 */
- (void)listObjectVersions:(OOSListObjectVersionsRequest *)request completionHandler:(void (^ _Nullable)(OOSListObjectVersionsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Returns some or all (up to 1000) of the objects in a bucket. You can use the request parameters as selection criteria to return a subset of the objects in a bucket.
 
 @param request A container for the necessary parameters to execute the ListObjects service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSListObjectsOutput`. On failed execution, `task.error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchBucket`.
 
 @see OOSListObjectsRequest
 @see OOSListObjectsOutput
 */
- (OOSTask<OOSListObjectsOutput *> *)listObjects:(OOSListObjectsRequest *)request;

/**
 Returns some or all (up to 1000) of the objects in a bucket. You can use the request parameters as selection criteria to return a subset of the objects in a bucket.
 
 @param request A container for the necessary parameters to execute the ListObjects service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful. On failed execution, `error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorNoSuchBucket`.
 
 @see OOSListObjectsRequest
 @see OOSListObjectsOutput
 */
- (void)listObjects:(OOSListObjectsRequest *)request completionHandler:(void (^ _Nullable)(OOSListObjectsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Lists the parts that have been uploaded for a specific multipart upload.
 
 @param request A container for the necessary parameters to execute the ListParts service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSListPartsOutput`.
 
 @see OOSListPartsRequest
 @see OOSListPartsOutput
 */
- (OOSTask<OOSListPartsOutput *> *)listParts:(OOSListPartsRequest *)request;

/**
 Lists the parts that have been uploaded for a specific multipart upload.
 
 @param request A container for the necessary parameters to execute the ListParts service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSListPartsRequest
 @see OOSListPartsOutput
 */
- (void)listParts:(OOSListPartsRequest *)request completionHandler:(void (^ _Nullable)(OOSListPartsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Sets the permissions on a bucket using access control lists (ACL).
 
 @param request A container for the necessary parameters to execute the PutBucketAcl service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketAclRequest
 */
- (OOSTask *)putBucketAcl:(OOSPutBucketAclRequest *)request;

/**
 Sets the permissions on a bucket using access control lists (ACL).
 
 @param request A container for the necessary parameters to execute the PutBucketAcl service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketAclRequest
 */
- (void)putBucketAcl:(OOSPutBucketAclRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Sets the cors configuration for a bucket.
 
 @param request A container for the necessary parameters to execute the PutBucketCors service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketCorsRequest
 */
- (OOSTask *)putBucketCors:(OOSPutBucketCorsRequest *)request;

/**
 Sets the cors configuration for a bucket.
 
 @param request A container for the necessary parameters to execute the PutBucketCors service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketCorsRequest
 */
- (void)putBucketCors:(OOSPutBucketCorsRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Deprecated, see the PutBucketLifecycleConfiguration operation.
 
 @param request A container for the necessary parameters to execute the PutBucketLifecycle service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketLifecycleRequest
 */
- (OOSTask *)putBucketLifecycle:(OOSPutBucketLifecycleRequest *)request;

/**
 Deprecated, see the PutBucketLifecycleConfiguration operation.
 
 @param request A container for the necessary parameters to execute the PutBucketLifecycle service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketLifecycleRequest
 */
- (void)putBucketLifecycle:(OOSPutBucketLifecycleRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Sets lifecycle configuration for your bucket. If a lifecycle configuration exists, it replaces it.
 
 @param request A container for the necessary parameters to execute the PutBucketLifecycleConfiguration service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketLifecycleConfigurationRequest
 */
- (OOSTask *)putBucketLifecycleConfiguration:(OOSPutBucketLifecycleConfigurationRequest *)request;

/**
 Sets lifecycle configuration for your bucket. If a lifecycle configuration exists, it replaces it.
 
 @param request A container for the necessary parameters to execute the PutBucketLifecycleConfiguration service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketLifecycleConfigurationRequest
 */
- (void)putBucketLifecycleConfiguration:(OOSPutBucketLifecycleConfigurationRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Set the logging parameters for a bucket and to specify permissions for who can view and modify the logging parameters. To set the logging status of a bucket, you must be the bucket owner.
 
 @param request A container for the necessary parameters to execute the PutBucketLogging service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketLoggingRequest
 */
- (OOSTask *)putBucketLogging:(OOSPutBucketLoggingRequest *)request;

/**
 Set the logging parameters for a bucket and to specify permissions for who can view and modify the logging parameters. To set the logging status of a bucket, you must be the bucket owner.
 
 @param request A container for the necessary parameters to execute the PutBucketLogging service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketLoggingRequest
 */
- (void)putBucketLogging:(OOSPutBucketLoggingRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Replaces a policy on a bucket. If the bucket already has a policy, the one in this request completely replaces it.
 
 @param request A container for the necessary parameters to execute the PutBucketPolicy service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketPolicyRequest
 */
- (OOSTask *)putBucketPolicy:(OOSPutBucketPolicyRequest *)request;

/**
 Replaces a policy on a bucket. If the bucket already has a policy, the one in this request completely replaces it.
 
 @param request A container for the necessary parameters to execute the PutBucketPolicy service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketPolicyRequest
 */
- (void)putBucketPolicy:(OOSPutBucketPolicyRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Set the website configuration for a bucket.
 
 @param request A container for the necessary parameters to execute the PutBucketWebsite service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will be `nil`.
 
 @see OOSPutBucketWebsiteRequest
 */
- (OOSTask *)putBucketWebsite:(OOSPutBucketWebsiteRequest *)request;

/**
 Set the website configuration for a bucket.
 
 @param request A container for the necessary parameters to execute the PutBucketWebsite service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutBucketWebsiteRequest
 */
- (void)putBucketWebsite:(OOSPutBucketWebsiteRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

/**
 Adds an object to a bucket.
 
 @param request A container for the necessary parameters to execute the PutObject service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSPutObjectOutput`.
 
 @see OOSPutObjectRequest
 @see OOSPutObjectOutput
 */
- (OOSTask<OOSPutObjectOutput *> *)putObject:(OOSPutObjectRequest *)request;

/**
 Adds an object to a bucket.
 
 @param request A container for the necessary parameters to execute the PutObject service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSPutObjectRequest
 @see OOSPutObjectOutput
 */
- (void)putObject:(OOSPutObjectRequest *)request completionHandler:(void (^ _Nullable)(OOSPutObjectOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 <p>Uploads a part in a multipart upload.</p><p><b>Note:</b> After you initiate multipart upload and upload one or more parts, you must either complete or abort multipart upload in order to stop getting charged for storage of the uploaded parts. Only after you either complete or abort multipart upload, Amazon  frees up the parts storage and stops charging you for the parts storage.</p>
 
 @param request A container for the necessary parameters to execute the UploadPart service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSUploadPartOutput`.
 
 @see OOSUploadPartRequest
 @see OOSUploadPartOutput
 */
- (OOSTask<OOSUploadPartOutput *> *)uploadPart:(OOSUploadPartRequest *)request;

/**
 <p>Uploads a part in a multipart upload.</p><p><b>Note:</b> After you initiate multipart upload and upload one or more parts, you must either complete or abort multipart upload in order to stop getting charged for storage of the uploaded parts. Only after you either complete or abort multipart upload, Amazon  frees up the parts storage and stops charging you for the parts storage.</p>
 
 @param request A container for the necessary parameters to execute the UploadPart service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSUploadPartRequest
 @see OOSUploadPartOutput
 */
- (void)uploadPart:(OOSUploadPartRequest *)request completionHandler:(void (^ _Nullable)(OOSUploadPartOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 Uploads a part by copying data from an existing object as data source.
 
 @param request A container for the necessary parameters to execute the UploadPartCopy service method.

 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSUploadPartCopyOutput`.
 
 @see OOSUploadPartCopyRequest
 @see OOSUploadPartCopyOutput
 */
- (OOSTask<OOSUploadPartCopyOutput *> *)uploadPartCopy:(OOSUploadPartCopyRequest *)request;

/**
 Uploads a part by copying data from an existing object as data source.
 
 @param request A container for the necessary parameters to execute the UploadPartCopy service method.
 @param completionHandler The completion handler to call when the load request is complete.
                          `response` - A response object, or `nil` if the request failed.
                          `error` - An error object that indicates why the request failed, or `nil` if the request was successful.
 
 @see OOSUploadPartCopyRequest
 @see OOSUploadPartCopyOutput
 */
- (void)uploadPartCopy:(OOSUploadPartCopyRequest *)request completionHandler:(void (^ _Nullable)(OOSUploadPartCopyOutput * _Nullable response, NSError * _Nullable error))completionHandler;


/**
 Creates a copy of an object that is already stored.
 
 @param request A container for the necessary parameters to execute the CopyObject service method.
 
 @return An instance of `OOSTask`. On successful execution, `task.result` will contain an instance of `OOSCopyObjectOutput`. On failed execution, `task.error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorObjectNotInActiveTier`.
 
 */
- (OOSTask<OOSCopyObjectOutput *> *)copyObject:(OOSCopyObjectRequest *)request;

/**
 Creates a copy of an object that is already stored.
 
 @param request A container for the necessary parameters to execute the CopyObject service method.
 @param completionHandler The completion handler to call when the load request is complete.
 `response` - A response object, or `nil` if the request failed.
 `error` - An error object that indicates why the request failed, or `nil` if the request was successful. On failed execution, `error` may contain an `NSError` with `OOSErrorDomain` domain and the following error code: `OOSErrorObjectNotInActiveTier`.
 
 */
- (void)copyObject:(OOSCopyObjectRequest *)request completionHandler:(void (^ _Nullable)(OOSCopyObjectOutput * _Nullable response, NSError * _Nullable error))completionHandler;


/**
 创建一对普通的 AccessKey 和 SecretKey，默认的状态是 Active。只有主 key
 才能执行此操作。
 */
- (OOSTask *)createAccessKey:(OOSCreateAccessKeyRequest *)request;

/**
 创建一对普通的 AccessKey 和 SecretKey，默认的状态是 Active。只有主 key
 才能执行此操作。
 */
- (void)createAccessKey:(OOSCreateAccessKeyRequest *)request completionHandler:(void (^ _Nullable)(OOSCreateAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
删除一对普通的 AccessKey 和 SecretKey。只有主 key 才能执行此操作。
 */
- (OOSTask *)deleteAccessKey:(OOSDeleteAccessKeyRequest *)request;

/**
删除一对普通的 AccessKey 和 SecretKey。只有主 key 才能执行此操作。
 */
- (void)deleteAccessKey:(OOSDeleteAccessKeyRequest *)request completionHandler:(void (^ _Nullable)(OOSDeleteAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 更新普通的 AccessKey 的状态，或将普通 key 设置成为主 key，反之亦然。
 只有主 key 才能执行此操作。
 */
- (OOSTask *)updateAccessKey:(OOSUpdateAccessKeyRequest *)request;

/**
 更新普通的 AccessKey 的状态，或将普通 key 设置成为主 key，反之亦然。
 只有主 key 才能执行此操作。
 */
- (void)updateAccessKey:(OOSUpdateAccessKeyRequest *)request completionHandler:(void (^ _Nullable)(OOSUpdateAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 列出账号下的主 ke 和普通 key。只有主 key 才能执行此操作。可以通过
 MaxItems 参数指定返回的结果数量，默认返回 100 个 key。可以通过 Marker 参
 数设置返回的起始位置，该参数可以从前一次请求的响应体中获得。为保证账号
 安全，list 操作时，不会返回 SecretKey。
 */
- (OOSTask *)listAccessKey:(OOSListAccessKeyRequest *)request;

/**
 列出账号下的主 ke 和普通 key。只有主 key 才能执行此操作。可以通过
 MaxItems 参数指定返回的结果数量，默认返回 100 个 key。可以通过 Marker 参
 数设置返回的起始位置，该参数可以从前一次请求的响应体中获得。为保证账号
 安全，list 操作时，不会返回 SecretKey。
 */
- (void)listAccessKey:(OOSListAccessKeyRequest *)request completionHandler:(void (^ _Nullable)(OOSListAccessKeyOutput * _Nullable response, NSError * _Nullable error))completionHandler;


/**
 这个 Get 操作用来获取 bucket 的索引位置和数据位置，只有 bucket 的所有者才能执行此操作
 */
- (OOSTask<OOSGetRegionsOutput *> *)getRegions:(OOSGetRegionsRequest *)request;

/**
 这个 Get 操作用来获取 bucket 的索引位置和数据位置，只有 bucket 的所有者才能执行此操作
 */
- (void)getRegions:(OOSGetRegionsRequest *)request completionHandler:(void (^ _Nullable)(OOSGetRegionsOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 这个 Get 操作用来获取 bucket 的索引位置和数据位置，只有 bucket 的所有者才能执行此操作
 */
- (OOSTask<OOSGetBucketLocationOutput *> *)getBucketLocation:(OOSGetBucketLocationRequest *)request;

/**
 这个 Get 操作用来获取 bucket 的索引位置和数据位置，只有 bucket 的所有者才能执行此操作
 */
- (void)getBucketLocation:(OOSGetBucketLocationRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketLocationOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
在 GET 操作的 url 中加上 accelerate，可以获得指定 bucket 的 cdn 配置信息。
 */
- (OOSTask<OOSGetBucketAccelerateConfigurationOutput *> *)getBucketAccelerateConfiguration:(OOSGetBucketAccelerateConfigurationRequest *)request;

/**
在 GET 操作的 url 中加上 accelerate，可以获得指定 bucket 的 cdn 配置信息。
 */
- (void)getBucketAccelerateConfiguration:(OOSGetBucketAccelerateConfigurationRequest *)request completionHandler:(void (^ _Nullable)(OOSGetBucketAccelerateConfigurationOutput * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 在 PUT 操作的 url 中加上 accelerate，可以进行添加或修改 CDN IP 白名单的操作。
 如果 bucket 已经配置了 CDN 加速，此操作会替换原有配置。只有 bucket 的 owner 才能
 执行此操作，否则会返回 403 AccessDenied 错误。一个 bucket 最多配置 5 个 IP 白名单地址段。
 */
- (OOSTask *)putBucketAccelerateConfiguration:(OOSPutBucketAccelerateConfigurationRequest *)request;

/**
 在 PUT 操作的 url 中加上 accelerate，可以进行添加或修改 CDN IP 白名单的操作。
 如果 bucket 已经配置了 CDN 加速，此操作会替换原有配置。只有 bucket 的 owner 才能
 执行此操作，否则会返回 403 AccessDenied 错误。一个 bucket 最多配置 5 个 IP 白名单地址段。
 */
- (void)putBucketAccelerateConfiguration:(OOSPutBucketAccelerateConfigurationRequest *)request completionHandler:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;


/**
 Head 操作用于获取对象的元数据信息，而不返回数据本身。当只希望获取对象的属性信息时，可以使用此操作。
 */
- (OOSTask<OOSHeadObjectOutput *> *)headObject:(OOSHeadObjectRequest *)request;

/**
 Head 操作用于获取对象的元数据信息，而不返回数据本身。当只希望获取对象的属性信息时，可以使用此操作。
 */
- (void)headObject:(OOSHeadObjectRequest *)request completionHandler:(void (^ _Nullable)(OOSHeadObjectOutput * _Nullable response, NSError * _Nullable error))completionHandler;


@end

NS_ASSUME_NONNULL_END
