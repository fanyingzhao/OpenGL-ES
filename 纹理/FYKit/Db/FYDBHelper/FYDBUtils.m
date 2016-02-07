//
//  FYDBUtils.m
//  FYDBHelper
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "FYDBUtils.h"
#import "FYModelMapping.h"
#import <objc/runtime.h>

@implementation FYDBUtils

+ (instancetype)shareInstance
{
    static FYDBUtils* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[FYDBUtils alloc] init];
    });
    
    return instance;
}

+ (BOOL)checkStringIsValid:(NSString *)string
{
    return ((nil == string) || [string isEqual:[NSNull null]] || [string isEqualToString:@"(null)"] || [string isEqualToString:@""])?NO:YES;
}

+ (void)getAttributeWithClass:(Class )className result:(void (^)(NSMutableArray* attributeArray, NSMutableArray* typeArray))result
{
    NSMutableArray* attributeArray = [NSMutableArray array];
    NSMutableArray* typeArray = [NSMutableArray array];
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(className, &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        
        [attributeArray addObject:[NSString stringWithFormat:@"%s",property_getName(property)]];
        NSString* propertyType = [NSString stringWithFormat:@"%s",property_getAttributes(property)];
        [typeArray addObject:[FYDBUtils getAttributeType:propertyType]];
    }
    
    free(properties);
    
    if (result) {
        result(attributeArray,typeArray);
    }
}

+ (NSString*)getAttributeType:(NSString*)propertyType
{
    NSString* propertyClassName = nil;
    if ([propertyType hasPrefix:@"T@"]) {
        
        NSRange range = [propertyType rangeOfString:@","];
        if(range.location > 4 && range.location <= propertyType.length)
        {
            range = NSMakeRange(3,range.location - 4);
            propertyClassName = [propertyType substringWithRange:range];
            if([propertyClassName hasSuffix:@">"])
            {
                NSRange categoryRange = [propertyClassName rangeOfString:@"<"];
                if (categoryRange.length>0)
                {
                    propertyClassName = [propertyClassName substringToIndex:categoryRange.location];
                }
            }
        }
    }
    else if([propertyType hasPrefix:@"T{"])
    {
        NSRange range = [propertyType rangeOfString:@"="];
        if(range.location > 2 && range.location <= propertyType.length)
        {
            range = NSMakeRange(2, range.location-2);
            propertyClassName = [propertyType substringWithRange:range];
        }
    }
    else
    {
        propertyType = [propertyType lowercaseString];
        if ([propertyType hasPrefix:@"ti"] || [propertyType hasPrefix:@"tb"])
        {
            propertyClassName = @"int";
        }
        else if ([propertyType hasPrefix:@"tf"])
        {
            propertyClassName = @"float";
        }
        else if([propertyType hasPrefix:@"td"])
        {
            propertyClassName = @"double";
        }
        else if([propertyType hasPrefix:@"tl"] || [propertyType hasPrefix:@"tq"])
        {
            propertyClassName = @"long";
        }
        else if ([propertyType hasPrefix:@"tc"])
        {
            propertyClassName = @"char";
        }
        else if([propertyType hasPrefix:@"ts"])
        {
            propertyClassName = @"short";
        }
    }
    
    return propertyClassName;
}

+ (void)getModelStr:(NSObject *)model complete:(void (^)(NSString *))complete
{
    __block NSString* result = @"";
    
    [FYDBUtils getAttributeWithClass:[model class] result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        for (NSInteger i = 0; i < attributeArray.count; i ++) {
            
            NSString* attribute = attributeArray[i];
            NSString* type = [FYModelMapping changeDBType:typeArray[i]];
            id tempValue = [model valueForKey:attribute];
            
            if ([type isEqualToString:@"text"]) {
                
                if (tempValue) {
                    
                    if ([tempValue isKindOfClass:[NSString class]]) {   // 排除字符串
                        
                        result = [result stringByAppendingString:[NSString stringWithFormat:@"\"\"%@\"\":",attribute]];
                        result = [result stringByAppendingString:[NSString stringWithFormat:@"\"\"%@\"\",",tempValue]];
                        
                    }else {
                        
                        // 自定义类
                        [FYDBUtils getModelStr:tempValue complete:^(NSString *modelStr) {
                            
                            result = [result stringByAppendingString:[NSString stringWithFormat:@"\"\"%@-%@\"\" : ",[tempValue class],attribute]];
                            result = [result stringByAppendingString:[NSString stringWithFormat:@"%@,",modelStr]];
                        }];
                    }
                }
            }else {
                
                result = [result stringByAppendingString:[NSString stringWithFormat:@"\"\"%@\"\":",attribute]];
                result = [result stringByAppendingString:[NSString stringWithFormat:@"%@,",tempValue]];
            }
        }
        
        result = [NSString stringWithFormat:@"{%@}",[result substringToIndex:(result.length - 1)]];
        
        if (complete) {
            complete(result);
        }
    }];
}

