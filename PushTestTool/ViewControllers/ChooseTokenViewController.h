
#import <UIKit/UIKit.h>

@interface ChooseTokenViewController : UIViewController
@property (nonatomic,copy) void(^selectedCallBack)(NSDictionary *selectedInfo);
@end
