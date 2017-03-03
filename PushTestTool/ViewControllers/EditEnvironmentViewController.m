
#import "EditEnvironmentViewController.h"
#import "PushEnvironmentAPI.h"
#import "IVEHUDManager.h"

@interface EditEnvironmentViewController () {
	PushEnvironmentAPI *_pushEnvironmentApi;
}
@property (weak, nonatomic) IBOutlet UITextField *environmentNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *certificatePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextView *certificateContentTextField;

@end

@implementation EditEnvironmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	_pushEnvironmentApi = [[PushEnvironmentAPI alloc] init];
	if (self.selectedItem) {
		_environmentNameTextField.text = self.selectedItem[PushEnvironmentAPIName];
		_certificatePasswordTextField.text = self.selectedItem[PushEnvironmentAPICerPassword];
		_certificateContentTextField.text = self.selectedItem[PushEnvironmentAPICerData];
	}
	
	
}
- (IBAction)editHasFinished:(id)sender {
	NSString *certificateContent = [self.certificateContentTextField text];
	if (certificateContent.length == 0) {
		[self showMessage:@"证书内容不能为空"];
		return;
	}
	
	NSString *environmentName = self.environmentNameTextField.text;
	if (environmentName.length == 0) {
		[self showMessage:@"环境名称不能为空"];
		return;
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:certificateContent,PushEnvironmentAPICerData,environmentName,PushEnvironmentAPIName,_certificatePasswordTextField.text,PushEnvironmentAPICerPassword, nil];
	if (self.selectedItem) {
		[dict setValue:self.selectedItem[PushEnvironmentAPIID] forKey:PushEnvironmentAPIID];
	}
	
	if ([_pushEnvironmentApi insertObjectWithInfo:dict]) {
		[self showMessage:@"保存成功"];
		[self.navigationController popViewControllerAnimated:YES];
		if (self.eidtHasFinished) {
			self.eidtHasFinished();
		}
	} else {
		[self showMessage:@"保存失败"];
	}
	
}

@end
