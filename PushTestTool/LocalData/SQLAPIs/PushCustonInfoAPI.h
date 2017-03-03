#import "SQLLiteDataBaseAPI.h"
extern NSString *const PushCustomInfoID ;
extern NSString *const PushCustomInfoName ;
extern NSString *const PushCustomInfoKeys ;

@interface PushCustonInfoAPI : SQLLiteDataBaseAPI <APISQLLiteManager>
- (void)markSlectedushCustonInfoWithInfoID:(NSNumber *)infoID;
- (NSDictionary *)querySelected;
@end
