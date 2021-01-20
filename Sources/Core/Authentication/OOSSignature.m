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


#import "OOSSignature.h"
#import <CommonCrypto/CommonCrypto.h>
#import "OOSCategory.h"
#import "OOSCredentialsProvider.h"
#import "CoreService.h"
#import "OOSTask.h"
#import "OOSCocoaLumberjack.h"

NSString *const OOSSignatureV2Algorithm = @"OOS";
NSString *const OOSSignatureV2Terminator = @"OOS4_request";
NSString *const OOSSignatureV4Algorithm = @"AWS4-HMAC-SHA256";
NSString *const OOSSignatureV4Terminator = @"aws4_request";
NSString *const OOSSignatureUnsignedPayload = @"UNSIGNED-PAYLOAD";

#pragma mark - OOSSignatureV4Signer
@implementation OOSSignatureV4Signer

- (OOSTask *)interceptRequest:(NSMutableURLRequest *)request {
    [request addValue:request.URL.host forHTTPHeaderField:@"Host"];
	
    return [[self.credentialsProvider credentials] continueWithSuccessBlock:^id _Nullable(OOSTask<OOSCredentials *> * _Nonnull task) {
        OOSCredentials *credentials = task.result;
        // clear authorization header if set
        [request setValue:nil forHTTPHeaderField:@"Authorization"];

        if (credentials) {
			NSString *authorization = [self signS3Request:request credentials:credentials];

            if (authorization) {
                [request setValue:authorization forHTTPHeaderField:@"Authorization"];
            }
        }
        return nil;
    }];
}

