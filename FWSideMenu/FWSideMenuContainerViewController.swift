//
//  FWSideMenuContainerViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/8.
//  Copyright © 2018年 xfg. All rights reserved.
//


/** ************************************************
 
 github地址：https://github.com/choiceyou/FWSideMenu
 bug反馈、交流群：670698309
 
 ***************************************************
 */


import Foundation
import UIKit
import QuartzCore

/// 拖动模式
///
/// - none: 不能拖动
/// - centerViewController: 能在centerViewController上拖动
/// - sideMenu: 能在sideMenu上拖动
/// - defaults: 能同时在centerViewController和sideMenu上拖动
@objc public enum FWSideMenuPanMode: Int {
    case none
    case centerViewController
    case sideMenu
    case defaults
}

/// 当前菜单状态
///
/// - closed: 关闭
/// - leftMenuOpen: 左边菜单打开
/// - rightMenuOpen: 右边菜单打开
@objc public enum FWSideMenuState: Int {
    case closed
    case leftMenuOpen
    case rightMenuOpen
}

/// 菜单操作事件
///
/// - willOpen: 将要打开
/// - didOpen: 打开动作刚结束
/// - willClose: 将要关闭
/// - didClose: 关闭动作刚结束
@objc public enum FWSideMenuStateEvent: Int {
    case willOpen
    case didOpen
    case willClose
    case didClose
}

/// 拖动位置
///
/// - none: 无拖动
/// - left: 左边
/// - right: 右边
private enum FWSideMenuPanDirection: Int {
    case none
    case left
    case right
}

public typealias FWSideMenuVoidBlock = () -> Void
fileprivate let FWSideMenuStateNotificationEvent = "FWSideMenuStateNotificationEvent"


