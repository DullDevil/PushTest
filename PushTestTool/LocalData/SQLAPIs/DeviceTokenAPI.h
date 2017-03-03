
#import <Foundation/Foundation.h>
#import "SQLLiteDataBaseAPI.h"
extern NSString * const  DeviceTokenAPITokenID;
extern NSString * const  DeviceTokenAPITokenName;
extern NSString * const  DeviceTokenAPITokenContent;


@interface DeviceTokenAPI : SQLLiteDataBaseAPI <APISQLLiteManager>
- (void)markSlectedTokenWithTokenID:(NSNumber *)tokenID;
- (NSDictionary *)querySelected;
@end
