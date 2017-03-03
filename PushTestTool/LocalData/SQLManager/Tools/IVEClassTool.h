//
//  IVEClassTool.h
//  MVC
//
//  Created by 张桂杨 on 16/8/29.
//  Copyright © 2016年 Ive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IVEClassTool : NSObject

+ (NSString *)classHashKeyWithClass:(Class)class;

+ (NSDictionary *)propertiesDict:(Class)class;
@end




