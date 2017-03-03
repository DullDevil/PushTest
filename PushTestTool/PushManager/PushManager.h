
#import <Foundation/Foundation.h>

@protocol PushManagerDelegate <NSObject>
@optional;
- (void)APNSDidConnected;
- (void)APNSDidDisconnected;

- (void)sendSucceed;
- (void)sendFailWithErrorMsg:(NSString *)errorMsg;

@end

@interface PushManager : NSObject
@property (nonatomic, weak) id <PushManagerDelegate>pushDelegate;
@property (nonatomic, assign,readonly) BOOL isConnected;
- (void)connectAPNSWithPkcs12Data:(NSData *)pkcs12Data password:(NSString *)password;
- (void)disconnectAPNS;
- (void)sendWithToken:(NSString *)token pushMessage:(NSString *)pushMessage;
@end
