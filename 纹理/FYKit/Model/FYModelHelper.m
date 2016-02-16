//
//  FYModel.m
//  EmotionCenter
//
//  Created by fanyingzhao on 15/12/9.
//  Copyright © 2015年 fyz. All rights reserved.
//

#import "FYModelHelper.h"
#import <MJExtension.h>
#import "FYDBHelper.h"

@implementation FYModelHelper

+ (instancetype)shareInstance
{
    static FYModelHelper* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [FYModelHelper new];
    });
    
    return instance;
}

- (void)updateModel:(id)response model:(NSObject *)obj
{
    if (!obj) {
        obj = [[[obj class] alloc] init];
    }
    
    obj = [[obj class] mj_objectWithKeyValues:response];
}

- (void)updateModel:(id)response array:(NSMutableArray *)array model:(__unsafe_unretained Class)modelClass
{
    if (!array) {
        array = [NSMutableArray array];
    }
    
    if ([response isKindOfClass:[NSArray class]]) {
        for (NSDictionary* dic in response) {
            id obj = [modelClass mj_objectWithKeyValues:dic];
            [array addObject:obj];
        }
    }
}
@end
