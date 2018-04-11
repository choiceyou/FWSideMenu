//
//  SeeViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/10.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class SeeViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 设置导航栏
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: navTitleFont)]
        self.navigationController?.navigationBar.setBackgroundImage(AppDelegate.resizableImage(imageName: "header_bg_message", edgeInsets: UIEdgeInsetsMake(0, 0, 0, 0)), for: .default)
        
        // 设置状态栏
        UIApplication.shared.statusBarStyle = .lightContent
        
        // 本页面开启支持打开侧滑菜单
        self.menuContainerViewController.sideMenuPanMode = .defaults
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 设置导航栏
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: navTitleFont)]
        self.navigationController?.navigationBar.setBackgroundImage(AppDelegate.getImageWithColor(color: UIColor.white), for: .default)
        
        // 离开本页面时关闭支持打开侧滑菜单
        self.menuContainerViewController.sideMenuPanMode = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "看点"
    }
}
