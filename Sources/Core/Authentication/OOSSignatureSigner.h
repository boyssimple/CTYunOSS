//
//  OOSSignatureSigner.h
//  OOS
//
//  Created by Ye Tong on 2019/2/14.
//  Copyright © 2019 CTYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OOSNetworking.h"

@class OOSEndpoint;
@protocol OOSCredentialsProvider;

@interface OOSSignatureSigner : NSObject <OOSNetworkingRequestInterceptor>

@property (nonatomic, strong, readonly) id<OOSCredentialsProvider> credentialsProvider;
@property (nonatomic, strong) OOSEndpoint *endpoint;

- (instancetype)initWithCredentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider
								   endpoint:(OOSEndpoint *)endpoint;

+ (NSString *)getCanonicalizedRequest:(NSString *)method
								 path:(NSString *)path
								query:(NSString *)query
							  headers:(NSDictionary *)headers
						contentSha256:(NSString *)contentSha256;

+ (NSData *)getDerivedKey:(NSString *)secret
					 date:(NSString *)dateStamp
				   region:(NSString *)regionName;

+ (NSString *)getSignedHeadersString:(NSDictionary *)headers;

+ (NSString *)getCanonicalizedHeaderString:(NSDictionary *)headers;

+ (NSString *)getCanonicalizedResource:(NSString *)method path:(NSString *)path query:(NSString *)query headers:(NSDictionary *)headers;

@end

