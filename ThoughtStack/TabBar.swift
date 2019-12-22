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
        
        let mockUserID = "uK4evBYAkmdU5KTGIn6c" // yesha id
        
        let feed = Feed(userId: mockUserID) // in future take userId from persistent data or FIRAuth
        feed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "grid-outline")!, selectedImage: UIImage(named: "grid-filled")!)
        
        let dashboard = Dashboard(userId: mockUserID) // TODO: take from persistent data later
        dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(named: "user-outline")!, selectedImage: UIImage(named: "user-filled")!)
        
        let createPost = CreatePost()
        createPost.tabBarItem = UITabBarItem(title: "Create Post", image: UIImage(named: "plus-outline"), selectedImage: UIImage(named: "plus-filled"))
        
        
        let wallet = ThoughtWallet(userId: mockUserID)
        wallet.tabBarItem = UITabBarItem(title: "ThoughtWallet", image: UIImage(named: "wallet-outline"), selectedImage: UIImage(named: "wallet-filled"))
        
        
        let cardDemo = UIViewController()
        
        let mockQuotes = Utilities.singleton.getMockQuotes()
        
        let card = Card(frame: .init(x: 0, y: 0, width: cardDemo.view.frame.width, height: cardDemo.view.frame.height), post: mockQuotes[0])
        
        cardDemo.view = card
        
        
        cardDemo.tabBarItem = UITabBarItem(title: "CardDemo", image: UIImage(named: "wallet-outline"), selectedImage: UIImage(named: "wallet-filled"))
        
        
        viewControllers = [cardDemo,feed,dashboard,wallet]
        
        
        
    }
    

    
}
