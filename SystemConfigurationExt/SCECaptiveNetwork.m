//
//  SCECaptiveNetwork.m
//  SystemConfigurationExt
//
//  Created by Dan Kalinin on 10/31/18.
//

#import "SCECaptiveNetwork.h"










@interface SCENetworkInfo ()

@property NSDictionary *dictionary;
@property NSData *ssidData;
@property NSString *ssid;
@property NSString *bssid;

@end



@implementation SCENetworkInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = super.init;
    if (self) {
        self.dictionary = dictionary;
        
        self.ssidData = self.dictionary[(__bridge NSString *)kCNNetworkInfoKeySSIDData];
        self.ssid = self.dictionary[(__bridge NSString *)kCNNetworkInfoKeySSID];
        self.bssid = self.dictionary[(__bridge NSString *)kCNNetworkInfoKeyBSSID];
    }
    return self;
}

- (NSString *)description {
    NSMutableArray *descriptions = NSMutableArray.array;

    NSString *description = [NSString stringWithFormat:@"SSID - %@", self.ssid];
    [descriptions addObject:description];

    description = [NSString stringWithFormat:@"BSSID - %@", self.bssid];
    [descriptions addObject:description];

    description = [descriptions componentsJoinedByString:@"\r\n"];
    return description;
}

@end










@interface SCECaptiveNetwork ()

@end



@implementation SCECaptiveNetwork

+ (instancetype)shared {
    static SCECaptiveNetwork *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
    });
    return shared;
}

- (SCENetworkInfo *)currentNetworkInfo:(NSString *)interfaceName {
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
    if (dictionary) {
        SCENetworkInfo *info = [SCENetworkInfo.alloc initWithDictionary:dictionary];
        return info;
    } else {
        return nil;
    }
}

#pragma mark - Accessors

- (NSArray<NSString *> *)supportedInterfaces {
    NSArray<NSString *> *interfaces = (__bridge_transfer NSArray<NSString *> *)CNCopySupportedInterfaces();
    return interfaces;
}

@end