open class FWSideMenuContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    /// 中间控制器
    @objc public var centerViewController: UIViewController? {
        willSet {
            // 如果有旧的centerVC，则移除
            self.removeCenterGestureRecognizers()
            self.removeChildViewControllerFromContainer(childViewController: centerViewController)
            
            if newValue != nil {
                self.addChild(newValue!)
                self.view.addSubview(newValue!.view)
                
                newValue?.didMove(toParent: self)
                
                if sideMenuShadowEnabled == true {
                    if self.sideMenuShadow != nil {
                        self.sideMenuShadow?.shadowedView = newValue?.view
                    } else {
                        self.sideMenuShadow = FWSideMenuShadow.shadow(sdView: newValue!.view)
                    }
                }
                
                self.addCenterGestureRecognizers()
            }
        }
    }
    
    /// 左侧侧滑控制器
    @objc public var leftMenuViewController: UIViewController? {
        willSet {
            self.removeChildViewControllerFromContainer(childViewController: leftMenuViewController)
            
            if newValue != nil {
                self.addChild(newValue!)
                newValue?.didMove(toParent: self)
                newValue?.view.isHidden = true
                
                if self.isViewHasLoad {
                    self.setLeftSideMenuFrameToClosedPosition()
                }
            }
        }
    }
    
    /// 右侧侧滑控制器
    @objc public var rightMenuViewController: UIViewController? {
        willSet {
            self.removeChildViewControllerFromContainer(childViewController: rightMenuViewController)
            
            if newValue != nil {
                self.addChild(newValue!)
                newValue?.didMove(toParent: self)
                newValue?.view.isHidden = true
                
                if self.isViewHasLoad {
                    self.setRightSideMenuFrameToClosedPosition()
                }
            }
        }
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.centerViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.centerViewController
    }
    
    /// 拖动状态
    @objc public var sideMenuPanMode: FWSideMenuPanMode = .defaults {
        willSet {
            if newValue == .none || newValue == .sideMenu {
                self.centerLeftPanView.isUserInteractionEnabled = false
                self.centerRightPanView.isUserInteractionEnabled = false
            } else {
                self.centerLeftPanView.isUserInteractionEnabled = true
                self.centerRightPanView.isUserInteractionEnabled = true
            }
        }
    }
    /// 设置当前菜单状态
    @objc public var sideMenuState: FWSideMenuState = .closed
    
    /// 左菜单宽度
    @objc public var leftMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    /// 右菜单宽度
    @objc public var rightMenuWidth: CGFloat = 270.0
    
    /// 左、右菜单是否跟随滑动
    @objc public var menuSlideAnimationEnabled: Bool = true
    /// 左（右）菜单滑动相对于本身的宽度值的 1/menuSlideAnimationFactor
    @objc public var menuSlideAnimationFactor: CGFloat = 3.0
    
    /// 打开左（右）菜单时中间视图是否需要遮罩层
    @objc public var centerMaskViewEnabled: Bool = true
    /// 打开左（右）菜单时中间视图边上是否需要阴影
    @objc public var sideMenuShadowEnabled: Bool = false
    
    /// 是否开启中间控制器点击事件
    @objc public var centerTapGestureEnabled: Bool = true
    
    /// 中间控制器的灰色遮罩层
    private var centerMaskView: UIView = {
        
        let centerMaskView = UIView(frame: UIScreen.main.bounds)
        return centerMaskView
    }()
    
    /// 中间控制器左边可拖动的视图
    private var centerLeftPanView: UIView = {
        
        let centerLeftPanView = UIView()
        centerLeftPanView.backgroundColor = UIColor.clear
        return centerLeftPanView
    }()
    
    /// 中间控制器右边可拖动的视图
    private var centerRightPanView: UIView = {
        
        let centerRightPanView = UIView()
        centerRightPanView.backgroundColor = UIColor.clear
        return centerRightPanView
    }()
    
    /// 中间控制器左边可拖动的视图宽度
    private var centerLeftPanViewWidth: CGFloat = 0.0
    /// 中间控制器右边可拖动的视图宽度
    private var centerRightPanViewWidth: CGFloat = 0.0
    
    /// 侧边菜单容器视图
    private var menuContainerView: UIView = {
       
        let menuContainerView = UIView()
        return menuContainerView
    }()
    
    /// 侧滑阴影
    private var sideMenuShadow: FWSideMenuShadow?
    
    /// 中间控制器单击手势
    private var centerTapGestureRecognizer: UITapGestureRecognizer?
    /// 中间控制器拖动手势手势（centerLeftPanViewWidth>0时有效）
    private var centerLeftPanGestureRecognizer: UIPanGestureRecognizer?
    /// 中间控制器拖动手势手势（centerRightPanViewWidth>0时有效）
    private var centerRightPanGestureRecognizer: UIPanGestureRecognizer?
    /// 中间控制器的灰色遮罩层拖动手势手势
    private var centerMaskPanGestureRecognizer: UIPanGestureRecognizer?
    /// 侧边菜单容器视图拖动手势
    private var sideMenuPanGestureRecognizer: UIPanGestureRecognizer?
    
    /// 视图是否被加载过了
    private var isViewHasLoad = false
    
    /// 开始拖动位置
    private var panGestureOrigin: CGPoint = CGPoint.zero
    private var panGestureVelocity: CGFloat = 0
    /// 拖动位置
    private var panGestureDirection: FWSideMenuPanDirection = .none
    
    private var menuAnimationDefaultDuration: CGFloat = 0.2
    private var menuAnimationMaxDuration: CGFloat = 0.4
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isViewHasLoad == false {
            
            self.setupMenuContainerView()
            self.setLeftSideMenuFrameToClosedPosition()
            self.setRightSideMenuFrameToClosedPosition()
            self.addGestureRecognizers()
            
            self.isViewHasLoad = true
        }
    }
}


// MARK: - 初始化方法
extension FWSideMenuContainerViewController {
    
    /// 类初始化方法1
    ///
    /// - Parameters:
    ///   - centerViewController: 中间控制器（即当前您的主控制器），此时该控制器视图全局可拖拽，因此可能会出现手势冲突，建议使用 类初始化方法2
    ///   - leftMenuViewController: 左侧菜单控制器，可为nil
    ///   - rightMenuViewController: 右侧菜单控制器，可为nil
    /// - Returns: self
    @objc open class func container(centerViewController: UIViewController?, leftMenuViewController: UIViewController?, rightMenuViewController: UIViewController?) -> FWSideMenuContainerViewController {
        
