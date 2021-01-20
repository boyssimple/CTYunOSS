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


#import "OOSCategory.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "OOSCocoaLumberjack.h"

NSString *const OOSDateRFC822DateFormat1 = @"EEE, dd MMM yyyy HH:mm:ss z";
NSString *const OOSDateISO8601DateFormat1 = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
NSString *const OOSDateISO8601DateFormat2 = @"yyyyMMdd'T'HHmmss'Z'";
NSString *const OOSDateISO8601DateFormat3 = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
NSString *const OOSDateShortDateFormat1 = @"yyyyMMdd";
NSString *const OOSDateShortDateFormat2 = @"yyyy-MM-dd";

@implementation NSDate (OOS)

static NSTimeInterval _clockskew = 0.0;

+ (NSDate *)OOS_clockSkewFixedDate {
    return [[NSDate date] dateByAddingTimeInterval:-1 * _clockskew];
}

+ (NSDate *)OOS_dateFromString:(NSString *)string {
    NSDate *parsedDate = nil;
    NSArray *arrayOfDateFormat = @[OOSDateRFC822DateFormat1,
                                   OOSDateISO8601DateFormat1,
                                   OOSDateISO8601DateFormat2,
                                   OOSDateISO8601DateFormat3];

    for (NSString *dateFormat in arrayOfDateFormat) {
        if (!parsedDate) {
            parsedDate = [NSDate OOS_dateFromString:string format:dateFormat];
        } else {
            break;
        }
    }

    return parsedDate;
}

+ (NSDate *)OOS_dateFromString:(NSString *)string format:(NSString *)dateFormat {
    if ([dateFormat isEqualToString:OOSDateRFC822DateFormat1]) {
        return [[NSDate OOS_RFC822Date1Formatter] dateFromString:string];
    }
    if ([dateFormat isEqualToString:OOSDateISO8601DateFormat1]) {
        return [[NSDate OOS_ISO8601Date1Formatter] dateFromString:string];
    }
    if ([dateFormat isEqualToString:OOSDateISO8601DateFormat2]) {
        return [[NSDate OOS_ISO8601Date2Formatter] dateFromString:string];
    }
    if ([dateFormat isEqualToString:OOSDateISO8601DateFormat3]) {
        return [[NSDate OOS_ISO8601Date3Formatter] dateFromString:string];
    }
    if ([dateFormat isEqualToString:OOSDateShortDateFormat1]) {
        return [[NSDate OOS_ShortDateFormat1Formatter] dateFromString:string];
    }
    if ([dateFormat isEqualToString:OOSDateShortDateFormat2]) {
        return [[NSDate OOS_ShortDateFormat2Formatter] dateFromString:string];
    }

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = dateFormat;

    return [dateFormatter dateFromString:string];
}

- (NSString *)OOS_stringValue:(NSString *)dateFormat {
    if ([dateFormat isEqualToString:OOSDateRFC822DateFormat1]) {
        return [[NSDate OOS_RFC822Date1Formatter] stringFromDate:self];
    }
    if ([dateFormat isEqualToString:OOSDateISO8601DateFormat1]) {
        return [[NSDate OOS_ISO8601Date1Formatter] stringFromDate:self];
    }
    if ([dateFormat isEqualToString:OOSDateISO8601DateFormat2]) {
        return [[NSDate OOS_ISO8601Date2Formatter] stringFromDate:self];
    }
    if ([dateFormat isEqualToString:OOSDateISO8601DateFormat3]) {
        return [[NSDate OOS_ISO8601Date3Formatter] stringFromDate:self];
    }
    if ([dateFormat isEqualToString:OOSDateShortDateFormat1]) {
        return [[NSDate OOS_ShortDateFormat1Formatter] stringFromDate:self];
    }
    if ([dateFormat isEqualToString:OOSDateShortDateFormat2]) {
        return [[NSDate OOS_ShortDateFormat2Formatter] stringFromDate:self];
    }

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = dateFormat;

    return [dateFormatter stringFromDate:self];
}

+ (NSDateFormatter *)OOS_RFC822Date1Formatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = OOSDateRFC822DateFormat1;
    });

    return _dateFormatter;
}

+ (NSDateFormatter *)OOS_ISO8601Date1Formatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = OOSDateISO8601DateFormat1;
    });

    return _dateFormatter;
}

+ (NSDateFormatter *)OOS_ISO8601Date2Formatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = OOSDateISO8601DateFormat2;
    });

    return _dateFormatter;
}

+ (NSDateFormatter *)OOS_ISO8601Date3Formatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = OOSDateISO8601DateFormat3;
    });

    return _dateFormatter;
}

