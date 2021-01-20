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

#import "OOSReachability.h"
#import <netdb.h>
#import <arpa/inet.h>
#import "OOSCocoaLumberjack.h"

// ----------------------------------------------------------------------
#pragma mark - ARC-Safe Memory Management -
// ----------------------------------------------------------------------

// Full version at https://github.com/kstenerud/ARCSafe-MemManagement
#if __has_feature(objc_arc)
    #define oos_as_release(X)
    #define oos_as_autorelease(X)        (X)
    #define oos_as_autorelease_noref(X)
    #define oos_as_superdealloc()
    #define oos_as_bridge                __bridge
#else
    #define oos_as_release(X)           [(X) release]
    #define oos_as_autorelease(X)       [(X) autorelease]
    #define oos_as_autorelease_noref(X) [(X) autorelease]
    #define oos_as_superdealloc()       [super dealloc]
    #define oos_as_bridge
#endif


#define kOOSKVOProperty_Flags     @"flags"
#define kOOSKVOProperty_Reachable @"reachable"
#define kOOSKVOProperty_WWANOnly  @"WWANOnly"


// ----------------------------------------------------------------------
#pragma mark - KSReachability -
// ----------------------------------------------------------------------

@interface OOSReachability ()

@property(nonatomic,readwrite,retain) NSString* hostname;
@property(nonatomic,readwrite,assign) SCNetworkReachabilityFlags flags;
@property(nonatomic,readwrite,assign) BOOL reachable;
@property(nonatomic,readwrite,assign) BOOL WWANOnly;
@property(nonatomic,readwrite,assign) SCNetworkReachabilityRef reachabilityRef;
@property(atomic,readwrite,assign) BOOL initialized;

@end

static void onReachabilityChanged(SCNetworkReachabilityRef target,
                                  SCNetworkReachabilityFlags flags,
                                  void* info);


@implementation OOSReachability

@synthesize onInitializationComplete = _onInitializationComplete;
@synthesize onReachabilityChanged = _onReachabilityChanged;
@synthesize flags = _flags;
@synthesize reachable = _reachable;
@synthesize WWANOnly = _WWANOnly;
@synthesize reachabilityRef = _reachabilityRef;
@synthesize hostname = _hostname;
@synthesize notificationName = _notificationName;
@synthesize initialized = _initialized;

+ (OOSReachability*) reachabilityToHost:(NSString*) hostname
{
    return oos_as_autorelease([[self alloc] initWithHost:hostname]);
}

+ (OOSReachability*) reachabilityToLocalNetwork
{
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

    return oos_as_autorelease([[self alloc] initWithAddress:(const struct sockaddr*)&address]);
}

+ (OOSReachability*) reachabilityToInternet
{
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    
    return oos_as_autorelease([[self alloc] initWithAddress:(const struct sockaddr*)&address]);
}

- (id) initWithHost:(NSString*) hostname
{
    hostname = [self extractHostName:hostname];
    const char* name = [hostname UTF8String];

    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET;

    if([hostname length] > 0)
    {
        if(inet_pton(address.sin6_family, name, &address.sin6_addr) != 1)
        {
            address.sin6_family = AF_INET6;
            if(inet_pton(address.sin6_family, name, &address.sin6_addr) != 1)
            {
                return [self initWithReachabilityRef:SCNetworkReachabilityCreateWithName(NULL, name)
                                            hostname:hostname];
            }
        }
    }

    return [self initWithAddress:(const struct sockaddr*)&address];
}

- (id) initWithAddress:(const struct sockaddr*) address
{
    return [self initWithReachabilityRef:SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, address)
                                hostname:nil];
}