        return self.container(centerViewController: centerViewController, centerLeftPanViewWidth: UIScreen.main.bounds.width / 2, centerRightPanViewWidth: UIScreen.main.bounds.width / 2, leftMenuViewController: leftMenuViewController, rightMenuViewController: rightMenuViewController)
    }
    
    /// 类初始化方法2
    ///
    /// - Parameters:
    ///   - centerViewController: 中间控制器（即当前您的主控制器）
    ///   - centerLeftPanViewWidth: 中间控制器 左侧可拖动视图的宽度（注意：该视图是不可见的，传入0即表示不可拖动，建议尽量不要传入太大的值，以免页面上手势冲突的区域太大）
    ///   - centerRightPanViewWidth: 中间控制器 右侧可拖动视图的宽度（注意：该视图是不可见的，传入0即表示不可拖动，建议尽量不要传入太大的值，以免页面上手势冲突的区域太大）
    ///   - leftMenuViewController: 左侧菜单控制器，可为nil
    ///   - rightMenuViewController: 右侧菜单控制器，可为nil
    /// - Returns: self
    @objc open class func container(centerViewController: UIViewController?, centerLeftPanViewWidth: CGFloat, centerRightPanViewWidth: CGFloat, leftMenuViewController: UIViewController?, rightMenuViewController: UIViewController?) -> FWSideMenuContainerViewController {
        
        let menuContainerViewController = FWSideMenuContainerViewController()
        menuContainerViewController.centerViewController = centerViewController
        menuContainerViewController.centerLeftPanViewWidth = centerLeftPanViewWidth
        menuContainerViewController.centerRightPanViewWidth = centerRightPanViewWidth
        menuContainerViewController.leftMenuViewController = leftMenuViewController
        menuContainerViewController.rightMenuViewController = rightMenuViewController
        menuContainerViewController.setupCommponent()
        return menuContainerViewController
    }
    
    private func setupCommponent() {
        
        self.centerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(centerVCTapAction(tap:)))
        self.centerTapGestureRecognizer?.delegate = self
        
        self.centerLeftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        self.centerLeftPanGestureRecognizer?.delegate = self
        
        self.centerRightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        self.centerRightPanGestureRecognizer?.delegate = self
        
        self.centerMaskPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        self.centerMaskPanGestureRecognizer?.delegate = self
        
        self.sideMenuPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        self.sideMenuPanGestureRecognizer?.delegate = self
    }
    
    private func setupMenuContainerView() {
        
        if self.menuContainerView.superview != nil {
            return
        }
        
        self.menuContainerView.frame = self.view.bounds
        self.menuContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.insertSubview(self.menuContainerView, at: 0)
        
        if self.leftMenuViewController != nil && self.leftMenuViewController?.view.superview == nil {
            self.menuContainerView.addSubview(self.leftMenuViewController!.view)
        }
        if self.rightMenuViewController != nil && self.rightMenuViewController?.view.superview == nil {
            self.menuContainerView.addSubview(self.rightMenuViewController!.view)
        }
    }
}