+ (NSDateFormatter *)OOS_ShortDateFormat1Formatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = OOSDateShortDateFormat1;
    });

    return _dateFormatter;
}

+ (NSDateFormatter *)OOS_ShortDateFormat2Formatter {
    static NSDateFormatter *_dateFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = OOSDateShortDateFormat2;
    });

    return _dateFormatter;
}

+ (void)OOS_setRuntimeClockSkew:(NSTimeInterval)clockskew {
    @synchronized(self) {
        _clockskew = clockskew;
    }
}

+ (NSTimeInterval)OOS_getRuntimeClockSkew {
    @synchronized(self) {
        return _clockskew;
    }
}

@end

@implementation NSDictionary (OOS)

- (NSDictionary *)OOS_removeNullValues {
    return [self OOS_recursivelyRemoveNullEntries:self];
}

- (NSDictionary *)OOS_recursivelyRemoveNullEntries:(NSDictionary *)inputDictionary {
    
    NSMutableDictionary *resultMutableDictionary = [NSMutableDictionary new];
    
    for (NSString *key in inputDictionary) {
        id value = inputDictionary[key];
        if ([value isEqual:[NSNull null]]) {
            continue;
        }
        if([value isKindOfClass:[NSDictionary class]]) {
            [resultMutableDictionary setObject:[self OOS_recursivelyRemoveNullEntries:value] forKey:key];
        } else {
            [resultMutableDictionary setObject:value forKey:key];
        }
    }
    return resultMutableDictionary;
}

-(id) OOS_objectForCaseInsensitiveKey:(id)aKey {
    for (NSString *key in self.allKeys) {
        if ([key compare:aKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [self objectForKey:key];
        }
    }
    return  nil;
}

@end

@implementation NSJSONSerialization (OOS)

+ (NSData *)OOS_dataWithJSONObject:(id)obj
                           options:(NSJSONWritingOptions)opt
                             error:(NSError **)error {
    if (!obj) {
        return nil;
    }
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        return [NSJSONSerialization dataWithJSONObject:obj
                                               options:opt
                                                 error:error];
    } else {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:@[obj]
                                                           options:opt
                                                             error:error];
        NSString *JSONString = [[NSString alloc] initWithData:JSONData
                                                     encoding:NSUTF8StringEncoding];
        if ([JSONString length] > 2) {
            JSONString = [JSONString substringWithRange:NSMakeRange(1, [JSONString length] - 2)];
            return [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            return nil;
        }
    }
}

@end

@implementation NSNumber (OOS)

+ (NSNumber *)OOS_numberFromString:(NSString *)string {
    static NSNumberFormatter *numberFormatter = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [NSNumberFormatter new];
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    });

    return [numberFormatter numberFromString:string];
}

@end

@implementation NSObject (OOS)

- (NSDictionary *)OOS_properties {
    NSMutableDictionary *propertyDictionary;
    if ([self superclass] != [NSObject class]) {
    	propertyDictionary = [NSMutableDictionary dictionaryWithDictionary:[[self superclass] OOS_properties]];
    } else {
    	propertyDictionary = [NSMutableDictionary dictionary];
    }

    unsigned int propertyListCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyListCount);
    for(uint32_t i = 0; i < propertyListCount; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        const char *attributes = property_getAttributes(property);
        if(propertyName) {
            NSString *propertyNameString = [NSString stringWithCString:propertyName
                                                              encoding:[NSString defaultCStringEncoding]];
            NSString *attributesString = [NSString stringWithCString:attributes
                                                            encoding:[NSString defaultCStringEncoding]];
            [propertyDictionary setObject:attributesString forKey:propertyNameString];
        }
    }
    free(properties);

    return propertyDictionary;
}

- (void)OOS_copyPropertiesFromObject:(NSObject *)object {
    NSDictionary *propertiesToObject = [self OOS_properties];
    NSDictionary *propertiesFromObject = [object OOS_properties];
    for (NSString *key in [propertiesFromObject allKeys]) {
        if ([propertiesToObject objectForKey:key]) {
            NSString *attributes = [propertiesFromObject valueForKey:key];
            /**
             * If it's not a readonly property
             * Ref. https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
             */
            if ([attributes rangeOfString:@",R,"].location == NSNotFound) {
                if (![key isEqualToString:@"uploadProgress"] && ![key isEqualToString:@"downloadProgress"]) {
                    //do not copy progress block since they do not have getter method and they have already been copied via internalRequest. copy it again will result in overwrite the current value to nil.
                    [self setValue:[object valueForKey:key]
                            forKey:key];
                }
            }
        }
    }
}

@end

@implementation NSString (OOS)