- (id) initWithReachabilityRef:(SCNetworkReachabilityRef) reachabilityRef
                      hostname:(NSString*)hostname
{
    if((self = [super init]))
    {
        if(reachabilityRef == NULL)
        {
            OOSDDLogError(@"KSReachability Error: %s: Could not resolve reachability destination", __PRETTY_FUNCTION__);
            goto init_failed;
        }
        else
        {
            self.hostname = hostname;
            self.reachabilityRef = reachabilityRef;

            SCNetworkReachabilityContext context = {0, (oos_as_bridge void*)self, NULL,  NULL, NULL};
            if(!SCNetworkReachabilitySetCallback(self.reachabilityRef,
                                                 onReachabilityChanged,
                                                 &context))
            {
                OOSDDLogError(@"KSReachability Error: %s: SCNetworkReachabilitySetCallback failed", __PRETTY_FUNCTION__);
                goto init_failed;
            }

            if(!SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef,
                                                         CFRunLoopGetMain(),
                                                         kCFRunLoopDefaultMode))
            {
                OOSDDLogError(@"KSReachability Error: %s: SCNetworkReachabilityScheduleWithRunLoop failed", __PRETTY_FUNCTION__);
                goto init_failed;
            }

            // If you create a reachability ref using SCNetworkReachabilityCreateWithAddress(),
            // it won't trigger from the runloop unless you kick it with SCNetworkReachabilityGetFlags()
            if([hostname length] == 0)
            {
                SCNetworkReachabilityFlags flags;
                // Note: This won't block because there's no host to look up.
                if(!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
                {
                    OOSDDLogError(@"KSReachability Error: %s: SCNetworkReachabilityGetFlags failed", __PRETTY_FUNCTION__);
                    goto init_failed;
                }

                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   [self onReachabilityFlagsChanged:flags];
                               });
            }
        }
    }
    return self;

init_failed:
    oos_as_release(self);
    self = nil;
    return self;
}

- (void) dealloc
{
    if(_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef,
                                                   CFRunLoopGetMain(),
                                                   kCFRunLoopDefaultMode);
        CFRelease(_reachabilityRef);
    }
    oos_as_release(_hostname);
    oos_as_release(_notificationName);
    oos_as_release(_onReachabilityChanged);
    oos_as_superdealloc();
}

- (NSString*) extractHostName:(NSString*) potentialURL
{
    if(potentialURL == nil)
    {
        return nil;
    }

    NSString* host = [[NSURL URLWithString:potentialURL] host];
    if(host != nil)
    {
        return host;
    }
    return potentialURL;
}

- (BOOL) isReachableWithFlags:(SCNetworkReachabilityFlags) flags
{
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
    {
        // Not reachable at all.
        return NO;
    }

    if(!(flags & kSCNetworkReachabilityFlagsConnectionRequired))
    {
        // Reachable with no connection required.
        return YES;
    }

    if((flags & (kSCNetworkReachabilityFlagsConnectionOnDemand |
                 kSCNetworkReachabilityFlagsConnectionOnTraffic)) &&
       !(flags & kSCNetworkReachabilityFlagsInterventionRequired))
    {
        // Automatic connection with no user intervention required.
        return YES;
    }

    return NO;
}

- (BOOL) isReachableWWANOnlyWithFlags:(SCNetworkReachabilityFlags) flags
{
#if TARGET_OS_IPHONE
    BOOL isReachable = [self isReachableWithFlags:flags];
    BOOL isWWANOnly = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;
    return isReachable && isWWANOnly;
#else
#pragma unused(flags)
    return NO;
#endif
}

- (OOSReachabilityCallback) onInitializationComplete
{
    @synchronized(self)
    {
        return _onInitializationComplete;
    }
}

- (void) setOnInitializationComplete:(OOSReachabilityCallback) onInitializationComplete
{
    @synchronized(self)
    {
        oos_as_autorelease_noref(_onInitializationComplete);
        _onInitializationComplete = [onInitializationComplete copy];
        if(_onInitializationComplete != nil && self.initialized)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self callInitializationComplete];
                           });
        }
    }
}

- (void) callInitializationComplete
{
    // This method expects to be called on the main run loop so that
    // all callbacks occur on the main run loop.
    @synchronized(self)
    {
        OOSReachabilityCallback callback = self.onInitializationComplete;
        self.onInitializationComplete = nil;
        if(callback != nil)
        {
            callback(self);
        }
    }
}

