//
//  SCEReachability.m
//  SystemConfigurationExt
//
//  Created by Dan Kalinin on 10/30/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "SCEReachability.h"



@interface SCEReachability ()

@property NSString *nodename;
@property SCNetworkReachabilityContext context;

@end



@implementation SCEReachability

void SCEReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    SCEReachability *reachability = (__bridge SCEReachability *)info;
    [reachability.delegates sceReachabilityDidUpdateFlags:reachability];
}

@dynamic delegates;

- (instancetype)initWithObject:(CFTypeRef)object {
    self = [super initWithObject:object];
    
    SCNetworkReachabilityContext context = {0};
    context.info = (__bridge void *)self;
    self.context = context;
    
    return self;
}

- (instancetype)initWithName:(NSString *)nodename {
    SCNetworkReachabilityRef object = SCNetworkReachabilityCreateWithName(NULL, nodename.UTF8String);
    
    self = [self initWithObject:object];
    
    self.nodename = nodename;
    
    return self;
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

- (void)setDispatchQueue:(dispatch_queue_t)dispatchQueue {
    Boolean success = SCNetworkReachabilitySetDispatchQueue(self.object, dispatchQueue);
    if (success) {
        _dispatchQueue = dispatchQueue;
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (SCNetworkReachabilityFlags)flags {
    SCNetworkReachabilityFlags flags = 0;
    Boolean success = SCNetworkReachabilityGetFlags(self.object, &flags);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
    return flags;
}

- (SCEReachabilityStatus)status {
    SCEReachabilityStatus status = SCEReachabilityStatusNone;
    
    SCNetworkReachabilityFlags flags = self.flags;
    if ((flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsConnectionRequired) && !(flags & kSCNetworkReachabilityFlagsInterventionRequired)) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            status = SCEReachabilityStatusWWAN;
        } else {
            status = SCEReachabilityStatusWiFi;
        }
    }
    
    return status;
}

- (void)setCallback:(SCNetworkReachabilityCallBack)callout context:(SCNetworkReachabilityContext)context {
    Boolean success = SCNetworkReachabilitySetCallback(self.object, callout, &context);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (void)scheduleWithRunLoop:(NSRunLoop *)runLoop runLoopMode:(NSRunLoopMode)runLoopMode {
    Boolean success = SCNetworkReachabilityScheduleWithRunLoop(self.object, runLoop.getCFRunLoop, (__bridge CFStringRef)runLoopMode);
    if (success) {
        NSError.nseThreadError = nil;
    } else {
        NSError.nseThreadError = (__bridge_transfer NSError *)SCCopyLastError();
    }
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)runLoop runLoopMode:(NSRunLoopMode)runLoopMode {
    Boolean success = SCNetworkReachabilityUnscheduleFromRunLoop(self.object, runLoop.getCFRunLoop, (__bridge CFStringRef)runLoopMode);
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

@end
