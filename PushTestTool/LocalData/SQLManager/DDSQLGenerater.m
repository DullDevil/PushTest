
#import "DDSQLGenerater.h"
#import <objc/runtime.h>

NSString *const SQLSortKey = @"SortKey";
NSString *const SQLSortStyle = @"SortStyle";

NSString *const SQLLimtCount = @"SQLLimtCount";
NSString *const SQLLimtStartValue = @"SQLLimtStartValue";



@implementation DDSQLGenerater
#pragma mark - -创建表

+ (NSString *)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey {
    return [self creatTableWithName:tableName KeyAttributes:KeyAttributes primaryKey:primaryKey autoIncrement:NO];
}
+ (NSString *)creatTableWithName:(NSString *)tableName KeyAttributes:(NSDictionary *)KeyAttributes primaryKey:(NSString *)primaryKey  autoIncrement:(BOOL)autoIncrement {
    if (!tableName) {
        return nil;
    }
    NSArray *keys = KeyAttributes.allKeys;
    NSMutableString *sqlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"CREATE TABLE  IF NOT EXISTS %@ (",tableName]];
    
    if (autoIncrement) {
        [sqlString appendString:[NSString stringWithFormat:@"%@ INTEGER PRIMARY KEY AUTOINCREMENT,",primaryKey]];
        for (NSString *keyName in keys) {
            NSString *keyType = [KeyAttributes valueForKey:keyName];
            if (![keyName isEqualToString:primaryKey]) {
                [sqlString appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL DEFAULT 0 ,",keyName,keyType]];
            }
        }
    } else {
        for (NSString *keyName in keys) {
            NSString *keyType = [KeyAttributes valueForKey:keyName];
            if (primaryKey && [keyName isEqualToString:primaryKey]) {
                [sqlString appendString:[NSString stringWithFormat:@"%@ %@ PRIMARY KEY NOT NULL,",keyName,keyType]];
            } else {
                [sqlString appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL DEFAULT 0 ,",keyName,keyType]];
            }
        }
    }
    
    [sqlString replaceCharactersInRange:NSMakeRange(sqlString.length - 1, 1) withString:@")"];
    return sqlString;
    
}

+ (NSString *)creatTableFormClass:(Class)class uniqueKey:(NSString *)uniqueKey {
    u_int count;
    objc_property_t *properties  =class_copyPropertyList(class, &count);
    NSMutableString *sqlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"CREATE TABLE  IF NOT EXISTS %@ (",NSStringFromClass(class)]];
    if (count == 0) {
        return nil;
    }
    for (NSInteger i = 0; i<count; i++) {
        const char* propertyName =property_getName(properties[i]);
        const char* propertyAttributes = property_getAttributes(properties[i]);
        
        NSString *type = [self propertyTypeFromPropertyAttributes:propertyAttributes];
        NSString *name = [NSString stringWithUTF8String: propertyName];
        
        if (type) {
            if (uniqueKey && [name isEqualToString:uniqueKey]) {
                [sqlString appendString:[NSString stringWithFormat:@"%@ %@ PRIMARY KEY NOT NULL,",name,type]];
            } else {
                [sqlString appendString:[NSString stringWithFormat:@"%@ %@ NOT NULL DEFAULT 0 ,",name,type]];
            }
        }
    }
    [sqlString replaceCharactersInRange:NSMakeRange(sqlString.length - 1, 1) withString:@")"];
    
    free(properties);
    return sqlString;

}
+ (NSString *)deleteTable:(NSString *)tableName {
    NSString *sqlString = [NSString stringWithFormat:@"DROP table %@",tableName];
    return sqlString;
}
#pragma mark - -表结构
+ (NSString *)queryTableKeyNamesWithName:(NSString *)tableName{
    return [NSString stringWithFormat:@"PRAGMA table_info ('%@')",tableName];
}

