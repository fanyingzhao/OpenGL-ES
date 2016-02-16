//
//  UIViewController+FYAdditions.m
//  纹理
//
//  Created by fan on 16/2/16.
//  Copyright © 2016年 fyz. All rights reserved.
//

#import "UIViewController+FYAdditions.h"

@implementation UIViewController (FYAdditions)

- (void)setLeftBackButton
{
    if (self.navigationController) {
        UIButton *navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [navBtn setTitle:@"" forState:UIControlStateNormal];
        [navBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [navBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [navBtn setFrame:CGRectMake(0, 0, 35, 35)];
        [navBtn setBackgroundColor:[UIColor clearColor]];
        navBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        UIBarButtonItem *navBarBtn = [[UIBarButtonItem alloc] initWithCustomView:navBtn];
        [self.navigationItem setLeftBarButtonItem:navBarBtn];
    }else {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 25, 48)];
        [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButton];
    }
}

#pragma mark - events
- (void)back
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
