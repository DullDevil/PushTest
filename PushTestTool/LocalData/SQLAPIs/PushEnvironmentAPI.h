
#import <Foundation/Foundation.h>
#import "SQLLiteDataBaseAPI.h"
extern NSString * const  PushEnvironmentAPIID;
extern NSString * const  PushEnvironmentAPIType;
extern NSString * const  PushEnvironmentAPIName;
extern NSString * const  PushEnvironmentAPICerData ;
extern NSString * const  PushEnvironmentAPICerPassword ;


@interface PushEnvironmentAPI : SQLLiteDataBaseAPI <APISQLLiteManager>
- (void)markSlectedEnvironmentWithEnvironmentID:(NSNumber *)environmentID;
- (NSDictionary *)querySelected;
@end
