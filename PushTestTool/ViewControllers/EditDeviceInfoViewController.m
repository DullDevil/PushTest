
#import "EditDeviceInfoViewController.h"
#import "ChooseEnvironmentViewController.h"

#import "DeviceTokenAPI.h"
#import "DDHUDManager.h"

@interface EditDeviceInfoViewController () {
	DeviceTokenAPI *_deviceTokenAPI;
}
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *deviceTokenTextView;

@end

@implementation EditDeviceInfoViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	_deviceTokenTextView.text = _deviceToken;
	_deviceNameTextField.text = _deviceName;
	_deviceTokenAPI = [[DeviceTokenAPI alloc] init];
}

- (IBAction)editHasFinished:(id)sender {

	NSString *token = _deviceTokenTextView.text;
	if (!token || token.length == 0) {
		[self showMessage:@"token 不能为空"];
		return;
	}
	
	NSString *deviceName = _deviceNameTextField.text;
	if (!deviceName) {
		deviceName = @"";
	}
	
	NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:token,DeviceTokenAPITokenContent,deviceName,DeviceTokenAPITokenName,_deviceID,DeviceTokenAPITokenID, nil];
	if ([_deviceTokenAPI insertObjectWithInfo:deviceInfo ]) {
		[self showMessage:@"保存成功"];
		if (self.editHasFinished) {
			self.editHasFinished();
		}
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self showMessage:@"保存失败"];
	}

}

@end
