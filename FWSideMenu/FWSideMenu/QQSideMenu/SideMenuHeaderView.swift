//
//  SideMenuHeaderView.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/9.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class SideMenuHeaderView: UIView {
    
    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var codeTopConstraint: NSLayoutConstraint!
    
    static func createView() -> SideMenuHeaderView {
        return Bundle.main.loadNibNamed("SideMenuHeaderView", owner: nil, options: nil)!.last as! SideMenuHeaderView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headerImgView.layer.cornerRadius = self.headerImgView.frame.width / 2
        self.headerImgView.clipsToBounds = true
        self.headerImgView.layer.borderColor = UIColor.white.cgColor
        self.headerImgView.layer.borderWidth = 2
        
        self.grayView.backgroundColor = UIColor(white: 0.05, alpha: 0.05)
        
        self.codeTopConstraint.constant = UIApplication.shared.statusBarFrame.height + 5
    }
}