+ (void)getValueArrayStr:(id)value complete:(void(^)(NSString* valueStr))complete
{
    __block NSString* res = @"";
    
    if ([value isKindOfClass:[NSString class]]) {
        
        res = [NSString stringWithFormat:@"\"%@\" , ",value];
        
    }else if ([value isKindOfClass:[NSDictionary class]]) {
        
        [FYDBUtils getDicStr:value complete:^(NSString * dicStr) {
           
            res = [res stringByAppendingString:dicStr];
        }];
        
    }else if ([value isKindOfClass:[NSArray class]]) {
        
        [FYDBUtils getArrayStr:value complete:^(NSString *arrayStr) {
           
            res = [res stringByAppendingString:arrayStr];
        }];
    }else {
        
        // 自定义类
        [FYDBUtils getModelStr:value complete:^(NSString *modelStr) {
           
            res = [res stringByAppendingFormat:@"{\"%@\" : %@} , ",[value class],modelStr];
        }];
    }
    
    res = [res substringToIndex:(res.length - 3)];
    
    if (complete) {
        complete(res);
    }
}

+ (void)getValueDicStr:(id)value complete:(void(^)(NSString* dicStr))complete
{
    __block NSString* res = @"";
    
    if ([value isKindOfClass:[NSString class]]) {
        
        res = value;
        
    }else if ([value isKindOfClass:[NSDictionary class]]) {
        
        [FYDBUtils getDicStr:value complete:^(NSString * dicStr) {
            
            res = [res stringByAppendingString:dicStr];
        }];
        
    }else if ([value isKindOfClass:[NSArray class]]) {
        
        [FYDBUtils getArrayStr:value complete:^(NSString *arrayStr) {
            
            res = [res stringByAppendingString:arrayStr];
        }];
    }else {
        
        //自定义类
        [FYDBUtils getModelStr:value complete:^(NSString *modelStr) {
           
            res = [res stringByAppendingFormat:@"%@:%@\",",[value class],modelStr];
        }];
    }
    
    if (complete) {
        complete(res);
    }
}

+ (void)getArrayStr:(NSArray *)array complete:(void (^)(NSString * arrayStr))complete
{
    __block NSString* res = @"";;
    
    for (NSInteger i = 0; i < array.count; i ++) {
     
        id value = array[i];
        
        [FYDBUtils getValueArrayStr:value complete:^(NSString *valueStr) {
           
            res = [res stringByAppendingFormat:@"%@ , ",valueStr];

        }];
    }
    
    res = [res substringToIndex:(res.length - 2)];
    res = [NSString stringWithFormat:@"[%@]",res];
    
    if (complete) {
        complete(res);
    }
}

+ (void)getDicStr:(NSDictionary* )dic complete:(void(^)(NSString * dicStr))complete
{
    __block NSString* res = @"";
    
    NSArray* keyList = [dic allKeys];
    for (NSInteger i = 0; keyList.count; i ++) {
        
        id value = [dic objectForKey:keyList[i]];
        
        [FYDBUtils getValueDicStr:value complete:^(NSString *dicStr) {
           
            res = [res stringByAppendingString:dicStr];
        }];
    }
    
    if (complete) {
        complete(res);
    }
}

