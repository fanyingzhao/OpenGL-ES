//
//  UIColor+Additions.m
//  FYHealth
//
//  Created by fanyingzhao on 15/10/15.
//  Copyright (c) 2015年 fyz. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

#pragma mark - Init
+ (UIColor *)colorWithHex:(NSInteger)hex
{
    return [UIColor colorWithHex:hex alpha:1];
}

+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:alpha];
}
@end
