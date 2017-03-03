

#import "ChoosePushCustomInfoViewController.h"
#import "PushCustonInfoAPI.h"
#import "EditPushCustomInfoViewController.h"

@interface ChoosePushCustomInfoViewController ()<UITableViewDelegate,UITableViewDataSource>{
	NSMutableArray *_dataArray;
	PushCustonInfoAPI *_pushCustomInfoApi;
	NSNumber *_selectedCustonInfoId;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *tableFoterButton;
@end

@implementation ChoosePushCustomInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	_pushCustomInfoApi = [[PushCustonInfoAPI alloc] init];
	NSDictionary *selectedInfo = [_pushCustomInfoApi querySelected];
	if (selectedInfo) {
		_selectedCustonInfoId = selectedInfo[PushCustomInfoID];
	}
	
	self.tableView.tableFooterView = self.tableFoterButton;
	self.tableView.allowsSelectionDuringEditing = YES;
	
	[self queryPushCustompushInfo];
}

#pragma mark - events
- (void)addNewCustomInfo {
	[self performSegueWithIdentifier:@"EditPushCustomInfo" sender:nil];
}
- (void)queryPushCustompushInfo {
	__weak typeof(self) wSelf = self;
	[_pushCustomInfoApi asynchroAueryInfoWithCondition:nil success:^(NSDictionary *dict) {
		__strong typeof(wSelf)sSelf = wSelf;
		NSArray *result = dict[@"result"];
		sSelf->_dataArray = [NSMutableArray arrayWithArray:result];
		[sSelf.tableView reloadData];
		
	}];
}
- (IBAction)editCustomInfo:(id)sender {
	if (_tableView.editing) {
		[_tableView setEditing:NO animated:YES];
		
		[sender setTitle:@"编辑"];
	} else {
		[_tableView setEditing:YES animated:YES];
		[sender setTitle:@"完成"];
	}
	
}
#pragma mark - deleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditPushCustomInfo"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EditPushCustomInfo"];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSDictionary *dict = _dataArray[indexPath.row];
	if ([_selectedCustonInfoId isEqual:dict[PushCustomInfoID]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = dict[PushCustomInfoName];
	cell.detailTextLabel.text = dict[PushCustomInfoKeys];

	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (_tableView.isEditing) {
		[self performSegueWithIdentifier:@"EditPushCustomInfo" sender:indexPath];
	} else {
		if (self.selectedCallBack) {
			NSDictionary *selectedInfo = _dataArray[indexPath.row];
			[_pushCustomInfoApi markSlectedushCustonInfoWithInfoID:selectedInfo[PushCustomInfoID]];
			if (self.selectedCallBack) {
				self.selectedCallBack(selectedInfo);
			}
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"已添加的自定义消息模版";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *deleteDeviceInfo = _dataArray[indexPath.row];
		
		if ([_pushCustomInfoApi deletObjectWithCondition:deleteDeviceInfo]) {
			[_dataArray removeObjectAtIndex:indexPath.row];	
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	
		
	}
}
#pragma mark - 跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EditPushCustomInfo"]) {
		EditPushCustomInfoViewController * destinationViewController = segue.destinationViewController;
		BOOL isEditSelected = NO;
		if ([sender isKindOfClass:[NSIndexPath class]]) {
			NSIndexPath *selectedIndexPath = (NSIndexPath *)sender;
			NSDictionary *selectedItem = _dataArray[selectedIndexPath.row];
			destinationViewController.selectedItem = selectedItem;
			isEditSelected = [selectedItem[PushCustomInfoID] isEqual:_selectedCustonInfoId];
		}
		destinationViewController.eidtHasFinished = ^() {
			[self queryPushCustompushInfo];
			
			if (isEditSelected) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"change" object:nil];
			}
		};
	}
}
#pragma mark - setter && getter
- (UIButton *)tableFoterButton {
	if (!_tableFoterButton) {
		_tableFoterButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_tableFoterButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 40, 60);
		[_tableFoterButton setTitle:@"添加新模版" forState:UIControlStateNormal];
		[_tableFoterButton addTarget:self action:@selector(addNewCustomInfo) forControlEvents:UIControlEventTouchUpInside];
	}
	return _tableFoterButton;
}
@end
