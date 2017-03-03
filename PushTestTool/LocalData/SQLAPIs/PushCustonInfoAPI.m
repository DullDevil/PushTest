#import "PushCustonInfoAPI.h"
NSString * const PushCustomInfoID = @"customInfoID";
NSString * const PushCustomInfoName = @"customInfoName";
NSString * const PushCustomInfoKeys = @"customInfoKeys";

static NSString * const PushCustomInfoSelectedID = @"PushCustomInfoSelectedID";


@implementation PushCustonInfoAPI

- (NSString *)tableName {
    return @"pushCustomInfoTable";
}
- (NSDictionary *)keyAttributes {
    return @{PushCustomInfoKeys:@"TEXT",
             PushCustomInfoName:@"TEXT",
			 PushCustomInfoID:@"INTEGER"};
}

- (NSString *)primaryKey {
    return PushCustomInfoID;
}

- (BOOL)primaryKeyAutoIncrement {
    return YES;
}

- (void)markSlectedushCustonInfoWithInfoID:(NSNumber *)infoID {
	[[NSUserDefaults standardUserDefaults] setValue:infoID forKey:PushCustomInfoSelectedID];
}
- (NSDictionary *)querySelected {
	NSString *selectedTokenID = [[NSUserDefaults standardUserDefaults] valueForKey:PushCustomInfoSelectedID];
	if (!selectedTokenID) {
		return nil;
	}
	NSArray *result = [self queryInfoWithCondition:[NSString stringWithFormat:@"%@ = '%@'",PushCustomInfoID,selectedTokenID]];
	if (result.count > 0) {
		return [result firstObject];
	}
	return nil;
}
@end
