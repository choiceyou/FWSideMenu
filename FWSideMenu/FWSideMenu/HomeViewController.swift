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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-icon"), style: .plain, target: self, action: #selector(leftBtnAction))
    }
    
    @objc func leftBtnAction() {
        
    }
    
}
