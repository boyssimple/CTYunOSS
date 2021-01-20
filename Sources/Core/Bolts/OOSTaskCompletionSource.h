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

@class OOSTask<__covariant ResultType>;

/*!
 A OOSTaskCompletionSource represents the producer side of tasks.
 It is a task that also has methods for changing the state of the
 task by settings its completion values.
 */
@interface OOSTaskCompletionSource<__covariant ResultType> : NSObject

/*!
 Creates a new unfinished task.
 */
+ (instancetype)taskCompletionSource;

/*!
 The task associated with this TaskCompletionSource.
 */
@property (nonatomic, strong, readonly) OOSTask<ResultType> *task;

/*!
 Completes the task by setting the result.
 Attempting to set this for a completed task will raise an exception.
 @param result The result of the task.
 */
- (void)setResult:(nullable ResultType)result NS_SWIFT_NAME(set(result:));

/*!
 Completes the task by setting the error.
 Attempting to set this for a completed task will raise an exception.
 @param error The error for the task.
 */
- (void)setError:(NSError *)error NS_SWIFT_NAME(set(error:));

/*!
 Completes the task by marking it as cancelled.
 Attempting to set this for a completed task will raise an exception.
 */
- (void)cancel;

/*!
 Sets the result of the task if it wasn't already completed.
 @returns whether the new value was set.
 */
- (BOOL)trySetResult:(nullable ResultType)result NS_SWIFT_NAME(trySet(result:));

/*!
 Sets the error of the task if it wasn't already completed.
 @param error The error for the task.
 @returns whether the new value was set.
 */
- (BOOL)trySetError:(NSError *)error NS_SWIFT_NAME(trySet(error:));

/*!
 Sets the cancellation state of the task if it wasn't already completed.
 @returns whether the new value was set.
 */
- (BOOL)trySetCancelled;

@end

NS_ASSUME_NONNULL_END
