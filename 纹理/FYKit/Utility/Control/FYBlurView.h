//
//  FYBlurView.h
//  CleanMaskView
//
//  Created by mac on 15/11/11.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYBlurView : UIView

/**
 *  模糊系数 默认是0.3
 */
@property (nonatomic, assign) CGFloat blurAmount;

/**
 *  默认是 keyWindow
 */
@property (nonatomic, strong) UIView* attachedView;

/**
 *  点击是否隐藏 默认为YES
 */
@property (nonatomic, assign) BOOL touchHidden;

- (void)show;

- (void)hide;

@end
