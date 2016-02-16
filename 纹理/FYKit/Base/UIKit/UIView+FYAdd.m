//
//  UIView+FYAdd.m
//  EmotionCenter
//
//  Created by fanyingzhao on 15/12/9.
//  Copyright © 2015年 fyz. All rights reserved.
//

#import "UIView+FYAdd.h"

@implementation UIView (FYAdd)

+ (UIView *)copyView:(UIView *)view
{
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}
@end
