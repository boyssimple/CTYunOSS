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

#import "OOSTask.h"

#import <libkern/OSAtomic.h>

#import "OOSBolts.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__ ((noinline)) void OOSbf_warnBlockingOperationOnMainThread() {
	OOSDDLogWarn(@"Warning: A long-running operation is being executed on the main thread. \n"
		  " Break on OOSbf_warnBlockingOperationOnMainThread() to debug.");
}

NSString *const OOSTaskErrorDomain = @"bolts";
NSInteger const kOOSMultipleErrorsError = 80175001;

NSString *const OOSTaskMultipleErrorsUserInfoKey = @"errors";

@interface OOSTask () {
	id _result;
	NSError *_error;
}

@property (nonatomic, assign, readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic, assign, readwrite, getter=isFaulted) BOOL faulted;
@property (nonatomic, assign, readwrite, getter=isCompleted) BOOL completed;

@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSMutableArray *callbacks;

@end

@implementation OOSTask

#pragma mark - Initializer

- (instancetype)init {
	self = [super init];
	if (!self) return self;
	
	_lock = [[NSObject alloc] init];
	_condition = [[NSCondition alloc] init];
	_callbacks = [NSMutableArray array];
	
	return self;
}

- (instancetype)initWithResult:(nullable id)result {
	self = [super init];
	if (!self) return self;
	
	[self trySetResult:result];
	
	return self;
}

- (instancetype)initWithError:(NSError *)error {
	self = [super init];
	if (!self) return self;
	
	[self trySetError:error];
	
	return self;
}

- (instancetype)initCancelled {
	self = [super init];
	if (!self) return self;
	
	[self trySetCancelled];
	
	return self;
}

#pragma mark - Task Class methods

+ (instancetype)taskWithResult:(nullable id)result {
	return [[self alloc] initWithResult:result];
}

+ (instancetype)taskWithError:(NSError *)error {
	return [[self alloc] initWithError:error];
}

+ (instancetype)cancelledTask {
	return [[self alloc] initCancelled];
}

+ (instancetype)taskForCompletionOfAllTasks:(nullable NSArray<OOSTask *> *)tasks {
	__block int32_t total = (int32_t)tasks.count;
	if (total == 0) {
		return [self taskWithResult:nil];
	}
	
	__block int32_t cancelled = 0;
	NSObject *lock = [[NSObject alloc] init];
	NSMutableArray *errors = [NSMutableArray array];
	
	OOSTaskCompletionSource *tcs = [OOSTaskCompletionSource taskCompletionSource];
	for (OOSTask *task in tasks) {
		[task continueWithBlock:^id(OOSTask *t) {
			if (t.error) {
				@synchronized (lock) {
					[errors addObject:t.error];
				}
			} else if (t.cancelled) {
				OSAtomicIncrement32Barrier(&cancelled);
			}
			
			if (OSAtomicDecrement32Barrier(&total) == 0) {
				if (errors.count > 0) {
					if (errors.count == 1) {
						tcs.error = [errors firstObject];
					} else {
						NSError *error = [NSError errorWithDomain:OOSTaskErrorDomain
															 code:kOOSMultipleErrorsError
														 userInfo:@{ OOSTaskMultipleErrorsUserInfoKey: errors }];
						tcs.error = error;
					}
				} else if (cancelled > 0) {
					[tcs cancel];
				} else {
					tcs.result = nil;
				}
			}
			return nil;
		}];
	}
	return tcs.task;
}

+ (instancetype)taskForCompletionOfAllTasksWithResults:(nullable NSArray<OOSTask *> *)tasks {
	return [[self taskForCompletionOfAllTasks:tasks] continueWithSuccessBlock:^id(OOSTask * __unused task) {
		return [tasks valueForKey:@"result"];
	}];
}

