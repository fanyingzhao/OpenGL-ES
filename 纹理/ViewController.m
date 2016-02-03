//
//  ViewController.m
//  纹理
//
//  Created by fanyingzhao on 16/2/1.
//  Copyright © 2016年 fyz. All rights reserved.
//

#import "ViewController.h"
#import "GLKVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GLKVC* vc = [[GLKVC alloc] init];
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
