
#import "SQLLiteDataBaseAPI.h"
#import "DDSqlManager.h"



@interface SQLLiteDataBaseAPI ()

@property (nonatomic,strong) NSObject<APISQLLiteManager> *SQLLiteChild;

@end

@implementation SQLLiteDataBaseAPI

- (instancetype)init {
	self = [super init];
	if (self) {
		if ([self conformsToProtocol:@protocol(APISQLLiteManager)]) {
			self.SQLLiteChild = (id <APISQLLiteManager>)self;
			[self createtable];
		} else {
			NSException *exception = [[NSException alloc] init];
			@throw exception;
		}
	}
	return self;
}

#pragma mark - sql lite

- (BOOL)createtable {
    NSString *primaryKey = [NSString stringWithFormat:@"%@ID",self.SQLLiteChild.tableName];
    if ([self.SQLLiteChild respondsToSelector:@selector(primaryKey)]) {
        primaryKey = self.SQLLiteChild.primaryKey;
		BOOL autoIncrement = NO;
		if ([self.SQLLiteChild respondsToSelector:@selector(primaryKeyAutoIncrement)]) {
			autoIncrement = self.SQLLiteChild.primaryKeyAutoIncrement;
		}
       return  [[DDSqlManager shareManager] creatTableWithName:self.SQLLiteChild.tableName KeyAttributes:self.SQLLiteChild.keyAttributes primaryKey:primaryKey autoIncrement:autoIncrement];
    }
	
	return [[DDSqlManager shareManager] creatTableWithName:self.SQLLiteChild.tableName KeyAttributes:self.SQLLiteChild.keyAttributes primaryKey:primaryKey autoIncrement:YES];
	
}

//插入数据
- (NSDictionary *)insertObjectWithInfo:(NSDictionary *)info {
	if ([self createtable]) {
		NSInteger lastID = [[DDSqlManager shareManager] insertInfo:info tableName:self.SQLLiteChild.tableName];
		if (lastID > 0) {
			if ([self.SQLLiteChild respondsToSelector:@selector(primaryKey)]) {
				NSString *primaryKey = self.SQLLiteChild.primaryKey;
				BOOL autoIncrement = NO;
				if ([self.SQLLiteChild respondsToSelector:@selector(primaryKeyAutoIncrement)]) {
					autoIncrement = self.SQLLiteChild.primaryKeyAutoIncrement;
				}
				if (autoIncrement) {
					return @{primaryKey:@(lastID)};
				}
				return @{primaryKey:info[primaryKey]};	
			}
			NSString *primaryKey = [NSString stringWithFormat:@"%@ID",self.SQLLiteChild.tableName];
			return  @{primaryKey:@(lastID)};
		}
	}
	return nil;
}

- (void)batchInsertDInfoArr:(NSArray *)infoArr success:(SQLLiteSuccessCallBack)success fail:(SQLLiteFailCallBack)fail {
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		__strong typeof (weakSelf) strongSelf = weakSelf;
		
		if ([strongSelf createtable]) {
			
			NSInteger lastID = [[DDSqlManager shareManager] batchInsertInfoArr:infoArr tableName:strongSelf.SQLLiteChild.tableName];
			if (lastID > 0) {
				if ([self.SQLLiteChild respondsToSelector:@selector(primaryKey)]) {
					NSString *primaryKey = self.SQLLiteChild.primaryKey;
					success(@{primaryKey:@(lastID)});
				} else {
					NSString *primaryKey = [NSString stringWithFormat:@"%@ID",self.SQLLiteChild.tableName];
					success(@{primaryKey:@(lastID)});
				}
			} else {
				fail(@{@"msg":@"插入数据失败"});
			}
		}
		
	});

}
//删除数据
- (BOOL)deletObjectWithCondition:(NSDictionary *)condition {

	return [[DDSqlManager shareManager] deleteObjectFromTable:self.SQLLiteChild.tableName condition:condition];
}
- (BOOL)deletObjectWithConditionString:(NSString *)conditionString {

	return [[DDSqlManager shareManager] deleteObjectFromTable:self.SQLLiteChild.tableName conditionString:conditionString];
}
//更新数据
- (BOOL)updateObjectWithInfo:(NSDictionary *)info condition:(NSDictionary *)condition  {
	return [[DDSqlManager shareManager] updateObjectFromTable:self.SQLLiteChild.tableName info:info condition:condition];
}

//查询数据
- (void)asynchroAueryInfoWithCondition:(NSString *)conditionStr success:(SQLLiteSuccessCallBack)success  { 
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        NSArray *result = [[DDSqlManager shareManager] queryTable:strongSelf.SQLLiteChild.tableName conditionStr:conditionStr ouputClass:nil];
        if (result.count > 0) {
            success(@{@"result":result});
        } else {
            success(@{@"msg":@"没有相关数据"});
        }
    });
}

- (NSArray *)queryInfoWithCondition:(NSString *)conditionStr {
	return [[DDSqlManager shareManager] queryTable:self.SQLLiteChild.tableName conditionStr:conditionStr ouputClass:nil];
}


@end
