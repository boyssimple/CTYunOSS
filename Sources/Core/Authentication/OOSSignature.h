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
#import "OOSSignatureSigner.h"
#import "OOSSignatureSignerUtility.h"

FOUNDATION_EXPORT NSString *const OOSSignatureV2Algorithm;
FOUNDATION_EXPORT NSString *const OOSSignatureV2Terminator;

@class OOSEndpoint;
@protocol OOSCredentialsProvider;

@interface OOSSignatureV2Signer : OOSSignatureSigner

+ (OOSTask<NSURL *> *)generateQueryStringForSignatureV2WithCredentialProvider:(id<OOSCredentialsProvider>)credentialsProvider
																   httpMethod:(OOSHTTPMethod)httpMethod
															   expireDuration:(int32_t)expireDuration
																	 endpoint:(OOSEndpoint *)endpoint
																	  keyPath:(NSString *)keyPath
															   requestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders
															requestParameters:(NSDictionary<NSString *, id> *)requestParameters
																	 signBody:(BOOL)signBody;

@end


@interface OOSSignatureV4Signer : OOSSignatureSigner

+ (OOSTask<NSURL *> *)generateQueryStringForSignatureV4WithCredentialProvider:(id<OOSCredentialsProvider>)credentialsProvider
																   httpMethod:(OOSHTTPMethod)httpMethod
															   expireDuration:(int32_t)expireDuration
																	 endpoint:(OOSEndpoint *)endpoint
																	  keyPath:(NSString *)keyPath
															   requestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders
															requestParameters:(NSDictionary<NSString *, id> *)requestParameters
																	 signBody:(BOOL)signBody;

@end
