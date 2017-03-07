//
//  ViewController.m
//  PushTestTool
//
//  Created by 张桂杨 on 2017/1/17.
//  Copyright © 2017年 Ive. All rights reserved.
//

#import "ViewController.h"


#import "ChooseTokenViewController.h"
#import "ChooseEnvironmentViewController.h"

#import "IVEHUDManager.h"

#import "PushEnvironmentAPI.h"
#import "DeviceTokenAPI.h"

#import "PushManager.h"

static NSString * const kPushContentKey = @"kPushContentKey";
@interface ViewController ()<PushManagerDelegate,UITextViewDelegate> {
	

	
	PushEnvironmentAPI *_pushEnvironmentApi;
	DeviceTokenAPI *_deviceTokenManager;
	
	
	NSString *_token;
	NSString *_tokenName;
	
	NSString *_cerDataBase64string;
	NSString *_cerPassword;
	NSString *_pushEnvironmentName;
	NSString *_pushEnvironmentType;
	
	PushManager *_pushManager;
	
	
}

@property (weak, nonatomic) IBOutlet UIButton *chooseTokenButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseEnvironmentButton;
@property (weak, nonatomic) IBOutlet UITextView *pushContentTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottom;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	_pushEnvironmentApi = [[PushEnvironmentAPI alloc] init];
	_deviceTokenManager = [[DeviceTokenAPI alloc] init];

	[self queryPushInfo];
	
	
	_pushManager = [[PushManager alloc] init];
	_pushManager.pushDelegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryToken) name:@"TokenChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryEnvironment) name:@"EnvironmentChanged" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.pushContentTextView resignFirstResponder];
}




#pragma mark - events
#pragma mark ---断开/链接apns
- (BOOL)isConnectedAPNS {
	if (_pushManager.isConnected) {
		return YES;
	}
	NSData *cerData = [[NSData alloc] initWithBase64EncodedString:_cerDataBase64string options:NSDataBase64DecodingIgnoreUnknownCharacters];
	if (cerData) {
		[_pushManager connectAPNSWithPkcs12Data:cerData password:_cerPassword type:[_pushEnvironmentType isEqualToString:@"1"]?PushEnvironmentTypeProduction:PushEnvironmentTypeDeveloper];
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
		if (self.pushContentTextView.text.length > 0) {
			[_pushManager sendWithToken:_token pushMessage:self.pushContentTextView.text];
		} else {
			[self showMessage:@"推送内容不能为空"];
		}
		
	}
}

#pragma mark ---数据查询
- (void)queryPushInfo {
	self.pushContentTextView.text = [[NSUserDefaults standardUserDefaults] valueForKey:kPushContentKey];
	[self queryToken];
	[self queryEnvironment];
}

- (void)queryToken {
	NSDictionary *selectedToken = [_deviceTokenManager querySelected];
	_tokenName = @"请选择设备Token";
	_token = @"";
	if (selectedToken) {
		_token = selectedToken[DeviceTokenAPITokenContent];
		_tokenName = selectedToken[DeviceTokenAPITokenName];
	}
	[_chooseTokenButton setTitle:_tokenName forState:UIControlStateNormal];
}

- (void)queryEnvironment {
	[_pushManager disconnectAPNS];
	_cerDataBase64string = @"";
	_cerPassword = @"";
	_pushEnvironmentName = @"请选择推送环境";
	NSDictionary *selectedEnvironment = [_pushEnvironmentApi querySelected];
	if (selectedEnvironment) {
		_cerDataBase64string = selectedEnvironment[PushEnvironmentAPICerData];
		_cerPassword = selectedEnvironment[PushEnvironmentAPICerPassword];
		_pushEnvironmentName = selectedEnvironment[PushEnvironmentAPIName];
		_pushEnvironmentType = selectedEnvironment[PushEnvironmentAPIType];
	}
	[_chooseEnvironmentButton setTitle:_pushEnvironmentName forState:UIControlStateNormal];
}
#pragma mark - notification
- (void)keyboardWillShow:(NSNotification *)notification {
	CGRect keyboardBounds = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.textViewBottom.constant = CGRectGetHeight(keyboardBounds) + 10;
	
	NSInteger type = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	[UIView animateKeyframesWithDuration:duration delay:0 options:type animations:^{
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		
	}];
}
- (void)keyboardWillHide:(NSNotification *)notification {
	self.textViewBottom.constant = 10;
	
	NSInteger type = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	[UIView animateKeyframesWithDuration:duration delay:0 options:type animations:^{
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		
	}];
}

#pragma mark - GCDAsyncSocketDelegate
#pragma mark ---连接成功
- (void)APNSDidConnected {
	if (self.pushContentTextView.text.length > 0) {
		[_pushManager sendWithToken:_token pushMessage:self.pushContentTextView.text];
	} else {
		[self showMessage:@"推送内容不能为空"];
	}
}

#pragma mark ---发送成功
- (void)sendSucceed {
	 dispatch_sync(dispatch_get_main_queue(), ^{
		 [self showMessage:@"发送成功"];
		 [self hideIndeterminate];
	 });
}
- (void)APNSDidDisconnected {
 dispatch_sync(dispatch_get_main_queue(), ^{
	 [self showMessage:@"发送失败"];
	 [self hideIndeterminate];
 });
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
	[[NSUserDefaults standardUserDefaults] setValue:textView.text forKey:kPushContentKey];
}
#pragma mark - 跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[self.pushContentTextView resignFirstResponder];
	 if ([segue.identifier isEqualToString:@"ChooseToken"]) {
		ChooseTokenViewController *destinationViewController = segue.destinationViewController;
		
		__weak typeof(self) wSelf = self;
		destinationViewController.selectedCallBack = ^(NSDictionary *selectedInfo) {
			__strong typeof(wSelf) sSelf = wSelf;
			sSelf->_token = selectedInfo[DeviceTokenAPITokenContent];
			sSelf->_tokenName = selectedInfo[DeviceTokenAPITokenName];
			[sSelf.chooseTokenButton setTitle:sSelf->_tokenName forState:UIControlStateNormal];
		};
	} else if ([segue.identifier isEqualToString:@"ChooseEnvironment"]) {
		ChooseEnvironmentViewController *destinationViewController = segue.destinationViewController;
		
		__weak typeof(self) wSelf = self;
		destinationViewController.selectedCallBack = ^(NSDictionary *selectedInfo) {
			__strong typeof(wSelf) sSelf = wSelf;
			sSelf->_pushEnvironmentName = selectedInfo[PushEnvironmentAPIName];
			[sSelf.chooseEnvironmentButton setTitle:sSelf->_pushEnvironmentName forState:UIControlStateNormal];
			sSelf->_cerPassword = selectedInfo[PushEnvironmentAPICerPassword];
			sSelf->_cerDataBase64string = selectedInfo[PushEnvironmentAPICerData];
		
		};
	}
}




@end
