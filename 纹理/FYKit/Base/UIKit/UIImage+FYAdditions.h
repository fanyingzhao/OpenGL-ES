//
//  UIImage+FYAdditions.h
//  ElephantPhoto
//
//  Created by fanyingzhao on 15/11/29.
//  Copyright © 2015年 fyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FYAdditions)

/**
 *  改变图片的颜色
 *
 *  @param color 要改变的颜色
 *
 *  @return 改变颜色后的图片
 */
- (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)createImageWithColor:(UIColor *)color;
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;

@end
