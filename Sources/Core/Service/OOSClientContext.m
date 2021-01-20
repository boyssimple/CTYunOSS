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

#import "OOSClientContext.h"
#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "OOSUICKeyChainStore.h"
#import "OOSCocoaLumberjack.h"

// Public constants
NSString *const OOSClientContextVersion = @"1.0";
NSString *const OOSClientContextHeader = @"x-amz-Client-Context";
NSString *const OOSClientContextHeaderEncoding = @"x-amz-Client-Context-Encoding";

// Private constants
static NSString *const OOSClientContextUnknown = @"Unknown";
static NSString *const OOSClientContextKeychainService = @"cn.ctyun.OOSClientContext";
static NSString *const OOSClientContextKeychainInstallationIdKey = @"cn.ctyun.OOSClientContextKeychainInstallationIdKey";

@interface OOSClientContext()

@end

@implementation OOSClientContext

#pragma mark - Public methods

- (instancetype)init {
    if (self = [super init]) {
        OOSUICKeyChainStore *keychain = [OOSUICKeyChainStore keyChainStoreWithService:OOSClientContextKeychainService];
        _installationId = [keychain stringForKey:OOSClientContextKeychainInstallationIdKey];
        if (!_installationId) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [keychain setString:[[NSUUID UUID] UUIDString]
                             forKey:OOSClientContextKeychainInstallationIdKey];
            });
            _installationId = [keychain stringForKey:OOSClientContextKeychainInstallationIdKey];
        }
        if (_installationId == nil) {
            OOSDDLogError(@"Failed to generate installation_id");
        }

        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *appPackageName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];

        //App details
        _appVersion = appVersion ? appVersion : OOSClientContextUnknown;
        _appBuild = appBuild ? appBuild : OOSClientContextUnknown;
        _appPackageName = appPackageName ? appPackageName : OOSClientContextUnknown;
        _appName = appName ? appName : OOSClientContextUnknown;

        //Device Details
        UIDevice* currentDevice = [UIDevice currentDevice];
        NSString *autoUpdatingLoaleIdentifier = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
        _devicePlatform = [currentDevice systemName] ? [currentDevice systemName] : OOSClientContextUnknown;
        _deviceModel = [currentDevice model] ? [currentDevice model] : OOSClientContextUnknown;
        _deviceModelVersion = [self deviceModelVersionCode] ? [self deviceModelVersionCode] : OOSClientContextUnknown;
        _devicePlatformVersion = [currentDevice systemVersion] ? [currentDevice systemVersion] : OOSClientContextUnknown;
        _deviceManufacturer = @"apple";
        _deviceLocale = autoUpdatingLoaleIdentifier ? autoUpdatingLoaleIdentifier : OOSClientContextUnknown;

        _customAttributes = @{};
        _serviceDetails = [NSMutableDictionary new];
    }

    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *clientDetails = @{@"installation_id": self.installationId?self.installationId:@"UNKNOWN_INSTALLATION_ID",
                                    @"app_package_name": self.appPackageName,
                                    @"app_version_name": self.appVersion,
                                    @"app_version_code": self.appBuild,
                                    @"app_title": self.appName};

    NSDictionary *deviceDetails = @{@"model": self.deviceModel,
                                    @"model_version": self.deviceModelVersion,
                                    @"make": self.deviceManufacturer,
                                    @"platform": self.devicePlatform,
                                    @"platform_version": self.devicePlatformVersion,
                                    @"locale": self.deviceLocale};

    NSDictionary *clientContext = @{@"version": OOSClientContextVersion,
                                    @"client": clientDetails,
                                    @"env": deviceDetails,
                                    @"custom": self.customAttributes,
                                    @"services": self.serviceDetails};

    return clientContext;
}

- (NSString *)JSONString {
    NSDictionary *JSONObject = [self dictionaryRepresentation];
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject
                                                       options:kNilOptions
                                                         error:&error];
    if (!JSONData) {
        OOSDDLogError(@"Failed to serialize JSON Data. [%@]", error);
    }

    return [[NSString alloc] initWithData:JSONData
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)base64EncodedJSONString {
    return [[[self JSONString] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

- (void)setDetails:(id)details
        forService:(NSString *)service {
    if (service) {
        [self.serviceDetails setValue:details
                               forKey:service];
    } else {
        OOSDDLogError(@"'service' cannot be nil.");
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Getter and setters

- (void)setAppVersion:(NSString *)appVersion {
    _appVersion = appVersion ? appVersion : OOSClientContextUnknown;
}

- (void)setAppBuild:(NSString *)appBuild {
    _appBuild = appBuild ? appBuild : OOSClientContextUnknown;
}

- (void)setAppPackageName:(NSString *)appPackageName {
    _appPackageName = appPackageName ? appPackageName : OOSClientContextUnknown;
}

- (void)setAppName:(NSString *)appName {
    _appName = appName ? appName : OOSClientContextUnknown;
}

- (void)setDevicePlatformVersion:(NSString *)devicePlatformVersion {
    _devicePlatformVersion = devicePlatformVersion ? devicePlatformVersion : OOSClientContextUnknown;
}

- (void)setDevicePlatform:(NSString *)devicePlatform {
    _devicePlatform = devicePlatform ? devicePlatform : OOSClientContextUnknown;
}

- (void)setDeviceManufacturer:(NSString *)deviceManufacturer {
    _deviceManufacturer = deviceManufacturer ? deviceManufacturer : OOSClientContextUnknown;
}

- (void)setDeviceModel:(NSString *)deviceModel {
    _deviceModel = deviceModel ? deviceModel : OOSClientContextUnknown;
}

- (void)setDeviceModelVersion:(NSString *)deviceModelVersion {
    _deviceModelVersion = deviceModelVersion ? deviceModelVersion : OOSClientContextUnknown;
}

- (void)setDeviceLocale:(NSString *)deviceLocale {
    _deviceLocale = deviceLocale ? deviceLocale : OOSClientContextUnknown;
}

#pragma mark - Internal

//For model translations see http://theiphonewiki.com/wiki/Models
- (NSString *)deviceModelVersionCode {
    int mib[2];
    size_t len;
    char *machine;

    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);

    NSString *modelVersionCode = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return modelVersionCode;
}

@end
