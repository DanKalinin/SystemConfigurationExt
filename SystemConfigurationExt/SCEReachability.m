//
//  SCEReachability.m
//  SystemConfigurationExt
//
//  Created by Dan Kalinin on 10/30/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "SCEReachability.h"



@interface SCEReachability ()

@property SCNetworkReachabilityRef target;
@property NSString *nodename;
@property SCNetworkReachabilityContext context;

@end



@implementation SCEReachability

void SCEReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    SCEReachability *reachability = (__bridge SCEReachability *)info;
    [reachability.delegates SCEReachabilityDidUpdateFlags:reachability];
}

@dynamic delegates;

- (instancetype)initWithTarget:(SCNetworkReachabilityRef)target {
    self = super.init;
    if (self) {
        self.target = target;
        
        SCNetworkReachabilityContext context = {0};
        context.info = (__bridge void *)self;
        self.context = context;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)nodename {
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithName(NULL, nodename.UTF8String);
    self = [self initWithTarget:target];
    if (self) {
        self.nodename = nodename;
    }
    return self;
}

- (void)dealloc {
    CFRelease(self.target);
}

- (NSString *)description {
    SCNetworkReachabilityFlags flags = self.flags;
    
    NSMutableArray *descriptions = NSMutableArray.array;
    
    NSString *description = [NSString stringWithFormat:@"TransientConnection - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsTransientConnection)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"Reachable - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsReachable)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionRequired - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsConnectionRequired)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionOnTraffic - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"InterventionRequired - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsInterventionRequired)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"ConnectionOnDemand - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsConnectionOnDemand)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsLocalAddress - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsIsLocalAddress)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsDirect - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsIsDirect)];
    [descriptions addObject:description];
    
    description = [NSString stringWithFormat:@"IsWWAN - %i", (BOOL)(flags & kSCNetworkReachabilityFlagsIsWWAN)];
    [descriptions addObject:description];
    
    description = [descriptions componentsJoinedByString:@"\r\n"];
    return description;
}

- (void)setCallback:(SCNetworkReachabilityCallBack)callout context:(SCNetworkReachabilityContext)context {
    Boolean success = SCNetworkReachabilitySetCallback(self.target, callout, &context);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (void)scheduleWithRunLoop:(NSRunLoop *)runLoop runLoopMode:(NSRunLoopMode)runLoopMode {
    Boolean success = SCNetworkReachabilityScheduleWithRunLoop(self.target, runLoop.getCFRunLoop, (__bridge CFStringRef)runLoopMode);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)runLoop runLoopMode:(NSRunLoopMode)runLoopMode {
    Boolean success = SCNetworkReachabilityUnscheduleFromRunLoop(self.target, runLoop.getCFRunLoop, (__bridge CFStringRef)runLoopMode);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (void)startMonitoring {
    [self setCallback:SCEReachabilityCallBack context:self.context];
    if (NSError.nseThreadError) {
    } else {
        [self scheduleWithRunLoop:self.loop runLoopMode:NSDefaultRunLoopMode];
    }
}

- (void)stopMonitoring {
    [self setCallback:NULL context:self.context];
    if (NSError.nseThreadError) {
    } else {
        [self unscheduleFromRunLoop:self.loop runLoopMode:NSDefaultRunLoopMode];
    }
}

#pragma mark - Accessors

- (void)setDispatchQueue:(dispatch_queue_t)dispatchQueue {
    Boolean success = SCNetworkReachabilitySetDispatchQueue(self.target, dispatchQueue);
    if (success) {
        _dispatchQueue = dispatchQueue;
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags = 0;
    Boolean success = SCNetworkReachabilityGetFlags(self.target, &flags);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
    return flags;
}

- (SCEReachabilityStatus)status {
    SCNetworkReachabilityFlags flags = self.flags;
    if ((flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired) && !(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            return SCEReachabilityStatusWWAN;
        } else {
            return SCEReachabilityStatusWiFi;
        }
    } else {
        return SCEReachabilityStatusNone;
    }
}

@end
