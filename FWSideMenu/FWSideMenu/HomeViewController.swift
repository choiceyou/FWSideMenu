//
//  HomeViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/8.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let leftBtn = UIButton(type: .custom)
        leftBtn.frame = CGRect(x: -5, y: 0, width: 30, height: 30)
        leftBtn.setBackgroundImage(UIImage(named: "header"), for: .normal)

        leftBtn.layer.cornerRadius = 20
        leftBtn.clipsToBounds = true
        leftBtn.layer.borderColor = UIColor.white.cgColor
        leftBtn.layer.borderWidth = 2
        leftBtn.addTarget(self, action: #selector(leftBtnAction), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        let tmpImgView = UIImageView(frame: self.view.bounds)
        tmpImgView.image = UIImage(named: "ceshi")
        self.view.addSubview(tmpImgView)
        
    }
    
    @objc func leftBtnAction() {
        self.menuContainerViewController.toggleLeftSideMenu(completeBolck: nil)
    }
    
}
