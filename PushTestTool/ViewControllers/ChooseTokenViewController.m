
#import "ChooseTokenViewController.h"

#import "DeviceTokenAPI.h"
#import "EditDeviceInfoViewController.h"

@interface ChooseTokenViewController ()<UITableViewDelegate,UITableViewDataSource>{
	DeviceTokenAPI *_deviceTokenManager;
	NSMutableArray *_dataArray;
	NSNumber *_selectedTokenID;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *tableFoterButton;

@end

@implementation ChooseTokenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	_deviceTokenManager = [[DeviceTokenAPI alloc] init];
	NSDictionary *selectedToken = [_deviceTokenManager querySelected];
	if (selectedToken) {
		_selectedTokenID = selectedToken[DeviceTokenAPITokenID];
	}
	
	self.tableView.tableFooterView = self.tableFoterButton;
	[self queryDeviceInfo];
}


#pragma mark - events
- (void)addNewDevice {
	[self performSegueWithIdentifier:@"editDeviceInfo" sender:nil];
}
- (IBAction)editDeviceInfo:(UIBarButtonItem *)sender {
	if (_tableView.editing) {
		[_tableView setEditing:NO animated:YES];
		[sender setTitle:@"编辑"];
	} else {
		[_tableView setEditing:YES animated:YES];
		[sender setTitle:@"完成"];
	}
}

- (void)queryDeviceInfo {
	__weak typeof(self) wSelf = self;
	[_deviceTokenManager asynchroAueryInfoWithCondition:nil success:^(NSDictionary *dict) {
		__strong typeof(wSelf) sSelf = wSelf;
		sSelf->_dataArray = [NSMutableArray arrayWithArray:[dict valueForKey:@"result"]];
		[sSelf.tableView reloadData];
	}];
}

#pragma mark - deleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceTokenCell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"deviceTokenCell"];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	NSDictionary *dict = _dataArray[indexPath.row];
	cell.textLabel.text = dict[DeviceTokenAPITokenName];
	NSString *token = dict[DeviceTokenAPITokenContent];
	cell.detailTextLabel.text = token;
	if (_selectedTokenID && [_selectedTokenID  isEqual:dict[DeviceTokenAPITokenID]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *deleteDeviceInfo = _dataArray[indexPath.row];
		if ([_deviceTokenManager deletObjectWithCondition:deleteDeviceInfo]) {
			[_dataArray removeObjectAtIndex:indexPath.row];
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"已添加的token";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (_tableView.editing) {
		[self performSegueWithIdentifier:@"editDeviceInfo" sender:indexPath];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
		NSDictionary *dict = _dataArray[indexPath.row];
		[_deviceTokenManager markSlectedTokenWithTokenID:dict[DeviceTokenAPITokenID]];
		if (self.selectedCallBack) {
			self.selectedCallBack(dict);
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"editDeviceInfo"]) {
		EditDeviceInfoViewController * destinationViewController = segue.destinationViewController;
		BOOL isEditSelected = NO;
		if ([sender isKindOfClass:[NSIndexPath class]]) {
			NSIndexPath *selectedIndexPath = (NSIndexPath *)sender;
			NSDictionary *selectedItem = _dataArray[selectedIndexPath.row];
	
			isEditSelected = [selectedItem[DeviceTokenAPITokenID] isEqual:_selectedTokenID];
			destinationViewController.deviceToken = selectedItem[DeviceTokenAPITokenContent];
			destinationViewController.deviceName = selectedItem[DeviceTokenAPITokenName];
			destinationViewController.deviceID = selectedItem[DeviceTokenAPITokenID];
			
		}
		destinationViewController.editHasFinished = ^() {
			[self queryDeviceInfo];
			if (isEditSelected) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"TokenChanged" object:nil];
			}
		};
		
	}
}

#pragma mark - setter && getter
- (UIButton *)tableFoterButton {
	if (!_tableFoterButton) {
		_tableFoterButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_tableFoterButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 40, 60);
		[_tableFoterButton setTitle:@"添加新token" forState:UIControlStateNormal];
		[_tableFoterButton addTarget:self action:@selector(addNewDevice) forControlEvents:UIControlEventTouchUpInside];
	}
	return _tableFoterButton;
}

@end