// MARK: - 手势
extension FWSideMenuContainerViewController {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer.isMember(of: UITapGestureRecognizer.self) {
            if (touch.view == self.centerLeftPanView) || touch.view == self.centerRightPanView {
                return false
            } else {
                if self.centerTapGestureEnabled == true {
                    return true
                } else {
                    return false
                }
            }
        } else {
            if self.sideMenuPanMode == .defaults {
                return true
            } else if self.sideMenuPanMode == .none {
                return false
            } else if self.sideMenuPanMode == .centerViewController {
                if (gestureRecognizer == self.centerLeftPanGestureRecognizer) || (gestureRecognizer == self.centerRightPanGestureRecognizer) || (gestureRecognizer == self.centerMaskPanGestureRecognizer) {
                    return true
                } else {
                    return false
                }
            } else if self.sideMenuPanMode == .sideMenu {
                if gestureRecognizer == self.sideMenuPanGestureRecognizer {
                    return true
                } else {
                    return false
                }
            }
            return true
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func addGestureRecognizers() {
        
        self.addCenterGestureRecognizers()
        self.menuContainerView.addGestureRecognizer(self.sideMenuPanGestureRecognizer!)
    }
    
    private func addCenterGestureRecognizers() {
        
        if self.centerViewController != nil {
            if self.centerLeftPanViewWidth > 0 {
                self.centerLeftPanView.frame = CGRect(x: 0, y: 0, width: self.centerLeftPanViewWidth, height: UIScreen.main.bounds.height)
                self.centerViewController?.view.addSubview(self.centerLeftPanView)
                self.centerLeftPanView.addGestureRecognizer(self.centerLeftPanGestureRecognizer!)
            }
            if self.centerRightPanViewWidth > 0 {
                self.centerRightPanView.frame = CGRect(x: UIScreen.main.bounds.width - self.centerRightPanViewWidth, y: 0, width: self.centerRightPanViewWidth, height: UIScreen.main.bounds.height)
                self.centerViewController?.view.addSubview(self.centerRightPanView)
                self.centerRightPanView.addGestureRecognizer(self.centerRightPanGestureRecognizer!)
            }
            
            self.centerMaskView.addGestureRecognizer(self.centerTapGestureRecognizer!)
            self.centerMaskView.addGestureRecognizer(self.centerMaskPanGestureRecognizer!)
        }
    }
    
    private func removeCenterGestureRecognizers() {
        
        if self.centerViewController != nil {
            self.centerMaskView.removeGestureRecognizer(self.centerTapGestureRecognizer!)
            self.centerMaskView.removeGestureRecognizer(self.centerMaskPanGestureRecognizer!)
            
            if self.centerLeftPanViewWidth > 0 {
                self.centerLeftPanView.removeGestureRecognizer(self.centerLeftPanGestureRecognizer!)
            }
            if self.centerRightPanViewWidth > 0 {
                self.centerRightPanView.removeGestureRecognizer(self.centerRightPanGestureRecognizer!)
            }
        }
    }
    
    private func removeChildViewControllerFromContainer(childViewController: UIViewController?) {
        
        if childViewController == nil {
            return
        }
        childViewController?.willMove(toParent: nil)
        childViewController?.removeFromParent()
        childViewController?.view.removeFromSuperview()
    }
    
    private func sideMenuPanEnabled() {
        
        
    }
    
    @objc private func centerVCTapAction(tap: UITapGestureRecognizer) {
        
        if self.sideMenuState != .closed {
            self.setSideMenuState(state: .closed, completeBlock: nil)
        }
    }
    
    @objc private func panAction(pan: UIPanGestureRecognizer) {
        
        let view = self.centerViewController!.view
        
        if pan.state == .began {
            self.panGestureOrigin = view!.frame.origin
            self.panGestureDirection = .none
        }
        
        if self.panGestureDirection == .none {
            let translatedPoint = pan.translation(in: view)
            if translatedPoint.x > 0 {
                self.panGestureDirection = .right
                if self.leftMenuViewController != nil && self.sideMenuState == .closed {
                    self.leftMenuWillShow()
                }
            } else if translatedPoint.x < 0 {
                self.panGestureDirection = .left
                if self.rightMenuViewController != nil && self.sideMenuState == .closed {
                    self.rightMenuWillShow()
                }
            }
        }
        
        if (self.sideMenuState == .leftMenuOpen && self.panGestureDirection == .right) || (self.sideMenuState == .rightMenuOpen && self.panGestureDirection == .left) {
            self.panGestureDirection = .none
            return
        }
        
        if self.panGestureDirection == .left {
            self.handleLeftPan(pan: pan)
        } else if self.panGestureDirection == .right {
            self.handleRightPan(pan: pan)
        }
    }
    
    private func handleLeftPan(pan: UIPanGestureRecognizer) {
        
        if self.rightMenuViewController == nil && self.sideMenuState == .closed {
            return
        }
        
        let view = self.centerViewController!.view
        var translatedPoint = pan.translation(in: view)
        let adjustedOrigin = self.panGestureOrigin
        translatedPoint = CGPoint(x: adjustedOrigin.x + translatedPoint.x, y: adjustedOrigin.y + translatedPoint.y)
        
        translatedPoint.x = max(translatedPoint.x, -self.rightMenuWidth)
        translatedPoint.x = min(translatedPoint.x, self.leftMenuWidth)
        if self.sideMenuState == .leftMenuOpen {
            translatedPoint.x = max(translatedPoint.x, 0)
        } else {
            translatedPoint.x = min(translatedPoint.x, 0)
        }
        
        if translatedPoint.x == 0.0 {
            self.setSideMenuState(state: .closed, completeBlock: nil)
        }
        
        if pan.state == .ended {
            let velocity = pan.velocity(in: view)
            let finalX = translatedPoint.x + (0.35 * velocity.x)
            let viewWidth = view!.frame.width
            
            if self.sideMenuState == .closed {
                let showMenu = (finalX < -viewWidth/2) || (finalX < -self.rightMenuWidth/2)
                if showMenu {
                    self.panGestureVelocity = velocity.x
                    self.setSideMenuState(state: .rightMenuOpen, completeBlock: nil)
                } else {
                    self.panGestureVelocity = 0
                    self.setCenterViewControllerOffset(offset: 0, animated: true, completeBlock: nil)
                }
            } else {
                let hideMenu = (finalX < adjustedOrigin.x)
                if hideMenu {
                    self.panGestureVelocity = velocity.x
                    self.setSideMenuState(state: .closed, completeBlock: nil)
                } else {
                    self.panGestureVelocity = 0
                    self.setCenterViewControllerOffset(offset: adjustedOrigin.x, animated: true, completeBlock: nil)
                }
            }
        } else {
            self.setCenterViewControllerOffset(offset: translatedPoint.x, time: 0)
        }
    }
    
    private func handleRightPan(pan: UIPanGestureRecognizer) {
        
        if self.leftMenuViewController == nil && self.sideMenuState == .closed {
            return
        }
        
        let view = self.centerViewController!.view
        var translatedPoint = pan.translation(in: view)
        let adjustedOrigin = self.panGestureOrigin
        translatedPoint = CGPoint(x: adjustedOrigin.x + translatedPoint.x, y: adjustedOrigin.y + translatedPoint.y)
        
        translatedPoint.x = max(translatedPoint.x, -self.rightMenuWidth)
        translatedPoint.x = min(translatedPoint.x, self.leftMenuWidth)
        if self.sideMenuState == .rightMenuOpen {
            translatedPoint.x = min(translatedPoint.x, 0)
        } else {
            translatedPoint.x = max(translatedPoint.x, 0)
        }
        
        if translatedPoint.x == 0.0 {
            self.setSideMenuState(state: .closed, completeBlock: nil)
        }
        
        if pan.state == .ended {
            let velocity = pan.velocity(in: view)
            let finalX = translatedPoint.x + (0.35 * velocity.x)
            let viewWidth = view!.frame.width
            
            if self.sideMenuState == .closed {
                let showMenu = (finalX > viewWidth/2) || (finalX > self.leftMenuWidth/2)
                if showMenu {
                    self.panGestureVelocity = velocity.x
                    self.setSideMenuState(state: .leftMenuOpen, completeBlock: nil)
                } else {
                    self.panGestureVelocity = 0
                    self.setCenterViewControllerOffset(offset: 0, animated: true, completeBlock: nil)
                }
            } else {
                let hideMenu = (finalX > adjustedOrigin.x)
                if hideMenu {
                    self.panGestureVelocity = velocity.x
                    self.setSideMenuState(state: .closed, completeBlock: nil)
                } else {
                    self.panGestureVelocity = 0
                    self.setCenterViewControllerOffset(offset: adjustedOrigin.x, animated: true, completeBlock: nil)
                }
            }
            self.panGestureDirection = .none
        } else {
            self.setCenterViewControllerOffset(offset: translatedPoint.x, time: 0)
        }
    }
}

// MARK: - sideMenu 位置
extension FWSideMenuContainerViewController {
    
