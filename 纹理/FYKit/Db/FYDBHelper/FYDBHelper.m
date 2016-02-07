//
//  FYDBHelper.m
//  FYDBHelper
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "FYDBHelper.h"
#import "FYDBUtils.h"
#import <FMDatabase.h>
#import <objc/runtime.h>
#import "FYModelMapping.h"

#define WEAK(self) __weak __typeof(self) weakSelf = self

@interface FYDBHelper ()

@property (nonatomic, strong) FMDatabaseQueue* dbHelper;
@end

@implementation FYDBHelper

+ (instancetype)shareInstance
{
    static FYDBHelper* instance = nil;
    static dispatch_once_t onceToke;
    
    dispatch_once(&onceToke, ^{
        
        instance = [[FYDBHelper alloc] init];
        instance.dbHelper = [FMDatabaseQueue databaseQueueWithPath:[NSString stringWithFormat:@"%@/Documents/database.db",NSHomeDirectory()]];
    });
    
    return instance;
}

#pragma mark - helper
- (NSString*)getTableName:(Class)className
{
    NSString* tableName = [className getTableName];
    
    return tableName;
}

- (NSString*)getKeyName:(Class)className
{
    NSString* keyName = [className getPrimaryName];
    
    return keyName;
}

#pragma mark - db
- (void)createTable:(Class )className
{
    NSString* tableName = [self getTableName:className];
    NSString* keyName = [self getKeyName:className];
    
    __weak typeof(self) weakSelf = self;
    
    [FYDBUtils getAttributeWithClass:className result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        NSString* sqlStructure = [NSString stringWithFormat:@"create table if not exists %@(",tableName];
        
        if (![FYDBUtils checkStringIsValid:keyName] || ![attributeArray containsObject:keyName]) {
            sqlStructure = [sqlStructure stringByAppendingString:@"ID integer primary key autoincrement,"];
        }
        
        for (NSInteger i = 0; i < attributeArray.count; i++) {
            
            NSString* type = typeArray[i];
            NSString* attribute = attributeArray[i];
            NSString* tempResult;
            
            tempResult = [NSString stringWithFormat:@"%@ %@,",attribute, [FYModelMapping changeDBType:type]];
            
            if ([FYDBUtils checkStringIsValid:keyName] && [keyName isEqualToString:attribute]) {
                
                tempResult = [tempResult substringToIndex:(tempResult.length - 1)];
                tempResult = [tempResult stringByAppendingString:@" primary key,"];
            }
            
            sqlStructure = [sqlStructure stringByAppendingString:tempResult];
        }
        
        sqlStructure = [sqlStructure substringToIndex:(sqlStructure.length - 1)];
        sqlStructure = [sqlStructure stringByAppendingString:@");"];
        
        [weakSelf.dbHelper inDatabase:^(FMDatabase *db) {
            
            [db open];
            
//            NSLog(@"%@",sqlStructure);
            [db executeUpdate:sqlStructure];
            
            [db close];
        }];
    }];
}


