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

#import "OOSSignatureSigner.h"
#import "OOSSignature.h"
#import <CommonCrypto/CommonCrypto.h>
#import "OOSCategory.h"
#import "OOSCredentialsProvider.h"
#import "CoreService.h"
#import "OOSTask.h"
#import "OOSCocoaLumberjack.h"

static NSString *const OOSSigV4Marker = @"OOS4";

@implementation OOSSignatureSigner

+ (instancetype)signerWithCredentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider
									 endpoint:(OOSEndpoint *)endpoint {
	OOSSignatureV2Signer *signer = [[OOSSignatureV2Signer alloc] initWithCredentialsProvider:credentialsProvider
																					endpoint:endpoint];
	return signer;
}

- (instancetype)initWithCredentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider
								   endpoint:(OOSEndpoint *)endpoint {
	if (self = [super init]) {
		_credentialsProvider = credentialsProvider;
		_endpoint = endpoint;
	}
	
	return self;
}

+ (NSString *)getCanonicalizedResource:(NSString *)method path:(NSString *)path query:(NSString *)query headers:(NSDictionary *)headers {
	NSMutableString *canonicalResource = [NSMutableString new];
	[canonicalResource appendString:path];
	
	// add bucket
	NSString *host = headers[@"host"];
	NSArray *hostItems = [host componentsSeparatedByString:@"."];
	if ([hostItems count] >= 4) {
		[canonicalResource insertString:[NSString stringWithFormat:@"/%@", [hostItems firstObject]] atIndex:0];
	}
	
	// add sub resource
	const NSArray *resourcesArray = @[ @"acl", @"lifecycle", @"location", @"logging", @"notification", @"partNumber", @"policy", @"requestPayment", @"torrent", @"uploadId", @"uploads", @"versionId", @"versioning", @"versions", @"website", @"delete", @"cors" ];
	
	__block NSMutableArray *subResourceArray = [NSMutableArray new];
	[[query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSArray *components = [obj componentsSeparatedByString:@"="];
		NSString *key;
		NSUInteger count = [components count];
		if (count > 0 && count <= 2) {
			//can be ?a=b or ?a
			key = components[0];
			if  (! [key isEqualToString:@""] && [resourcesArray indexOfObject:key] != NSNotFound ) {
				[subResourceArray addObject:key];
			}
		}
	}];
	
	[subResourceArray sortUsingSelector:@selector(compare:)];
	NSString *subResource = [subResourceArray componentsJoinedByString:@"&"];
	
	if (subResource != nil && subResource.length > 0 ) {
		if ([method isEqualToString:@"DELETE"] && [subResource isEqualToString:@"trigger"]) {
			[canonicalResource appendFormat:@"?%@", query];
		} else if ([subResource containsString:@"uploadId"] ) {
			[canonicalResource appendFormat:@"?%@", query];
		} else {
			[canonicalResource appendFormat:@"?%@", subResource];
		}
	}
	
	return canonicalResource;
}

+ (NSString *)getCanonicalizedRequest:(NSString *)method path:(NSString *)path query:(NSString *)query headers:(NSDictionary *)headers contentSha256:(NSString *)contentSha256 {
	NSMutableString *canonicalRequest = [NSMutableString new];
	[canonicalRequest appendString:method];
	[canonicalRequest appendString:@"\n"];
	[canonicalRequest appendString:path]; // Canonicalized resource path
	[canonicalRequest appendString:@"\n"];
	
	[canonicalRequest appendString:[OOSSignatureSigner getCanonicalizedQueryString:query]]; // Canonicalized Query String
	[canonicalRequest appendString:@"\n"];
	
	if (contentSha256 != nil){
		[canonicalRequest appendString:[OOSSignatureSigner getCanonicalizedV4HeaderString:headers]];
	}else {
		[canonicalRequest appendString:[OOSSignatureSigner getCanonicalizedHeaderString:headers]];
	}
	
	[canonicalRequest appendString:@"\n"];
	
	[canonicalRequest appendString:[OOSSignatureSigner getSignedHeadersString:headers]];
	[canonicalRequest appendString:@"\n"];
	
	if (contentSha256 != nil){
		[canonicalRequest appendString:[NSString stringWithFormat:@"%@", contentSha256]];
	}
	
	return canonicalRequest;
}

