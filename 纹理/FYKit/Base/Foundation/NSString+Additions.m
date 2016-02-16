//
//  NSString+Additions.m
//  FYHealth
//
//  Created by fanyingzhao on 15/10/20.
//  Copyright (c) 2015年 fyz. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isVaild
{
    return ((nil == self) || [self isEqual:[NSNull null]] || [self isEqualToString:@"(null)"] || [self isEqualToString:@""])?NO:YES;
}
@end
