

#import <UIKit/UIKit.h>

@interface EditEnvironmentViewController : UIViewController

@property (nonatomic, strong)  NSDictionary *selectedItem;
@property (nonatomic,copy) void(^eidtHasFinished)(void);
@end
