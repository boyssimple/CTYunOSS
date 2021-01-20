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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 An object that can run a given block.
 */
@interface OOSExecutor : NSObject

/*!
 Returns a default executor, which runs continuations immediately until the call stack gets too
 deep, then dispatches to a new GCD queue.
 */
+ (instancetype)defaultExecutor;

/*!
 Returns an executor that runs continuations on the thread where the previous task was completed.
 */
+ (instancetype)immediateExecutor;

/*!
 Returns an executor that runs continuations on the main thread.
 */
+ (instancetype)mainThreadExecutor;

/*!
 Returns a new executor that uses the given block to execute continuations.
 @param block The block to use.
 */
+ (instancetype)executorWithBlock:(void(^)(void(^block)(void)))block;

/*!
 Returns a new executor that runs continuations on the given queue.
 @param queue The instance of `dispatch_queue_t` to dispatch all continuations onto.
 */
+ (instancetype)executorWithDispatchQueue:(dispatch_queue_t)queue;

/*!
 Returns a new executor that runs continuations on the given queue.
 @param queue The instance of `NSOperationQueue` to run all continuations on.
 */
+ (instancetype)executorWithOperationQueue:(NSOperationQueue *)queue;

/*!
 Runs the given block using this executor's particular strategy.
 @param block The block to execute.
 */
- (void)execute:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
