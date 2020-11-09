//
//  RecentViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/8.
//  Copyright © 2018年 xfg. All rights reserved.
//

import Foundation
import UIKit

class RecentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let imageArray = ["header_0", "header_1", "header_2", "header_3", "header_4", "header_5", "header_6", "header_7", "header_8", "header_9", "header_10"]
    let titleArray = ["服务号", "小甜", "怪蜀黍", "恶天使", "小鱼人", "我的其他QQ账号", "关联账号", "QQ直播", "QQ购物", "HI", "企鹅大叔"]
    let decArray = ["QQ天气：【鼓楼】多云15°/28°，08:05更新~", "[图片]", "或者由于。。。", "你们怕吗？怕你？不存在的。。。", "喂鱼咯", "关联QQ号，代收其他账号好友消息。", "关联账号就是方便，随心所欲，想收就收~", "恭喜你获得10个春暖花开红包~", "前不够花？手机可随借1000-3000元！", "HI咯", "元宵快乐，来给好友们送上祝福吧！"]
    var timeArray: [String] = []
    
    
    lazy var tableView: UITableView = {
        
        let tableview = UITableView(frame: self.view.bounds)
        tableview.separatorStyle = .none
        return tableview
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 设置导航栏
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: navTitleFont)]
        self.navigationController?.navigationBar.setBackgroundImage(AppDelegate.resizableImage(imageName: "header_bg_message", edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)), for: .default)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        // 本页面开启支持打开侧滑菜单
        self.menuContainerViewController.sideMenuPanMode = .defaults
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 设置导航栏
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: navTitleFont)]
        self.navigationController?.navigationBar.setBackgroundImage(AppDelegate.getImageWithColor(color: UIColor.white), for: .default)
        
        // 本页面开启支持关闭侧滑菜单
        self.menuContainerViewController.sideMenuPanMode = .none
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "消息"
        self.view.frame.size.height = UIScreen.main.bounds.height - kStatusAndNavBarHeight - kTabBarHeight
        
        for index in 0...self.imageArray.count {
            self.timeArray.append(self.obtainRandomTime(index: index))
        }
        
        let buttonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "header"), style: .plain, target: self, action: #selector(leftBtnAction))
        buttonItem.imageInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = buttonItem
        
        let buttonItem2: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "mqz_nav_add"), style: .plain, target: self, action: #selector(rightBtnAction))
        buttonItem2.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6)
        self.navigationItem.rightBarButtonItem = buttonItem2
        
        
        self.view.addSubview(self.tableView)
        self.tableView.register(UINib(nibName: "RecentTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func leftBtnAction() {
        self.menuContainerViewController.toggleLeftSideMenu(completeBolck: nil)
    }
    
    @objc func rightBtnAction() {
        self.menuContainerViewController.toggleRightSideMenu(completeBolck: nil)
    }
    
    func obtainRandomTime(index: Int) -> String {
        return "\(arc4random()%2 == 0 ? "上午" : "下午")" + "\(arc4random()%12):\(arc4random()%5)\(arc4random()%9)"
    }
}

extension RecentViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! RecentTableViewCell
        cell.headerImgView.image = UIImage(named: self.imageArray[indexPath.row])
        cell.nameLabel.text = self.titleArray[indexPath.row]
        cell.decLabel.text = self.decArray[indexPath.row]
        cell.timeLabel.text = self.timeArray[indexPath.row]
        if cell.decLabel.text!.count > 15 {
            cell.tipLabel.isHidden = false
            cell.tipLabel.text = "\(cell.decLabel.text!.count % 10)"
        } else {
            cell.tipLabel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("您当前点击了第 \(indexPath.row + 1) 行")
        self.navigationController?.pushViewController(SubViewController(), animated: true)
    }
}
