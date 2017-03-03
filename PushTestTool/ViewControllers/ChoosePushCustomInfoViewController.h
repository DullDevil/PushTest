
#import <UIKit/UIKit.h>

@interface ChoosePushCustomInfoViewController : UIViewController
@property (nonatomic,copy) void(^selectedCallBack)(NSDictionary *selectedInfo);
@end
