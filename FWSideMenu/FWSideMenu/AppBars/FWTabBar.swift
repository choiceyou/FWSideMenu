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
    
    lazy var animateImageView0: UIImageView = {
        
        let animateImageView = UIImageView(image: UIImage(named: "tab_recent_fg_press"))
        self.addSubview(animateImageView)
        return animateImageView
    }()
    lazy var animateImageView1: UIImageView = {
        
        let animateImageView = UIImageView(image: UIImage(named: "tab_buddy_fg_nor"))
        self.addSubview(animateImageView)
        return animateImageView
    }()
    lazy var animateImageView2: UIImageView = {
        
        let animateImageView = UIImageView(image: UIImage(named: "tab_see_fg_nor"))
        self.addSubview(animateImageView)
        return animateImageView
    }()
    lazy var animateImageView3: UIImageView = {
        
        let animateImageView = UIImageView(image: UIImage(named: "tab_qworld_fg_press"))
        self.addSubview(animateImageView)
        return animateImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.backgroundImage = AppDelegate.resizableImage(imageName: (kStatusBarHeight > 20) ? "tabbar_bg_X" : "tabbar_bg", edgeInsets: UIEdgeInsetsMake(0.1, 0, 0, 0))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
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
                view.tag = index
                
                switch index {
                case 0:
                    self.animateImageView0.center = view.center
                    self.animateImageView0.frame.origin.y -= 5
                    break
                case 1:
                    self.animateImageView1.center = view.center
                    self.animateImageView1.frame.origin.y -= 5
                    break
                case 2:
                    self.animateImageView2.center = view.center
                    self.animateImageView2.frame.origin.y -= 5
                    break
                case 3:
                    self.animateImageView3.center = view.center
                    self.animateImageView3.frame.origin.y -= 5
                    self.animateImageView3.image = nil
                    break
                default:
                    break
                }
                
                (view as! UIControl).addTarget(self, action: #selector(tabBarBtnAction(bar:)), for: .touchUpInside)
                
                index += 1
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
        
        switch bar.tag {
        case 0:
            self.animateImageView0.image = UIImage(named: "tab_recent_fg_press")
            self.animateImageView1.image = UIImage(named: "tab_buddy_fg_nor")
            self.animateImageView2.image = UIImage(named: "tab_see_fg_nor")
            self.animateImageView3.image = nil
            break
        case 1:
            self.animateImageView0.image = UIImage(named: "tab_recent_fg_nor")
            self.animateImageView1.image = UIImage(named: "tab_buddy_fg_press")
            self.animateImageView2.image = UIImage(named: "tab_see_fg_nor")
            self.animateImageView3.image = nil
            break
        case 2:
            self.animateImageView0.image = UIImage(named: "tab_recent_fg_nor")
            self.animateImageView1.image = UIImage(named: "tab_buddy_fg_nor")
            self.animateImageView2.image = UIImage(named: "tab_see_fg_press")
            self.animateImageView3.image = nil
            break
        case 3:
            self.animateImageView0.image = UIImage(named: "tab_recent_fg_nor")
            self.animateImageView1.image = UIImage(named: "tab_buddy_fg_nor")
            self.animateImageView2.image = UIImage(named: "tab_see_fg_nor")
            self.animateImageView3.image = UIImage(named: "tab_qworld_fg_press")
            break
        default:
            break
        }
    }
}
