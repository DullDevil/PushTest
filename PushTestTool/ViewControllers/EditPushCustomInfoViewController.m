
#import "EditPushCustomInfoViewController.h"
#import "PushCustonInfoAPI.h"
#import "IVEHUDManager.h"

@interface EditPushCustomInfoViewController () {

	PushCustonInfoAPI *_pushCustomInfoApi;
}

@property (nonatomic, strong) UIButton *tableFoterButton;
@property (weak, nonatomic) IBOutlet UITextField *pushInfoNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *pushInfoContentTextView;
@end

@implementation EditPushCustomInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	_pushCustomInfoApi = [[PushCustonInfoAPI alloc] init];
	
	if (self.selectedItem) {
		_pushInfoNameTextField.text = self.selectedItem[PushCustomInfoName];
		_pushInfoContentTextView.text = self.selectedItem[PushCustomInfoKeys];
	}
	
}
- (IBAction)editHasFinished:(id)sender {
	NSString *pushInfoName = _pushInfoNameTextField.text;
	if (pushInfoName.length == 0) {
		[self showMessage:@"模版名称不能为空"];
		return;
	}
	NSString *pushInfoContent = _pushInfoContentTextView.text;
	if (pushInfoContent.length == 0) {
		[self showMessage:@"模版内容不能为空"];
		return;
	}
	
	NSArray *array = [pushInfoContent componentsSeparatedByString:pushInfoContent];
	if (array.count == 0 ) {
		[self showMessage:@"模版内容格式错误"];
		return;
	}
	
	NSMutableDictionary *insertInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:pushInfoName,PushCustomInfoName,pushInfoContent,PushCustomInfoKeys, nil];
	if (self.selectedItem) {
		[insertInfo setObject:self.selectedItem[PushCustomInfoID] forKey:PushCustomInfoID];
	}
	if([_pushCustomInfoApi insertObjectWithInfo:insertInfo]) {
		[self showMessage:@"保存成功"];
		[self.navigationController popViewControllerAnimated:YES];
		if (self.eidtHasFinished) {
			self.eidtHasFinished();
		}
	
	}
	
}


@end