    private func setLeftSideMenuFrameToClosedPosition() {
        
        if self.leftMenuViewController == nil {
            return
        }
        
        var leftFrame = self.leftMenuViewController!.view.frame
        leftFrame.size.width = self.leftMenuWidth
        leftFrame.origin.x = self.menuSlideAnimationEnabled ? -leftFrame.width / self.menuSlideAnimationFactor : 0
        leftFrame.origin.y = 0
        self.leftMenuViewController!.view.frame = leftFrame
        self.leftMenuViewController!.view.autoresizingMask = [.flexibleRightMargin, .flexibleHeight]
    }
    
    private func setRightSideMenuFrameToClosedPosition() {
        
        if self.rightMenuViewController == nil {
            return
        }
        
        var rightFrame = self.rightMenuViewController!.view.frame
        rightFrame.size.width = self.rightMenuWidth
        rightFrame.origin.y = 0
        rightFrame.origin.x = self.menuContainerView.frame.width - self.rightMenuWidth
        if self.menuSlideAnimationEnabled {
            rightFrame.origin.x += self.rightMenuWidth / self.menuSlideAnimationFactor
        }
        self.rightMenuViewController!.view.frame = rightFrame
        self.rightMenuViewController!.view.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
    }
    
    private func alignLeftMenuControllerWithCenterViewController() {
        
        var leftMenuFrame = self.leftMenuViewController!.view.frame
        leftMenuFrame.size.width = self.leftMenuWidth
        
        let xOffset = self.centerViewController!.view.frame.origin.x
        let xPositionDivider = self.menuSlideAnimationEnabled ? self.menuSlideAnimationFactor : 1.0
        leftMenuFrame.origin.x = xOffset / xPositionDivider - self.leftMenuWidth / xPositionDivider
        
        self.leftMenuViewController?.view.frame = leftMenuFrame
    }
    
