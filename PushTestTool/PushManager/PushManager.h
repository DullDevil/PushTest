
#import <Foundation/Foundation.h>

@protocol PushManagerDelegate <NSObject>
@optional;
- (void)APNSDidConnected;
- (void)APNSDidDisconnected;

- (void)sendSucceed;
- (void)sendFailWithErrorMsg:(NSString *)errorMsg;

@end

typedef NS_ENUM(NSUInteger,PushEnvironmentType) {
	PushEnvironmentTypeDeveloper = 0,
	PushEnvironmentTypeProduction = 1
};

@interface PushManager : NSObject
@property (nonatomic, weak) id <PushManagerDelegate>pushDelegate;
@property (nonatomic, assign,readonly) BOOL isConnected;
- (void)connectAPNSWithPkcs12Data:(NSData *)pkcs12Data password:(NSString *)password type:(PushEnvironmentType)type;
- (void)disconnectAPNS;
- (void)sendWithToken:(NSString *)token pushMessage:(NSString *)pushMessage;
@end
