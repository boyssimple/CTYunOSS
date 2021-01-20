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
#import "CoreService.h"

#import <UIKit/UIKit.h>
#import "OOSSynchronizedMutableDictionary.h"
#import "OOSURLResponseSerialization.h"
#import "OOSCategory.h"

NSString *const OOSiOSSDKVersion = @"2.6.32";
NSString *const OOSServiceErrorDomain = @"cn.ctyun.OOSServiceErrorDomain";

static NSString *const OOSServiceConfigurationUnknown = @"Unknown";


#pragma mark - CoreService

@implementation CoreService

+ (NSDictionary<NSString *, NSNumber *> *)errorCodeDictionary {
	static NSDictionary *_errorCodeDictionary = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_errorCodeDictionary = @{
								 @"RequestTimeTooSkewed" : @(OOSServiceErrorRequestTimeTooSkewed),
								 @"InvalidSignatureException" : @(OOSServiceErrorInvalidSignatureException),
								 @"RequestExpired" : @(OOSServiceErrorRequestExpired),
								 @"SignatureDoesNotMatch" : @(OOSServiceErrorSignatureDoesNotMatch),
								 @"AuthFailure" : @(OOSServiceErrorAuthFailure),
								 @"AccessDeniedException" : @(OOSServiceErrorAccessDeniedException),
								 @"UnrecognizedClientException" : @(OOSServiceErrorUnrecognizedClientException),
								 @"IncompleteSignature" : @(OOSServiceErrorIncompleteSignature),
								 @"InvalidClientTokenId" : @(OOSServiceErrorInvalidClientTokenId),
								 @"MissingAuthenticationToken" : @(OOSServiceErrorMissingAuthenticationToken),
								 @"AccessDenied" : @(OOSServiceErrorAccessDenied),
								 @"ExpiredToken" : @(OOSServiceErrorExpiredToken),
								 @"InvalidAccessKeyId" : @(OOSServiceErrorInvalidAccessKeyId),
								 @"InvalidToken" : @(OOSServiceErrorInvalidToken),
								 @"TokenRefreshRequired" : @(OOSServiceErrorTokenRefreshRequired),
								 @"AccessFailure" : @(OOSServiceErrorAccessFailure),
								 @"AuthMissingFailure" : @(OOSServiceErrorAuthMissingFailure),
								 @"Throttling" : @(OOSServiceErrorThrottling),
								 @"ThrottlingException" : @(OOSServiceErrorThrottlingException),
								 };
	});
	
	return _errorCodeDictionary;
}

@end

#pragma mark - OOSServiceManager

@interface OOSServiceManager()

@property (nonatomic, strong) OOSSynchronizedMutableDictionary *dictionary;

@end

@implementation OOSServiceManager

+ (instancetype)defaultServiceManager {
	static OOSServiceManager *_defaultServiceManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_defaultServiceManager = [OOSServiceManager new];
	});
	
	return _defaultServiceManager;
}

- (instancetype)init {
	if ( self = [super init]) {
		_dictionary = [OOSSynchronizedMutableDictionary new];
		
	}
	return self;
}

- (void)setDefaultServiceConfiguration:(OOSServiceConfiguration *)defaultServiceConfiguration {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		self->_defaultServiceConfiguration = [defaultServiceConfiguration copy];
	});
}

@end

#pragma mark - OOSServiceConfiguration

@interface OOSServiceConfiguration()

@property (nonatomic, assign) OOSRegionType regionType;
@property (nonatomic, strong) id<OOSCredentialsProvider> credentialsProvider;
@property (nonatomic, strong) OOSEndpoint *endpoint;
@property (nonatomic, strong) NSArray *userAgentProductTokens;

@end

@implementation OOSServiceConfiguration

- (instancetype)init {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"`- init` is not a valid initializer. Use `+ configurationWithRegion:credentialsProvider:` instead."
								 userInfo:nil];
}

- (instancetype)initWithRegion:(OOSRegionType)regionType
		   credentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider {
	if (self = [super init]) {
		_regionType = regionType;
		_credentialsProvider = credentialsProvider;
		_useV4Signer = YES;
	}
	
	return self;
}

- (instancetype)initWithRegion:(OOSRegionType)regionType
					  endpoint:(OOSEndpoint *)endpoint
		   credentialsProvider:(id<OOSCredentialsProvider>)credentialsProvider{
	if(self = [self initWithRegion:regionType credentialsProvider:credentialsProvider]){
		_endpoint = endpoint;
	}
	
	return self;
}

