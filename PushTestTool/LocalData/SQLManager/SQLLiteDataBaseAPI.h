
#import <Foundation/Foundation.h>

#import "DDSQLliteConfig.h"


typedef void(^SQLLiteSuccessCallBack)(NSDictionary *dict);
typedef void(^SQLLiteFailCallBack)(NSDictionary *dict);

@interface SQLLiteDataBaseAPI : NSObject

- (BOOL)createtable;

- (NSDictionary *)insertObjectWithInfo:(NSDictionary *)info;

- (BOOL)deletObjectWithCondition:(NSDictionary *)condition;
- (BOOL)deletObjectWithConditionString:(NSString *)conditionString;

- (BOOL)updateObjectWithInfo:(NSDictionary *)info condition:(NSDictionary *)condition;

- (NSArray *)queryInfoWithCondition:(NSString *)conditionStr;


- (void)batchInsertDInfoArr:(NSArray *)infoArr success:(SQLLiteSuccessCallBack)success fail:(SQLLiteFailCallBack)fail;
- (void)asynchroAueryInfoWithCondition:(NSString *)conditionStr success:(SQLLiteSuccessCallBack)success ;

@end
