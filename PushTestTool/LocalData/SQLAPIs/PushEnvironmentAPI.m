
#import "PushEnvironmentAPI.h"

NSString * const  PushEnvironmentAPIID = @"id";
NSString * const  PushEnvironmentAPIType = @"type";
NSString * const  PushEnvironmentAPIName = @"environmentName";
NSString * const  PushEnvironmentAPICerData = @"cerDataString";
NSString * const  PushEnvironmentAPICerPassword = @"cerPassword";

static NSString * const PushEnvironmentSelectedID = @"PushEnvironmentSelectedID";

@implementation PushEnvironmentAPI

- (NSString *)tableName {
	return @"pushEnvironmentTable";
}
- (NSDictionary *)keyAttributes {
	return @{PushEnvironmentAPIID:@"INTEGER",
			 PushEnvironmentAPIName:@"TEXT",
			 PushEnvironmentAPICerData:@"TEXT",
			 PushEnvironmentAPICerPassword:@"TEXT",
			 PushEnvironmentAPIType:@"TEXT"};
}

- (NSString *)primaryKey {
	return PushEnvironmentAPIID;
}
- (BOOL)primaryKeyAutoIncrement {
	return YES;
}

- (void)markSlectedEnvironmentWithEnvironmentID:(NSNumber *)environmentID {
	[[NSUserDefaults standardUserDefaults] setValue:environmentID forKey:PushEnvironmentSelectedID];
}
- (NSDictionary *)querySelected {
	NSString *selectedTokenID = [[NSUserDefaults standardUserDefaults] valueForKey:PushEnvironmentSelectedID];
	if (!selectedTokenID) {
		return nil;
	}
	NSArray *result = [self queryInfoWithCondition:[NSString stringWithFormat:@"%@ = '%@'",PushEnvironmentAPIID,selectedTokenID]];
	if (result.count > 0) {
		return [result firstObject];
	}
	
	return nil;
}
@end
