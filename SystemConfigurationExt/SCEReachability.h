//
//  SCEReachability.h
//  SystemConfigurationExt
//
//  Created by Dan Kalinin on 10/30/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <FoundationExt/FoundationExt.h>

@class SCEReachability;

@protocol SCEReachabilityDelegate;



@protocol SCEReachabilityDelegate <NSEObjectDelegate>

@optional
- (void)sceReachabilityDidUpdateFlags:(SCEReachability *)reachability;

@end



@interface SCEReachability : NSECFObject <SCEReachabilityDelegate>

extern void SCEReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

typedef NS_ENUM(NSUInteger, SCEReachabilityStatus) {
    SCEReachabilityStatusNone,
    SCEReachabilityStatusWiFi,
    SCEReachabilityStatusWWAN
};

@property (nonatomic) dispatch_queue_t dispatchQueue;

@property (readonly) NSEOrderedSet<SCEReachabilityDelegate> *delegates;
@property (readonly) NSString *nodename;
@property (readonly) SCNetworkReachabilityContext context;
@property (readonly) SCNetworkReachabilityFlags flags;
@property (readonly) SCEReachabilityStatus status;

- (instancetype)initWithName:(NSString *)nodename;

- (void)setCallback:(SCNetworkReachabilityCallBack)callout context:(SCNetworkReachabilityContext)context;
- (void)scheduleWithRunLoop:(NSRunLoop *)runLoop runLoopMode:(NSRunLoopMode)runLoopMode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)runLoop runLoopMode:(NSRunLoopMode)runLoopMode;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
