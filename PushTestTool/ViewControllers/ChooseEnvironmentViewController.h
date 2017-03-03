
#import <UIKit/UIKit.h>

@interface ChooseEnvironmentViewController : UIViewController
@property (nonatomic,copy) void(^selectedCallBack)(NSDictionary *selectedInfo);
@end