+ (NSString *)addNewKey:(NSDictionary *)keysDict toTable:(NSString *)tableName {
    if (keysDict && keysDict.allKeys.count > 0) {
        NSMutableString *sqlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"ALTER TABLE %@ ADD",tableName]];
        NSString *keyName = keysDict.allKeys[0];
        [sqlString appendString:[NSString stringWithFormat:@" %@ %@ NOT NULL DEFAULT 0 ",keyName,keysDict[keyName]]];
        [sqlString replaceCharactersInRange:NSMakeRange(sqlString.length - 1, 1) withString:@" "];
        return sqlString;
    }
    return nil;
}

+ (NSString *)changeTableKeyWithTableName:(NSString *)tableName newKeyName:(NSString *)newKeyName oldKeyName:(NSString *)oldKeyName {
    if (newKeyName && oldKeyName) {
        return  [NSString stringWithFormat:@"ALTER TABLE %@ RENAME COLUMN %@ TO %@ ",tableName,oldKeyName,newKeyName];
    }
    return nil;
}

#pragma mark - -插入
+ (NSString *)insertInfo:(NSDictionary *)infoDict tableName:(NSString *)tableName {

    NSMutableString *propertiesNameStr = [[NSMutableString alloc] initWithString:@"("];
    NSMutableString *propertiesValueStr = [[NSMutableString alloc] initWithString:@"("];
    NSArray *allKeys = infoDict.allKeys;
    if (allKeys.count == 0) {
        return nil;
    }
    
    for (NSInteger i = 0; i<allKeys.count; i++) {
        NSString *name = allKeys[i];
        NSString *value = [infoDict valueForKey:name];
        if (value) {
            [propertiesNameStr appendString:[NSString stringWithFormat:@"%@,",name]];
            [propertiesValueStr appendString:[NSString stringWithFormat:@"'%@',",value]];
        }
    }
    [propertiesNameStr replaceCharactersInRange:NSMakeRange(propertiesNameStr.length - 1, 1) withString:@")"];
    [propertiesValueStr replaceCharactersInRange:NSMakeRange(propertiesValueStr.length - 1, 1) withString:@")"];
    
    
    NSString *sqlString = [NSString stringWithFormat:@"%@ VALUES %@ ",propertiesNameStr,propertiesValueStr];
    if (tableName) {
        sqlString = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ %@ ",tableName,sqlString];
    }
   
    return sqlString;
}

+ (NSString *)insertObject:(id)object {
    Class class = [object class];
    u_int count;
    objc_property_t *properties  =class_copyPropertyList(class, &count);
    
    NSMutableString *propertiesNameStr = [[NSMutableString alloc] initWithString:@"("];
    NSMutableString *propertiesValueStr = [[NSMutableString alloc] initWithString:@"("];
    if (count == 0) {
        return nil;
    }
    for (NSInteger i = 0; i<count; i++) {
        const char* propertyName =property_getName(properties[i]);
        const char* propertyAttributes = property_getAttributes(properties[i]);
        
        NSString *type = [self propertyTypeFromPropertyAttributes:propertyAttributes];
        NSString *name = [NSString stringWithUTF8String: propertyName];
        
        if (type) {
            NSString *value = [object valueForKey:name];
            if (!value) {
                value = @"";
            }
            [propertiesNameStr appendString:[NSString stringWithFormat:@"%@,",name]];
            [propertiesValueStr appendString:[NSString stringWithFormat:@"'%@',",value]];
        }
    }
    [propertiesNameStr replaceCharactersInRange:NSMakeRange(propertiesNameStr.length - 1, 1) withString:@")"];
    [propertiesValueStr replaceCharactersInRange:NSMakeRange(propertiesValueStr.length - 1, 1) withString:@")"];
    NSString *sqlString = [NSString stringWithFormat:@"%@ VALUES %@",propertiesNameStr,propertiesValueStr];
    sqlString = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ %@ ",NSStringFromClass([object class]),sqlString];
    free(properties);
    return sqlString;
}

