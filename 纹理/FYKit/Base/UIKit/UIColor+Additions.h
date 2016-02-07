//
//  UIColor+Additions.h
//  FYHealth
//
//  Created by fanyingzhao on 15/10/15.
//  Copyright (c) 2015年 fyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

#pragma mark - Init
+ (UIColor*)colorWithHex:(NSInteger)hex;
+ (UIColor*)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

@end
