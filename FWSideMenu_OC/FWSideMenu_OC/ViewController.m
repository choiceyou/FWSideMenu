//
//  ViewController.m
//  FWSideMenu_OC
//
//  Created by xfg on 2018/4/11.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "ViewController.h"
#import <FWSideMenu/FWSideMenu-Swift.h>
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header"] style:UIBarButtonItemStylePlain target:self action:@selector(leftNavBtnAction)];
}

- (void)leftNavBtnAction
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.sideMenuContainer toggleLeftSideMenuWithCompleteBolck:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
