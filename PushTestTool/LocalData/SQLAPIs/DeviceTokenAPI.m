
#import "DeviceTokenAPI.h"

NSString  * const  DeviceTokenAPITokenID = @"tokenID";
NSString  * const  DeviceTokenAPITokenName = @"tokenName";
NSString  * const  DeviceTokenAPITokenContent = @"tokenContent";

static NSString * const DeviceTokenSelectedTokenID = @"DeviceTokenSelectedTokenID";



@implementation DeviceTokenAPI

- (NSString *)tableName {
	return @"deviceTokenTable";
}
- (NSDictionary *)keyAttributes {
	return @{DeviceTokenAPITokenName:@"TEXT",
			 DeviceTokenAPITokenContent:@"TEXT",
			 DeviceTokenAPITokenID:@"INTEGER"};
}

- (NSString *)primaryKey {
	return DeviceTokenAPITokenID;
}
- (BOOL)primaryKeyAutoIncrement {
	return YES;
}
#pragma mark - public method

- (void)markSlectedTokenWithTokenID:(NSNumber *)tokenID {
	[[NSUserDefaults standardUserDefaults] setValue:tokenID forKey:DeviceTokenSelectedTokenID];
}

- (NSDictionary *)querySelected {
	NSString *selectedTokenID = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceTokenSelectedTokenID];
	if (!selectedTokenID) {
		return nil;
	}
	NSArray *result = [self queryInfoWithCondition:[NSString stringWithFormat:@"%@ = '%@'",DeviceTokenAPITokenID,selectedTokenID]];
	if (result.count > 0) {
		return [result firstObject];
	}
	
	return nil;
	
}
@end
