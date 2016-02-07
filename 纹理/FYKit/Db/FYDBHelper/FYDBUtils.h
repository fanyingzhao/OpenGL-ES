//
//  FYDBUtils.h
//  FYDBHelper
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYDBUtils : NSObject

+ (instancetype)shareInstance;

+ (BOOL)checkStringIsValid:(NSString*)string;

+ (void)getAttributeWithClass:(Class )className result:(void (^)(NSMutableArray* attributeArray, NSMutableArray* typeArray))result;

+ (void)getModelStr:(NSObject*)model complete:(void(^)(NSString* modelStr))complete;

+ (void)getModel:(NSString*)className modelDic:(NSDictionary*)dic complete:(void(^)(id obj))complete;

+ (void)getArrayStr:(NSArray*)array complete:(void(^)(NSString* arrayStr))complete;
+ (void)getDicStr:(NSDictionary* )dic complete:(void(^)(NSString * dicStr))complete;

+ (void)getArray:(NSString*)arrayStr complete:(void(^)(NSArray* array))complete;
+ (void)getDic:(NSString*)dicStr complete:(void(^)(NSDictionary* dic))complete;
@end