- (NSString *)signS3Request:(NSMutableURLRequest *)urlRequest
                  credentials:(OOSCredentials *)credentials {
	
	NSString *contentType = [urlRequest valueForHTTPHeaderField:@"Content-Type"];
	if (contentType == nil) {
		contentType = @"";
	}
	// 奇怪，为啥要增加这个判断？
//	[urlRequest setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	
    NSDate *date = [NSDate OOS_clockSkewFixedDate];
	[urlRequest setValue:[date OOS_stringValue:OOSDateISO8601DateFormat2] forHTTPHeaderField:@"X-Amz-Date"];
	
	NSString *dateStamp = [date OOS_stringValue:OOSDateShortDateFormat1];
	NSString *scope = [NSString stringWithFormat:@"%@/%@/%@/%@", dateStamp, self.endpoint.regionName, self.endpoint.serviceName, OOSSignatureV4Terminator];
	NSString *signingCredentials = [NSString stringWithFormat:@"%@/%@", credentials.accessKey, scope];

    // compute canonical request
    NSString *httpMethod = urlRequest.HTTPMethod;
    // URL.path returns unescaped path
    // For S3,  url-encoded URI need to be decoded before generate  CanonicalURI, otherwise, signature doesn't match occurs. (I.e. CanonicalURI for "/ios-v2-test-445901470/name%3A" will still be  "/ios-v2-test-445901470/name%3A".  "%3A" -> ":" -> "%3A")
    NSString *cfPath = (NSString*)CFBridgingRelease(CFURLCopyPath((CFURLRef)urlRequest.URL));
    NSString *path = [cfPath OOS_stringWithURLEncodingPath];
    
    if (path.length == 0) {
        path = [NSString stringWithFormat:@"/"];
    }
	
	NSString *query = urlRequest.URL.query;
    if (query == nil) {
        query = [NSString stringWithFormat:@""];
    }
	
	// Compute contentSha256
	NSUInteger contentLength = (unsigned long)[[urlRequest HTTPBody] length];

	//using Content-Length with value of '0' cause auth issue, remove it.
	NSString *contentSha256;
	if ([self.endpoint.serviceName isEqualToString:@"sts"]) {
		// iam 相关的接口contentsha256直接设定为"UNSIGNED-PAYLOAD"，不参与签名
		contentSha256 = OOSSignatureUnsignedPayload;
	} else if (contentLength == 0) {
		[urlRequest setValue:nil forHTTPHeaderField:@"Content-Length"];
		contentSha256 = @"UNSIGNED-PAYLOAD";
	} else {
		[urlRequest setValue:[NSString stringWithFormat:@"%lu", contentLength] forHTTPHeaderField:@"Content-Length"];
		contentSha256 = [OOSSignatureSignerUtility hexEncode:[[NSString alloc] initWithData:[OOSSignatureSignerUtility hash:[urlRequest HTTPBody]] encoding:NSASCIIStringEncoding]];
	}
	
	NSString *nobody = [[urlRequest allHTTPHeaderFields] objectForKey:@"x-ctyun-nobody"];
	if ( nobody != nil ) {
		// trick 某些请求虽然拥有body，也是s3服务，但不参与计算
		contentSha256 = OOSSignatureUnsignedPayload;
		[urlRequest setValue:nil forHTTPHeaderField:@"x-ctyun-nobody"];
		[urlRequest setValue:nil forHTTPHeaderField:@"Content-Length"];
	}
	
	[urlRequest setValue:contentSha256 forHTTPHeaderField:@"x-amz-content-sha256"];

    //Set Content-MD5 header field if required by server.
    if (([ urlRequest.HTTPMethod isEqualToString:@"PUT"] && ([[[urlRequest URL] query] hasPrefix:@"tagging"] ||
                                                             [[[urlRequest URL] query] hasPrefix:@"lifecycle"] ||
                                                             [[[urlRequest URL] query] hasPrefix:@"cors"]))
        || ([urlRequest.HTTPMethod isEqualToString:@"POST"] && [[[urlRequest URL] query] hasPrefix:@"delete"])
		|| ([urlRequest.HTTPMethod isEqualToString:@"POST"] && [[[urlRequest URL] query] hasPrefix:@"uploadId"])
        ) {
        if (![urlRequest valueForHTTPHeaderField:@"Content-MD5"]) {
            [urlRequest setValue:[NSString OOS_base64md5FromData:urlRequest.HTTPBody] forHTTPHeaderField:@"Content-MD5"];
        }
    }
	
	// 移除不参与签名的元素
	NSMutableDictionary *headers = [[urlRequest allHTTPHeaderFields] mutableCopy];
	[headers removeObjectForKey:@"user-agent"];
	
	NSMutableArray *removed = [NSMutableArray new];
	for (NSString *key in headers) {
		if ([key hasPrefix:@"x-ctyun-"]) {
			[removed addObject:key];
		}
	}
	
	[headers removeObjectsForKeys:removed];
	
	NSString *canonicalRequest = [OOSSignatureV4Signer getCanonicalizedRequest:httpMethod
																		  path:path
																		 query:query
																	   headers:headers
																 contentSha256:contentSha256];
	OOSDDLogVerbose(@"Canonical request: [%@]", canonicalRequest);
	
	NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",
							  OOSSignatureV4Algorithm,
							  [date OOS_stringValue:OOSDateISO8601DateFormat2],
							  scope,
							  [OOSSignatureSignerUtility hexEncode:[OOSSignatureSignerUtility hashString:canonicalRequest]]];
	OOSDDLogVerbose(@"String to Sign: [%@]", stringToSign);
	
	NSData *kSigning  = [OOSSignatureV4Signer getDerivedKey:credentials.secretKey
														 date:dateStamp
													   region:self.endpoint.regionName
														service:self.endpoint.serviceName];
	
	NSData *signature = [OOSSignatureSignerUtility sha256HMacWithData:[stringToSign dataUsingEncoding:NSUTF8StringEncoding]
															  withKey:kSigning];
	NSString *signatureString = [OOSSignatureSignerUtility hexEncode:[[NSString alloc] initWithData:signature
																						   encoding:NSASCIIStringEncoding]];
	
	NSString *authorization = [NSString stringWithFormat:@"%@ Credential=%@, SignedHeaders=%@, Signature=%@",
							   OOSSignatureV4Algorithm,
							   signingCredentials,
							   [OOSSignatureSigner getSignedHeadersString:headers],
							   signatureString];
	OOSDDLogDebug(@"authorization: %@", authorization);
	
    return authorization;
}

