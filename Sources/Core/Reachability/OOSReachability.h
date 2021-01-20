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
#import <SystemConfiguration/SystemConfiguration.h>


/** This is the notification name used in the Apple reachability example.
 * It is not used internally, and is merely a suggested notification name.
 */
#define kOOSDefaultNetworkReachabilityChangedNotification @"kOOSNetworkReachabilityChangedNotification"


@class OOSReachability;

typedef void(^OOSReachabilityCallback)(OOSReachability* reachability);


/** Monitors network connectivity.
 *
 * You can elect to be notified via blocks (onReachabilityChanged),
 * notifications (notificationName), or KVO (flags, reachable, and WWANOnly).
 *
 * All notification methods are disabled by default.
 *
 * Note: Upon construction, this object will fetch its initial reachability
 * state in the background. This means that the reachability status will ALWAYS
 * be "unreachable" until some time after object construction (possibly up to 10
 * seconds, depending on how long the DNS lookup takes). Use the "initialized"
 * property to monitor initialization, or set the callback "onInitializationComplete".
 */
@interface OOSReachability : NSObject

#pragma mark Constructors

/** Reachability to a specific host. Returns nil if an initialization error occurs.
 *
 * @param hostname The name or IP address of the host to monitor. If nil or
 *                 empty string, check reachability to the internet in general.
 */
+ (OOSReachability*) reachabilityToHost:(NSString*) hostname;

/** Reachability to the local (wired or wifi) network. Returns nil if an initialization error occurs.
 */
+ (OOSReachability*) reachabilityToLocalNetwork;

/** Reachability to the internet. Returns nil if an initialization error occurs.
 */
+ (OOSReachability*) reachabilityToInternet;


#pragma mark General Information

/** The host we are monitoring reachability to, if any. */
@property(nonatomic,readonly,retain) NSString* hostname;


#pragma mark Notifications and Callbacks

/** If non-nil, called when the KSReachability object has finished initializing.
 * If initialization has already completed, calls on the next main thread run loop.
 * This block will only be called once, and then discarded (released).
 * Block will be invoked on the main thread.
 */
@property(atomic,readwrite,copy) OOSReachabilityCallback onInitializationComplete;

/** If non-nil, called whenever reachability flags change.
 * Block will be invoked on the main thread.
 */
@property(atomic,readwrite,copy) OOSReachabilityCallback onReachabilityChanged;

/** The notification to send when reachability changes (nil = don't send).
 * Default = nil
 */
@property(nonatomic,readwrite,retain) NSString* notificationName;


#pragma mark KVO Compliant Status Properties

/** The current reachability flags.
 * This property will always report 0 while "initialized" property = NO.
 */
@property(nonatomic,readonly,assign) SCNetworkReachabilityFlags flags;

/** Whether the host is reachable or not.
 * This property will always report NO while "initialized" property = NO.
 */
@property(nonatomic,readonly,assign) BOOL reachable;

/* If YES, the host is only reachable by WWAN (iOS only).
 * This property will always report NO while "initialized" property = NO.
 */
@property(nonatomic,readonly,assign) BOOL WWANOnly;

/** If YES, this object's status properties are valid. */
@property(atomic,readonly,assign) BOOL initialized;

@end



/** A one-time operation to perform as soon as a host is deemed reachable.
 * The operation will only be performed once, regardless of how many times a
 * host becomes reachable.
 */
@interface OOSReachableOperation: NSObject

/** Constructor. Returns nil if an initialization error occurs.
 *
 * @param hostname The name or IP address of the host to monitor. If nil or
 *                 empty string, check reachability to the internet in general.
 *                 If hostname is a URL string, it will use the host portion.
 *
 * @param allowWWAN If NO, a WWAN-only connection is not enough to trigger
 *                  this operation.
 *
 * @param onReachabilityAchieved Invoke when the host becomes reachable.
 *                               This will be invoked ONE TIME ONLY, no matter
 *                               how many times reachability changes.
 *                               Block will be invoked on the main thread.
 */
+ (OOSReachableOperation*) operationWithHost:(NSString*) hostname
                                  allowWWAN:(BOOL) allowWWAN
                     onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved;

/** Constructor. Returns nil if an initialization error occurs.
 *
 * @param reachability A reachability instance. Note: This object will overwrite
 *                     the onReachabilityChanged property.
 *
 * @param allowWWAN If NO, a WWAN-only connection is not enough to trigger
 *                  this operation.
 *
 * @param onReachabilityAchieved Invoke when the host becomes reachable.
 *                               This will be invoked ONE TIME ONLY, no matter
 *                               how many times reachability changes.
 *                               Block will be invoked on the main thread.
 */
+ (OOSReachableOperation*) operationWithReachability:(OOSReachability*) reachability
                                          allowWWAN:(BOOL) allowWWAN
                             onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved;

/** Initializer. Returns nil if an initialization error occurs.
 *
 * @param hostname The name or IP address of the host to monitor. If nil or
 *                 empty string, check reachability to the internet in general.
 *                 If hostname is a URL string, it will use the host portion.
 *
 * @param allowWWAN If NO, a WWAN-only connection is not enough to trigger
 *                  this operation.
 *
 * @param onReachabilityAchieved Invoke when the host becomes reachable.
 *                               This will be invoked ONE TIME ONLY, no matter
 *                               how many times reachability changes.
 *                               Block will be invoked on the main thread.
 */
- (id) initWithHost:(NSString*) hostname
          allowWWAN:(BOOL) allowWWAN
onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved;

/** Initializer. Returns nil if an initialization error occurs.
 *
 * @param reachability A reachability instance. Note: This object will overwrite
 *                     the onReachabilityChanged property.
 *
 * @param allowWWAN If NO, a WWAN-only connection is not enough to trigger
 *                  this operation.
 *
 * @param onReachabilityAchieved Invoke when the host becomes reachable.
 *                               This will be invoked ONE TIME ONLY, no matter
 *                               how many times reachability changes.
 *                               Block will be invoked on the main thread.
 */
- (id) initWithReachability:(OOSReachability*) reachability
                  allowWWAN:(BOOL) allowWWAN
     onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved;

/** Access to internal reachability instance. Use this to monitor for errors. */
@property(nonatomic,readonly,retain) OOSReachability* reachability;

@end
