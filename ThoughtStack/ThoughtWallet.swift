//
//  ThoughtWallet.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//


/*
 
 Issues:
 
 
 Bit laggy tbh
 
 TW got zero posts
 Cards have hardcoded username and profile pics
 
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
    var emptyPostInfo = UIView()
    
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
    
    func noMorePostsLeft(){
        
        self.view.addSubview(emptyPostInfo)
        
        self.emptyPostInfo.centerInSuperview()
        self.emptyPostInfo.size(.init(width: 200, height: 200))
        
        let emptyPostText = UILabel(text: "There are no more posts to show", font: .boldSystemFont(ofSize: 16), textColor: .black, textAlignment: .center, numberOfLines: 1)
        
        self.emptyPostInfo.addSubview(emptyPostText)
        emptyPostText.center(in: emptyPostInfo)
        
        
    }
    
    func checkPostCount(){
        // this function keeps track of number of posts by current user every time the view appears, if it changes it reflects dashboard
        
        print("TW: Check for new content?")
        
        FirebaseService.shared.getThoughtWalletPostCount(userId: userId, completion: { postCount,error in
            
             let newPostCount = postCount ?? 0
             print("Old TW pc: \(self.lastpostCount) New TW pc: \(newPostCount)")
            
            if newPostCount == 0 {
                self.lastpostCount = 0
                self.noMorePostsLeft()
                return
            }
            
             if newPostCount != self.lastpostCount {
                
                self.setUpSpinner()
                
                FirebaseService.shared.getUsersThoughtWallet(userId: self.userId, completion: { posts,error in
                    
                    if error != nil || posts == nil || posts!.count == 0{
                        print("Couldnt get dashboard",error?.localizedDescription ?? "")
                        self.noMorePostsLeft()
                        self.tearDownSpinner()
                        return
                    }
                    print("Got \(posts!.count) quotes")
                    self.items = posts!
                    self.lastpostCount = newPostCount
                    self.tearDownSpinner()
                    })
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
