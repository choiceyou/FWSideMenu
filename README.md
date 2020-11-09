# IOS之侧滑控件 -- OC/Swift4.0  

[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](http://cocoapods.org/?q=FWSideMenu)&nbsp;
![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)&nbsp;
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/choiceyou/FWSideMenu/blob/master/FWSideMenu/LICENSE)



## 支持pod导入：

```cocoaPods
use_frameworks!
pod 'FWSideMenu'
注意：
1、如出现 [!] Unable to find a specification for 'FWSideMenu' 错误 或 看不到最新的版本，
  可执行 pod repo update 命令更新一下本地pod仓库。
2、use_frameworks! 的使用：
（1）纯OC项目中，通过cocoapods导入OC库时，一般都不使用use_frameworks!
（2）纯swift项目中，通过cocoapods导入swift库时，必须使用use_frameworks!
（3）只要是通过cocoapods导入swift库时，都必须使用use_frameworks!
（4）使用动态链接库dynamic frameworks时，必须使用use_frameworks!
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



## 更新记录：

• v2.0.5：
- [x] 修复侧滑关闭过程中，在距离屏幕边缘小于等于5pt的位置松手时发生死屏现象；
- [x] 修复侧滑打开的状态下，拖动侧滑至关闭的的状态，发生死屏现象；
- [x] 优化点击关闭侧滑菜单过程中灰色层动画变化过程（动画更加自然，不会出现一闪的现象）；

• v2.0.6：
- [x] 修复左右拖动菜单栏时可能会出现隐藏菜单的问题；

• v2.1.0：
- [x] 升级到Swift5；
- [x] 解决子控制器状态栏设置无效问题；



## 结尾语：

- 使用过程中发现bug请issues或加入FW问题反馈群：670698309（此群只接受FW相关组件问题）；
- 有新的需求欢迎提出；