+ (NSData *)getDerivedKey:(NSString *)secret date:(NSString *)dateStamp region:(NSString *)regionName service:(NSString *)serviceName {
	// OOS4 uses a series of derived keys, formed by hashing different pieces of data
	NSString *kSecret = [NSString stringWithFormat:@"%@%@", @"AWS4", secret];
	NSData *kDate = [OOSSignatureSignerUtility sha256HMacWithData:[dateStamp dataUsingEncoding:NSUTF8StringEncoding]
														  withKey:[kSecret dataUsingEncoding:NSUTF8StringEncoding]];
	NSData *kRegion = [OOSSignatureSignerUtility sha256HMacWithData:[regionName dataUsingEncoding:NSASCIIStringEncoding]
															withKey:kDate];
	NSData *kService = [OOSSignatureSignerUtility sha256HMacWithData:[serviceName dataUsingEncoding:NSUTF8StringEncoding]
															 withKey:kRegion];
	NSData *kSigning = [OOSSignatureSignerUtility sha256HMacWithData:[OOSSignatureV4Terminator dataUsingEncoding:NSUTF8StringEncoding]
															 withKey:kService];
	//TODO: cache this derived key?
	return kSigning;
}

+ (OOSTask<NSURL *> *)generateQueryStringForSignatureV4WithCredentialProvider:(id<OOSCredentialsProvider>)credentialsProvider
																   httpMethod:(OOSHTTPMethod)httpMethod
															   expireDuration:(int32_t)expireDuration
																	 endpoint:(OOSEndpoint *)endpoint
																	  keyPath:(NSString *)keyPath
															   requestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders
															requestParameters:(NSDictionary<NSString *, id> *)requestParameters
																	 signBody:(BOOL)signBody{
	
	return [[credentialsProvider credentials] continueWithSuccessBlock:^id _Nullable(OOSTask<OOSCredentials *> * _Nonnull task) {
		OOSCredentials *credentials = task.result;
		
		//Implementation of V4 signaure http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
		NSMutableString *queryString = [NSMutableString new];
		
		//Append Identifies the version of OOS Signature and the algorithm that you used to calculate the signature.
		[queryString appendFormat:@"%@=%@&",@"X-Amz-Algorithm",OOSSignatureV4Algorithm];
		
		//Get ClockSkew Fixed Date
		NSDate *currentDate = [NSDate OOS_clockSkewFixedDate];
		
		//Format of X-Amz-Credential : <your-access-key-id>/<date>/<AWS-region>/<AWS-service>/aws4_request.
		NSString *scope = [NSString stringWithFormat:@"%@/%@/%@/%@",
						   [currentDate OOS_stringValue:OOSDateShortDateFormat1],
						   endpoint.regionName,
						   endpoint.serviceName,
						   OOSSignatureV4Terminator];
		
		NSString *signingCredentials = [NSString stringWithFormat:@"%@/%@",credentials.accessKey, scope];
		//need to replace "/" with "%2F"
		NSString *xAmzCredentialString = [signingCredentials stringByReplacingOccurrencesOfString:@"/" withString:@"\%2F"];
		
		[queryString appendFormat:@"%@=%@&",@"X-Amz-Credential",xAmzCredentialString];
		
		//X-Amz-Date in ISO 8601 format, for example, 20130721T201207Z. This value must match the date value used to calculate the signature.
		[queryString appendFormat:@"%@=%@&",@"X-Amz-Date",[currentDate OOS_stringValue:OOSDateISO8601DateFormat2]];
		
		//X-Amz-Expires, Provides the time period, in seconds, for which the generated presigned URL is valid.
		//For example, 86400 (24 hours). This value is an integer. The minimum value you can set is 1, and the maximum is 604800 (seven days).
		[queryString appendFormat:@"%@=%d&", @"X-Amz-Expires", expireDuration];
		
		/*
		 X-Amz-SignedHeaders Lists the headers that you used to calculate the signature. The HTTP host header is required.
		 Any x-amz-* headers that you plan to add to the request are also required for signature calculation.
		 In general, for added security, you should sign all the request headers that you plan to include in your request.
		 */
		
		[queryString appendFormat:@"%@=%@&", @"X-Amz-SignedHeaders", [[OOSSignatureV4Signer getSignedHeadersString:requestHeaders] OOS_stringWithURLEncoding]];
		
		//add additionalParameters to queryString
		for (NSString *key in requestParameters) {
			if ([requestParameters[key] isKindOfClass:[NSArray class]]) {
				NSArray<NSString *> *parameterValues = requestParameters[key];
				for (NSString *paramValue in parameterValues) {
					[queryString appendFormat:@"%@=%@&", [key OOS_stringWithURLEncoding], [paramValue OOS_stringWithURLEncoding]];
				}
			} else if ([requestParameters[key] isKindOfClass:[NSString class]]) {
				NSString *value = requestParameters[key];
				[queryString appendFormat:@"%@=%@&",[key OOS_stringWithURLEncoding], [value OOS_stringWithURLEncoding]];
			} else {
				// Only @[NSString: NSString] and @[NSString: NSArray<NSString>] supported currently
				@throw [NSException exceptionWithName:NSInternalInconsistencyException
											   reason:@"Invalid requestParameters dictionary. Supported Dictionaries include [NSString: NSString] and [NSString: NSArray<NSString>]"
											 userInfo:nil];
			}
		}
		
		// =============  generate v4 signature string ===================
		
		/* Canonical Request Format:
		 *
		 * HTTP-VERB + "\n" +  (e.g. GET, PUT, POST)
		 * Canonical URI + "\n" + (e.g. /test.txt)
		 * Canonical Query String + "\n" (multiple queryString need to sorted by QueryParameter)
		 * Canonical Headrs + "\n" + (multiple headers need to be sorted by HeaderName)
		 * Signed Headers + "\n" + (multiple headers need to be sorted by HeaderName)
		 * "UNSIGNED-PAYLOAD"
		 */
		
		
		NSString *httpMethodString = [NSString oos_stringWithHTTPMethod:httpMethod];
		
		//CanonicalURI is the URI-encoded version of the absolute path component of the URI—everything starting with the "/" that follows the domain name and up to the end of the string or to the question mark character ('?') if you have query string parameters. e.g. https://s3.amazonaws.com/examplebucket/myphoto.jpg /examplebucket/myphoto.jpg is the absolute path. In the absolute path, you don't encode the "/".
		
		NSString *canonicalURI = [NSString stringWithFormat:@"/%@", [keyPath OOS_stringWithURLEncodingPath]]; //keyPath is not url-encoded.
		
		NSString *contentSha256;
		if(signBody && httpMethod == OOSHTTPMethodGET){
			//in case of http get we sign the body as an empty string only if the sign body flag is set to true
			contentSha256 = [OOSSignatureSignerUtility hexEncode:[[NSString alloc] initWithData:[OOSSignatureSignerUtility hash:[@"" dataUsingEncoding:NSUTF8StringEncoding]] encoding:NSASCIIStringEncoding]];
		}else{
			contentSha256 = @"UNSIGNED-PAYLOAD";
		}
		//Generate Canonical Request
		NSString *canonicalRequest = [OOSSignatureV4Signer getCanonicalizedRequest:httpMethodString
																			  path:canonicalURI
																			 query:queryString
																		   headers:requestHeaders
																	 contentSha256:contentSha256];
		OOSDDLogVerbose(@"AWSS4 PresignedURL Canonical request: [%@]", canonicalRequest);
		
		//Generate String to Sign
		NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",
								  OOSSignatureV4Algorithm,
								  [currentDate OOS_stringValue:OOSDateISO8601DateFormat2],
								  scope,
								  [OOSSignatureSignerUtility hexEncode:[OOSSignatureSignerUtility hashString:canonicalRequest]]];
		
		OOSDDLogVerbose(@"AWS4 PresignedURL String to Sign: [%@]", stringToSign);
		
		//Generate Signature
		NSData *kSigning  = [OOSSignatureV4Signer getDerivedKey:credentials.secretKey
															 date:[currentDate OOS_stringValue:OOSDateShortDateFormat1]
														   region:endpoint.regionName
														  service:endpoint.serviceName];
		NSData *signature = [OOSSignatureSignerUtility sha256HMacWithData:[stringToSign dataUsingEncoding:NSUTF8StringEncoding]
																  withKey:kSigning];
		NSString *signatureString = [OOSSignatureSignerUtility hexEncode:[[NSString alloc] initWithData:signature
																							   encoding:NSASCIIStringEncoding]];
		
		// ============  generate v4 signature string (END) ===================
		
		[queryString appendFormat:@"%@=%@", @"X-Amz-Signature", signatureString];
		
		NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@?%@", endpoint.URL.scheme, endpoint.hostName, keyPath, queryString];
		
		return [NSURL URLWithString:urlString];
	}];
}

