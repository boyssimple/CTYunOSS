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

@class OOSCancellationToken;

/*!
 OOSCancellationTokenSource represents the producer side of a CancellationToken.
 Signals to a CancellationToken that it should be canceled.
 It is a cancellation token that also has methods
 for changing the state of a token by cancelling it.
 */
@interface OOSCancellationTokenSource : NSObject

/*!
 Creates a new cancellation token source.
 */
+ (instancetype)cancellationTokenSource;

/*!
 The cancellation token associated with this CancellationTokenSource.
 */
@property (nonatomic, strong, readonly) OOSCancellationToken *token;

/*!
 Whether cancellation has been requested for this token source.
 */
@property (nonatomic, assign, readonly, getter=isCancellationRequested) BOOL cancellationRequested;

/*!
 Cancels the token if it has not already been cancelled.
 */
- (void)cancel;

/*!
 Schedules a cancel operation on this CancellationTokenSource after the specified number of milliseconds.
 @param millis The number of milliseconds to wait before completing the returned task.
 If delay is `0` the cancel is executed immediately. If delay is `-1` any scheduled cancellation is stopped.
 */
- (void)cancelAfterDelay:(int)millis;

/*!
 Releases all resources associated with this token source,
 including disposing of all registrations.
 */
- (void)dispose;

@end

NS_ASSUME_NONNULL_END