+ (void)getModel:(NSString*)className modelDic:(NSDictionary*)dic complete:(void(^)(id obj))complete
{
    id obj = [[NSClassFromString(className) alloc] init];
    
    [FYDBUtils getAttributeWithClass:NSClassFromString(className) result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        for (NSInteger i = 0; i < attributeArray.count; i ++) {
            
            NSString* type = typeArray[i];
            NSString* attribute = attributeArray[i];
            
            BOOL isCustom = NO;
            NSArray* tempList = [dic allKeys];
            for (NSInteger i = 0; i < tempList.count; i ++) {
                
                NSString* value = tempList[i];
                if ([value containsString:@"-"]) {
                    
                    isCustom = YES;
                }
            }
            
            id value = [dic objectForKey:attribute];
            
            type = [FYModelMapping changeDBType:type];
            
            if ([type isEqualToString:LKSQL_Type_Text]) {
                
                if (!value || [value isKindOfClass:[NSDictionary class]]) {  // 自定义类
                    
                    NSString* tempAttribute = attributeArray[i];
                    tempAttribute = [NSString stringWithFormat:@"%@-%@",typeArray[i],tempAttribute];
                    
                    if (![dic objectForKey:tempAttribute]) {
                        
                        continue;
                    }
                    
                    [FYDBUtils getModel:typeArray[i] modelDic:[dic objectForKey:tempAttribute] complete:^(id tempObj) {
                        
                        [obj setValue:tempObj forKey:attribute];
                    }];
                    
                }else {
                    
                    [obj setValue:[dic objectForKey:attribute] forKey:attribute];
                }
            }else {
                
                [obj setValue:[dic objectForKey:attribute] forKey:attribute];
            }
        }
    }];
    
    if (complete) {
        complete(obj);
    }
}

