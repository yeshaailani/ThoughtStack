//
//  ThoughtWallet.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import LBTATools

class ThoughtWallet: LBTAListController<PostCell,Post>,UICollectionViewDelegateFlowLayout {
    // all self posts
    var userId : String
    var lastpostCount : Int
    let spinner = SpinnerViewController()
    let normalPostSize : CGFloat = 250
    let imagePostSize : CGFloat = 450
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = Utilities.singleton.getMockQuotes() // change this to get user liked posts
    }
    
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
    //    let textPostSize : CGFloat = 300
        
        
    init(userId : String){
        self.userId = userId
        self.lastpostCount = 0
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    func checkPostCount(){
        print("checking for new posts?")
        // this function keeps track of number of posts by current user every time the view appears, if it changes it reflects dashboard
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
        navigationItem.title = "ThoughtWallet"
        checkPostCount()
    }
        

}
