//
//  UIViewController+FWSideMenuExtension.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/9.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    public var menuContainerViewController: FWSideMenuContainerViewController {
        
        var contrainerVC = self
        while !contrainerVC.isKind(of: FWSideMenuContainerViewController.self) {
            if contrainerVC.responds(to: #selector(getter: parent)) {
                contrainerVC = contrainerVC.parent!
            }
        }
        return contrainerVC as! FWSideMenuContainerViewController
    }
}
