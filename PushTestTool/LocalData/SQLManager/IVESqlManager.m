

#import "IVESqlManager.h"
#import <objc/runtime.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "IVESQLGenerater.h"
#import "IVEClassTool.h"


static NSString *const k_DB_NAME = @"Push.db";

static IVESqlManager *sqlManager = nil;


@implementation IVESqlManager {
    NSMutableArray *_propertiesArray;
    FMDatabase * _db;
    NSString *_dbPath;
}
+ (IVESqlManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlManager = [[IVESqlManager alloc] init];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *directoryPath = [NSString stringWithFormat:@"%@/db",pathDocuments];
		
		// 判断文件夹是否存在，如果不存在，则创建
		if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
			[fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
        sqlManager->_dbPath = [directoryPath stringByAppendingPathComponent:k_DB_NAME];
        sqlManager->_db =[FMDatabase databaseWithPath:sqlManager->_dbPath];
        
		NSLog(@"%@",sqlManager->_dbPath);
        
    });
    return sqlManager;
}
#pragma mark - 创建表
- (BOOL)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey {
    return [self creatTableWithName:tableName KeyAttributes:KeyAttributes primaryKey:primaryKey autoIncrement:NO];
}
- (BOOL)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey autoIncrement:(BOOL)autoIncrement {

    if ([_db open]) {
        NSString *creatTableSql = [IVESQLGenerater creatTableWithName:tableName KeyAttributes:KeyAttributes primaryKey:primaryKey autoIncrement:autoIncrement];
        if (!creatTableSql) {
            
            return NO;
        }

        return [_db executeUpdate:creatTableSql];
    }
    return NO;

}


#pragma mark - 删除表
- (BOOL)deleteTable:(Class)tableClass {
    if ([_db open]) {
        NSString *tableName = NSStringFromClass(tableClass);
        NSString *changeTableNameSql = [IVESQLGenerater deleteTable:tableName];
        return [_db executeUpdate:changeTableNameSql];
    }
    return NO;
}

#pragma mark - 增
- (BOOL)insertObject:(NSObject *)object {
    if ([_db open]) {
        NSString *insertSql = [IVESQLGenerater insertObject:object];
		
        return [_db executeUpdate:insertSql];
    }
    return NO;
}

- (NSInteger)insertInfo:(NSDictionary *)info tableName:(NSString *)tableName  {
    if ([_db open]) {
        NSString *insertSql = [IVESQLGenerater insertInfo:info tableName:tableName];
        BOOL executeResult = [_db executeUpdate:insertSql];
        if (executeResult) {
            return (NSInteger)[_db lastInsertRowId];
        }
        
    }
    return -1;
}
- (NSInteger)batchInsertInfoArr:(NSArray *)infoArr tableName:(NSString *)tableName {
	NSInteger lastID = -1;
	if ([_db open]) {
		[_db beginTransaction];
		BOOL isRollBack = NO;
		
		@try {
			for (NSInteger index = 0; index < infoArr.count; index ++) {
				NSDictionary *info = infoArr[index];
				NSString *insertSql = [IVESQLGenerater insertInfo:info tableName:tableName];
				[_db executeUpdate:insertSql];
			}
		} @catch (NSException *exception) {
			isRollBack = YES;
			[_db rollback];
		} @finally {
			if (!isRollBack)
			{
				[_db commit];
				lastID = (NSInteger)[_db lastInsertRowId];
			}
		}
		
	}
	
	return lastID;
}
#pragma mark - 删
- (BOOL)deleteObjectFromTable:(NSString *)tableName condition:(NSDictionary *)condition {
    if ([_db open]) {
        NSString *deleteSql = [IVESQLGenerater deleteFromTableWithTableName:tableName condition:condition];
        return [_db executeUpdate:deleteSql];
    }
    return NO;
}

- (BOOL)deleteObjectFromTable:(NSString *)tableName conditionString:(NSString *)conditionString {
 if ([_db open]) {
	 NSString *deleteSql = [IVESQLGenerater deleteSqlStringWithTableName:tableName conditionString:conditionString];
	 return [_db executeUpdate:deleteSql];
 }
	return NO;
}

#pragma mark - 改
- (BOOL)updateObjectFromTable:(NSString *)tableName info:(NSDictionary *)info condition:(NSDictionary *)condition {
    if ([_db open]) {
        NSString *updateSql = [IVESQLGenerater updateSqlStringWithTableName:tableName updateDict:info condition:condition];
        return [_db executeUpdate:updateSql];
    }
    return NO;
}
    
#pragma mark - 查
- (NSArray *)queryTable:(NSString *)tableName conditionStr:(NSString *)conditionStr ouputClass:(Class)className{
    
    NSMutableArray *array = [NSMutableArray array];
    
    if ([_db open]) {
        NSString *sql = [IVESQLGenerater querySqlStringWithTableName:tableName conditionStr:conditionStr sortDict:nil];
        
        FMResultSet *set = [_db executeQuery:sql];
        if (className) {
            [array addObjectsFromArray:[self transfromResultToObject:set className:className]];
        } else {
            while ([set next]) {
                [array addObject:set.resultDictionary];
            }
        }
        
        
        return array;
    }
    return nil;
}

- (NSArray *)queryTable:(NSString *)tableName limtInfo:(NSDictionary *)limtInfo sortDict:(NSDictionary *)sortDict ouputClass:(Class)className{

	NSMutableArray *array = [NSMutableArray array];
	
	if ([_db open]) {
		NSString *sql = [IVESQLGenerater querySqlStringWithTableName:tableName limtInfo:limtInfo sortDict:sortDict];
		
		FMResultSet *set = [_db executeQuery:sql];
		if (className) {
			[array addObjectsFromArray:[self transfromResultToObject:set className:className]];
		} else {
			while ([set next]) {
				[array addObject:set.resultDictionary];
			}
		}
		
		
		return array;
	}
	return nil;

}

- (NSArray *)transfromResultToObject:(FMResultSet *)set className:(Class)className{
	NSMutableArray *array = [NSMutableArray array];
	NSDictionary *dict = [IVEClassTool propertiesDict:className];
	while ([set next]) {
		id object = [[className alloc] init];
		for (NSString *propertyName in dict.allKeys) {
			id propertyValue = [set stringForColumn:propertyName];
			SEL selector = [self constructSetSelectorWithKey:propertyName];
			if ([className instancesRespondToSelector:selector]) {
				[object setValue:propertyValue forKey:propertyName];
			}
		}
		[array addObject:object];
	}
	return array;
}
#pragma mark - help method
- (SEL)constructSetSelectorWithKey:(NSString *)key {
    NSString *keyOfSelector = [NSString stringWithFormat:@"set%@%@:",[key substringToIndex:1].uppercaseString,[key substringFromIndex:1]];
    return NSSelectorFromString(keyOfSelector);
}

@end
