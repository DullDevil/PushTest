
#import "EditEnvironmentViewController.h"
#import "PushEnvironmentAPI.h"
#import "IVEHUDManager.h"

@interface EditEnvironmentViewController () {
	PushEnvironmentAPI *_pushEnvironmentApi;
}
@property (weak, nonatomic) IBOutlet UITextField *environmentNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *certificatePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextView *certificateContentTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeTypeButton;

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
		NSString *type = self.selectedItem[PushEnvironmentAPIType];
		[_changeTypeButton setTitle:[type isEqualToString:@"1"]?@"生产":@"测试" forState:UIControlStateNormal];
	}
	
	
}
- (IBAction)changeType:(UIButton *)button {
	if ([button.titleLabel.text isEqualToString:@"测试"]) {
		[button setTitle:@"生产" forState:UIControlStateNormal];
	} else if ([button.titleLabel.text isEqualToString:@"生产"]) {
		[button setTitle:@"测试" forState:UIControlStateNormal];
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
	
	NSString *type = [self.changeTypeButton.titleLabel.text isEqualToString:@"测试"] ? @"0":@"1";
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:certificateContent,PushEnvironmentAPICerData,environmentName,PushEnvironmentAPIName,_certificatePasswordTextField.text,PushEnvironmentAPICerPassword,type,PushEnvironmentAPIType, nil];
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
