//
//  SideMenuViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/8.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class SideMenuViewController: UITableViewController {
    
    let titleArray = [["测试一", "测试二", "测试三测试三测试三测试三测试三测试三测试三测试三测试三测试三"],
                      ["测试a", "测试b", "测试c"],
                      ["测试1", "测试2", "测试3"],
                      ["测试ds", "测试2sd", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss", "测试3dss"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame.size.height = UIScreen.main.bounds.height
        
        self.view.backgroundColor = UIColor.white
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
    }
}

extension SideMenuViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = self.titleArray[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
