//
//  IVESQLliteConfig.h
//  PushTestTool
//
//  Created by 张桂杨 on 2017/2/3.
//  Copyright © 2017年 Ive. All rights reserved.
//

#ifndef IVESQLliteConfig_h
#define IVESQLliteConfig_h

extern NSString *const SQLSortKey;
extern NSString *const SQLSortStyle;
extern NSString *const SQLLimtCount;
extern NSString *const SQLLimtStartValue;

@protocol APISQLLiteManager <NSObject>
- (NSString *)tableName;
- (NSDictionary *)keyAttributes;
@optional
- (NSString *)primaryKey;
- (BOOL)primaryKeyAutoIncrement;
@end

#endif /* IVESQLliteConfig_h */