#pragma mark - -删除
+ (NSString *)deleteFromTableWithTableName:(NSString *)tableName condition:(NSDictionary *)condition {
    return [self deleteSqlStringWithTableName:tableName condition:condition exceptCondition:nil];
}

+ (NSString *)deleteFromTableWithTableName:(NSString *)tableName exceptCondition:(NSDictionary *)exceptCondition {
    return [self deleteSqlStringWithTableName:tableName condition:nil exceptCondition:exceptCondition];
}

+ (NSString *)deleteSqlStringWithTableName:(NSString *)tableName condition:(NSDictionary *)condition exceptCondition:(NSDictionary *)exceptCondition{
    if (!condition && !exceptCondition) {
        return nil;
    }
    if (condition.allKeys.count == 0 && exceptCondition.allKeys.count == 0) {
        return nil;
    }
    NSMutableString *deleteSql = [[NSMutableString alloc] initWithFormat:@"DELETE FROM %@ ",tableName];
    NSString *conditionString = [NSString stringWithFormat:@"WHERE %@%@",[self conditionString:condition except:NO],[self conditionString:exceptCondition except:YES]];
    [deleteSql appendString:conditionString];
    return deleteSql;
}

+ (NSString *)deleteSqlStringWithTableName:(NSString *)tableName conditionString:(NSString *)conditionString {
	NSMutableString *deleteSql = [[NSMutableString alloc] initWithFormat:@"DELETE FROM %@ ",tableName];
	if (conditionString) {
		[deleteSql appendFormat:@"WHERE %@ ",conditionString];
	}
	return deleteSql;

}

#pragma mark - -更新

+ (NSString *)updateSqlStringWithTableName:(NSString *)tableName updateDict:(NSDictionary *)updateDict condition:(NSDictionary *)condition {
    if (!condition) {
        return nil;
    }
    
    NSArray *updateProperties = updateDict.allKeys;
    NSInteger count = updateProperties.count;
    if (count == 0) {
        return nil;
    }
    NSMutableString *updateSqlString = [[NSMutableString alloc] initWithFormat:@"UPDATE %@ SET ",tableName];
    for (NSInteger i = 0; i<count; i++) {
        NSString *name = updateProperties[i];
        id value = [updateDict valueForKey:name];
        [updateSqlString appendString:[NSString stringWithFormat:@"%@ = '%@',",name,value]];
    }

    NSString *conditionString = [NSString stringWithFormat:@"WHERE %@",[self conditionString:condition except:NO]];
    [updateSqlString replaceCharactersInRange:NSMakeRange(updateSqlString.length - 1, 1) withString:conditionString];
    return  updateSqlString;
}

#pragma mark - -查询

+ (NSString *)querySqlStringWithTableName:(NSString *)tableName conditionStr:(NSString *)conditionStr sortDict:(NSDictionary *)sortDict{
	NSMutableString *querySql = [[NSMutableString alloc] initWithFormat:@"SELECT * FROM %@ ",tableName];
	if (conditionStr) {
		[querySql appendString:[NSString stringWithFormat:@"WHERE %@ ",conditionStr]];
	}
	
	NSString *sortString = [self sortStringWithSortDict:sortDict];
	[querySql appendString:sortString];
	
	return querySql;
}
+ (NSString *)querySqlStringWithTableName:(NSString *)tableName limtInfo:(NSDictionary *)limtInfo sortDict:(NSDictionary *)sortDict{
	
	NSMutableString *querySql = [[NSMutableString alloc] initWithFormat:@"SELECT * FROM %@ ",tableName];
	
	NSString *sortKey = @"";
	if ([sortDict.allKeys containsObject:SQLSortKey]) {
		sortKey =  sortDict[SQLSortKey];
	}
	
	NSString *sortStyle = @"DESC";
	if ([sortDict.allKeys containsObject:SQLSortStyle]) {
		sortStyle = sortDict[SQLSortKey];
	}
	
	NSString *startValue = @"";
	if ([limtInfo.allKeys containsObject:SQLLimtStartValue]) {
		startValue = limtInfo[SQLLimtStartValue];
	}
	
	NSString *limtCount = @"10";
	if ([limtInfo.allKeys containsObject:SQLLimtCount]) {
		limtCount = limtInfo[SQLLimtCount];
	}
	NSString *comparisonSymbol = [sortStyle isEqualToString:@"DESC"]?@"<":@">";
	NSString *conditionString = [NSString stringWithFormat:@"WHERE %@ %@ %@ ORDER BY %@ %@ limit %@",sortKey,comparisonSymbol,startValue,sortDict[SQLSortKey],sortStyle,limtCount];
	[querySql appendString:conditionString];
	
	return querySql;
}

