//
//  MJExtensionConfig.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/22.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJExtensionConfig.h"
#import "MJExtension.h"
#import "Bag.h"
#import "User.h"
#import "StatusResult.h"
#import "Student.h"
#import "Dog.h"
#import "Book.h"

@implementation MJExtensionConfig
/**
 *  这个方法会在MJExtensionConfig加载进内存时调用一次
 */
+ (void)load
{
#pragma mark 如果使用NSObject来调用这些方法，代表所有继承自NSObject的类都会生效
#pragma mark NSObject中的ID属性对应着字典中的id
    [NSObject mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"ID" : @"id"
                 };
    }];
    
#pragma mark User类的只有name、icon属性参与字典转模型
//    [User mj_setupAllowedPropertyNames:^NSArray *{
//        return @[@"name", @"icon"];
//    }];
    // 相当于在User.m中实现了+(NSArray *)mj_allowedPropertyNames方法
    
#pragma mark Bag类中的name属性不参与归档
    [Bag mj_setupIgnoredCodingPropertyNames:^NSArray *{
        return @[@"name"];
    }];
    // 相当于在Bag.m中实现了+(NSArray *)mj_ignoredCodingPropertyNames方法
    
#pragma mark Bag类中只有price属性参与归档
//    [Bag mj_setupAllowedCodingPropertyNames:^NSArray *{
//        return @[@"price"];
//    }];
    // 相当于在Bag.m中实现了+(NSArray *)mj_allowedCodingPropertyNames方法
    
#pragma mark StatusResult类中的statuses数组中存放的是Status模型
#pragma mark StatusResult类中的ads数组中存放的是Ad模型
    [StatusResult mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"statuses" : @"Status", // @"statuses" : [Status class],
                 @"ads" : @"Ad" // @"ads" : [Ad class]
                 };
    }];
    // 相当于在StatusResult.m中实现了+(NSDictionary *)mj_objectClassInArray方法
    
#pragma mark Student中的desc属性对应着字典中的desciption
#pragma mark ....
    [Student mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"desc" : @"desciption",
                 @"oldName" : @"name.oldName",
                 @"nowName" : @"name.newName",
                 @"otherName" : @[@"otherName", @"name.newName", @"name.oldName"],
                 @"nameChangedTime" : @"name.info[1].nameChangedTime",
                 @"bag" : @"other.bag"
                 };
    }];
    // 相当于在Student.m中实现了+(NSDictionary *)mj_replacedKeyFromPropertyName方法
    
#pragma mark Dog的所有驼峰属性转成下划线key去字典中取值
    [Dog mj_setupReplacedKeyFromPropertyName121:^NSString *(NSString *propertyName) {
        return [propertyName mj_underlineFromCamel];
    }];
    // 相当于在Dog.m中实现了+(NSDictionary *)mj_replacedKeyFromPropertyName121:方法
    
#pragma mark Book的日期处理、字符串nil值处理
    [Book mj_setupNewValueFromOldValue:^id(id object, id oldValue, MJProperty *property) {
        if ([property.name isEqualToString:@"publisher"]) {
            if (oldValue == nil || [oldValue isKindOfClass:[NSNull class]]) return @"";
        } else if (property.type.typeClass == [NSDate class]) {
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy-MM-dd";
            return [fmt dateFromString:oldValue];
        }
            
        return oldValue;
    }];
    // 相当于在Book.中实现了- (id)mj_newValueFromOldValue:property:方法
}
@end