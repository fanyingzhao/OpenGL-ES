//
//  FYModelMapping.m
//  FYDBHelper
//
//  Created by mac on 15/10/27.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "FYModelMapping.h"
#import "FYDBUtils.h"
#import <UIKit/UIKit.h>
#import "FYDBHelper.h"

@implementation FYModelMapping

+ (instancetype)shareInstance
{
    return [[FYModelMapping alloc] init];
}

+ (NSString*)changeDBType:(NSString*)type
{
    NSString* result = nil;
    
    if ([LKSQL_Convert_FloatType containsString:type]) {
        
        result = @"double";
        
    }else if ([LKSQL_Convert_IntType containsString:type]) {
        
        result = @"integer";
    }else {
    
        result = @"text";
    }
    
    return result;
}

+ (void)getModelType:(NSString *)attribute
                type:(NSString *)attributeType
    systemClassBlock:(void (^)())systemBlock
    customClassBlcok:(void (^)())customBlock
      baseClassBlock:(void (^)())baseBlock
{
    NSString* type = [FYModelMapping changeDBType:attributeType];
    
    if ([type isEqualToString:LKSQL_Type_Text]) {   // 对象类型
        
        if ([attributeType isEqualToString:NSStringFromClass([NSString class])]) {
            
            systemBlock();
            
        }else if ([attributeType isEqualToString:NSStringFromClass([NSDictionary class])] || [attributeType isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
           
            systemBlock();
            
        }else if ([attributeType isEqualToString:NSStringFromClass([NSArray class])] || [attributeType isEqualToString:NSStringFromClass([NSMutableArray class])]) {
            
            systemBlock();
            
        }else { // 自定义类型
            
            customBlock();
        }
        
    }else { // 基本类型
        
        baseBlock();
    }
}

@end
