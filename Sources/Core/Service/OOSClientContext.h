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

FOUNDATION_EXPORT NSString *const OOSClientContextVersion;
FOUNDATION_EXPORT NSString *const OOSClientContextHeader;
FOUNDATION_EXPORT NSString *const OOSClientContextHeaderEncoding;

@interface OOSClientContext : NSObject

#pragma mark - App Details
@property (nonatomic, strong, readonly) NSString *installationId;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *appBuild;
@property (nonatomic, strong) NSString *appPackageName;
@property (nonatomic, strong) NSString *appName;

#pragma mark - Device Details
@property (nonatomic, strong) NSString *devicePlatformVersion;
@property (nonatomic, strong) NSString *devicePlatform;
@property (nonatomic, strong) NSString *deviceManufacturer;
@property (nonatomic, strong) NSString *deviceModel;
@property (nonatomic, strong) NSString *deviceModelVersion;
@property (nonatomic, strong) NSString *deviceLocale;

#pragma mark - Custom Attributes
@property (nonatomic, strong) NSDictionary *customAttributes;

#pragma mark - Service Details
@property (nonatomic, strong, readonly) NSDictionary *serviceDetails;

- (instancetype)init;

- (NSDictionary *)dictionaryRepresentation;

- (NSString *)JSONString;

- (NSString *)base64EncodedJSONString;

- (void)setDetails:(id)details
        forService:(NSString *)service;

@end
