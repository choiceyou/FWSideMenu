//
//  SideMenuViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/8.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

fileprivate let bgImageViewHeight: CGFloat = UIScreen.main.bounds.height * 0.32
fileprivate let bottomViewHeight: CGFloat = 88

fileprivate let kBackgroundColor = UIColor(white: 0.98, alpha: 0.98)

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let titleArray = ["了解会员特权", "QQ钱包", "个性装扮", "我的收藏", "我的相册", "我的文件", "免流量特权"]
    let imageArray = ["qq_setting_svip", "qq_setting_qianbao", "qq_setting_zhuangban", "qq_setting_shoucang", "qq_setting_xiangce", "qq_setting_wenjian", "qq_setting_freetraffic"]
    
    
    lazy var tableView: UITableView = {
        
        let tableview = UITableView(frame: CGRect(x: 0, y: bgImageViewHeight, width: kMenuWidth, height: UIScreen.main.bounds.height - bgImageViewHeight - bottomViewHeight))
        tableview.separatorStyle = .none
        tableview.backgroundColor = kBackgroundColor
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = kBackgroundColor
        
        self.view.addSubview(self.tableView)
        //        self.tableView.estimatedRowHeight = 44.0
        self.tableView.register(UINib(nibName: "SideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let headerView = SideMenuHeaderView.createView()
        headerView.frame = CGRect(x: 0, y: 0, width: kMenuWidth, height: bgImageViewHeight)
        self.view.addSubview(headerView)
        
        let bottomView = SideMenuBottomView.createView()
        bottomView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - bottomViewHeight, width: kMenuWidth, height: bottomViewHeight)
        bottomView.backgroundColor = kBackgroundColor
        self.view.addSubview(bottomView)
        
    }
}

extension SideMenuViewController {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10))
        tmpView.backgroundColor = UIColor.clear
        return tmpView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SideMenuTableViewCell
        cell.iconImgView.image = UIImage(named: self.imageArray[indexPath.row])
        cell.titleLabel.text = self.titleArray[indexPath.row]
        cell.backgroundColor = kBackgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var navigationController: UINavigationController?
        
        if self.menuContainerViewController.centerViewController!.isKind(of: UITabBarController.self) {
            let tmpVC = self.menuContainerViewController.centerViewController!.childViewControllers[0]
            if tmpVC.isKind(of: UINavigationController.self) {
                navigationController = tmpVC as? UINavigationController
            }
        } else if self.menuContainerViewController.centerViewController!.isKind(of: UINavigationController.self) {
            navigationController = self.menuContainerViewController.centerViewController as? UINavigationController
        }
        
        if navigationController != nil {
            navigationController!.pushViewController(SubViewController(), animated: true)
        }
        
        self.menuContainerViewController.setSideMenuState(state: .closed, completeBlock: nil)
    }
}
