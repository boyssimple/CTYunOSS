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


#import "OOSExecutor.h"

#import <pthread.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 Get the remaining stack-size of the current thread.

 @param totalSize The total stack size of the current thread.

 @return The remaining size, in bytes, available to the current thread.

 @note This function cannot be inlined, as otherwise the internal implementation could fail to report the proper
 remaining stack space.
 */
__attribute__((noinline)) static size_t remaining_stack_size(size_t *restrict totalSize) {
    pthread_t currentThread = pthread_self();

    // NOTE: We must store stack pointers as uint8_t so that the pointer math is well-defined
    uint8_t *endStack = pthread_get_stackaddr_np(currentThread);
    *totalSize = pthread_get_stacksize_np(currentThread);

    // NOTE: If the function is inlined, this value could be incorrect
    uint8_t *frameAddr = __builtin_frame_address(0);

    return (*totalSize) - (size_t)(endStack - frameAddr);
}

@interface OOSExecutor ()

@property (nonatomic, copy) void(^block)(void(^block)(void));

@end

@implementation OOSExecutor

#pragma mark - Executor methods

+ (instancetype)defaultExecutor {
    static OOSExecutor *defaultExecutor = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultExecutor = [self executorWithBlock:^void(void(^block)(void)) {
            // We prefer to run everything possible immediately, so that there is callstack information
            // when debugging. However, we don't want the stack to get too deep, so if the remaining stack space
            // is less than 10% of the total space, we dispatch to another GCD queue.
            size_t totalStackSize = 0;
            size_t remainingStackSize = remaining_stack_size(&totalStackSize);

            if (remainingStackSize < (totalStackSize / 10)) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
            } else {
                @autoreleasepool {
                    block();
                }
            }
        }];
    });
    return defaultExecutor;
}

+ (instancetype)immediateExecutor {
    static OOSExecutor *immediateExecutor = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        immediateExecutor = [self executorWithBlock:^void(void(^block)(void)) {
            block();
        }];
    });
    return immediateExecutor;
}

+ (instancetype)mainThreadExecutor {
    static OOSExecutor *mainThreadExecutor = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainThreadExecutor = [self executorWithBlock:^void(void(^block)(void)) {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), block);
            } else {
                @autoreleasepool {
                    block();
                }
            }
        }];
    });
    return mainThreadExecutor;
}

+ (instancetype)executorWithBlock:(void(^)(void(^block)(void)))block {
    return [[self alloc] initWithBlock:block];
}

+ (instancetype)executorWithDispatchQueue:(dispatch_queue_t)queue {
    return [self executorWithBlock:^void(void(^block)(void)) {
        dispatch_async(queue, block);
    }];
}

+ (instancetype)executorWithOperationQueue:(NSOperationQueue *)queue {
    return [self executorWithBlock:^void(void(^block)(void)) {
        [queue addOperation:[NSBlockOperation blockOperationWithBlock:block]];
    }];
}

#pragma mark - Initializer

- (instancetype)initWithBlock:(void(^)(void(^block)(void)))block {
    self = [super init];
    if (!self) return self;

    _block = block;

    return self;
}

#pragma mark - Execution

- (void)execute:(void(^)(void))block {
    self.block(block);
}

@end

NS_ASSUME_NONNULL_END
