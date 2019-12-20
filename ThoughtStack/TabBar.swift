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
        
        let feed = Feed(userId: "oG7weadM3FHXhb9XyJBC")
        feed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "grid-outline")!, selectedImage: UIImage(named: "grid-filled")!)
        
        let dashboard = Dashboard(userId: "oG7weadM3FHXhb9XyJBC") // TODO: take from persistent data later
        dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "user-outline")!, selectedImage: UIImage(named: "user-filled")!)
        
        let createPost = CreatePost()
        createPost.tabBarItem = UITabBarItem(title: "Create Post", image: UIImage(named: "plus-outline"), selectedImage: UIImage(named: "plus-filled"))
        
        
        viewControllers = [feed,dashboard,createPost]
    }
    
    
    
    
    
}
