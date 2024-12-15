//
//  UIApplication.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 9.12.24.
//

import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        windows.first(where: \.isKeyWindow)
    }

    var currentStatusBarFrame: CGRect? {
        currentKeyWindow?.windowScene?.statusBarManager?.statusBarFrame
    }

    var topViewController: UIViewController? {
        currentKeyWindow?.rootViewController?.topViewController()
    }
}