+ (instancetype)taskForCompletionOfAnyTask:(nullable NSArray<OOSTask *> *)tasks
{
	__block int32_t total = (int32_t)tasks.count;
	if (total == 0) {
		return [self taskWithResult:nil];
	}
	
	__block int completed = 0;
	__block int32_t cancelled = 0;
	
	NSObject *lock = [NSObject new];
	NSMutableArray<NSError *> *errors = [NSMutableArray new];
	
	OOSTaskCompletionSource *source = [OOSTaskCompletionSource taskCompletionSource];
	for (OOSTask *task in tasks) {
		[task continueWithBlock:^id(OOSTask *t) {
			if (t.error != nil) {
				@synchronized(lock) {
					[errors addObject:t.error];
				}
			} else if (t.cancelled) {
				OSAtomicIncrement32Barrier(&cancelled);
			} else {
				if(OSAtomicCompareAndSwap32Barrier(0, 1, &completed)) {
					[source setResult:t.result];
				}
			}
			
			if (OSAtomicDecrement32Barrier(&total) == 0 &&
				OSAtomicCompareAndSwap32Barrier(0, 1, &completed)) {
				if (cancelled > 0) {
					[source cancel];
				} else if (errors.count > 0) {
					if (errors.count == 1) {
						source.error = errors.firstObject;
					} else {
						NSError *error = [NSError errorWithDomain:OOSTaskErrorDomain
															 code:kOOSMultipleErrorsError
														 userInfo:@{ @"errors": errors }];
						source.error = error;
					}
				}
			}
			// Abort execution of per tasks continuations
			return nil;
		}];
	}
	return source.task;
}


+ (OOSTask<OOSVoid> *)taskWithDelay:(int)millis {
	OOSTaskCompletionSource *tcs = [OOSTaskCompletionSource taskCompletionSource];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, millis * NSEC_PER_MSEC);
	dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		tcs.result = nil;
	});
	return tcs.task;
}

+ (OOSTask<OOSVoid> *)taskWithDelay:(int)millis cancellationToken:(nullable OOSCancellationToken *)token {
	if (token.cancellationRequested) {
		return [OOSTask cancelledTask];
	}
	
	OOSTaskCompletionSource *tcs = [OOSTaskCompletionSource taskCompletionSource];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, millis * NSEC_PER_MSEC);
	dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		if (token.cancellationRequested) {
			[tcs cancel];
			return;
		}
		tcs.result = nil;
	});
	return tcs.task;
}

+ (instancetype)taskFromExecutor:(OOSExecutor *)executor withBlock:(nullable id (^)(void))block {
	return [[self taskWithResult:nil] continueWithExecutor:executor withBlock:^id(OOSTask *task) {
		return block();
	}];
}

#pragma mark - Custom Setters/Getters

- (nullable id)result {
	@synchronized(self.lock) {
		return _result;
	}
}

- (BOOL)trySetResult:(nullable id)result {
	@synchronized(self.lock) {
		if (self.completed) {
			return NO;
		}
		self.completed = YES;
		_result = result;
		[self runContinuations];
		return YES;
	}
}

- (nullable NSError *)error {
	@synchronized(self.lock) {
		return _error;
	}
}

- (BOOL)trySetError:(NSError *)error {
	@synchronized(self.lock) {
		if (self.completed) {
			return NO;
		}
		self.completed = YES;
		self.faulted = YES;
		_error = error;
		[self runContinuations];
		return YES;
	}
}

- (BOOL)isCancelled {
	@synchronized(self.lock) {
		return _cancelled;
	}
}

- (BOOL)isFaulted {
	@synchronized(self.lock) {
		return _faulted;
	}
}

- (BOOL)trySetCancelled {
	@synchronized(self.lock) {
		if (self.completed) {
			return NO;
		}
		self.completed = YES;
		self.cancelled = YES;
		[self runContinuations];
		return YES;
	}
}

- (BOOL)isCompleted {
	@synchronized(self.lock) {
		return _completed;
	}
}

- (void)runContinuations {
	@synchronized(self.lock) {
		[self.condition lock];
		[self.condition broadcast];
		[self.condition unlock];
		for (void (^callback)(void) in self.callbacks) {
			callback();
		}
		[self.callbacks removeAllObjects];
	}
}

#pragma mark - Chaining methods

- (OOSTask *)continueWithExecutor:(OOSExecutor *)executor withBlock:(OOSContinuationBlock)block {
	return [self continueWithExecutor:executor block:block cancellationToken:nil];
}

