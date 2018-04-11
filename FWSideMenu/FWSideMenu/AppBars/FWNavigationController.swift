//
//  FWNavigationController.swift
//  FanweApps
//
//  Created by xfg on 2018/1/23.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

typealias FWVoidBlock = () -> Void
let navTitleFont: CGFloat = 18.0


class FWNavigationController: UINavigationController {
    
    /// 点击某个VC的返回按钮的回调
    var vcBackActionBlock: FWVoidBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttrs = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: navTitleFont)]
        navigationBar.titleTextAttributes = textAttrs
        
        navigationBar.setBackgroundImage(AppDelegate.resizableImage(imageName: "header_bg_message", edgeInsets: UIEdgeInsetsMake(0, 0, 0, 0)), for: .default)
        navigationBar.isTranslucent = false
        
        self.extendedLayoutIncludesOpaqueBars = false
        let edgeOptions: UIRectEdge = [.left, .bottom, .right, .top] //注意位移多选枚举的使用
        self.edgesForExtendedLayout = edgeOptions
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.childViewControllers.count > 0 {
            
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "com_arrow_vc_back"), for: .normal)
            button.setImage(UIImage(named: "com_arrow_vc_back"), for: .highlighted)
            button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitleColor(.red, for: .highlighted)
            button.sizeToFit()
            //            button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
            button.contentHorizontalAlignment = .left
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
            
            button.frame = CGRect(x: 0, y: 0, width: (button.currentImage?.size.width)!+15, height: (button.currentImage?.size.height)!+5)
            viewController.navigationItem.leftBarButtonItem?.customView?.frame = button.frame
            
            viewController.hidesBottomBarWhenPushed = true
            
            // 设置状态栏
            UIApplication.shared.statusBarStyle = .default
        }
        
        super.pushViewController(viewController, animated: animated)
    }
}

extension FWNavigationController {
    
    @objc func backAction() {
        self.popViewController(animated: true)
        
        if self.vcBackActionBlock != nil {
            vcBackActionBlock!()
        }
    }
    
    
}
