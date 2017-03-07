

#import "DDClassTool.h"
#import <objc/runtime.h>

@implementation DDClassTool


+ (NSDictionary *)propertiesDict:(Class)class {
    u_int count;
    objc_property_t *properties  =class_copyPropertyList(class, &count);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (count == 0) {
        return nil;
    }
    for (NSInteger i = 0; i<count; i++) {
        const char* propertyName =property_getName(properties[i]);
        const char* propertyAttributes = property_getAttributes(properties[i]);
        
        NSString *type = [self propertyTypeFromPropertyAttributes:propertyAttributes];
        NSString *name = [NSString stringWithUTF8String: propertyName];
        
        if (type) {
            [dict setValue:type forKey:name];
        }
    }
    
    free(properties);
    return dict;
}


+ (NSString *)classHashKeyWithClass:(Class)class { //!OCLint
    BOOL hasInsert = NO;
    u_int count;
    objc_property_t *properties  =class_copyPropertyList(class, &count);
    NSMutableArray* propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    for (NSInteger i = 0; i<count; i++) {
        const char* propertyName =property_getName(properties[i]);
        const char* propertyAttributes = property_getAttributes(properties[i]);
        
        NSString *type = [self propertyTypeFromPropertyAttributes:propertyAttributes];
        NSString *name = [NSString stringWithUTF8String: propertyName];
        if (type) {
            if (propertiesArray.count > 0) {
                hasInsert = NO;
                for (NSInteger index = 0; index < propertiesArray.count; index ++) {
                    NSString *value = propertiesArray[index];
                    if ([name compare:value] == NSOrderedAscending) {
                        [propertiesArray insertObject:name atIndex:index];
                        hasInsert = YES;
                        break;
                    }
                }
                if (!hasInsert) {
                    [propertiesArray addObject:name];
                }
            } else {
                [propertiesArray addObject:name];
            }
        }
        
    }
    
    
    free(properties);
    
    
    NSMutableString *propertyNameString = [NSMutableString string];
    for (NSInteger index = 0; index < propertiesArray.count; index ++) {
        [propertyNameString appendString:[propertiesArray objectAtIndex:index]];
    }
    NSUInteger hashKey = [propertyNameString hash];
    return [NSString stringWithFormat:@"%tu",hashKey];
}




+ (NSString *)propertyTypeFromPropertyAttributes:(const char*)propertyAttributes {
    /*
     Attributes 的格式
     
     指针类型            T@"NSString",&,N,V_string
     NSInteger,long     Tq,N,V_
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
    } else if ([TString isEqualToString:@"Tq"]|| [TString isEqualToString:@"Ti"] ) {
        return @"integer";
    } else if ([TString isEqualToString:@"Td"] || [TString isEqualToString:@"Tf"] ) {
        return @"double";
    } else if ([TString isEqualToString:@"TB"]) {
        return @"integer";
    }
    return nil;
}

@end

