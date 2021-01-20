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


#import "OOSCredentialsProvider.h"
#import "OOSTask.h"

static NSString *const OOSCredentialsProviderKeychainAccessKeyId = @"accessKey";
static NSString *const OOSCredentialsProviderKeychainSecretAccessKey = @"secretKey";


@implementation OOSCredentials

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey {
    if (self = [super init]) {
        _accessKey = accessKey;
        _secretKey = secretKey;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{\nOOSCredentials\nAccessKey: %@\nSecretKey: %@\n}",
            self.accessKey,
            self.secretKey];
}

@end

@interface OOSStaticCredentialsProvider()

@property (nonatomic, strong) OOSCredentials *internalCredentials;

@end

@implementation OOSStaticCredentialsProvider

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey {
    if (self = [super init]) {
        _internalCredentials = [[OOSCredentials alloc] initWithAccessKey:accessKey
                                                               secretKey:secretKey];
    }
    return self;
}

- (OOSTask<OOSCredentials *> *)credentials {
    return [OOSTask taskWithResult:self.internalCredentials];
}

- (void)invalidateCachedTemporaryCredentials {
    // No-op
}

@end
