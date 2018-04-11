//
//  FWSideMenuContainerViewController.swift
//  FWSideMenu
//
//  Created by xfg on 2018/4/8.
//  Copyright © 2018年 xfg. All rights reserved.
//

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
            // 如果有就的centerVC，则移除
            self.removeCenterGestureRecognizers()
            self.removeChildViewControllerFromContainer(childViewController: centerViewController)
            
            if newValue != nil {
                self.addChildViewController(newValue!)
                self.view.addSubview(newValue!.view)
                
                newValue?.didMove(toParentViewController: self)
                
                if self.sideMenuShadow != nil {
                    self.sideMenuShadow?.shadowedView = newValue?.view
                } else {
                    self.sideMenuShadow = FWSideMenuShadow.shadow(sdView: newValue!.view)
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
                self.addChildViewController(newValue!)
                newValue?.didMove(toParentViewController: self)
                
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
                self.addChildViewController(newValue!)
                newValue?.didMove(toParentViewController: self)
                
                if self.isViewHasLoad {
                    self.setRightSideMenuFrameToClosedPosition()
                }
            }
        }
    }
    
    /// 拖动状态
    @objc public var sideMenuPanMode: FWSideMenuPanMode = .defaults
    /// 当前菜单状态
    @objc public var sideMenuState: FWSideMenuState = .closed
    
    /// 左菜单宽度
    @objc public var leftMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    /// 右菜单宽度
    @objc public var rightMenuWidth: CGFloat = 270.0
    
    /// 左、右菜单是否跟随滑动
    @objc public var menuSlideAnimationEnabled: Bool = true
    /// 左（右）菜单滑动相对于本身的宽度值的 1/menuSlideAnimationFactor
    @objc public var menuSlideAnimationFactor: CGFloat = 3.0
    
    
    /// 侧边菜单容器视图
    private var menuContainerView: UIView = {
       
        let menuContainerView = UIView()
        return menuContainerView
    }()
    
    /// 侧滑阴影
    private var sideMenuShadow: FWSideMenuShadow?
    
    private var centerTapGestureRecognizer: UITapGestureRecognizer?
    private var centerPanGestureRecognizer: UIPanGestureRecognizer?
    private var sideMenuPanGestureRecognizer: UIPanGestureRecognizer?
    
    /// 视图是否被加载过了
    private var isViewHasLoad = false
    
    /// 开始拖动位置
    private var panGestureOrigin: CGPoint = CGPoint(x: 0, y: 0)
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
    
    /// 类初始化方法
    ///
    /// - Parameters:
    ///   - centerViewController: 中间控制器（即当前您的主控制器）
    ///   - leftMenuViewController: 左侧菜单控制器，可为nil
    ///   - rightMenuViewController: 右侧菜单控制器，可为nil
    /// - Returns: self
    @objc open class func container(centerViewController: UIViewController?, leftMenuViewController: UIViewController?, rightMenuViewController: UIViewController?) -> FWSideMenuContainerViewController {
        
        let menuContainerViewController = FWSideMenuContainerViewController()
        menuContainerViewController.centerViewController = centerViewController
        menuContainerViewController.leftMenuViewController = leftMenuViewController
        menuContainerViewController.rightMenuViewController = rightMenuViewController
        menuContainerViewController.setupCommponent()
        return menuContainerViewController
    }
    
    private func setupCommponent() {
        
        self.centerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(centerVCTapAction(tap:)))
        self.centerTapGestureRecognizer?.delegate = self
        
        self.centerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        self.centerPanGestureRecognizer?.delegate = self
        
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
        if self.sideMenuPanMode == .defaults {
            return true
        } else if self.sideMenuPanMode == .none {
            return false
        } else if self.sideMenuPanMode == .centerViewController {
            if gestureRecognizer == self.centerPanGestureRecognizer {
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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func addGestureRecognizers() {
        
        self.addCenterGestureRecognizers()
        self.menuContainerView.addGestureRecognizer(self.sideMenuPanGestureRecognizer!)
    }
    
    private func addCenterGestureRecognizers() {
        if self.centerViewController != nil {
            self.centerViewController?.view.addGestureRecognizer(self.centerTapGestureRecognizer!)
            self.centerTapGestureRecognizer?.isEnabled = false
            self.centerViewController?.view.addGestureRecognizer(self.centerPanGestureRecognizer!)
        }
    }
    
    private func removeCenterGestureRecognizers() {
        if self.centerViewController != nil {
            self.centerViewController?.view.removeGestureRecognizer(self.centerTapGestureRecognizer!)
            self.centerViewController?.view.removeGestureRecognizer(self.centerPanGestureRecognizer!)
        }
    }
    
    private func removeChildViewControllerFromContainer(childViewController: UIViewController?) {
        
        if childViewController == nil {
            return
        }
        childViewController?.willMove(toParentViewController: nil)
        childViewController?.removeFromParentViewController()
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
        self.setCenterViewControllerOffset(offset: translatedPoint.x)
        
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
            self.setCenterViewControllerOffset(offset: translatedPoint.x)
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
            self.setCenterViewControllerOffset(offset: translatedPoint.x)
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
        self.leftMenuViewController?.view.isHidden = false
        self.menuContainerView.bringSubview(toFront: self.leftMenuViewController!.view)
    }
    
    private func rightMenuWillShow() {
        self.rightMenuViewController?.view.isHidden = false
        self.menuContainerView.bringSubview(toFront: self.rightMenuViewController!.view)
    }
    
    /// 设置侧滑菜单状态
    ///
    /// - Parameters:
    ///   - state: 状态
    ///   - completeBlock: 回调
    @objc public func setSideMenuState(state: FWSideMenuState, completeBlock: (FWSideMenuVoidBlock?) = nil) {
        
        let innerCompleteBlock = { [weak self] in
            
            self?.sideMenuState = state
            
            self?.setUserInteractionStateForCenterViewController()
            let eventType: FWSideMenuStateEvent = (self?.sideMenuState == .closed) ? .didClose : .didOpen
            self?.sendStateEventNotification(event: eventType)
            
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
            
            self.sendStateEventNotification(event: .willOpen)
            self.leftMenuWillShow()
            self.openLeftSideMenu(completeBolck: innerCompleteBlock)
            break
        case .rightMenuOpen:
            if self.rightMenuViewController == nil {
                return
            }
            
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
        
        if self.centerViewController!.responds(to: #selector(getter: childViewControllers)) {
            
            let childVCs = self.centerViewController?.childViewControllers
            for vc in childVCs! {
                vc.view.isUserInteractionEnabled = (self.sideMenuState == .closed)
            }
        }
    }
    
    private func openLeftSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        
        if self.leftMenuViewController == nil {
            return
        }
        
        self.menuContainerView.bringSubview(toFront: self.leftMenuViewController!.view)
        self.setCenterViewControllerOffset(offset: self.leftMenuWidth, animated: true, completeBlock: completeBolck)
    }
    
    private func openRightSideMenu(completeBolck: (FWSideMenuVoidBlock?) = nil) {
        
        if self.rightMenuViewController == nil {
            return
        }
        
        self.menuContainerView.bringSubview(toFront: self.rightMenuViewController!.view)
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
    
    private func setCenterViewControllerOffset(offset: CGFloat) {
        
        self.centerViewController?.view.frame.origin.x = offset
        
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
                self.setCenterViewControllerOffset(offset: offset)
                if additionalAnimationsBlock != nil {
                    additionalAnimationsBlock!()
                }
            }, completion: { (finished) in
                self.panGestureVelocity = 0.0
                if completeBlock != nil {
                    completeBlock!()
                }
            })
        } else {
            self.setCenterViewControllerOffset(offset: offset)
            if additionalAnimationsBlock != nil {
                additionalAnimationsBlock!()
            }
            self.panGestureVelocity = 0.0
            if completeBlock != nil {
                completeBlock!()
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
        
        if event == .didClose {
            self.centerTapGestureRecognizer?.isEnabled = false
        } else {
            self.centerTapGestureRecognizer?.isEnabled = true
        }
        
        let userInfo = ["eventType": NSNumber(value: Int8(event.rawValue))]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FWSideMenuStateNotificationEvent), object: self, userInfo: userInfo)
        
    }
}