+ (NSString *)getCanonicalizedQueryString:(NSString *)query {
	NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *queryDictionary = [NSMutableDictionary new];
	[[query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSArray *components = [obj componentsSeparatedByString:@"="];
		NSString *key;
		NSString *value = @"";
		NSUInteger count = [components count];
		if (count > 0 && count <= 2) {
			//can be ?a=b or ?a
			key = components[0];
			if  (! [key isEqualToString:@""] ) {
				if (count == 2) {
					//is ?a=b
					value = components[1];
				}
				if (queryDictionary[key]) {
					// If the query parameter has multiple values, add it in the mutable array
					[[queryDictionary objectForKey:key] addObject:value];
				} else {
					// Insert the value for query parameter as an element in mutable array
					[queryDictionary setObject:[@[value] mutableCopy] forKey:key];
				}
			}
		}
	}];
	
	NSMutableArray *sortedQuery = [[NSMutableArray alloc] initWithArray:[queryDictionary allKeys]];
	
	[sortedQuery sortUsingSelector:@selector(compare:)];
	
	NSMutableString *sortedQueryString = [NSMutableString new];
	for (NSString *key in sortedQuery) {
		[queryDictionary[key] sortUsingSelector:@selector(compare:)];
		for (NSString *parameterValue in queryDictionary[key]) {
			[sortedQueryString appendString:key];
			[sortedQueryString appendString:@"="];
			[sortedQueryString appendString:parameterValue];
			[sortedQueryString appendString:@"&"];
		}
	}
	// Remove the trailing & for a valid canonical query string.
	if ([sortedQueryString hasSuffix:@"&"]) {
		return [sortedQueryString substringToIndex:[sortedQueryString length] - 1];
	}
	
	return sortedQueryString;
}

+ (NSString *)getCanonicalizedHeaderString:(NSDictionary *)headers {
	NSMutableArray *sortedHeaders = [[NSMutableArray alloc] initWithArray:[headers allKeys]];
	
	[sortedHeaders sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSMutableString *headerString = [NSMutableString new];
	for (NSString *header in sortedHeaders) {
		NSString *lowerHeader = [header lowercaseString];
		if ( [lowerHeader hasPrefix:@"x-amz-"]) {
			[headerString appendString:[header lowercaseString]];
			[headerString appendString:@":"];
			[headerString appendString:[headers valueForKey:header]];
			[headerString appendString:@"\n"];
		}
	}
	
	// SigV4 expects all whitespace in headers and values to be collapsed to a single space
	NSCharacterSet *whitespaceChars = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [headerString componentsSeparatedByCharactersInSet:whitespaceChars];
	NSArray *nonWhitespace = [parts filteredArrayUsingPredicate:noEmptyStrings];
	return [nonWhitespace componentsJoinedByString:@" "];
}

+ (NSString *)getCanonicalizedV4HeaderString:(NSDictionary *)headers {
	NSMutableArray *sortedHeaders = [[NSMutableArray alloc] initWithArray:[headers allKeys]];
	
	[sortedHeaders sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSMutableString *headerString = [NSMutableString new];
	for (NSString *header in sortedHeaders) {
//		NSString *lowerHeader = [header lowercaseString];
//		if ( [lowerHeader hasPrefix:@"x-amz-"] || [lowerHeader isEqualToString:@"host"] || [lowerHeader isEqualToString:@"content-type"] ) {
			[headerString appendString:[header lowercaseString]];
			[headerString appendString:@":"];
			[headerString appendString:[headers valueForKey:header]];
			[headerString appendString:@"\n"];
//		}
	}
	
	// SigV4 expects all whitespace in headers and values to be collapsed to a single space
	NSCharacterSet *whitespaceChars = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [headerString componentsSeparatedByCharactersInSet:whitespaceChars];
	NSArray *nonWhitespace = [parts filteredArrayUsingPredicate:noEmptyStrings];
	return [nonWhitespace componentsJoinedByString:@" "];
}

+ (NSString *)getSignedHeadersString:(NSDictionary *)headers {
	NSMutableArray *sortedHeaders = [[NSMutableArray alloc] initWithArray:[headers allKeys]];
	
	[sortedHeaders sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSMutableString *headerString = [NSMutableString new];
	for (NSString *header in sortedHeaders) {
		if ([headerString length] > 0) {
			[headerString appendString:@";"];
		}
		[headerString appendString:[header lowercaseString]];
	}
	
	return headerString;
}

+ (NSData *)getDerivedKey:(NSString *)secret date:(NSString *)dateStamp region:(NSString *)regionName {
	// OOS4 uses a series of derived keys, formed by hashing different pieces of data
	NSString *kSecret = [NSString stringWithFormat:@"%@%@", OOSSigV4Marker, secret];
	NSData *kDate = [OOSSignatureSignerUtility sha256HMacWithData:[dateStamp dataUsingEncoding:NSUTF8StringEncoding]
														  withKey:[kSecret dataUsingEncoding:NSUTF8StringEncoding]];
	NSData *kRegion = [OOSSignatureSignerUtility sha256HMacWithData:[regionName dataUsingEncoding:NSASCIIStringEncoding]
															withKey:kDate];
	NSData *kSigning = [OOSSignatureSignerUtility sha256HMacWithData:[OOSSignatureV2Terminator dataUsingEncoding:NSUTF8StringEncoding]
															 withKey:kRegion];
	
	//TODO: cache this derived key?
	return kSigning;
}

- (OOSTask *)interceptRequest:(NSMutableURLRequest *)request {
	return nil;
}

@end

