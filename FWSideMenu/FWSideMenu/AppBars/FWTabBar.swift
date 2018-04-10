//
//  FWTabBar.swift
//  FanweApps
//
//  Created by xfg on 2018/1/23.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class FWTabBar: UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //        self.backgroundColor = UIColor.white
        self.backgroundImage = AppDelegate.resizableImage(imageName: "tabbar_bg", edgeInsets: UIEdgeInsetsMake(0.1, 0, 0, 0))
    }
    
    //    override func draw(_ rect: CGRect) {
    //
    //        var index = 0
    //        for view in subviews {
    //            if view.isKind(of: NSClassFromString("UITabBarButton")!) {
    //
    //                index += 1
    //                if index == 1 {
    //                    let tmpImage = UIImageView(image: UIImage(named: "tab_recent_fg_nor"))
    //                    tmpImage.center = view.center
    //                    tmpImage.tag = index
    //                    view.addSubview(tmpImage)
    //                    view.bringSubview(toFront: tmpImage)
    //                }
    //            }
    //        }
    //    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.frame.height > kTabBarHeight {
            self.frame.size.height = kTabBarHeight
        }
        
        let btnW = self.frame.width / CGFloat(self.items!.count)
        let btnH: CGFloat = 49
        let btnY: CGFloat = 0
        
        var index = 0
        for view in subviews {
            if view.isKind(of: NSClassFromString("UITabBarButton")!) {
                let buttonX = CGFloat(index) * btnW
                view.frame = CGRect(x: buttonX, y: btnY, width: btnW, height: btnH)
                
                index += 1
                view.tag = index
                
                (view as! UIControl).addTarget(self, action: #selector(tabBarBtnAction(bar:)), for: .touchUpInside)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FWTabBar {
    
    @objc func tabBarBtnAction(bar: UIControl) {
        
        for imageView in bar.subviews {
            if imageView.isKind(of: NSClassFromString("UITabBarSwappableImageView")!) {
                let animation = CAKeyframeAnimation()
                animation.keyPath = "transform.scale"
                animation.values = [1.0, 1.25, 1.0]
                animation.duration = 0.2
                animation.calculationMode = kCAAnimationCubic
                imageView.layer.add(animation, forKey: nil)
            }
        }
    }
}
