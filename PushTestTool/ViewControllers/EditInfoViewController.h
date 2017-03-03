//
//  EditInfoViewController.h
//  PushTestTool
//
//  Created by 张桂杨 on 2017/1/19.
//  Copyright © 2017年 Ive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditInfoViewController : UIViewController
@property (nonatomic,copy) NSString *editKey;
@property (nonatomic,copy) NSString *editContent;
@property (nonatomic,copy) void(^editFinish)(NSString *editKey,NSString *editContent);
@end
