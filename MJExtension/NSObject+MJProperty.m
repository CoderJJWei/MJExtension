//
//  NSObject+MJProperty.m
//  MJExtensionExample
//
//  Created by MJ Lee on 15/4/17.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "NSObject+MJProperty.h"
#import "NSObject+MJKeyValue.h"
#import "NSObject+MJCoding.h"
#import "NSObject+MJClass.h"
#import "MJProperty.h"
#import "MJFoundation.h"
#import <objc/runtime.h>



static const char MJReplacedKeyFromPropertyNameKey = '\0';
static const char MJReplacedKeyFromPropertyName121Key = '\0';
static const char MJNewValueFromOldValueKey = '\0';
static const char MJObjectClassInArrayKey = '\0';

static const char MJCachedPropertiesKey = '\0';

@implementation NSObject (Property)

static NSMutableDictionary *replacedKeyFromPropertyNameDict_;
static NSMutableDictionary *replacedKeyFromPropertyName121Dict_;
static NSMutableDictionary *newValueFromOldValueDict_;
static NSMutableDictionary *objectClassInArrayDict_;
static NSMutableDictionary *cachedPropertiesDict_;

+ (void)load
{
    replacedKeyFromPropertyNameDict_ = [NSMutableDictionary dictionary];
    replacedKeyFromPropertyName121Dict_ = [NSMutableDictionary dictionary];
    newValueFromOldValueDict_ = [NSMutableDictionary dictionary];
    objectClassInArrayDict_ = [NSMutableDictionary dictionary];
    cachedPropertiesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    if (key == &MJReplacedKeyFromPropertyNameKey) return replacedKeyFromPropertyNameDict_;
    if (key == &MJReplacedKeyFromPropertyName121Key) return replacedKeyFromPropertyName121Dict_;
    if (key == &MJNewValueFromOldValueKey) return newValueFromOldValueDict_;
    if (key == &MJObjectClassInArrayKey) return objectClassInArrayDict_;
    if (key == &MJCachedPropertiesKey) return cachedPropertiesDict_;
    return nil;
}

#pragma mark - --私有方法--
+ (NSString *)propertyKey:(NSString *)propertyName
{
    MJExtensionAssertParamNotNil2(propertyName, nil);
    
    __block NSString *key = nil;
    // 查看有没有需要替换的key
    if ([self respondsToSelector:@selector(mj_replacedKeyFromPropertyName121:)]) {
        key = [self mj_replacedKeyFromPropertyName121:propertyName];
    }

    
    // 调用block
    if (!key) {
        [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            MJReplacedKeyFromPropertyName121 block = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyName121Key);
            if (block) {
                key = block(propertyName);
            }
            if (key) *stop = YES;
        }];
    }
    
    // 查看有没有需要替换的key
    if (!key && [self respondsToSelector:@selector(mj_replacedKeyFromPropertyName)]) {
        key = [self mj_replacedKeyFromPropertyName][propertyName];
    }
    
    
    if (!key) {
        [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
            NSDictionary *dict = objc_getAssociatedObject(c, &MJReplacedKeyFromPropertyNameKey);
            if (dict) {
                key = dict[propertyName];
            }
            if (key) *stop = YES;
        }];
    }
    
    // 2.用属性名作为key
    if (!key) key = propertyName;
    
    return key;
}




#pragma mark - 新值配置
+ (void)mj_setupNewValueFromOldValue:(MJNewValueFromOldValue)newValueFormOldValue
{
    objc_setAssociatedObject(self, &MJNewValueFromOldValueKey, newValueFormOldValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (id)mj_getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(MJProperty *__unsafe_unretained)property{
    // 如果有实现方法
    if ([object respondsToSelector:@selector(mj_newValueFromOldValue:property:)]) {
        return [object mj_newValueFromOldValue:oldValue property:property];
    }

    
    // 查看静态设置
    __block id newValue = oldValue;
    [self mj_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        MJNewValueFromOldValue block = objc_getAssociatedObject(c, &MJNewValueFromOldValueKey);
        if (block) {
            newValue = block(object, oldValue, property);
            *stop = YES;
        }
    }];
    return newValue;
}

#pragma mark - array model class配置
+ (void)mj_setupObjectClassInArray:(MJObjectClassInArray)objectClassInArray
{
    [self mj_setupBlockReturnValue:objectClassInArray key:&MJObjectClassInArrayKey];
    
    [[self dictForKey:&MJCachedPropertiesKey] removeAllObjects];
}

#pragma mark - key配置
+ (void)mj_setupReplacedKeyFromPropertyName:(MJReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self mj_setupBlockReturnValue:replacedKeyFromPropertyName key:&MJReplacedKeyFromPropertyNameKey];
    
    [[self dictForKey:&MJCachedPropertiesKey] removeAllObjects];
}

+ (void)mj_setupReplacedKeyFromPropertyName121:(MJReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    objc_setAssociatedObject(self, &MJReplacedKeyFromPropertyName121Key, replacedKeyFromPropertyName121, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [[self dictForKey:&MJCachedPropertiesKey] removeAllObjects];
}
@end

@implementation NSObject (MJPropertyDeprecated_v_2_5_16)
+ (void)enumerateProperties:(MJPropertiesEnumeration)enumeration
{
    [self mj_enumerateProperties:enumeration];
}

+ (void)setupNewValueFromOldValue:(MJNewValueFromOldValue)newValueFormOldValue
{
    [self mj_setupNewValueFromOldValue:newValueFormOldValue];
}

+ (id)getNewValueFromObject:(__unsafe_unretained id)object oldValue:(__unsafe_unretained id)oldValue property:(__unsafe_unretained MJProperty *)property
{
    return [self mj_getNewValueFromObject:object oldValue:oldValue property:property];
}

+ (void)setupReplacedKeyFromPropertyName:(MJReplacedKeyFromPropertyName)replacedKeyFromPropertyName
{
    [self mj_setupReplacedKeyFromPropertyName:replacedKeyFromPropertyName];
}

+ (void)setupReplacedKeyFromPropertyName121:(MJReplacedKeyFromPropertyName121)replacedKeyFromPropertyName121
{
    [self mj_setupReplacedKeyFromPropertyName121:replacedKeyFromPropertyName121];
}

+ (void)setupObjectClassInArray:(MJObjectClassInArray)objectClassInArray
{
    [self mj_setupObjectClassInArray:objectClassInArray];
}
@end

#pragma clang diagnostic pop
