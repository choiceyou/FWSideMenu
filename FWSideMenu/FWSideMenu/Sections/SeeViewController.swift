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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: navTitleFont)]
        self.navigationController?.navigationBar.setBackgroundImage(AppDelegate.getImageWithColor(color: UIColor.white), for: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 设置导航栏
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: navTitleFont)]
        self.navigationController?.navigationBar.setBackgroundImage(AppDelegate.getImageWithColor(color: UIColor.white), for: .default)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "看点"
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