@end


#pragma mark - OOSSignatureV2Signer
@implementation OOSSignatureV2Signer

- (OOSTask *)interceptRequest:(NSMutableURLRequest *)request {
	[request addValue:request.URL.host forHTTPHeaderField:@"Host"];
	
	return [[self.credentialsProvider credentials] continueWithSuccessBlock:^id _Nullable(OOSTask<OOSCredentials *> * _Nonnull task) {
		OOSCredentials *credentials = task.result;
		// clear authorization header if set
		[request setValue:nil forHTTPHeaderField:@"Authorization"];
		
		if (credentials) {
			NSString *authorization = [self signS3Request:request credentials:credentials];
			
			if (authorization) {
				[request setValue:authorization forHTTPHeaderField:@"Authorization"];
			}
		}
		return nil;
	}];
}

- (NSString *)signS3Request:(NSMutableURLRequest *)urlRequest
				credentials:(OOSCredentials *)credentials {
	
	NSMutableDictionary *headers = [[urlRequest allHTTPHeaderFields] mutableCopy];
	
	NSString *contentType = [urlRequest valueForHTTPHeaderField:@"Content-Type"];
	if (contentType == nil) {
		contentType = @"";
	}
	
	NSDate *date = [NSDate OOS_clockSkewFixedDate];
	
	NSString *dateTime  = [date OOS_stringValue:OOSDateRFC822DateFormat1];
	[urlRequest setValue:dateTime forHTTPHeaderField:@"Date"];
	
	// compute canonical request
	NSString *httpMethod = urlRequest.HTTPMethod;
	// URL.path returns unescaped path
	// For S3,  url-encoded URI need to be decoded before generate  CanonicalURI, otherwise, signature doesn't match occurs. (I.e. CanonicalURI for "/ios-v2-test-445901470/name%3A" will still be  "/ios-v2-test-445901470/name%3A".  "%3A" -> ":" -> "%3A")
	NSString *cfPath = (NSString*)CFBridgingRelease(CFURLCopyPath((CFURLRef)urlRequest.URL));
	NSString *path = [cfPath OOS_stringWithURLEncodingPath];
	
	if (path.length == 0) {
		path = [NSString stringWithFormat:@"/"];
	}
	
	NSString *query = urlRequest.URL.query;
	if (query == nil) {
		query = [NSString stringWithFormat:@""];
	}
	
	//using Content-Length with value of '0' cause auth issue, remove it.
	NSUInteger contentLength = [[urlRequest allHTTPHeaderFields][@"Content-Length"] integerValue];
	if (contentLength == 0) {
		[urlRequest setValue:nil forHTTPHeaderField:@"Content-Length"];
	}
	
	//Set Content-MD5 header field if required by server.
	if (([ urlRequest.HTTPMethod isEqualToString:@"PUT"] && ([[[urlRequest URL] query] hasPrefix:@"tagging"] ||
															 [[[urlRequest URL] query] hasPrefix:@"lifecycle"] ||
															 [[[urlRequest URL] query] hasPrefix:@"cors"]))
		|| ([urlRequest.HTTPMethod isEqualToString:@"POST"] && [[[urlRequest URL] query] hasPrefix:@"delete"])
		|| ([urlRequest.HTTPMethod isEqualToString:@"POST"] && [[[urlRequest URL] query] hasPrefix:@"uploadId"])
		) {
		if (![urlRequest valueForHTTPHeaderField:@"Content-MD5"]) {
			[urlRequest setValue:[NSString OOS_base64md5FromData:urlRequest.HTTPBody] forHTTPHeaderField:@"Content-MD5"];
		}
	}
	
	//	StringToSign = HTTP-VERB + "\n" +
	//	Content-MD5 + "\n" +
	//	Content-Type + "\n" +
	//	Date + "\n" +
	//	CanonicalizedAmzHeaders +
	//	CanonicalizedResource;
	
	NSString *contentMD5 = [urlRequest valueForHTTPHeaderField:@"Content-MD5"];
	if (contentMD5 == nil) {
		contentMD5 = @"";
	}
	NSString *CanonicalizedAmzHeaders = [OOSSignatureSigner getCanonicalizedHeaderString:headers];
	NSString *CanonicalizedResource = [OOSSignatureSigner getCanonicalizedResource:httpMethod path:path query:query headers:headers];
	
	NSString *dateString = [urlRequest valueForHTTPHeaderField:@"Date"];
	if (dateString == nil) {
		dateString = @"";
	}
	NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@",
							  urlRequest.HTTPMethod,
							  contentMD5,
							  contentType,
							  dateString,
							  CanonicalizedAmzHeaders,
							  CanonicalizedResource];
	OOSDDLogDebug(@"String to Sign: %@", stringToSign);
	
	NSData *stringToSignData = [stringToSign dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString *signatureString = [OOSSignatureSignerUtility HMACSign:stringToSignData withKey:credentials.secretKey usingAlgorithm:kCCHmacAlgSHA1];
	
	NSString *prefix = @"OOS";
	// 批量删除接口需要设置为AWS
	if ([query isEqualToString:@"delete="]) {
		prefix = @"AWS";
	}
	
	NSString *accessKey = credentials.accessKey;
	NSString *authorization = [NSString stringWithFormat:@"%@ %@:%@",
							   prefix,
							   accessKey,
							   signatureString];
	
	return authorization;
}