- (OOSTask *)continueWithExecutor:(OOSExecutor *)executor
							block:(OOSContinuationBlock)block
				cancellationToken:(nullable OOSCancellationToken *)cancellationToken {
	OOSTaskCompletionSource *tcs = [OOSTaskCompletionSource taskCompletionSource];
	
	// Capture all of the state that needs to used when the continuation is complete.
	dispatch_block_t executionBlock = ^{
		if (cancellationToken.cancellationRequested) {
			[tcs cancel];
			return;
		}
		
		id result = block(self);
		if ([result isKindOfClass:[OOSTask class]]) {
			
			id (^setupWithTask) (OOSTask *) = ^id(OOSTask *task) {
				if (cancellationToken.cancellationRequested || task.cancelled) {
					[tcs cancel];
				} else if (task.error) {
					tcs.error = task.error;
				} else {
					tcs.result = task.result;
				}
				return nil;
			};
			
			OOSTask *resultTask = (OOSTask *)result;
			
			if (resultTask.completed) {
				setupWithTask(resultTask);
			} else {
				[resultTask continueWithBlock:setupWithTask];
			}
			
		} else {
			tcs.result = result;
		}
	};
	
	BOOL completed;
	@synchronized(self.lock) {
		completed = self.completed;
		if (!completed) {
			[self.callbacks addObject:[^{
				[executor execute:executionBlock];
			} copy]];
		}
	}
	if (completed) {
		[executor execute:executionBlock];
	}
	
	return tcs.task;
}

- (OOSTask *)continueWithBlock:(OOSContinuationBlock)block {
	return [self continueWithExecutor:[OOSExecutor defaultExecutor] block:block cancellationToken:nil];
}

- (OOSTask *)continueWithBlock:(OOSContinuationBlock)block cancellationToken:(nullable OOSCancellationToken *)cancellationToken {
	return [self continueWithExecutor:[OOSExecutor defaultExecutor] block:block cancellationToken:cancellationToken];
}

- (OOSTask *)continueWithExecutor:(OOSExecutor *)executor
				 withSuccessBlock:(OOSContinuationBlock)block {
	return [self continueWithExecutor:executor successBlock:block cancellationToken:nil];
}

- (OOSTask *)continueWithExecutor:(OOSExecutor *)executor
					 successBlock:(OOSContinuationBlock)block
				cancellationToken:(nullable OOSCancellationToken *)cancellationToken {
	if (cancellationToken.cancellationRequested) {
		return [OOSTask cancelledTask];
	}
	
	return [self continueWithExecutor:executor block:^id(OOSTask *task) {
		if (task.faulted || task.cancelled) {
			return task;
		} else {
			return block(task);
		}
	} cancellationToken:cancellationToken];
}

- (OOSTask *)continueWithSuccessBlock:(OOSContinuationBlock)block {
	return [self continueWithExecutor:[OOSExecutor defaultExecutor] successBlock:block cancellationToken:nil];
}

- (OOSTask *)continueWithSuccessBlock:(OOSContinuationBlock)block cancellationToken:(nullable OOSCancellationToken *)cancellationToken {
	return [self continueWithExecutor:[OOSExecutor defaultExecutor] successBlock:block cancellationToken:cancellationToken];
}

#pragma mark - Syncing Task (Avoid it)

- (void)warnOperationOnMainThread {
	OOSbf_warnBlockingOperationOnMainThread();
}

- (void)waitUntilFinished {
	if ([NSThread isMainThread]) {
		[self warnOperationOnMainThread];
	}
	
	@synchronized(self.lock) {
		if (self.completed) {
			return;
		}
		[self.condition lock];
	}
	// TODO: (nlutsenko) Restructure this to use Bolts-Swift thread access synchronization architecture
	// In the meantime, it's absolutely safe to get `_completed` aka an ivar, as long as it's a `BOOL` aka less than word size.
	while (!_completed) {
		[self.condition wait];
	}
	[self.condition unlock];
}

#pragma mark - NSObject

- (NSString *)description {
	// Acquire the data from the locked properties
	BOOL completed;
	BOOL cancelled;
	BOOL faulted;
	NSString *resultDescription = nil;
	
	@synchronized(self.lock) {
		completed = self.completed;
		cancelled = self.cancelled;
		faulted = self.faulted;
		resultDescription = completed ? [NSString stringWithFormat:@" result = %@", self.result] : @"";
	}
	
	// Description string includes status information and, if available, the
	// result since in some ways this is what a promise actually "is".
	return [NSString stringWithFormat:@"<%@: %p; completed = %@; cancelled = %@; faulted = %@;%@>",
			NSStringFromClass([self class]),
			self,
			completed ? @"YES" : @"NO",
			cancelled ? @"YES" : @"NO",
			faulted ? @"YES" : @"NO",
			resultDescription];
}

@end

NS_ASSUME_NONNULL_END
