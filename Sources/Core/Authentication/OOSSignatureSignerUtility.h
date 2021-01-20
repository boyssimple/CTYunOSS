//
//  OOSSignatureSignerUtility.h
//  OOS
//
//  Created by Ye Tong on 2019/2/14.
//  Copyright © 2019 CTYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OOSSignatureSignerUtility : NSObject

+ (NSData *)sha256HMacWithData:(NSData *)data withKey:(NSData *)key;
+ (NSString *)hashString:(NSString *)stringToHash;
+ (NSData *)hash:(NSData *)dataToHash;
+ (NSString *)hexEncode:(NSString *)string;
+ (NSString *)HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(uint32_t)algorithm;

@end
