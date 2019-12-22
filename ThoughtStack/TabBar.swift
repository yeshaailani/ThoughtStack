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
        
//        Utilities.singleton.testFIR() // add quotes as abhi
        
//        let mockUserID = "uK4evBYAkmdU5KTGIn6c" // yesha id
        
        var mockUserID : String
        
        if let creds = Utilities.singleton.load()
        {
        mockUserID = creds[UserFields.userId.rawValue]!
        let email = creds[UserFields.email.rawValue]!
        print("Userid: \(mockUserID) EmailId: \(email)")
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        
        let feed = Feed(userId: mockUserID) // in future take userId from persistent data or FIRAuth
        feed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "grid-outline")!, selectedImage: UIImage(named: "grid-filled")!)
        
        let dashboard = Dashboard(userId: mockUserID) // TODO: take from persistent data later
        dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "user-outline")!, selectedImage: UIImage(named: "user-filled")!)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreatePostViewController")
    
        let createPost = controller
        createPost.tabBarItem = UITabBarItem(title: "Create Post", image: UIImage(named: "plus-outline"), selectedImage: UIImage(named: "plus-filled"))
        
        
        let wallet = ThoughtWallet(userId: mockUserID)
        wallet.tabBarItem = UITabBarItem(title: "ThoughtWallet", image: UIImage(named: "wallet-outline"), selectedImage: UIImage(named: "wallet-filled"))
        
        
        viewControllers = [createPost,feed,dashboard]
        
        
    }
    

    
}
