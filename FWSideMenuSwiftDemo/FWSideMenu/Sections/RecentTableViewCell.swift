//
//  RecentTableViewCell.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/10.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var decLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.tipLabel.layer.cornerRadius = self.tipLabel.frame.width / 2
        self.tipLabel.clipsToBounds = true
        self.tipLabel.backgroundColor = UIColor.red
    }
}
