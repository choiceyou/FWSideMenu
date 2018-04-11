# IOS之侧滑控件 -- OC/Swift4.0  

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](http://cocoapods.org/?q=FWSideMenu)&nbsp;
![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)&nbsp;
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/choiceyou/FWSideMenu/blob/master/FWSideMenu/LICENSE)



## 支持pod导入：

```cocoaPods
pod 'FWSideMenu'
注意：如出现 Unable to find a specification for 'FWSideMenu' 错误，可执行 pod repo update 命令。
```



## 可设置参数：
```参数
/// 中间控制器
@objc public var centerViewController: UIViewController?
/// 左侧侧滑控制器
@objc public var leftMenuViewController: UIViewController?
/// 右侧侧滑控制器
@objc public var rightMenuViewController: UIViewController?

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
```


## 简单使用：（注：可下载demo具体查看，分别有OC、Swift的demo）

```swift
/// 类初始化方法
///
/// - Parameters:
///   - centerViewController: 中间控制器（即当前您的主控制器）
///   - leftMenuViewController: 左侧菜单控制器，可为nil
///   - rightMenuViewController: 右侧菜单控制器，可为nil
/// - Returns: self
@objc open class func container(centerViewController: UIViewController?, 
                              leftMenuViewController: UIViewController?, 
                             rightMenuViewController: UIViewController?) -> FWSideMenuContainerViewController
```

### OC：
```oc
ViewController *vc = [[ViewController alloc] init];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
[FWSideMenuContainerViewController containerWithCenterViewController: nav 
                                              leftMenuViewController:[[MenuViewController alloc] init] 
                                             rightMenuViewController:nil];
```


## Swift: <br>
```swift
FWSideMenuContainerViewController.container(centerViewController: FWTabBarController(),
                                          leftMenuViewController: SideMenuViewController(), 
                                         rightMenuViewController: SideMenuViewController())
```



## 效果：

![](https://github.com/choiceyou/FWSideMenu/blob/master/%E6%95%88%E6%9E%9C/%E6%95%88%E6%9E%9C.gif)



## 结尾语：

> * 使用过程中有任何问题或者新的需求都可以issues我哦；
> * 欢迎关注本人更多的UI库，谢谢；
