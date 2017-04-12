//
//  NSObject+SerializeKit.h
//  UsCher
//
//  Created by cooper Cher on 2017/4/11.
//  Copyright © 2017年 cooper Cher. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
   Person *person = [Person new];
   person.name = @"jack";
   [person archiverKey:@"person"];
 
   NSDictionary *dic = @{ @"name":@"liz"};
   [dic archiverKey:@"dic"];
 
   NSArray *arr = @[@"1",@"2"];
   [arr archiverKey:@"arr"];
 
   Person *person = [Person unarchiverKey:@"person"];
   NSLog(@"%@",person.name);
 
   NSDictionary *dic = [NSDictionary unarchiverKey:@"dic"];
   NSLog(@"%@",dic);
 
   NSArray *arr = [NSArray unarchiverKey:@"arr"];
   NSLog(@"%@",arr);
 */

@interface NSObject (SerializeKit)<NSCoding>

//归档
- (BOOL)archiverKey:(NSString *)key;
//解档
+ (id)unarchiverKey:(NSString *)key;

@end