+ (NSString *)OOS_base64md5FromData:(NSData *)data {
    
    if([data length] > UINT32_MAX)
    {
        //The NSData size is too large. The maximum allowable size is UINT32_MAX.
        return nil;
    }
    
    const void    *cStr = [data bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (uint32_t)[data length], result);
    
    NSData *md5 = [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return [md5 base64EncodedStringWithOptions:kNilOptions];
}

- (BOOL)OOS_isBase64Data {
    if ([self length] % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="] invertedSet];
        }
        return [self rangeOfCharacterFromSet:invertedBase64CharacterSet
                                     options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}

- (NSString *)OOS_stringWithURLEncoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self OOS_decodeURLEncoding],
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,/?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)OOS_stringWithURLEncodingPath {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self OOS_decodeURLEncoding],
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)OOS_stringWithURLEncodingPathWithoutPriorDecoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)OOS_decodeURLEncoding {
    NSString *result = [self stringByRemovingPercentEncoding];
    return result?result:self;
}

- (NSString *)OOS_md5String {
    NSData *dataString = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digestArray[CC_MD5_DIGEST_LENGTH];
    CC_MD5([dataString bytes], (CC_LONG)[dataString length], digestArray);

    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", digestArray[i]];
    }
    return md5String;
}

- (NSString *)OOS_md5StringLittleEndian {
    NSData *dataString = [self dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    unsigned char digestArray[CC_MD5_DIGEST_LENGTH];
    CC_MD5([dataString bytes], (CC_LONG)[dataString length], digestArray);

    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", digestArray[i]];
    }
    return md5String;
}

- (BOOL)OOS_isDNSBucketName {
    if ([self length] < 3 || [self length] > 63) {
        return NO;
    }

    if ([self hasSuffix:@"-"]) {
        return NO;
    }

    if ([self OOS_contains:@"_"]) {
        return NO;
    }

    if ([self OOS_contains:@"-."] || [self OOS_contains:@".-"]) {
        return NO;
    }

    if ([[self lowercaseString] isEqualToString:self] == NO) {
        return NO;
    }

    return YES;
}

- (BOOL)OOS_isVirtualHostedStyleCompliant {
    if (![self OOS_isDNSBucketName]) {
        return NO;
    } else {
        return ![self OOS_contains:@"."];
    }
}

- (BOOL)OOS_contains:(NSString *)searchString {
    NSRange range = [self rangeOfString:searchString];

    return (range.location != NSNotFound);
}

@end

@implementation NSFileManager (OOS)

- (BOOL)OOS_atomicallyCopyItemAtURL:(NSURL *)sourceURL
                              toURL:(NSURL *)destinationURL
                     backupItemName:(NSString *)backupItemName
                              error:(NSError **)outError {
    
    NSURL *tempDir = [self URLForDirectory:NSItemReplacementDirectory
                                  inDomain:NSUserDomainMask
                         appropriateForURL:destinationURL
                                    create:YES
                                     error:outError];
    
    if (!tempDir) return NO;
    
    NSURL *tempURL = [tempDir URLByAppendingPathComponent:[destinationURL lastPathComponent]];
    
    BOOL result = [self copyItemAtURL:sourceURL toURL:tempURL error:outError];
    if (result) {
        
        result = [self replaceItemAtURL:destinationURL
                          withItemAtURL:tempURL
                         backupItemName:backupItemName
                                options:NSFileManagerItemReplacementUsingNewMetadataOnly
                       resultingItemURL:nil
                                  error:outError];
        if (NO == result) {
            if (backupItemName) {
                NSURL *backupItemURL = [[destinationURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:backupItemName];
                NSError *error = nil;
                BOOL success = [self replaceItemAtURL:destinationURL
                                        withItemAtURL:backupItemURL
                                       backupItemName:nil
                                              options:NSFileManagerItemReplacementUsingNewMetadataOnly
                                     resultingItemURL:nil error:&error];
                if (NO == success) {
                    if (error) {
                        OOSDDLogError(@"Failed to move backupItemURL directory(%@) to destinationURL(%@): %@" ,backupItemURL,destinationURL,error);
                    }
                    if ([self fileExistsAtPath:[destinationURL path]]) {
                        NSError *removeError = nil;
                        if (NO == [self removeItemAtURL:destinationURL error:&removeError]) {
                            OOSDDLogError(@"Failed to remove destinationURL(%@): %@",destinationURL,removeError);
                        }
                    }
                    
                }
            }
        }
    }
    
    NSError *error;
    if (![self removeItemAtURL:tempDir error:&error])
    {
        OOSDDLogError(@"Failed to remove temp(%@) directory after atomic copy: %@",tempDir,error);
    }
    
    return result;
}

@end
