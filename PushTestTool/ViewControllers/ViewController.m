//
//  ViewController.m
//  PushTestTool
//
//  Created by 张桂杨 on 2017/1/17.
//  Copyright © 2017年 Ive. All rights reserved.
//

#import "ViewController.h"

#import "EditInfoViewController.h"
#import "ChooseTokenViewController.h"
#import "ChooseEnvironmentViewController.h"
#import "ChoosePushCustomInfoViewController.h"
#import "PushCustonInfoAPI.h"
#import "IVEHUDManager.h"


#import "PushEnvironmentAPI.h"
#import "DeviceTokenAPI.h"

#import "PushManager.h"

static NSString * const kPushTestKeyToken = @"token";
static NSString * const kPushTestKeyEnvironment = @"environment";
static NSString * const kPushTestKeyCustomInfoID = @"customInfoID";


static NSString * const kPushTestKeyAlert = @"alert";
static NSString * const kPushTestKeyBadge = @"badge";
static NSString * const kPushTestKeySound = @"sound";
static NSString * const kPushTestContentAvailable = @"kPushTestContentAvailable";



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,PushManagerDelegate> {
	
	NSMutableArray *_cellDataArray;
	
	PushEnvironmentAPI *_pushEnvironmentApi;
	DeviceTokenAPI *_deviceTokenManager;
	PushCustonInfoAPI *_pushCustomInfoApi;
	
	NSString *_token;
	
	NSString *_cerDataBase64string;
	NSString *_cerPassword;
	
	PushManager *_pushManager;
	
	
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIButton *tableFoterButton;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	_pushEnvironmentApi = [[PushEnvironmentAPI alloc] init];
	_deviceTokenManager = [[DeviceTokenAPI alloc] init];
	_pushCustomInfoApi = [[PushCustonInfoAPI alloc] init];
	
	_cellDataArray = [self queryPushInfo];
	
	_pushManager = [[PushManager alloc] init];
	_pushManager.pushDelegate = self;
	
    _tableView.estimatedRowHeight = 44;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"change" object:nil];
}

- (void)reloadData {
	_cellDataArray = [self queryPushInfo];
	[self.tableView reloadData];
}

#pragma mark - events
#pragma mark ---断开/链接apns
- (BOOL)isConnectedAPNS {
	if (_pushManager.isConnected) {
		return YES;
	}
	NSData *cerData = [[NSData alloc] initWithBase64EncodedString:_cerDataBase64string options:NSDataBase64DecodingIgnoreUnknownCharacters];
	if (cerData) {
		[_pushManager connectAPNSWithPkcs12Data:cerData password:_cerPassword];
		[self showIndeterminate];
	} else {
		[self showMessage:@"未获取到推送证书"];
	}
	return NO;
}
#pragma mark ---发送推送
- (IBAction)sendPush:(id)sender {
	if (_token.length != 64) {
		[self showMessage:@"token 格式不正确"];
		return;
	}
	if ([self isConnectedAPNS]) {
		NSString *payloadStr = [self creatPayloadString];
		[_pushManager sendWithToken:_token pushMessage:payloadStr];
	}
}

- (void)addCustomInfo {
    [self performSegueWithIdentifier:@"ChoosePushCustomInfo" sender:nil];
}

- (NSString *)creatPayloadString {

	NSMutableDictionary *apsDict = [NSMutableDictionary dictionary];
	NSArray *apsArray = _cellDataArray[1];
	for (NSDictionary *itemInfo in apsArray) {
		NSDictionary *copyItem = [itemInfo mutableCopy];
		if ([copyItem.allKeys containsObject:@"badge"]) {
			NSString *badge = itemInfo[@"badge"];
			NSNumber *num = @([badge integerValue]);
			[copyItem setValue:num forKey:@"badge"];
		}
		[apsDict addEntriesFromDictionary:copyItem];
	}
	NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithObjectsAndKeys:apsDict,@"aps", nil];
	
	
	/* -----------------------custom---------------------*/
	if (_cellDataArray.count >= 3) {
			NSArray *customArray = _cellDataArray[2];
			for (NSDictionary *itemInfo in customArray) {
				[payload addEntriesFromDictionary:itemInfo];
			}
	}

	
	NSData *payloadData  = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil];
	return  [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
}

