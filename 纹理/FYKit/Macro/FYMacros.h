//
//  FYMacros.h
//  FYHealth
//
//  Created by fanyingzhao on 15/10/15.
//  Copyright (c) 2015年 fyz. All rights reserved.
//

#ifndef FYHealth_FYMacros_h
#define FYHealth_FYMacros_h

#define FYScreenSize                    [UIScreen mainScreen].bounds.size
#define FYScreenBounds                  [UIScreen mainScreen].bounds
#define FYScreenWidth                   [UIScreen mainScreen].bounds.size.width
#define FYScreenHeight                  [UIScreen mainScreen].bounds.size.height



#pragma mark - 方法宏
#define FYClass(x)               NSStringFromClass([x class])
#define WeakSelf(x)              __weak __typeof(x) weakSelf = x


#endif
