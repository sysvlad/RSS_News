//
//  ViewController.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 9.12.24.
//

import UIKit

extension UIViewController {
    
    // MARK: - Properties
    
    static var visibleViewController: UIViewController? {
        var rootViewController = UIApplication.shared.currentKeyWindow?.rootViewController
        
        if let presentedVc = rootViewController?.presentedViewController {
            rootViewController = getTopController(presentedVc)
        } else {
            rootViewController = getTopController(rootViewController)
        }
        
        return rootViewController
    }
    
    private static func getTopController(_ root: UIViewController?) -> UIViewController? {
        var rootViewController = root

        if let nc = root as? UINavigationController, let topController = nc.topViewController {
            rootViewController = getTopController(topController)
        } else if let tabVc = root as? UITabBarController, let topController = tabVc.selectedViewController {
            rootViewController = getTopController(topController)
        }

        return rootViewController
    }
}

extension UIViewController {
    func topViewController() -> UIViewController? {
        if let tabBarViewController = self as? UITabBarController {
            if let selectedTab = tabBarViewController.selectedViewController {
                return selectedTab.topViewController()
            } else {
                return tabBarViewController.topViewController()
            }
        } else if let navigationViewController = self as? UINavigationController {
            return navigationViewController.visibleViewController?.topViewController()
        } else if presentedViewController == nil {
            return self
        } else {
            return presentedViewController?.topViewController()
        }
    }

    func presentedViewController() -> UIViewController? {
        if let presentedViewController = presentedViewController?.topViewController() {
            return presentedViewController
        } else if let tabBarViewController = self as? UITabBarController {
            if let selectedTab = tabBarViewController.selectedViewController {
                return selectedTab.topViewController()
            } else {
                return tabBarViewController.topViewController()
            }
        } else if let navigationViewController = self as? UINavigationController {
            return navigationViewController.visibleViewController?.topViewController()
        } else {
            return self
        }
    }
}