+ (NSString *)baseUserAgent {
	static NSString *_userAgent = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *systemName = [[[UIDevice currentDevice] systemName] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
		if (!systemName) {
			systemName = OOSServiceConfigurationUnknown;
		}
		NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
		if (!systemVersion) {
			systemVersion = OOSServiceConfigurationUnknown;
		}
		NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
		if (!localeIdentifier) {
			localeIdentifier = OOSServiceConfigurationUnknown;
		}
		_userAgent = [NSString stringWithFormat:@"OOS-sdk-iOS/%@ %@/%@ %@", OOSiOSSDKVersion, systemName, systemVersion, localeIdentifier];
	});
	
	NSMutableString *userAgent = [NSMutableString stringWithString:_userAgent];
	for (NSString *prefix in _globalUserAgentPrefixes) {
		[userAgent appendFormat:@" %@", prefix];
	}
	
	return [NSString stringWithString:userAgent];
}

static NSMutableArray *_globalUserAgentPrefixes = nil;

+ (void)addGlobalUserAgentProductToken:(NSString *)productToken {
	if (productToken) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			_globalUserAgentPrefixes = [NSMutableArray new];
		});
		
		if (![_globalUserAgentPrefixes containsObject:productToken]) {
			[_globalUserAgentPrefixes addObject:productToken];
		}
	}
}

- (NSString *)userAgent {
	NSMutableString *userAgent = [NSMutableString stringWithString:[OOSServiceConfiguration baseUserAgent]];
	for (NSString *prefix in self.userAgentProductTokens) {
		[userAgent appendFormat:@" %@", prefix];
	}
	
	return [NSString stringWithString:userAgent];
}

- (void)addUserAgentProductToken:(NSString *)productToken {
	if (productToken) {
		if (self.userAgentProductTokens) {
			if (![self.userAgentProductTokens containsObject:productToken]) {
				NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self.userAgentProductTokens];
				[mutableArray addObject:productToken];
				self.userAgentProductTokens = [NSArray arrayWithArray:mutableArray];
			}
		} else {
			self.userAgentProductTokens = @[productToken];
		}
	}
}

- (id)copyWithZone:(NSZone *)zone {
	OOSServiceConfiguration *configuration = [[OOSServiceConfiguration alloc] initWithRegion:self.regionType credentialsProvider:self.credentialsProvider];
	configuration.userAgentProductTokens = self.userAgentProductTokens;
	configuration.endpoint = self.endpoint;
	
	return configuration;
}

@end

#pragma mark - OOSEndpoint

static NSString *const OOSRegionNameHangZhou = @"hz";
static NSString *const OOSRegionNameJiangShu = @"js";
static NSString *const OOSRegionNameChangSha = @"hncs";
static NSString *const OOSRegionNameGuangZhou = @"gz";
static NSString *const OOSRegionNameXiAn = @"snxa";
static NSString *const OOSRegionNameBeiJing2 = @"bj2";
static NSString *const OOSRegionNameNeiMeng2 = @"nm2";
static NSString *const OOSRegionNameShangHaiHQ = @"hqsh";
static NSString *const OOSRegionNameBeiJingHQ = @"hqbj";

static NSString *const OOSRegionNameNeiMeng = @"nm";
static NSString *const OOSRegionNameFuJian = @"fj";
static NSString *const OOSRegionNameFuJian2 = @"fj2";
static NSString *const OOSRegionNameZhengZhou = @"cn";
static NSString *const OOSRegionNameShenYang = @"lnsy";
static NSString *const OOSRegionNameShiJiaZhuang = @"hesjz";
static NSString *const OOSRegionNameJinHua = @"zjjh";
static NSString *const OOSRegionNameChengDu = @"sccd";
static NSString *const OOSRegionNameWuLuMuQi = @"xjwlmq";
static NSString *const OOSRegionNameGanShuLanZhou = @"gslz";
static NSString *const OOSRegionNameShanDongQingDao = @"sdqd";
static NSString *const OOSRegionNameGuiZhouGuiYang = @"gzgy";
static NSString *const OOSRegionNameHuBeiWuHan = @"hbwh";
static NSString *const OOSRegionNameXiZangLaSa = @"xzls";
static NSString *const OOSRegionNameAnHuiWuHu = @"ahwh";


static NSString *const OOSServiceNameS3 = @"s3";

@interface OOSEndpoint()

- (void) setRegion:(OOSRegionType)regionType;

@end

@implementation OOSEndpoint

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `- initWithRegion:useUnsafeURL:` instead."
                                 userInfo:nil];
}

- (instancetype)initWithRegion:(OOSRegionType)regionType {
	return [self initWithRegion:regionType useUnsafeURL:YES];
}