- (void) onReachabilityFlagsChanged:(SCNetworkReachabilityFlags) flags
{
    // This method expects to be called on the main run loop so that
    // all callbacks occur on the main run loop.
    @synchronized(self)
    {
        BOOL wasInitialized = self.initialized;

        if(_flags != flags || !wasInitialized)
        {
            BOOL reachable = [self isReachableWithFlags:flags];
            BOOL WWANOnly = [self isReachableWWANOnlyWithFlags:flags];
            BOOL rChanged = (_reachable != reachable) || !wasInitialized;
            BOOL wChanged = (_WWANOnly != WWANOnly) || !wasInitialized;

            [self willChangeValueForKey:kOOSKVOProperty_Flags];
            if(rChanged) [self willChangeValueForKey:kOOSKVOProperty_Reachable];
            if(wChanged) [self willChangeValueForKey:kOOSKVOProperty_WWANOnly];

            _flags = flags;
            _reachable = reachable;
            _WWANOnly = WWANOnly;

            if(!wasInitialized)
            {
                self.initialized = YES;
            }

            [self didChangeValueForKey:kOOSKVOProperty_Flags];
            if(rChanged) [self didChangeValueForKey:kOOSKVOProperty_Reachable];
            if(wChanged) [self didChangeValueForKey:kOOSKVOProperty_WWANOnly];

            if(self.onReachabilityChanged != nil)
            {
                self.onReachabilityChanged(self);
            }

            if(self.notificationName != nil)
            {
                NSNotificationCenter* nCenter = [NSNotificationCenter defaultCenter];
                [nCenter postNotificationName:self.notificationName object:self];
            }

            if(!wasInitialized)
            {
                [self callInitializationComplete];
            }
        }
    }
}


static void onReachabilityChanged(__unused SCNetworkReachabilityRef target,
                                  SCNetworkReachabilityFlags flags,
                                  void* info)
{
    OOSReachability* reachability = (oos_as_bridge OOSReachability*) info;
    [reachability onReachabilityFlagsChanged:flags];
}

@end


// ----------------------------------------------------------------------
#pragma mark - KSReachableOperation -
// ----------------------------------------------------------------------

@interface OOSReachableOperation ()

@property(nonatomic,readwrite,retain) OOSReachability* reachability;

@end


@implementation OOSReachableOperation

@synthesize reachability = _reachability;

+ (OOSReachableOperation*) operationWithHost:(NSString*) host
                                  allowWWAN:(BOOL) allowWWAN
                     onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved
{
    return oos_as_autorelease([[self alloc] initWithHost:host
                                           allowWWAN:allowWWAN
                              onReachabilityAchieved:onReachabilityAchieved]);
}

+ (OOSReachableOperation*) operationWithReachability:(OOSReachability*) reachability
                                          allowWWAN:(BOOL) allowWWAN
                             onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved
{
    return oos_as_autorelease([[self alloc] initWithReachability:reachability
                                                   allowWWAN:allowWWAN
                                      onReachabilityAchieved:onReachabilityAchieved]);
}

- (id) initWithHost:(NSString*) host
          allowWWAN:(BOOL) allowWWAN
onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved
{
    return [self initWithReachability:[OOSReachability reachabilityToHost:host]
                            allowWWAN:allowWWAN
               onReachabilityAchieved:onReachabilityAchieved];
}

- (id) initWithReachability:(OOSReachability*) reachability
                  allowWWAN:(BOOL) allowWWAN
     onReachabilityAchieved:(dispatch_block_t) onReachabilityAchieved
{
    if((self = [super init]))
    {
        self.reachability = reachability;
        if(self.reachability == nil || onReachabilityAchieved == nil)
        {
            oos_as_release(self);
            self = nil;
        }
        else
        {
            onReachabilityAchieved = oos_as_autorelease([onReachabilityAchieved copy]);
            OOSReachabilityCallback onReachabilityChanged = ^(OOSReachability* reachability2)
            {
                @synchronized(reachability2)
                {
                    if(reachability2.onReachabilityChanged != nil &&
                       reachability2.reachable &&
                       (allowWWAN || !reachability2.WWANOnly))
                    {
                        reachability2.onReachabilityChanged = nil;
                        onReachabilityAchieved();
                    }
                }
            };

            self.reachability.onReachabilityChanged = onReachabilityChanged;

            // Check once manually in case the host is already reachable.
            onReachabilityChanged(self.reachability);
        }
    }
    return self;
}

- (void) dealloc
{
    oos_as_release(_reachability);
    oos_as_superdealloc();
}

@end
