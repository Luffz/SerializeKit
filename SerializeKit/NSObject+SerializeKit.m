//
//  NSObject+SerializeKit.m
//  UsCher
//
//  Created by cooper Cher on 2017/4/11.
//  Copyright © 2017年 cooper Cher. All rights reserved.
//

#import "NSObject+SerializeKit.h"
#import <objc/runtime.h>

@implementation NSObject (SerializeKit)

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSLog(@"%s",__func__);
    Class cls = [self class];
    while (cls != [NSObject class]) {
        BOOL isSelfSuper = (cls == [self class]);
        unsigned int iVarCount = 0;
        unsigned int propVarCount = 0;
        unsigned int sharedVarCount = 0;
        Ivar *ivarList = isSelfSuper? class_copyIvarList([cls class], &iVarCount):NULL;/*变量列表，含属性以及私有变量*/
        objc_property_t *propertyList = isSelfSuper?NULL:class_copyPropertyList([cls class], &propVarCount);/*属性列表*/
        sharedVarCount = isSelfSuper?iVarCount:propVarCount;
        
        for (int i = 0; i<sharedVarCount; i++) {
            const char *varName = isSelfSuper?ivar_getName(*(ivarList+i)):property_getName(*(propertyList+i));
            NSString *key = [NSString stringWithUTF8String:varName];
            id varValue = [self valueForKey:key];
            /*valueForKey只能获取本类所有变量以及所有层级父类的属性，不包含任何父类的私有变量(会崩溃)*/
            NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
            if (varValue && [filters containsObject:key] == NO) {
                [coder encodeObject:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propertyList);
        cls = class_getSuperclass(cls);
    }
}



- (id)initWithCoder:(NSCoder *)coder{
    NSLog(@"%s",__func__);
    Class cls = [self class];
    while (cls != [NSObject class]) {
        BOOL isSelfSuper = (cls == [self class]);
        unsigned int iVarCount = 0;
        unsigned int propVarCount = 0;
        unsigned int sharedVarCount = 0;
        Ivar *ivarList = isSelfSuper? class_copyIvarList([cls class], &iVarCount):NULL;/*变量列表，含属性以及私有变量*/
        objc_property_t *propertyList = isSelfSuper?NULL:class_copyPropertyList([cls class], &propVarCount);/*属性列表*/
        sharedVarCount = isSelfSuper?iVarCount:propVarCount;
        
        for (int i = 0; i<sharedVarCount; i++) {
            const char *varName = isSelfSuper?ivar_getName(*(ivarList+i)):property_getName(*(propertyList+i));
            NSString *key = [NSString stringWithUTF8String:varName];
            id varValue = [coder decodeObjectForKey:key];
            NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
            if (varValue && [filters containsObject:key] == NO) {
                [self setValue:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propertyList);
        cls = class_getSuperclass(cls);
        
    }
    return self;
}

//归档
- (BOOL)archiverKey:(NSString *)key{
    NSMutableData *data = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    if (self) {
        [archiver encodeObject:self forKey:key];
        [archiver finishEncoding];
        return [data writeToFile:[self getObjFilePathByKey:key] atomically:YES];
    }
    return NO;
}

//解档
+ (id)unarchiverKey:(NSString *)key{
    NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:[self getObjFilePathByKey:key]];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        id unarchiverData = [unarchiver decodeObjectForKey:key];
        [unarchiver finishDecoding];
        return unarchiverData;
    }
    return nil;
}

- (NSString *)getObjFilePathByKey:(NSString *)key{
    
    //设定存储文件的位置
    NSString *strFilePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    //指定存储文件的文件名
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.archiver",strFilePath,key];
    NSLog(@"==文件名==%@",fileName);
    return fileName;
}


@end
