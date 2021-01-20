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

FOUNDATION_EXPORT NSString *const OOSDateRFC822DateFormat1;
FOUNDATION_EXPORT NSString *const OOSDateISO8601DateFormat1;
FOUNDATION_EXPORT NSString *const OOSDateISO8601DateFormat2;
FOUNDATION_EXPORT NSString *const OOSDateISO8601DateFormat3;
FOUNDATION_EXPORT NSString *const OOSDateShortDateFormat1;
FOUNDATION_EXPORT NSString *const OOSDateShortDateFormat2;

@interface NSDate (OOS)

+ (NSDate *)OOS_clockSkewFixedDate;

+ (NSDate *)OOS_dateFromString:(NSString *)string;
+ (NSDate *)OOS_dateFromString:(NSString *)string format:(NSString *)dateFormat;
- (NSString *)OOS_stringValue:(NSString *)dateFormat;

/**
 * Set the clock skew for the current device.  This clock skew will be used for calculating
 * signatures to OOS signatures and for parsing/converting date values from responses.
 *
 * @param clockskew the skew (in seconds) for this device.  If the clock on the device is fast, pass positive skew to correct.  If the clock on the device is slow, pass negative skew to correct.
 */
+ (void)OOS_setRuntimeClockSkew:(NSTimeInterval)clockskew;

/**
 * Get the clock skew for the current device.
 *
 * @return the skew (in seconds) currently set for this device.  Positive clock skew implies the device is fast, negative implies the device is slow.
 */
+ (NSTimeInterval)OOS_getRuntimeClockSkew;

@end

@interface NSDictionary (OOS)

- (NSDictionary *)OOS_removeNullValues;
- (id)OOS_objectForCaseInsensitiveKey:(id)aKey;

@end

@interface NSJSONSerialization (OOS)

+ (NSData *)OOS_dataWithJSONObject:(id)obj
                           options:(NSJSONWritingOptions)opt
                             error:(NSError **)error;

@end

@interface NSNumber (OOS)

+ (NSNumber *)OOS_numberFromString:(NSString *)string;

@end

@interface NSObject (OOS)

- (NSDictionary *)OOS_properties;
- (void)OOS_copyPropertiesFromObject:(NSObject *)object;

@end

@interface NSString (OOS)

+ (NSString *)OOS_base64md5FromData:(NSData *)data;
- (BOOL)OOS_isBase64Data;
- (NSString *)OOS_stringWithURLEncoding;
- (NSString *)OOS_stringWithURLEncodingPath;
- (NSString *)OOS_stringWithURLEncodingPathWithoutPriorDecoding;
- (NSString *)OOS_md5String;
- (NSString *)OOS_md5StringLittleEndian;
- (BOOL)OOS_isVirtualHostedStyleCompliant;

@end

@interface NSFileManager (OOS)

- (BOOL)OOS_atomicallyCopyItemAtURL:(NSURL *)sourceURL
                              toURL:(NSURL *)destinationURL
                     backupItemName:(NSString *)backupItemName
                              error:(NSError **)outError;

@end
