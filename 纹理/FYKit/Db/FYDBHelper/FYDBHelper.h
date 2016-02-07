//
//  FYDBHelper.h
//  FYDBHelper
//
//  Created by mac on 15/10/23.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "NSObject+FYModel.h"

typedef void(^CALL_BACK)(BOOL result);
typedef void(^SEARCH_CALL_BACK)(NSArray* resutlArray);

@interface FYDBHelper : NSObject

+ (instancetype)shareInstance;

#pragma mark - create
- (void)createTable:(Class)className;

#pragma mark - insert
- (void)insertToDB:(NSObject*)model;

/**
 *  异步插入,数据量大时使用
 */
- (void)asyInsertToDB:(NSArray*)modelArray callback:(CALL_BACK)callback;


#pragma mark - update
- (void)updateToDB:(NSObject*)model;
- (void)updateToDB:(NSObject*)model where:(NSString*)where;
- (void)updateToDB:(NSObject*)model where:(NSString*)where callback:(CALL_BACK)callback;


#pragma mark - delete
- (void)deleteToDB:(NSObject*)model;
- (void)deleteAllToDB:(Class)className;


#pragma makr - search
- (NSArray*)searchToDB:(Class)className where:(NSString*)where;

- (BOOL)searchTableIsExitsData:(Class)className;

- (NSArray*)searchToDB:(Class)className
                 where:(NSString*)where
               orderby:(NSString*)orderAttribute
                   asc:(BOOL)isAsc
                 count:(NSInteger)count;

/**
 *  异步查询
 */
- (void)asySearchToDB:(Class)className
                where:(NSString*)where
              orderby:(NSString*)orderAttribute
                  asc:(BOOL)isAsc
                count:(NSInteger)count
             callback:(SEARCH_CALL_BACK)callback;
@end
