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

NS_ASSUME_NONNULL_BEGIN

@class OOSTask<__covariant ResultType>;

/**
 An OOS credentials container class.
 */
@interface OOSCredentials : NSObject

/**
 Access Key component of credentials.
 */
@property (nonatomic, strong, readonly) NSString *accessKey;

/**
 Secret Access Key component of credentials.
 */
@property (nonatomic, strong, readonly) NSString *secretKey;

/**
 Initiates an OOS credentials object.

 @param accessKey  An OOS Access key.
 @param secretKey  An OOS Secret key.

 @return An OOS credentials object.
 */
- (instancetype)initWithAccessKey:(NSString *)accessKey
						secretKey:(NSString *)secretKey;

@end

/**
 The OOS credentials provider protocol used to provide credentials to the SDK in order to make calls to the OOS services.
 */
@protocol OOSCredentialsProvider <NSObject>

/**
 Asynchronously returns a valid OOS credentials or an error object if it cannot retrieve valid credentials. It should cache valid credentials as much as possible and refresh them when they are invalid.

 @return A valid OOS credentials or an error object describing the error.
 */
- (OOSTask<OOSCredentials *> *)credentials;

/**
 Invalidates the cached temporary OOS credentials. If the credentials provider does not cache temporary credentials, this operation is a no-op.
 */
- (void)invalidateCachedTemporaryCredentials;

@end

/**
 @warning This credentials provider is intended only for testing purposes.
 */
@interface OOSStaticCredentialsProvider : NSObject <OOSCredentialsProvider>

/**
 Instantiates a static credentials provider.

 @param accessKey An OOS Access key.
 @param secretKey An OOS Secret key.

 @return An OOS credentials object.
 */
- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey;

@end

NS_ASSUME_NONNULL_END
