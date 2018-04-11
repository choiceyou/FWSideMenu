//
//  MenuViewController.m
//  FWSideMenu_OC
//
//  Created by xfg on 2018/4/11.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "MenuViewController.h"
#import "SubViewController.h"
#import "AppDelegate.h"

@interface MenuViewController ()

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    CGRect tmpFrame = self.view.frame;
    tmpFrame.size.height = [UIScreen mainScreen].bounds.size.height;
    self.view.frame = tmpFrame;
    
    self.titleArray = @[@"了解会员特权", @"QQ钱包", @"个性装扮", @"我的收藏", @"我的相册", @"我的文件", @"免流量特权免流量特权免流量特权免流量特权"];
    
    self.tableView.estimatedRowHeight = 44.0;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nav = nil;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate.sideMenuContainer.centerViewController isKindOfClass:[UITabBarController class]]) {
        
        id tmp = delegate.sideMenuContainer.centerViewController.childViewControllers[0];
        if ([tmp isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)tmp;
        }
        
    } else if ([delegate.sideMenuContainer.centerViewController isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *)delegate.sideMenuContainer.centerViewController;
    }
    
    if (nav) {
        [nav pushViewController:[[SubViewController alloc] init] animated:YES];
    }
    
    [delegate.sideMenuContainer setSideMenuStateWithState:FWSideMenuStateClosed completeBlock:nil];
}

@end
