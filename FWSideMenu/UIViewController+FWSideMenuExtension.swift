//
//  UIViewController+FWSideMenuExtension.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/9.
//  Copyright © 2018年 xfg. All rights reserved.
//


/** ************************************************
 
 github地址：https://github.com/choiceyou/FWSideMenu
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit

public extension UIViewController {
    
    var menuContainerViewController: FWSideMenuContainerViewController {
        var contrainerVC = self
        while !contrainerVC.isKind(of: FWSideMenuContainerViewController.self) {
            if contrainerVC.responds(to: #selector(getter: parent)) {
                contrainerVC = contrainerVC.parent!
            }
        }
        return contrainerVC as! FWSideMenuContainerViewController
    }
}