    private func alignRightMenuControllerWithCenterViewController() {
        
        var rightMenuFrame = self.rightMenuViewController!.view.frame
        rightMenuFrame.size.width = self.rightMenuWidth
        
        let xOffset = self.centerViewController!.view.frame.origin.x
        let xPositionDivider = self.menuSlideAnimationEnabled ? self.menuSlideAnimationFactor : 1.0
        rightMenuFrame.origin.x = self.menuContainerView.frame.width - self.rightMenuWidth + xOffset / xPositionDivider + self.rightMenuWidth / xPositionDivider
        
        self.rightMenuViewController?.view.frame = rightMenuFrame
    }
}

// MARK: - sideMenu 状态
extension FWSideMenuContainerViewController {
    
    private func leftMenuWillShow() {
        self.menuContainerView.bringSubviewToFront(self.leftMenuViewController!.view)
    }
    
    private func rightMenuWillShow() {
        self.menuContainerView.bringSubviewToFront(self.rightMenuViewController!.view)
    }
    
    /// 设置侧滑菜单状态
    ///
    /// - Parameters:
    ///   - state: 状态
    ///   - completeBlock: 回调
    @objc public func setSideMenuState(state: FWSideMenuState, completeBlock: (FWSideMenuVoidBlock?) = nil) {
        
        let innerCompleteBlock = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.sideMenuState = state
            
            strongSelf.setUserInteractionStateForCenterViewController()
            let eventType: FWSideMenuStateEvent = (strongSelf.sideMenuState == .closed) ? .didClose : .didOpen
            strongSelf.sendStateEventNotification(event: eventType)
            
            if completeBlock != nil {
                completeBlock!()
            }
        }
        