#pragma mark - GCDAsyncSocketDelegate
#pragma mark ---连接成功
- (void)APNSDidConnected {
	NSString *payloadStr = [self creatPayloadString];
	[_pushManager sendWithToken:_token pushMessage:payloadStr];
}

#pragma mark ---发送成功
- (void)sendSucceed {
	 dispatch_sync(dispatch_get_main_queue(), ^{
		 [self showMessage:@"发送成功"];
		 [self hideIndeterminate];
	 });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *itemArray = _cellDataArray[section];
	return itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.numberOfLines = 0;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
	
	NSDictionary *itemDict = _cellDataArray[indexPath.section][indexPath.row];
	if (itemDict.allKeys.count > 0) {
		NSString *key = itemDict.allKeys[0];
		cell.textLabel.text = key;
		cell.detailTextLabel.text = itemDict[key];
	}

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _cellDataArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"环境及token设置";
	}else if (section == 1) {
		return @"推送内容";
	}
	return @"自定义内容";
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 2) {
		return self.tableFoterButton;
	}
	return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 2) {
		return 60;
	}
	return 0;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			[self performSegueWithIdentifier:@"ChooseToken" sender:nil];
		} else if (indexPath.row == 1) {
			[self performSegueWithIdentifier:@"ChooseEnvironment" sender:nil];
		}
	} else {
		[self performSegueWithIdentifier:@"EditInfo" sender:indexPath];
	}
}

#pragma mark - 跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"EditInfo"]) {
		NSIndexPath *selectedIndexPath = (NSIndexPath *)sender;
		if ([selectedIndexPath isKindOfClass:[NSIndexPath class]]) {
			EditInfoViewController * destinationViewController = segue.destinationViewController;
			__block NSDictionary *itemDict = _cellDataArray[selectedIndexPath.section][selectedIndexPath.row];
			
			NSString *key = itemDict.allKeys[0];
			destinationViewController.title = key;
			destinationViewController.editKey = key;
			destinationViewController.editContent = itemDict[key];
			
			destinationViewController.editFinish = ^(NSString *editKey,NSString *editContent) {
				[itemDict setValue:editContent forKey:editKey];
				[self savePushInfoWithKey:editKey value:editContent];
				[self.tableView reloadData];
			};
		}
	} else if ([segue.identifier isEqualToString:@"ChooseToken"]) {
		ChooseTokenViewController *destinationViewController = segue.destinationViewController;
		__block NSArray * PushEnvironmentInfo = _cellDataArray[0];
		__weak typeof(self) wSelf = self;
		destinationViewController.selectedCallBack = ^(NSDictionary *selectedInfo) {
			__strong typeof(wSelf) sSelf = wSelf;
			sSelf->_token = selectedInfo[DeviceTokenAPITokenContent];
			NSDictionary *tokenNameDict = PushEnvironmentInfo[0];
			[tokenNameDict setValue:selectedInfo[DeviceTokenAPITokenName] forKey:@"tokenName"];
			[sSelf.tableView reloadData];
		};
	} else if ([segue.identifier isEqualToString:@"ChooseEnvironment"]) {
		ChooseEnvironmentViewController *destinationViewController = segue.destinationViewController;
		__block NSArray * PushEnvironmentInfo = _cellDataArray[0];
		__weak typeof(self) wSelf = self;
		destinationViewController.selectedCallBack = ^(NSDictionary *selectedInfo) {
			__strong typeof(wSelf) sSelf = wSelf;
			NSDictionary *pushEnvironmentDict = PushEnvironmentInfo[1];
			NSString *pushEnvironmentName = selectedInfo[PushEnvironmentAPIName];
			[pushEnvironmentDict setValue:pushEnvironmentName forKey:@"environment"];
			
			sSelf->_cerPassword = selectedInfo[PushEnvironmentAPICerPassword];
			sSelf->_cerDataBase64string = selectedInfo[PushEnvironmentAPICerData];
			
			[sSelf.tableView reloadData];
		};
	} else if ([segue.identifier isEqualToString:@"ChoosePushCustomInfo"]) {
		ChooseEnvironmentViewController *destinationViewController = segue.destinationViewController;
		__block NSMutableArray * pushCustomInfos = [_cellDataArray lastObject];
		
		__weak typeof(self) wSelf = self;
		destinationViewController.selectedCallBack = ^(NSDictionary *selectedInfo){
			__strong typeof(wSelf) sSelf = wSelf;
			NSString *selectedpushInfoContent = selectedInfo[PushCustomInfoKeys];
			NSArray *keys = [selectedpushInfoContent componentsSeparatedByString:@","];
			[pushCustomInfos removeAllObjects];
			for (NSString *key in keys) {
				NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",key, nil];
				[pushCustomInfos addObject:dict];
			}
			
			[sSelf.tableView reloadData];
		};
	}
}


