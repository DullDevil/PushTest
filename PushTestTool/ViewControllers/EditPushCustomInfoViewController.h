

#import <UIKit/UIKit.h>

@interface EditPushCustomInfoViewController : UIViewController


@property (nonatomic, strong)  NSDictionary *selectedItem;
@property (nonatomic,copy) void(^eidtHasFinished)(void);
@end