- (instancetype)initWithRegion:(OOSRegionType)regionType
                  useUnsafeURL:(BOOL)useUnsafeURL {
    if (self = [super init]) {
		_serviceName = @"s3";
		_useV6Version = YES;
        _regionType = regionType;
        _useUnsafeURL = useUnsafeURL;
        _regionName = [self regionNameFromType:regionType];
        if (!_regionName) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Invalid region type."
                                         userInfo:nil];
        }

        _URL = [self URLWithRegion:_regionType
                        regionName:_regionName
                      useUnsafeURL:useUnsafeURL];
		
		_IAMURL = [self IAMURLWithRegion:_regionType
							  regionName:_regionName
						 	useUnsafeURL:useUnsafeURL];
		
        _hostName = [_URL host];
    }

    return self;
}

- (instancetype)initWithRegion:(OOSRegionType)regionType
                           URL:(NSURL *)URL {
    if (self = [super init]) {
		_serviceName = @"s3";
		_useV6Version = YES;
        _regionType = regionType;
        _useUnsafeURL = [[URL scheme] isEqualToString:@"http"];
        _regionName = [self regionNameFromType:regionType];
        _URL = URL;
        _hostName = [_URL host];
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL{
    if (self = [super init]) {
		_serviceName = @"s3";
        _URL = URL;
        _hostName = [_URL host];
        if ([[_URL scheme].lowercaseString isEqualToString:@"https"]) {
            _useUnsafeURL = NO;
        }else{
            _useUnsafeURL = YES;
        }
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString{
    return [self initWithURL:[[NSURL alloc] initWithString:URLString]];
}

- (void) setRegion:(OOSRegionType)regionType {
    _regionType = regionType;
    _regionName = [self regionNameFromType:regionType];
}

- (NSString *)regionNameFromType:(OOSRegionType)regionType {
    switch (regionType) {
        case OOSRegionHangZhou:
            return OOSRegionNameHangZhou;
		case OOSRegionJiangShu:
			return OOSRegionNameJiangShu;
		case OOSRegionChangSha:
			return OOSRegionNameChangSha;
		case OOSRegionGuangZhou:
			return OOSRegionNameGuangZhou;
		case OOSRegionXiAn:
			return OOSRegionNameXiAn;
		case OOSRegionBeiJing2:
			return OOSRegionNameBeiJing2;
		case OOSRegionNeiMeng2:
			return OOSRegionNameNeiMeng2;
		case OOSRegionShangHaiHQ:
			return OOSRegionNameShangHaiHQ;
		case OOSRegionBeiJingHQ:
			return OOSRegionNameBeiJingHQ;

		case OOSRegionNeiMeng:
			return OOSRegionNameNeiMeng;
		case OOSRegionFuJian:
			return OOSRegionNameFuJian;
		case OOSRegionFuJian2:
			return OOSRegionNameFuJian2;
		case OOSRegionZhengZhou:
			return OOSRegionNameZhengZhou;
		case OOSRegionShenYang:
			return OOSRegionNameShenYang;
		case OOSRegionShiJiaZhuang:
			return OOSRegionNameShiJiaZhuang;
		case OOSRegionJinHua:
			return OOSRegionNameJinHua;
		case OOSRegionChengDu:
			return OOSRegionNameChengDu;
		case OOSRegionWuLuMuQi:
			return OOSRegionNameWuLuMuQi;
		case OOSRegionGanShuLanZhou:
			return OOSRegionNameGanShuLanZhou;
		case OOSRegionShanDongQingDao:
			return OOSRegionNameShanDongQingDao;
		case OOSRegionGuiZhouGuiYang:
			return OOSRegionNameGuiZhouGuiYang;
		case OOSRegionHuBeiWuHan:
			return OOSRegionNameHuBeiWuHan;
		case OOSRegionXiZangLaSa:
			return OOSRegionNameXiZangLaSa;
		case OOSRegionAnHuiWuHu:
			return OOSRegionNameAnHuiWuHu;
			
        default:
            return nil;
    }
}

- (NSURL *)URLWithRegion:(OOSRegionType)regionType
              regionName:(NSString *)regionName
            useUnsafeURL:(BOOL)useUnsafeURL {

    NSString *HTTPType = @"https";
    if (useUnsafeURL) {
        HTTPType = @"http";
    }

	if (_useV6Version) {
		return [NSURL URLWithString:[NSString stringWithFormat:@"%@://oos-cn.ctyunapi.cn", HTTPType]];
	} else {
		return [NSURL URLWithString:[NSString stringWithFormat:@"%@://oos-%@.ctyunapi.cn", HTTPType, regionName]];
	}
}

- (NSURL *)IAMURLWithRegion:(OOSRegionType)regionType
			  regionName:(NSString *)regionName
			useUnsafeURL:(BOOL)useUnsafeURL {
	
	NSString *HTTPType = @"https";
	if (useUnsafeURL) {
		HTTPType = @"http";
	}
	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://oos-%@-iam.ctyunapi.cn", HTTPType, regionName]];
	
	return URL;
}

@end
