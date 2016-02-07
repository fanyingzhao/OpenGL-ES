//
//  ViewController.m
//  纹理
//
//  Created by fanyingzhao on 16/2/1.
//  Copyright © 2016年 fyz. All rights reserved.
//

#import "ViewController.h"
#import "GLKVC.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"OpenGL ES";
    self.dataList = @[@[@"纹理映射模式",[GLKVC class]]];
    
    TableViewRegisterClass(self.tableView, [UITableViewCell class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tools
- (void)presentToViewController:(Class)class title:(NSString*)title
{
    UIViewController* vc = [[class alloc] init];
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [self.dataList[indexPath.row] firstObject];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self presentToViewController:[self.dataList[indexPath.row] lastObject] title:[self.dataList[indexPath.row] firstObject]];
}

@end