#pragma mark - condition string
+ (NSString *)conditionString:(NSDictionary *)dict except:(BOOL)except{
    NSMutableString *conditionString = [[NSMutableString alloc] init];
    NSString *exceptString = except ? @"NOT LIKE" : @"=";
    for (NSInteger index = 0; index < dict.allKeys.count; index ++) {
        NSString *conditionKey = dict.allKeys[index];
        id conditionValue = [dict valueForKey:conditionKey];
        if (index == 0) {
            [conditionString appendString:[NSString stringWithFormat:@"%@ %@ '%@' ",conditionKey,exceptString,conditionValue]];
        } else {
            [conditionString appendString:[NSString stringWithFormat:@"AND %@ %@ '%@' ",conditionKey,exceptString,conditionValue]];
        }
    }
    return conditionString;
}
#pragma mark - sort string
+ (NSString *)sortStringWithSortDict:(NSDictionary *)sortDict {

	if (sortDict && [sortDict.allKeys containsObject:SQLSortKey]) {
		
		NSString *sortKey = [sortDict valueForKey:SQLSortKey];
		NSMutableString *sortSql = [[NSMutableString alloc] initWithFormat:@"ORDER BY %@ ",sortKey];
		if ([sortDict.allKeys containsObject:SQLSortStyle]) {
			[sortSql appendString:[sortDict valueForKey:SQLSortStyle]];
		} else {
			[sortSql appendString:@"DESC"];
		}
		return sortSql;
	
	}
	
	return @"";
}

#pragma mark - help method
+ (NSString *)propertyTypeFromPropertyAttributes:(const char*)propertyAttributes {
    /*
     Attributes 的格式
     
     指针类型            T@"NSString",&,N,V_string
     NSInteger,long     Tq,N,V_
     NSUInteger         TQ,N,V_
     CGFloat,double     Td,N,V_
     float              Tf,N,V_
     int                Ti,N,V_
     bool               TB,N,V_
     
     CGRect T{CGRect={CGPoint=dd}{CGSize=dd}},N,V_rect
     CGPoint T^{CGPoint=dd},N,V_point
     */
    
    NSString *strOfAttribute = [NSString stringWithUTF8String:propertyAttributes];
    
    NSString *propertyType = nil;
    NSArray *subStingArr = [strOfAttribute componentsSeparatedByString:@","];
    NSString *TString = subStingArr[0];
    NSRange rang = [TString rangeOfString:@"T@"];
    if (rang.location != NSNotFound && rang.length > 0) {
        propertyType = [TString substringFromIndex:rang.length];
        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if ([propertyType isEqualToString:@"NSString"]) {
            return @"text";
        }
    } else if ([TString isEqualToString:@"Tq"]|| [TString isEqualToString:@"Ti"] || [TString isEqualToString:@"TQ"] ) {
        return @"integer";
    } else if ([TString isEqualToString:@"Td"] || [TString isEqualToString:@"Tf"] ) {
        return @"double";
    } else if ([TString isEqualToString:@"TB"]) {
        return @"integer";
    }
    return nil;
}

@end
