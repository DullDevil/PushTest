

#import <UIKit/UIKit.h>

@interface IVEHUDManager : NSObject
@property (nonatomic,copy) void(^tapCancle)();
@end

@interface UIViewController (HUD)

- (void)showMessage:(NSString *)message;

- (void)showIndeterminateWithTapCancle:(void(^)())tapCancle;
- (void)showIndeterminate;
- (void)hideIndeterminate;
@end

