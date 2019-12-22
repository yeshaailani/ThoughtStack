//
//  AppDelegate.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseService.shared.configure()
//        window = UIWindow(frame:UIScreen.main.bounds)
//        window?.rootViewController = UINavigationController(rootViewController: TabBar())
//        window?.makeKeyAndVisible()
        
        return true
    }

    var orientationLock = UIInterfaceOrientationMask.portrait // forbid rotation

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }

}

