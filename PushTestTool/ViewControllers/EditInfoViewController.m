//
//  EditInfoViewController.m
//  PushTestTool
//
//  Created by 张桂杨 on 2017/1/19.
//  Copyright © 2017年 Ive. All rights reserved.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextView *editContentTF;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.editContentTF.text = self.editContent;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editDone:(id)sender {
	if (self.editFinish) {
		if (self.editContentTF.text) {
			self.editFinish(self.editKey,self.editContentTF.text);
		} else {
			self.editFinish(self.editKey,@"");
		}
		[self.navigationController popViewControllerAnimated:YES];
		
	}
}



@end