        switch state {
        case .closed:
            self.sendStateEventNotification(event: .willClose)
            self.closeSideMenu(completeBolck: {
                self.leftMenuViewController?.view.isHidden = true
                self.rightMenuViewController?.view.isHidden = true
                innerCompleteBlock()
            })
            break
        case .leftMenuOpen:
            if self.leftMenuViewController == nil {
                return
            }
            
            self.leftMenuViewController?.view.isHidden = false
            self.sendStateEventNotification(event: .willOpen)
            self.leftMenuWillShow()
            self.openLeftSideMenu(completeBolck: innerCompleteBlock)
            break
        case .rightMenuOpen:
            if self.rightMenuViewController == nil {
                return
            }
            
            self.rightMenuViewController?.view.isHidden = false
            self.sendStateEventNotification(event: .willOpen)
            self.rightMenuWillShow()
            self.openRightSideMenu(completeBolck: innerCompleteBlock)
            break
        }
    }
    
    private func closeSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        self.setCenterViewControllerOffset(offset: 0, animated: true, completeBlock: completeBolck)
    }
    
    private func setUserInteractionStateForCenterViewController() {
        
        if self.centerViewController!.responds(to: #selector(getter: children)) {
            
            let childVCs = self.centerViewController?.children
            for vc in childVCs! {
                vc.view.isUserInteractionEnabled = (self.sideMenuState == .closed)
            }
        }
    }
    
    private func openLeftSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        
        if self.leftMenuViewController == nil {
            return
        }
        
        self.menuContainerView.bringSubviewToFront(self.leftMenuViewController!.view)
        self.setCenterViewControllerOffset(offset: self.leftMenuWidth, animated: true, completeBlock: completeBolck)
    }
    
    private func openRightSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        
        if self.rightMenuViewController == nil {
            return
        }
        
        self.menuContainerView.bringSubviewToFront(self.rightMenuViewController!.view)
        self.setCenterViewControllerOffset(offset: -self.rightMenuWidth, animated: true, completeBlock: completeBolck)
    }
    
    /// 点击切换左菜单
    ///
    /// - Parameter completeBolck: 完成回调
    @objc public func toggleLeftSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        
        if self.sideMenuState == .leftMenuOpen {
            self.setSideMenuState(state: .closed, completeBlock: completeBolck)
        } else {
            self.setSideMenuState(state: .leftMenuOpen, completeBlock: completeBolck)
        }
    }
    
    /// 点击切换右菜单
    ///
    /// - Parameter completeBolck: 完成回调
    @objc public func toggleRightSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        
        if self.sideMenuState == .rightMenuOpen {
            self.setSideMenuState(state: .closed, completeBlock: completeBolck)
        } else {
            self.setSideMenuState(state: .rightMenuOpen, completeBlock: completeBolck)
        }
    }
}

// MARK: - 移动centerViewController
extension FWSideMenuContainerViewController {
    
    private func setCenterViewControllerOffset(offset: CGFloat, time: TimeInterval) {
        
        self.leftMenuViewController?.view.isHidden = false
        self.rightMenuViewController?.view.isHidden = false
        self.centerViewController?.view.frame.origin.x = offset
        
        let foffset = fabsf(Float(offset))
        var percent = 0.0
        if offset > 0 {
            percent = Double(foffset / Float(leftMenuWidth))
        } else {
            percent = Double(foffset / Float(rightMenuWidth))
        }
        percent = percent * 0.4
        
        if foffset > 0 && self.centerMaskView.superview == nil {
            self.centerViewController?.view.addSubview(self.centerMaskView)
            self.centerViewController?.view.bringSubviewToFront(self.centerMaskView)
        } else if foffset <= 0 && self.centerMaskView.superview != nil {
            DispatchQueue.main.asyncAfter(deadline: .now()+time) {
                self.centerMaskView.removeFromSuperview()
            }
        }
        if centerMaskViewEnabled == true && foffset > 0 {
            self.centerMaskView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(percent))
        }
        
        if !self.menuSlideAnimationEnabled {
            return
        }
        
