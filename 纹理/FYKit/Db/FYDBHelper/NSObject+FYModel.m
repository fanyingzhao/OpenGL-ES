//
//  NSObject+FYModel.m
//  FYDBHelper
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "NSObject+FYModel.h"

@implementation NSObject (FYModel)

+ (NSString *)getPrimaryName
{
    return @"id";
}

+ (NSString *)getTableName
{
    return [NSString stringWithFormat:@"%@Table",NSStringFromClass([self class])];
}
@end
