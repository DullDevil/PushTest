

#import <Foundation/Foundation.h>

@interface DDClassTool : NSObject

+ (NSString *)classHashKeyWithClass:(Class)class;

+ (NSDictionary *)propertiesDict:(Class)class;
@end




