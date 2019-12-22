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
        var userId : String
        
        if let creds = Utilities.singleton.load()
        {
        userId = creds[UserFields.userId.rawValue]!
        let email = creds[UserFields.email.rawValue]!
        print("Userid: \(userId) EmailId: \(email)")
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
            Utilities.singleton.clearCache()
            return
        }
        
        let feed = Feed(userId: userId)
        feed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "grid-outline")!, selectedImage: UIImage(named: "grid-filled")!)
        
        let dashboard = Dashboard(userId: userId) // TODO: take from persistent data later
        dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "user-outline")!, selectedImage: UIImage(named: "user-filled")!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreatePostViewController")
    
        let createPost = controller
        createPost.tabBarItem = UITabBarItem(title: "Create Post", image: UIImage(named: "plus-outline"), selectedImage: UIImage(named: "plus-filled"))
        
        let wallet = ThoughtWallet(userId: userId)
        wallet.tabBarItem = UITabBarItem(title: "ThoughtWallet", image: UIImage(named: "wallet-outline"), selectedImage: UIImage(named: "wallet-filled"))
        
        
        viewControllers = [createPost,feed,dashboard]
        
        
    }
    

    
}
