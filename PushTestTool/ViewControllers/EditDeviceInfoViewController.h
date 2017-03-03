//
//  EditDeviceInfoViewController.h
//  PushTestTool
//
//  Created by 张桂杨 on 2017/2/3.
//  Copyright © 2017年 Ive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditDeviceInfoViewController : UIViewController
@property (nonatomic,copy) NSString *deviceID;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *deviceToken;

@property (nonatomic,copy) void(^editHasFinished)(void);
@end
