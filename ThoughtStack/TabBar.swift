//
//  TabBar.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import Foundation
import UIKit

class TabBar: UITabBarController {

    
    let firebase = FirebaseService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.barStyle = .black
        
        Utilities.singleton.testFIR()
        
        let firstVC = Dashboard()
        firstVC.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "grid-outline")!, selectedImage: UIImage(named: "grid-filled")!)
        
        let secondVC = CreatePost()
        secondVC.tabBarItem = UITabBarItem(title: "Create Post", image: UIImage(named: "plus-outline"), selectedImage: UIImage(named: "plus-filled"))
        
        let thirdVC = ThoughtWallet()
        thirdVC.tabBarItem = UITabBarItem(title: "ThoughtWallet", image:UIImage(named: "wallet-outline")!, selectedImage: UIImage(named: "wallet-filled")!)
        
        viewControllers = [firstVC,secondVC,thirdVC]
    }
    
    
    
    
    
}
