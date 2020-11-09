//
//  FWTabBarController.swift
//  FanweApps
//
//  Created by xfg on 2018/1/23.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var currentSelectedIndex: NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色设为白色
        self.view.backgroundColor = UIColor.white
        
        self.delegate = self
        
        let tabBar = UITabBarItem.appearance()
        let attrsNormal = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0), NSAttributedString.Key.foregroundColor: UIColor.gray]
        let attrsSelected = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0), NSAttributedString.Key.foregroundColor: UIColor(red: (71/255), green: (186/255), blue: (254/255), alpha: 1.0)]
        tabBar.setTitleTextAttributes(attrsNormal, for: .normal)
        tabBar.setTitleTextAttributes(attrsSelected, for: .selected)
        
        setupUI()
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    //    override var childViewControllerForStatusBarStyle: UIViewController? {
    //        return self.tabBarController!.viewControllers![self.currentSelectedIndex]
    //    }
    //
    //    override var childViewControllerForStatusBarHidden: UIViewController? {
    //        return self.tabBarController!.viewControllers![self.currentSelectedIndex]
    //    }
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
            addChild(nav)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //        if tabBarController.viewControllers != nil {
        //            self.currentSelectedIndex = tabBarController.viewControllers!.firstIndex(of: viewController) ?? 0
        //        }
        //        self.setNeedsStatusBarAppearanceUpdate()
        return true
    }
}

