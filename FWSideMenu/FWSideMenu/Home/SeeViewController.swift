//
//  SeeViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/10.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class SeeViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let textAttrs = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18.0)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttrs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "看点"
    }
}
