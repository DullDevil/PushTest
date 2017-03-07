
#import "ChooseEnvironmentViewController.h"
#import "PushEnvironmentAPI.h"
#import "EditEnvironmentViewController.h"

@interface ChooseEnvironmentViewController ()<UITableViewDelegate,UITableViewDataSource> {
	NSMutableArray *_dataArray;
	PushEnvironmentAPI *_pushEnvironmentApi;
	NSNumber *_selectedEnvironmentID;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *tableFoterButton;
@end

@implementation ChooseEnvironmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	_pushEnvironmentApi = [[PushEnvironmentAPI alloc] init];
	NSDictionary *selectedEnvironment = [_pushEnvironmentApi querySelected];
	if (selectedEnvironment) {
		_selectedEnvironmentID = selectedEnvironment[PushEnvironmentAPIID];
	}
	_tableView.allowsSelectionDuringEditing = YES;
	_tableView.tableFooterView = self.tableFoterButton;
	
	[self queryEnvironmentInfo];
}
- (IBAction)editEnvironment:(UIBarButtonItem *)sender {
	
	if (_tableView.editing) {
		[_tableView setEditing:NO animated:YES];
		[sender setTitle:@"编辑"];
	} else {
		[_tableView setEditing:YES animated:YES];
		[sender setTitle:@"完成"];
	}
}

#pragma mark - events
- (void)addNewEnvironment {
	[self performSegueWithIdentifier:@"EditEnvironment" sender:nil];
}

- (void)queryEnvironmentInfo {
	__weak typeof(self) wSelf = self;
	[_pushEnvironmentApi asynchroAueryInfoWithCondition:nil success:^(NSDictionary *dict) {
		__strong typeof(wSelf) sSelf = wSelf;
		sSelf->_dataArray = [NSMutableArray arrayWithArray:[dict valueForKey:@"result"]];
		[sSelf.tableView reloadData];
	}];
	
}


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
	cell.textLabel.text = dict[PushEnvironmentAPIName];
	if ([_selectedEnvironmentID isEqual:dict[PushEnvironmentAPIID]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *deleteDeviceInfo = _dataArray[indexPath.row];
		
		if ([_pushEnvironmentApi deletObjectWithCondition:deleteDeviceInfo]) {
			[_dataArray removeObjectAtIndex:indexPath.row];
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
		
		
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"已添加的推送环境";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (_tableView.editing) {
		[self performSegueWithIdentifier:@"EditEnvironment" sender:indexPath];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
		NSDictionary *dict = _dataArray[indexPath.row];
		[_pushEnvironmentApi markSlectedEnvironmentWithEnvironmentID:dict[PushEnvironmentAPIID]];
		if (self.selectedCallBack) {
		
			self.selectedCallBack(dict);
		}
	}
}

#pragma mark - 跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"EditEnvironment"]) {
		EditEnvironmentViewController * destinationViewController = segue.destinationViewController;
		BOOL isEditSelected = NO;
		if ([sender isKindOfClass:[NSIndexPath class]]) {
			NSIndexPath *selectedIndexPath = (NSIndexPath *)sender;
			NSDictionary *selectedItem = _dataArray[selectedIndexPath.row];
			destinationViewController.selectedItem = selectedItem;
			isEditSelected = [selectedItem[PushEnvironmentAPIID] isEqual:_selectedEnvironmentID];
		}
		destinationViewController.eidtHasFinished = ^() {
			[self queryEnvironmentInfo];
			if (isEditSelected) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"EnvironmentChanged" object:nil];
			}
		};
		
	}
}
#pragma mark - setter && getter
- (UIButton *)tableFoterButton {
	if (!_tableFoterButton) {
		_tableFoterButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_tableFoterButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 40, 60);
		[_tableFoterButton setTitle:@"添加新环境" forState:UIControlStateNormal];
		[_tableFoterButton addTarget:self action:@selector(addNewEnvironment) forControlEvents:UIControlEventTouchUpInside];
	}
	return _tableFoterButton;
}


@end
