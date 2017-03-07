
#ifndef DDSQLliteConfig_h
#define DDSQLliteConfig_h

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

#endif /* DDSQLliteConfig_h */
