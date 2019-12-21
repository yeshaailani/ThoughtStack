//
//  ThoughtWallet.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//


/*
 
 Issues:
 
 TW got zero posts
 
 Cards have hardcoded username and profile pics
 
 Dashboard got zero posts
 
 Undo did not work for the backend part.
 
 
 */


import UIKit
import LBTATools

class ThoughtWallet: LBTAListController<PostCell,Post>,UICollectionViewDelegateFlowLayout {
    // all self posts
    var userId : String
    var lastpostCount : Int
    let spinner = SpinnerViewController()
    let normalPostSize : CGFloat = 250
    let imagePostSize : CGFloat = 450
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpSpinner()
//        self.items = Utilities.singleton.getMockQuotes() // change this to get user liked posts
        
    }
    */
    
    func tearDownSpinner(){
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    func setUpSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    init(userId : String){
        self.userId = userId
        self.lastpostCount = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func checkPostCount(){
        // this function keeps track of number of posts by current user every time the view appears, if it changes it reflects dashboard
        
        print("checking for new posts?")
        
        FirebaseService.shared.getUsersThoughtWallet(userId: userId, completion: { posts,error in
            
            if error != nil || posts == nil {
                print("Couldnt get tw")
                return
            }
            
            
            if let thoughtWalletPosts = posts {
               
                let postCount = thoughtWalletPosts.count
               
                if postCount > self.lastpostCount {
                    // write logic that appends to items rather than overwrite its completely
                    let sortedPosts = thoughtWalletPosts.sorted{ post1, post2 in
                        return post1.timeStamp > post2.timeStamp
                    }
    
                    self.items = sortedPosts
                    self.lastpostCount = postCount
                }
               
               self.tearDownSpinner()
            }
            
           
            
        })
        
    }
        
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item \(indexPath.item) selected!")
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let size : CGSize
        
        if let _ = items[indexPath.item].image {
            size = .init(width: width, height: self.imagePostSize)
        }else
        {
            size = .init(width: width, height: self.normalPostSize)
        }

        return size
        
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Got called")
        navigationItem.title = "ThoughtWallet"
        self.checkPostCount()
    }
        

}
