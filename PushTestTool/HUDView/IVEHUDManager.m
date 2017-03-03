
#import "IVEHUDManager.h"
#import "MBProgressHUD.h"

static IVEHUDManager * kHUDManager = nil;

@interface IVEHUDManager ()
@property (nonatomic,strong) MBProgressHUD *messageHUD;
@property (nonatomic,strong) MBProgressHUD *indeterminateHUD;
@end

@implementation IVEHUDManager
+ (IVEHUDManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kHUDManager = [[IVEHUDManager alloc] init];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        kHUDManager.messageHUD = [[MBProgressHUD alloc] initWithView:keyWindow];
        kHUDManager.messageHUD.mode = MBProgressHUDModeText;
        kHUDManager.messageHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        kHUDManager.messageHUD.bezelView.color = [UIColor blackColor];
        kHUDManager.messageHUD.contentColor = [UIColor whiteColor];
        [keyWindow addSubview:kHUDManager.messageHUD];
        [kHUDManager.messageHUD hideAnimated:NO];
        
        kHUDManager.indeterminateHUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        kHUDManager.indeterminateHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        kHUDManager.indeterminateHUD.bezelView.color = [UIColor blackColor];
        kHUDManager.indeterminateHUD.contentColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:kHUDManager action:@selector(tap:)];
        [kHUDManager.indeterminateHUD addGestureRecognizer:tap];
        [keyWindow addSubview:kHUDManager.indeterminateHUD];
        [kHUDManager.indeterminateHUD hideAnimated:NO];
    });
    return kHUDManager;
}
- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.tapCancle) {
        self.tapCancle();
    }
}
@end

@implementation UIViewController (HUD)
- (void)showMessage:(NSString *)message {
    MBProgressHUD *messageHUD = [IVEHUDManager shareManager].messageHUD;
    messageHUD.label.text = message;
    [messageHUD showAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(message.length * 0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [messageHUD hideAnimated:YES];
    });
}

- (void)showIndeterminateWithTapCancle:(void(^)())tapCancle {
    MBProgressHUD *indeterminateHUD = [IVEHUDManager shareManager].indeterminateHUD;
    [indeterminateHUD showAnimated:YES];
    [IVEHUDManager shareManager].tapCancle = tapCancle;
}

- (void)showIndeterminate {
    MBProgressHUD *indeterminateHUD = [IVEHUDManager shareManager].indeterminateHUD;
    
    [indeterminateHUD showAnimated:YES];
}

- (void)hideIndeterminate {
    MBProgressHUD *indeterminateHUD = [IVEHUDManager shareManager].indeterminateHUD;
    [indeterminateHUD hideAnimated:YES];
}


@end

