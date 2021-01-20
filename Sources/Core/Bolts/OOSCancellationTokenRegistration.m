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


#import "OOSCancellationTokenRegistration.h"

#import "OOSCancellationToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface OOSCancellationTokenRegistration ()

@property (nonatomic, weak) OOSCancellationToken *token;
@property (nullable, nonatomic, strong) OOSCancellationBlock cancellationObserverBlock;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic) BOOL disposed;

@end

@interface OOSCancellationToken (OOSCancellationTokenRegistration)

- (void)unregisterRegistration:(OOSCancellationTokenRegistration *)registration;

@end

@implementation OOSCancellationTokenRegistration

+ (instancetype)registrationWithToken:(OOSCancellationToken *)token delegate:(OOSCancellationBlock)delegate {
    OOSCancellationTokenRegistration *registration = [OOSCancellationTokenRegistration new];
    registration.token = token;
    registration.cancellationObserverBlock = delegate;
    return registration;
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    _lock = [NSObject new];
    
    return self;
}

- (void)dispose {
    @synchronized(self.lock) {
        if (self.disposed) {
            return;
        }
        self.disposed = YES;
    }

    OOSCancellationToken *token = self.token;
    if (token != nil) {
        [token unregisterRegistration:self];
        self.token = nil;
    }
    self.cancellationObserverBlock = nil;
}

- (void)notifyDelegate {
    @synchronized(self.lock) {
        [self throwIfDisposed];
        self.cancellationObserverBlock();
    }
}

- (void)throwIfDisposed {
    NSAssert(!self.disposed, @"Object already disposed");
}

@end

NS_ASSUME_NONNULL_END