#pragma mark - 数据持久化

- (void)savePushInfoWithKey:(NSString *)key value:(NSString *)value {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue:value forKey:key];
	[userDefaults synchronize];
}

- (NSMutableArray *)queryPushInfo {
	NSMutableArray *pushInfo = [NSMutableArray array];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	/* -----------------------push setting ---------------------*/
	NSDictionary *selectedToken = [_deviceTokenManager querySelected];
	NSString *tokenName = @"";
	_token = @"";
	if (selectedToken) {
		_token = selectedToken[DeviceTokenAPITokenContent];
		tokenName = selectedToken[DeviceTokenAPITokenName];
	}
		
	_cerDataBase64string = @"";
	_cerPassword = @"";
	NSString *environmentName = @"";
	NSDictionary *selectedEnvironment = [_pushEnvironmentApi querySelected];
	if (selectedEnvironment) {
		_cerDataBase64string = selectedEnvironment[PushEnvironmentAPICerData];
		_cerPassword = selectedEnvironment[PushEnvironmentAPICerPassword];
		environmentName = selectedEnvironment[PushEnvironmentAPIName];
	}
	
	NSMutableDictionary *environmentDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:environmentName,@"environment", nil];
	NSMutableDictionary *tokenNameDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tokenName,@"tokenName", nil];
	[pushInfo addObject:@[tokenNameDict,environmentDict]];
	
	/* -----------------------aps---------------------*/
	NSString *alertMessage = [userDefaults valueForKey:kPushTestKeyAlert];
	if (!alertMessage) {
		alertMessage = @"push test";
	}
	
	NSMutableDictionary *alertDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:alertMessage,kPushTestKeyAlert, nil];
	
	NSString *badgeNumString = [userDefaults valueForKey:kPushTestKeyBadge];
	if (!badgeNumString) {
		badgeNumString = @"1";
	}
	NSMutableDictionary *badgeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:badgeNumString,kPushTestKeyBadge, nil];
	
	NSString *sound = [userDefaults valueForKey:kPushTestKeySound];
	if (!sound) {
		sound = @"default";
	}
	NSMutableDictionary *soundDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:sound,kPushTestKeySound, nil];
	
	NSString *contentAvailable = [userDefaults valueForKey:kPushTestContentAvailable];
	if (!contentAvailable) {
		contentAvailable = @"0";
	}
	NSMutableDictionary *contentAvailableDict  =[NSMutableDictionary dictionaryWithObjectsAndKeys:contentAvailable,@"content-available", nil];
	[pushInfo addObject:@[alertDict,badgeDict,soundDict,contentAvailableDict]];
	
	
	/* -----------------------custom info---------------------*/
	NSDictionary *selectedCustomInfo = [_pushCustomInfoApi querySelected];
	NSMutableArray *pushCustomInfos = [NSMutableArray array];
	if (selectedCustomInfo) {
		NSString *customInfoContent = selectedCustomInfo[PushCustomInfoKeys];
		NSArray *keys = [customInfoContent componentsSeparatedByString:@","];
		for (NSInteger i = 0; i < keys.count; i ++) {
			NSString *vaule = [userDefaults valueForKey:keys[i]];
			if (!vaule) {
				vaule = @"";
			}
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:vaule,keys[i], nil];
			[pushCustomInfos addObject:dict];
		}
	}
	[pushInfo addObject:pushCustomInfos];
	
	return pushInfo;
}

#pragma mark - setter && getter
- (UIButton *)tableFoterButton {
	if (!_tableFoterButton) {
		_tableFoterButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_tableFoterButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 40, 44);
		[_tableFoterButton setTitle:@"选择自定义内容格式" forState:UIControlStateNormal];
		[_tableFoterButton addTarget:self action:@selector(addCustomInfo) forControlEvents:UIControlEventTouchUpInside];

	}
	return _tableFoterButton;
}

@end