+ (OOSTask<NSURL *> *)generateQueryStringForSignatureV2WithCredentialProvider:(id<OOSCredentialsProvider>)credentialsProvider
																   httpMethod:(OOSHTTPMethod)httpMethod
															   expireDuration:(int32_t)expireDuration
																	 endpoint:(OOSEndpoint *)endpoint
																	  keyPath:(NSString *)keyPath
															   requestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders
															requestParameters:(NSDictionary<NSString *, id> *)requestParameters
																	 signBody:(BOOL)signBody{
	
	return [[credentialsProvider credentials] continueWithSuccessBlock:^id _Nullable(OOSTask<OOSCredentials *> * _Nonnull task) {
		OOSCredentials *credentials = task.result;
		
		NSMutableString *queryString = [NSMutableString new];
		
		//Append Identifies the version of OOS Signature and the algorithm that you used to calculate the signature.
		//		[queryString appendFormat:@"%@=%@&",@"X-Amz-Algorithm",OOSSignatureV2Algorithm];
		
		//Get ClockSkew Fixed Date
		NSDate *currentDate = [NSDate OOS_clockSkewFixedDate];
		
		//Format of X-Amz-Credential : <your-access-key-id>/<date>/<OOS-region>/.
		NSString *scope = [NSString stringWithFormat:@"%@/%@/",
						   [currentDate OOS_stringValue:OOSDateShortDateFormat1],
						   endpoint.regionName];
		
		NSString *signingCredentials = [NSString stringWithFormat:@"%@/%@",credentials.accessKey, scope];
		//need to replace "/" with "%2F"
		NSString *xAmzCredentialString = [signingCredentials stringByReplacingOccurrencesOfString:@"/" withString:@"\%2F"];
		
		[queryString appendFormat:@"%@=%@&",@"X-Amz-Credential",xAmzCredentialString];
		
		//X-Amz-Date in ISO 8601 format, for example, 20130721T201207Z. This value must match the date value used to calculate the signature.
		[queryString appendFormat:@"%@=%@&",@"X-Amz-Date",[currentDate OOS_stringValue:OOSDateISO8601DateFormat2]];
		
		//X-Amz-Expires, Provides the time period, in seconds, for which the generated presigned URL is valid.
		//For example, 86400 (24 hours). This value is an integer. The minimum value you can set is 1, and the maximum is 604800 (seven days).
		[queryString appendFormat:@"%@=%d&", @"X-Amz-Expires", expireDuration];
		
		/*
		 X-Amz-SignedHeaders Lists the headers that you used to calculate the signature. The HTTP host header is required.
		 Any x-amz-* headers that you plan to add to the request are also required for signature calculation.
		 In general, for added security, you should sign all the request headers that you plan to include in your request.
		 */
		
		//		[queryString appendFormat:@"%@=%@&", @"X-Amz-SignedHeaders", [[OOSSignatureV2Signer getSignedHeadersString:requestHeaders] OOS_stringWithURLEncoding]];
		
		//add additionalParameters to queryString
		for (NSString *key in requestParameters) {
			if ([requestParameters[key] isKindOfClass:[NSArray class]]) {
				NSArray<NSString *> *parameterValues = requestParameters[key];
				for (NSString *paramValue in parameterValues) {
					[queryString appendFormat:@"%@=%@&", [key OOS_stringWithURLEncoding], [paramValue OOS_stringWithURLEncoding]];
				}
			} else if ([requestParameters[key] isKindOfClass:[NSString class]]) {
				NSString *value = requestParameters[key];
				[queryString appendFormat:@"%@=%@&",[key OOS_stringWithURLEncoding], [value OOS_stringWithURLEncoding]];
			} else {
				// Only @[NSString: NSString] and @[NSString: NSArray<NSString>] supported currently
				@throw [NSException exceptionWithName:NSInternalInconsistencyException
											   reason:@"Invalid requestParameters dictionary. Supported Dictionaries include [NSString: NSString] and [NSString: NSArray<NSString>]"
											 userInfo:nil];
			}
		}
		
		// =============  generate signature string ===================
		/* Canonical Request Format:
		 *
		 * HTTP-VERB + "\n" +  (e.g. GET, PUT, POST)
		 * Canonical URI + "\n" + (e.g. /test.txt)
		 * Canonical Query String + "\n" (multiple queryString need to sorted by QueryParameter)
		 * Canonical Headrs + "\n" + (multiple headers need to be sorted by HeaderName)
		 * Signed Headers + "\n" + (multiple headers need to be sorted by HeaderName)
		 * "UNSIGNED-PAYLOAD"
		 */
		
		NSString *httpMethodString = [NSString oos_stringWithHTTPMethod:httpMethod];
		
		//CanonicalURI is the URI-encoded version of the absolute path component of the URI—everything starting with the "/" that follows the domain name and up to the end of the string or to the question mark character ('?') if you have query string parameters. e.g. https://s3.amazonOOS.com/examplebucket/myphoto.jpg /examplebucket/myphoto.jpg is the absolute path. In the absolute path, you don't encode the "/".
		
		NSString *canonicalURI = [NSString stringWithFormat:@"/%@", [keyPath OOS_stringWithURLEncodingPath]]; //keyPath is not url-encoded.
		
		NSString *contentSha256;
		if(signBody && httpMethod == OOSHTTPMethodGET){
			//in case of http get we sign the body as an empty string only if the sign body flag is set to true
			contentSha256 = [OOSSignatureSignerUtility hexEncode:[[NSString alloc] initWithData:[OOSSignatureSignerUtility hash:[@"" dataUsingEncoding:NSUTF8StringEncoding]] encoding:NSASCIIStringEncoding]];
		}else{
			contentSha256 = @"UNSIGNED-PAYLOAD";
		}
		//Generate Canonical Request
		NSString *canonicalRequest = [OOSSignatureV2Signer getCanonicalizedRequest:httpMethodString
																			  path:canonicalURI
																			 query:queryString
																		   headers:requestHeaders
																	 contentSha256:contentSha256];
		
		//Generate String to Sign
		NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",
								  OOSSignatureV2Algorithm,
								  [currentDate OOS_stringValue:OOSDateISO8601DateFormat2],
								  scope,
								  [OOSSignatureSignerUtility hexEncode:[OOSSignatureSignerUtility hashString:canonicalRequest]]];
		
		//Generate Signature
		NSData *kSigning  = [OOSSignatureV2Signer getDerivedKey:credentials.secretKey
														   date:[currentDate OOS_stringValue:OOSDateShortDateFormat1]
														 region:endpoint.regionName];
		
		NSData *signature = [OOSSignatureSignerUtility sha256HMacWithData:[stringToSign dataUsingEncoding:NSUTF8StringEncoding]
																  withKey:kSigning];
		NSString *signatureString = [OOSSignatureSignerUtility hexEncode:[[NSString alloc] initWithData:signature
																							   encoding:NSASCIIStringEncoding]];
		
		// ============  generate signature string (END) ===================
		
		[queryString appendFormat:@"%@=%@", @"X-Amz-Signature", signatureString];
		
		NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@?%@", endpoint.URL.scheme, endpoint.hostName, keyPath, queryString];
		
		return [NSURL URLWithString:urlString];
	}];
}

@end

