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


#import "OOSTaskCompletionSource.h"

#import "OOSTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface OOSTask (OOSTaskCompletionSource)

- (BOOL)trySetResult:(nullable id)result;
- (BOOL)trySetError:(NSError *)error;
- (BOOL)trySetCancelled;

@end

@implementation OOSTaskCompletionSource

#pragma mark - Initializer

+ (instancetype)taskCompletionSource {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;

    _task = [[OOSTask alloc] init];

    return self;
}

#pragma mark - Custom Setters/Getters

- (void)setResult:(nullable id)result {
    if (![self.task trySetResult:result]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the result on a completed task."];
    }
}

- (void)setError:(NSError *)error {
    if (![self.task trySetError:error]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the error on a completed task."];
    }
}

- (void)cancel {
    if (![self.task trySetCancelled]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot cancel a completed task."];
    }
}

- (BOOL)trySetResult:(nullable id)result {
    return [self.task trySetResult:result];
}

- (BOOL)trySetError:(NSError *)error {
    return [self.task trySetError:error];
}

- (BOOL)trySetCancelled {
    return [self.task trySetCancelled];
}

@end

NS_ASSUME_NONNULL_END
