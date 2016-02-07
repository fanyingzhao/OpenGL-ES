//
//  FYModelMapping.h
//  FYDBHelper
//
//  Created by mac on 15/10/27.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const LKSQL_Type_Text        =   @"text";
static NSString* const LKSQL_Type_Int         =   @"integer";
static NSString* const LKSQL_Type_Double      =   @"double";
static NSString* const LKSQL_Type_Blob        =   @"blob";

static NSString* const LKSQL_Convert_FloatType   =   @"float_double_decimal";
static NSString* const LKSQL_Convert_IntType     =   @"int_char_short_long";

static NSString* const FYModelType_CGRect       = @"FY_CGRect";
static NSString* const FYModelType_NSString     = @"FY_NSString";
static NSString* const FYModelType_CGPoint      = @"FY_CGPoint";
static NSString* const FYModelType_CGSize       = @"FY_CGSize";
static NSString* const FYModelType_NSObjcet     = @"FY_NSObject";
static NSString* const FYModelType_Base         =   @"FY_Base";              // 基本类型

@interface FYModelMapping : NSObject

+ (instancetype)shareInstance;

+ (NSString*)changeDBType:(NSString*)type;

+ (void)getModelType:(NSString*)attribute
                type:(NSString*)attributeType
    systemClassBlock:(void(^)())systemBlock
    customClassBlcok:(void(^)())customBlock
      baseClassBlock:(void(^)())baseBlock;
@end