#pragma mark - insert
- (void)insertToDB:(NSObject *)model
{
    __weak typeof(self) weakSelf = self;
    
    [FYDBUtils getAttributeWithClass:[model class] result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        NSString* insertSql = [NSString stringWithFormat:@"insert into %@",[[model class] getTableName]];
        NSString* insertKey = @"";
        __block NSString* valueKey = @"";
        
        for (NSInteger i = 0; i < attributeArray.count; i ++) {
            
            NSString* attribute = attributeArray[i];
            id tempValue = [model valueForKey:attribute];
            
            insertKey = [insertKey stringByAppendingString:[NSString stringWithFormat:@"%@,",attribute]];
            
            [FYModelMapping getModelType:attribute type:typeArray[i] systemClassBlock:^{
                
                if ([tempValue isKindOfClass:[NSString class]]) {
                    
                    valueKey = [valueKey stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",tempValue]];
                    
                }else if ([tempValue isKindOfClass:[NSArray class]]) {
                    
                    NSArray* array = (NSArray*)tempValue;
                    
                    [FYDBUtils getArrayStr:array complete:^(NSString *arrayStr) {
                       
                        arrayStr = [arrayStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
                        
                        valueKey = [valueKey stringByAppendingString:[NSString stringWithFormat:@"\"%@-%@:%@\",",[NSArray class],attribute,arrayStr]];
                        
                    }];
                }else if ([tempValue isKindOfClass:[NSDictionary class]]) {
                    
                    [FYDBUtils getDicStr:tempValue complete:^(NSString *dicStr) {
                        
                        dicStr = [dicStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
                        
                        valueKey = [valueKey stringByAppendingString:[NSString stringWithFormat:@"\"%@-%@:%@\",",[NSDictionary class],attribute,dicStr]];
                        
                    }];
                }
            } customClassBlcok:^{
                
                // 自定义类
                [FYDBUtils getModelStr:tempValue complete:^(NSString *modelStr) {
                    
                    valueKey = [valueKey stringByAppendingString:[NSString stringWithFormat:@"\"%@-%@:%@\",",[tempValue class],attribute,modelStr]];
                }];
                
            } baseClassBlock:^{
                
                valueKey = [valueKey stringByAppendingString:[NSString stringWithFormat:@"%@,",tempValue]];
            }];
        }
        
        insertKey = [insertKey substringToIndex:(insertKey.length - 1)];
        valueKey = [valueKey substringToIndex:(valueKey.length - 1)];
        
        insertSql = [insertSql stringByAppendingString:[NSString stringWithFormat:@"(%@) values(%@);",insertKey,valueKey]];
        
        [weakSelf.dbHelper inDatabase:^(FMDatabase *db) {
            
            [db open];
            
//            NSLog(@"%@",insertSql);
            BOOL res = [db executeUpdate:insertSql];
            
            if (res) {
                NSLog(@"成功");
            }
            
            [db close];
        }];
    }];
}

- (void)asyInsertToDB:(NSArray *)modelArray callback:(CALL_BACK)callback
{
    
}


#pragma mark - update
- (void)updateToDB:(NSObject *)model
{
    return [self updateToDB:model where:nil];
}

- (void)updateToDB:(NSObject *)model where:(NSString*)where;
{
    __weak typeof (self) weakSelf = self;
    
    if (![self searchTableIsExitsData:[model class]]) {
        [self insertToDB:model];
        return;
    }
    
    [FYDBUtils getAttributeWithClass:[model class] result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        NSString* updateSql = [NSString stringWithFormat:@"update %@ set ",[self getTableName:[model class]]];
        __block NSString* insertKey = @"";
        
        for (NSInteger i = 0; i < attributeArray.count; i ++) {
            
            NSString* attribute = attributeArray[i];
            NSString* type = typeArray[i];
            
            id value = [model valueForKey:attribute];
            
            [FYModelMapping getModelType:attribute type:type systemClassBlock:^{
                
                if ([value isKindOfClass:[NSString class]]) {
                    
                    insertKey = [insertKey stringByAppendingFormat:@"%@ = \"%@\",",attribute,[model valueForKey:attribute]];
                }
                
            } customClassBlcok:^{
                
                // 自定义类
                [FYDBUtils getModelStr:value complete:^(NSString *modelStr) {
                    
                    insertKey = [insertKey stringByAppendingString:[NSString stringWithFormat:@"%@ = \"%@:%@\",",attribute,[value class],modelStr]];
                }];
                
            } baseClassBlock:^{
                
                insertKey = [insertKey stringByAppendingFormat:@"%@ = %@,",attribute,[model valueForKey:attribute]];
            }];
        }
        
        insertKey = [insertKey substringToIndex:(insertKey.length - 1)];
        updateSql = [updateSql stringByAppendingFormat:@"%@",insertKey];
        
        if ([FYDBUtils checkStringIsValid:where]) {
            updateSql = [updateSql stringByAppendingString:where];
        }
        
        [weakSelf.dbHelper inDatabase:^(FMDatabase *db) {
            
            [db open];
            
            BOOL res = [db executeUpdate:updateSql];
            if (res) {
                NSLog(@"更新成功");
            }
            
            [db close];
        }];
        
    }];
}

#pragma mark - delete
- (void)deleteToDB:(NSObject *)model
{
    NSString* deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = ",[self getTableName:[model class]],[self getKeyName:[model class]]];
    
    id value = [model valueForKey:[self getKeyName:[model class]]];
    if ([value isKindOfClass:[NSString class]]) {
        
        deleteSql = [deleteSql stringByAppendingFormat:@"\"%@\"",value];
        
    }else {
        
        deleteSql = [deleteSql stringByAppendingString:value];
    }
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        [db open];
        
        BOOL res = [db executeUpdate:deleteSql];
        if (res) {
            NSLog(@"删除成功");
        }
        
        [db close];
        
    }];
}

