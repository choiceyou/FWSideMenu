//
//  SideMenuBottomView.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/9.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class SideMenuBottomView: UIView {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    static func createView() -> SideMenuBottomView {
        return Bundle.main.loadNibNamed("SideMenuBottomView", owner: nil, options: nil)!.last as! SideMenuBottomView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
