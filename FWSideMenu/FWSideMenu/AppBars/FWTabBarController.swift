//
//  FWTabBarController.swift
//  FanweApps
//
//  Created by xfg on 2018/1/23.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色设为白色
        self.view.backgroundColor = UIColor.white
        
        let tabBar = UITabBarItem.appearance()
        let attrsNormal = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10.0), NSAttributedStringKey.foregroundColor: UIColor.gray]
        let attrsSelected = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10.0), NSAttributedStringKey.foregroundColor: UIColor(red: (71/255), green: (186/255), blue: (254/255), alpha: 1.0)]
        tabBar.setTitleTextAttributes(attrsNormal, for: .normal)
        tabBar.setTitleTextAttributes(attrsSelected, for: .selected)
        
        setupUI()
    }
}


extension FWTabBarController {
    
    fileprivate func setupUI() {
        
        setValue(FWTabBar(), forKey: "tabBar")
        
        let vcArray:[UIViewController] = [RecentViewController(), BuddyViewController(), SeeViewController(), QworldViewController()]
        let titleArray = [("消息", "recent"), ("联系人", "buddy"), ("看点", "see"), ("动态", "qworld")]
        for (index, vc) in vcArray.enumerated() {
            // 需要title的情况
            vc.tabBarItem.title = titleArray[index].0
            // 不需要title的情况，需要调整image位置
            // vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            vc.tabBarItem.image = UIImage(named: "tab_\(titleArray[index].1)_nor")
            vc.tabBarItem.selectedImage = UIImage(named: "tab_\(titleArray[index].1)_press")
            let nav = FWNavigationController(rootViewController: vc)
            addChildViewController(nav)
        }
    }
}

