
#import <Foundation/Foundation.h>

typedef void(^InsertCallBack)(NSInteger lastInsertId);
@interface IVESqlManager : NSObject
+ (IVESqlManager *)shareManager;

//创建表
- (BOOL)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey;
- (BOOL)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey autoIncrement:(BOOL)autoIncrement;

//新增数据
- (BOOL)insertObject:(NSObject *)object ;
- (NSInteger)insertInfo:(NSDictionary *)info tableName:(NSString *)tableName ;
- (NSInteger)batchInsertInfoArr:(NSArray *)infoArr tableName:(NSString *)tableName;

//删除数据
- (BOOL)deleteObjectFromTable:(NSString *)tableName condition:(NSDictionary *)condition;
- (BOOL)deleteObjectFromTable:(NSString *)tableName conditionString:(NSString *)conditionString;

//修改数据
- (BOOL)updateObjectFromTable:(NSString *)tableName info:(NSDictionary *)info condition:(NSDictionary *)condition;

//查询数据
- (NSArray *)queryTable:(NSString *)tableName conditionStr:(NSString *)conditionStr ouputClass:(Class)className;
- (NSArray *)queryTable:(NSString *)tableName limtInfo:(NSDictionary *)limtInfo sortDict:(NSDictionary *)sortDict ouputClass:(Class)className;



@end
