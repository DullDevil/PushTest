

#import <UIKit/UIKit.h>

@interface EditDeviceInfoViewController : UIViewController
@property (nonatomic,copy) NSString *deviceID;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *deviceToken;

@property (nonatomic,copy) void(^editHasFinished)(void);
@end
