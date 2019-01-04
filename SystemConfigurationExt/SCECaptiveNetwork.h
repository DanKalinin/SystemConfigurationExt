//
//  SCECaptiveNetwork.h
//  SystemConfigurationExt
//
//  Created by Dan Kalinin on 10/31/18.
//

#import <SystemConfiguration/CaptiveNetwork.h>
#import <Helpers/Helpers.h>

@class SCENetworkInfo;
@class SCECaptiveNetwork;










@interface SCENetworkInfo : NSEDictionaryObject

@property (readonly) NSData *ssidData;
@property (readonly) NSString *ssid;
@property (readonly) NSString *bssid;

@end










@protocol SCECaptiveNetworkDelegate <NSEOperationDelegate>

@end



@interface SCECaptiveNetwork : NSEOperation <SCECaptiveNetworkDelegate>

@property (readonly) NSArray<NSString *> *supportedInterfaces;

- (SCENetworkInfo *)currentNetworkInfo:(NSString *)interfaceName;

@end