        if offset > 0 {
            self.alignLeftMenuControllerWithCenterViewController()
            self.setRightSideMenuFrameToClosedPosition()
        } else if offset < 0 {
            self.alignRightMenuControllerWithCenterViewController()
            self.setLeftSideMenuFrameToClosedPosition()
        } else {
            self.setLeftSideMenuFrameToClosedPosition()
            self.setRightSideMenuFrameToClosedPosition()
        }
    }
    
    private func setCenterViewControllerOffset(offset: CGFloat, animated: Bool, completeBlock: (FWSideMenuVoidBlock?) = nil) {
        self.setCenterViewControllerOffset(offset: offset, additionalAnimationsBlock: nil, animated: animated, completeBlock: completeBlock)
    }
    
    private func setCenterViewControllerOffset(offset: CGFloat, additionalAnimationsBlock: (FWSideMenuVoidBlock?) = nil, animated: Bool, completeBlock: (FWSideMenuVoidBlock?) = nil) {
        
        if animated {
            let centerViewControllerXPosition = abs(self.centerViewController!.view.frame.origin.x)
            let duration = self.animationDurationFromStartPosition(startPosition: centerViewControllerXPosition, endPosition: offset)
            
            UIView.animate(withDuration: TimeInterval(duration), animations: {
                self.setCenterViewControllerOffset(offset: offset, time: TimeInterval(duration))
                if additionalAnimationsBlock != nil {
                    additionalAnimationsBlock!()
                }
                
                let foffset = fabsf(Float(offset))
                var percent = 0.0
                if offset > 0 {
                    percent = Double(foffset / Float(self.leftMenuWidth))
                } else {
                    percent = Double(foffset / Float(self.rightMenuWidth))
                }
                percent = percent * 0.4
                self.centerMaskView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(percent))
            }, completion: { (finished) in
                self.panGestureVelocity = 0.0
                if completeBlock != nil {
                    completeBlock!()
                }
                if self.centerViewController?.view.frame.minX == 0 {
                    self.leftMenuViewController?.view.isHidden = true
                    self.rightMenuViewController?.view.isHidden = true
                } else {
                    self.leftMenuViewController?.view.isHidden = false
                    self.rightMenuViewController?.view.isHidden = false
                }
            })
        } else {
            self.setCenterViewControllerOffset(offset: offset, time: 0)
            if additionalAnimationsBlock != nil {
                additionalAnimationsBlock!()
            }
            self.panGestureVelocity = 0.0
            if completeBlock != nil {
                completeBlock!()
            }
            
            if self.centerViewController?.view.frame.minX == 0 {
                self.leftMenuViewController?.view.isHidden = true
                self.rightMenuViewController?.view.isHidden = true
            } else {
                self.leftMenuViewController?.view.isHidden = false
                self.rightMenuViewController?.view.isHidden = false
            }
        }
    }
    
    private func animationDurationFromStartPosition(startPosition: CGFloat, endPosition: CGFloat) -> CGFloat {
        
        let animationPositionDelta = abs(endPosition - startPosition)
        
        var duration: CGFloat = 0
        if abs(self.panGestureVelocity) > 1.0 {
            duration = animationPositionDelta / abs(self.panGestureVelocity)
        } else {
            let menuWidth = max(self.leftMenuWidth, self.rightMenuWidth)
            let animationPerecent = (animationPositionDelta == 0) ? 0 : (menuWidth / animationPositionDelta)
            duration = self.menuAnimationDefaultDuration * animationPerecent
        }
        return min(duration, self.menuAnimationMaxDuration)
    }
    
    private func sendStateEventNotification(event: FWSideMenuStateEvent) {
        
        if self.centerTapGestureEnabled == true {
            if event == .didClose {
                self.centerTapGestureRecognizer?.isEnabled = false
            } else {
                self.centerTapGestureRecognizer?.isEnabled = true
            }
        }
        
        let userInfo = ["eventType": NSNumber(value: Int8(event.rawValue))]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FWSideMenuStateNotificationEvent), object: self, userInfo: userInfo)
        
    }
}