+ (void)getArray:(NSString *)arrayStr complete:(void (^)(NSArray *))complete
{
    NSMutableArray* array = [NSMutableArray array];
    
    arrayStr = [arrayStr stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
    arrayStr = [arrayStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
    arrayStr = [arrayStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
    
    NSArray* tempArray = [arrayStr componentsSeparatedByString:@" , "];
    
    for (NSInteger i = 0; i < tempArray.count; i ++) {
        
        NSString* valueStr = tempArray[i];
        
        [FYDBUtils changeModel:valueStr complete:^(id obj) {
            
            [array addObject:obj];
        }];
        
    }
    
    if (complete) {
        complete(array.copy);
    }
}

+ (void)getDic:(NSString *)dicStr complete:(void (^)(NSDictionary *))complete
{
    
}

+ (void)getModelByModelStr:(NSString*)modelStr className:(NSString*)className complete:(void(^)(id obj))complete
{
    Class cla = NSClassFromString(className);
    
    id obj = [[cla alloc] init];
    
    [FYDBUtils getAttributeWithClass:cla result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        for (NSInteger i = 0; i < attributeArray.count; i ++) {
            
            NSString* attribute = attributeArray[i];
            NSString* type = typeArray[i];
            
            [FYModelMapping getModelType:attribute type:type systemClassBlock:^{
                
                
                
            } customClassBlcok:^{
                
            } baseClassBlock:^{
                
            }];
        }
    }];
    
}

//// 将模型字符串转化成模型
//+ (void)changeModel:(NSString*)modelStr complete:(void(^)(id obj))complete
//{
//    // 搜索右括号
//    NSRange rightRange = [modelStr rangeOfString:@"}"];
//    
//    if (rightRange.location != NSNotFound && rightRange.location != 1) {
//        
//        NSRange leftRange = [modelStr rangeOfString:@"{" options:NSBackwardsSearch range:NSMakeRange(0, rightRange.location)];
//        NSString* model = [modelStr substringWithRange:NSMakeRange(leftRange.location, rightRange.location + 1 - leftRange.location)];
//        
//        NSRange typeRightRange = [modelStr rangeOfString:@"\"" options:NSBackwardsSearch range:NSMakeRange(0, leftRange.location)];
//        NSRange typeLeftRange = [modelStr rangeOfString:@"\"" options:NSBackwardsSearch range:NSMakeRange(0, typeRightRange.location - 1)];
//        NSString* type = [modelStr substringWithRange:NSMakeRange(typeLeftRange.location + 1, typeRightRange.location - typeLeftRange.location - 1)];
//        
//        NSArray* array = [type componentsSeparatedByString:@"-"];
//        type = [array lastObject];
//        NSString* classType = [array firstObject];
//        
//        __block id obj;
//        
//        // 变为字典
//        NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:[model dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
//        [FYDBUtils getModel:classType modelDic:dic complete:^(id tempObj) {
//           
//            obj = tempObj;
//            
//        }];
//        
//        
//        
//        // 继续搜索
//        modelStr = [modelStr stringByReplacingCharactersInRange:NSMakeRange(typeLeftRange.location, rightRange.location - typeLeftRange.location) withString:@""];
//        
//        [FYDBUtils changeModel:modelStr complete:^(id lastObj){
//            
//            [lastObj setValue:obj forKey:type];
//        }];
//        
//    }else {
//        
////        NSLog(@"%@",obj);
////        if (complete) {
////            complete(obj);
////        }
//    }
//}

// 将模型字符串转化成模型
+ (void)changeModel:(NSString*)modelStr complete:(void(^)(id obj))complete
{
    NSArray* temp = [modelStr componentsSeparatedByString:@" : "];
    NSString* classType = [[temp firstObject] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    classType = [classType stringByReplacingOccurrencesOfString:@"{" withString:@""];
    classType = [classType stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    if ([classType containsString:@"-"]) {
        
        classType = [[classType componentsSeparatedByString:@"-"] firstObject];
    }
    
    id obj = [[NSClassFromString(classType) alloc] init];
    
    [FYDBUtils getTypeListAndValueList:modelStr complete:^(NSArray *typeList, NSArray *valueList) {
       
        for (NSInteger i = 0; i < typeList.count; i++) {
            
            NSString* type = typeList[i];
            NSString* value = valueList[i];
            
            if ([type containsString:@"-"]) {
                
                NSString* model = [NSString stringWithFormat:@"\"%@\" : %@",type,value];
                // 自定义类
                [FYDBUtils changeModel:model complete:^(id tempObj) {
                   
                    [obj setValue:tempObj forKey:[[type componentsSeparatedByString:@"-"] lastObject]];
                }];
                
            }else {
                
                [obj setValue:value forKey:type];
            }
        }
        
        if (complete) {
            complete(obj);
        }
    }];
  
}

// changeModel 帮助方法
+ (void)getTypeListAndValueList:(NSString*)modelStr complete:(void(^)(NSArray* typeList, NSArray* valueList))complete
{
    NSMutableArray* typeList = [NSMutableArray array];
    NSMutableArray* valueList = [NSMutableArray array];
    
    NSRange range = [modelStr rangeOfString:@" : "];
    NSString* temp = [modelStr substringWithRange:NSMakeRange(range.location + range.length, modelStr.length - range.length - range.location)];
    
    range = [temp rangeOfString:@" : "];
    
    if (range.location != NSNotFound) {
        
        // 提取类型
        NSString* typeTemp = [[temp componentsSeparatedByString:@" : "] firstObject];
        NSRange rightRange = [typeTemp rangeOfString:@"\"" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
        NSRange leftRange = [typeTemp rangeOfString:@"\"" options:NSBackwardsSearch range:NSMakeRange(0, rightRange.location)];
        typeTemp = [typeTemp substringWithRange:NSMakeRange(leftRange.location, rightRange.location - leftRange.location)];
        typeTemp = [typeTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        // 提取值
        NSString* valueTemp = [temp substringWithRange:NSMakeRange(range.location + range.length, temp.length - range.location - range.length)];
        
        NSInteger count = 0;
        NSInteger position = -1;
        
        for (NSInteger i = 0; i < valueTemp.length; i++) {
            
            char c = [valueTemp characterAtIndex:i];
            if (c == '{') {
                
                count ++ ;
                
            }else if (c == '}') {
                
                count --;
            }
            
            if (count == 0) {
                
                position = i;
                break;
            }
        }
        
        valueTemp = [valueTemp substringWithRange:NSMakeRange(0, position + 1)];
        
        [typeList addObject:typeTemp];
        [valueList addObject:valueTemp];

        NSString* removeStr = [NSString stringWithFormat:@"\"%@\" : %@",typeTemp,valueTemp];
        temp = [temp stringByReplacingOccurrencesOfString:removeStr withString:@""];
    }
    
    temp = [[temp componentsSeparatedByString:@" : "] lastObject];
    NSArray* array = [temp componentsSeparatedByString:@","];
    
    for (NSInteger i = 0; i < array.count; i ++) {
        
        NSString* valueStr = [array[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"{" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"}" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* type = [[valueStr componentsSeparatedByString:@":"] firstObject];
        NSString* value = [[valueStr componentsSeparatedByString:@":"] lastObject];
        
        if ([FYDBUtils checkStringIsValid:type] && [FYDBUtils checkStringIsValid:value]) {
            
            [typeList addObject:type];
            [valueList addObject:value];
        }
    }
    
    if (complete) {
        
        complete(typeList, valueList);
    }
}

@end
