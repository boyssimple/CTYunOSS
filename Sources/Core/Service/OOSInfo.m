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
#import "OOSInfo.h"
#import "OOSCategory.h"
#import "OOSCredentialsProvider.h"
#import "CoreService.h"

NSString *const OOSInfoDefault = @"Default";

static NSString *const OOSInfoRoot = @"OOS";
static NSString *const OOSInfoCredentialsProvider = @"CredentialsProvider";
static NSString *const OOSInfoRegion = @"Region";
static NSString *const OOSInfoUserAgent = @"UserAgent";
static NSString *const OOSInfoCognitoIdentity = @"CognitoIdentity";
static NSString *const OOSInfoCognitoIdentityPoolId = @"PoolId";
static NSString *const OOSInfoCognitoUserPool = @"CognitoUserPool";

@interface OOSInfo()

@property (nonatomic, assign) OOSRegionType defaultRegion;
@property (nonatomic, strong) NSDictionary <NSString *, id> *rootInfoDictionary;

@end

@interface OOSServiceInfo()

@property (nonatomic, strong) NSDictionary <NSString *, id> *infoDictionary;

- (instancetype)initWithInfoDictionary:(NSDictionary <NSString *, id> *)infoDictionary
                           serviceName:(NSString *) serviceName;

@end

@implementation OOSInfo

- (instancetype)init {
    if (self = [super init]) {
        
        NSString *pathToOOSConfigJson = [[NSBundle mainBundle] pathForResource:@"OOSconfiguration"
                                                                        ofType:@"json"];
        if (pathToOOSConfigJson) {
            NSData *data = [NSData dataWithContentsOfFile:pathToOOSConfigJson];
            if (!data) {
                OOSDDLogDebug(@"Couldn't read the OOSconfiguration.json file. Skipping load of OOSconfiguration.json.");
            } else {
                NSError *error = nil;
                NSDictionary <NSString *, id> *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:kNilOptions
                                                                                                  error:&error];
                if (!jsonDictionary || [jsonDictionary count] <= 0 || error) {
                    OOSDDLogDebug(@"Couldn't deserialize data from the JSON file or the contents are empty. Please check the OOSconfiguration.json file.");
                } else {
                    _rootInfoDictionary = jsonDictionary;
                }
            }
            
        } else {
            OOSDDLogDebug(@"Couldn't locate the OOSconfiguration.json file. Skipping load of OOSconfiguration.json.");
        }
        
        if (!_rootInfoDictionary) {
            _rootInfoDictionary = [[[NSBundle mainBundle] infoDictionary] objectForKey:OOSInfoRoot];
        }
        
        if (_rootInfoDictionary) {
            NSString *userAgent = [self.rootInfoDictionary objectForKey:OOSInfoUserAgent];
            if (userAgent) {
                [OOSServiceConfiguration addGlobalUserAgentProductToken:userAgent];
            }
        }

		_defaultRegion = OOSRegionHangZhou;
    }
    
    return self;
}

+ (instancetype)defaultOOSInfo {
    static OOSInfo *_defaultOOSInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultOOSInfo = [OOSInfo new];
    });

    return _defaultOOSInfo;
}

- (OOSServiceInfo *)serviceInfo:(NSString *)serviceName
                         forKey:(NSString *)key {
    NSDictionary <NSString *, id> *infoDictionary = [[self.rootInfoDictionary objectForKey:serviceName] objectForKey:key];
    return [[OOSServiceInfo alloc] initWithInfoDictionary:infoDictionary
                                              serviceName:serviceName];
}

- (OOSServiceInfo *)defaultServiceInfo:(NSString *)serviceName {
    return [self serviceInfo:serviceName
                      forKey:OOSInfoDefault];
}

@end

@implementation OOSServiceInfo

- (instancetype)initWithInfoDictionary:(NSDictionary <NSString *, id> *)infoDictionary
                           serviceName:(NSString *) serviceName {
    if (self = [super init]) {
        _infoDictionary = infoDictionary;
        if (!_infoDictionary) {
            _infoDictionary = @{};
        }
		
        _region = OOSRegionUnknown;
        if (_region == OOSRegionUnknown) {
            _region = [OOSInfo defaultOOSInfo].defaultRegion;
        }
        
        if (_region == OOSRegionUnknown) {
            if (![OOSServiceManager defaultServiceManager].defaultServiceConfiguration) {
                OOSDDLogDebug(@"Couldn't read the region configuration from `OOSconfiguration.json` / `Info.plist`. Please check your configuration file if you are loading the configuration through it.");
            }
            return nil;
        }
    }
    
    return self;
}

@end
