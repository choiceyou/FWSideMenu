//
//  SubViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/11.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class SubViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "子控制器"
        
        let emptyImgView = UIImageView(image: UIImage(named: "img_empty_photo"))
        emptyImgView.center = self.view.center
        self.view.addSubview(emptyImgView)
        
    }
}
