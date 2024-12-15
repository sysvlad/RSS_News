//
//  AppDelegate.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 9.12.24.
//

import UIKit
import SDWebImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let sharedInstance = UIApplication.shared.delegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow()
        let viewController = NewsListWireframe().initNewsListViewController(dataStorage: NewsListDataStorage())
        let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        configureApp()
        
        return true
    }
}

fileprivate extension AppDelegate {
    
    func configureApp() {
        SDImageCache.shared.config.maxDiskAge = 3600 * 24 * 7 // 1 Week
        SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 4 * 20 // 20 images (1024 * 1024 pixels)
        SDImageCache.shared.config.shouldCacheImagesInMemory = false // Disable memory cache, may cause cell-reusing flash because disk query is async
        SDImageCache.shared.config.shouldUseWeakMemoryCache = false // Disable weak cache, may see blank when return from background because memory cache is purged under pressure
        SDImageCache.shared.config.diskCacheReadingOptions = .mappedIfSafe // Use mmap for disk cache query
        SDWebImageManager.shared.optionsProcessor = SDWebImageOptionsProcessor() { url, options, context in
            var mutableOptions = options
            mutableOptions.insert(.continueInBackground)
            return SDWebImageOptionsResult(options: mutableOptions, context: context)
        }
    }
}
