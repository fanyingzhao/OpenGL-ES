//
//  FYModel.h
//  EmotionCenter
//
//  Created by fanyingzhao on 15/12/9.
//  Copyright © 2015年 fyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYModelHelper : NSObject

+ (instancetype)shareInstance;

/**
 *  将返回数据（字典，数组）转化到模型obj 中，如果模型不存在则创建（init）
 *
 *  @param response 返回数据
 *  @param obj      需要转化的模型
 */
- (void)updateModel:(id)response model:(NSObject*)obj;

/**
 *  将返回的数据（字典，数组）转化为模型添加到数组array 中
 *
 *  @param response 返回的数据
 *  @param array    要添加的数组
 *  @param array    数组中的模型类
 */
- (void)updateModel:(id)response array:(NSMutableArray*)array model:(Class)modelClass;
@end
