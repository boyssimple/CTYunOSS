//
// Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://OOS.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import <Foundation/Foundation.h>
#import "OOSServiceEnum.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const OOSInfoDefault;

@class OOSServiceInfo;

@interface OOSInfo : NSObject

@property (nonatomic, readonly) NSDictionary <NSString *, id> *rootInfoDictionary;

+ (instancetype)defaultOOSInfo;

- (nullable OOSServiceInfo *)serviceInfo:(NSString *)serviceName
                                  forKey:(NSString *)key;

- (nullable OOSServiceInfo *)defaultServiceInfo:(NSString *)serviceName;

@end

@interface OOSServiceInfo : NSObject

@property (nonatomic, readonly) OOSRegionType region;

@property (nonatomic, readonly) NSDictionary <NSString *, id> *infoDictionary;

@end

NS_ASSUME_NONNULL_END
