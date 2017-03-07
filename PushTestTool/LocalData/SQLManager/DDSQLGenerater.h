
#import <Foundation/Foundation.h>

@interface DDSQLGenerater : NSObject

#pragma mark - -创建表
+ (NSString *)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey ;
+ (NSString *)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey  autoIncrement:(BOOL)autoIncrement;
+ (NSString *)creatTableFormClass:(Class)class uniqueKey:(NSString *)uniqueKey;

#pragma mark - - 删除表
+ (NSString *)deleteTable:(NSString *)tableName;

#pragma mark - -表结构
+ (NSString *)queryTableKeyNamesWithName:(NSString *)tableName;
+ (NSString *)addNewKey:(NSDictionary *)keysDict toTable:(NSString *)tableName;
+ (NSString *)changeTableKeyWithTableName:(NSString *)tableName newKeyName:(NSString *)newKeyName oldKeyName:(NSString *)oldKeyName;

#pragma mark - -插入数据
+ (NSString *)insertInfo:(NSDictionary *)infoDict tableName:(NSString *)tableName;
+ (NSString *)insertObject:(id)object;

#pragma mark - -删除数据
+ (NSString *)deleteFromTableWithTableName:(NSString *)tableName condition:(NSDictionary *)condition;
+ (NSString *)deleteFromTableWithTableName:(NSString *)tableName exceptCondition:(NSDictionary *)exceptCondition;
+ (NSString *)deleteSqlStringWithTableName:(NSString *)tableName condition:(NSDictionary *)condition exceptCondition:(NSDictionary *)exceptCondition;

+ (NSString *)deleteSqlStringWithTableName:(NSString *)tableName conditionString:(NSString *)conditionString;

#pragma mark - -更新数据
+ (NSString *)updateSqlStringWithTableName:(NSString *)tableName updateDict:(NSDictionary *)updateDict condition:(NSDictionary *)condition;

#pragma mark - -查询数据
+ (NSString *)querySqlStringWithTableName:(NSString *)tableName conditionStr:(NSString *)conditionStr sortDict:(NSDictionary *)sortDict;
+ (NSString *)querySqlStringWithTableName:(NSString *)tableName limtInfo:(NSDictionary *)limtInfo sortDict:(NSDictionary *)sortDict;
@end