- (void)deleteAllToDB:(Class)className
{
    NSString* deleteSql = [NSString stringWithFormat:@"delete from %@",[self getTableName:className]];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        [db open];
        
        BOOL res = [db executeUpdate:deleteSql];
        if (res) {
            NSLog(@"删除表所有数据成功");
        }
        
        [db close];
    }];
}

#pragma mark - search
- (BOOL)searchTableIsExitsData:(Class)className
{
    __block BOOL res = NO;
    
    NSString* searchSql = [NSString stringWithFormat:@"select COUNT(*) from %@",[self getTableName:className]];
    
    [self.dbHelper inDatabase:^(FMDatabase *db) {
        
        [db open];
        
        FMResultSet* set = [db executeQuery:searchSql];
        while ([set next]) {
            
            res = [set intForColumnIndex:0]?YES:NO;
            break;
        }
        
        [db close];
    }];
    
    return res;
}

- (NSArray*)searchToDB:(Class)className where:(NSString *)where
{
    return [self searchToDB:className where:where orderby:nil asc:NO count:0];
}

- (NSArray*)searchToDB:(Class)className where:(NSString *)where orderby:(NSString *)orderAttribute asc:(BOOL)isAsc count:(NSInteger)count
{
    NSString* tableName = [self getTableName:className];
    
    NSString* search = [NSString stringWithFormat:@"select * from %@",tableName];
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray* resList = [NSMutableArray array];
    
    [FYDBUtils getAttributeWithClass:className result:^(NSMutableArray *attributeArray, NSMutableArray *typeArray) {
        
        [weakSelf.dbHelper inDatabase:^(FMDatabase *db) {
            
            [db open];
            
            FMResultSet* set = [db executeQuery:search];
            
            while ([set next]) {
                
                id obj = [[className alloc] init];
                
                for (NSInteger i = 0; i < attributeArray.count; i ++) {
                    
                    NSString* type = typeArray[i];
                    NSString* attribute = attributeArray[i];
                    
                    NSString* value = [set stringForColumn:attribute];
                    
                    type = [FYModelMapping changeDBType:type];
                    
                    if ([type isEqualToString:LKSQL_Type_Text]) {
                        
                        if ([value containsString:@":"]) {  // 自定义类
                            
                            NSArray* array = [value componentsSeparatedByString:@":"];
                            
                            NSRange range = [value rangeOfString:@":"];
                            value = [value substringFromIndex:range.location + 1];
                            NSString* className = [[[array firstObject] componentsSeparatedByString:@"-"] firstObject];
                            
                            if ([className isEqualToString:NSStringFromClass([NSArray class])]) {
                                
                                [FYDBUtils getArray:value complete:^(NSArray *array) {
                                   
                                    [obj setValue:array forKey:attribute];
                                }];
                                
                            }else if ([className isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                
                                [FYDBUtils getDic:value complete:^(NSDictionary *dic) {
                                   
                                    [obj setValue:dic forKey:attribute];
                                }];
                                
                            }else { // 自定义类
                                
                                NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
                                NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                
                                [FYDBUtils getModel:className modelDic:dic complete:^(id tempObj) {
                                    
                                    [obj setValue:tempObj forKey:attribute];
                                }];
                            }
                            
                        }else {
                            
                            [obj setValue:value forKey:attribute];
                        }
                        
                    }else {
                        
                        [obj setValue:value forKey:attribute];
                    }
                }
                
                [resList addObject:obj];
            }
            
            [db close];
        }];
    }];
    
    return [resList copy];
}

@end
