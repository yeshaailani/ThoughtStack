//
//  Feed.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//
import UIKit
import LBTATools

/*
 This scene will show all the posts the user created in a feed like format.
 
 User has the ability to see all of his posts and delete any he doesnt like.
 
 Bonus:
 User can update any post he chooses to do so. It ll take him to create post scene with all the values prefilled allowing him to do his thing.
 
 */



class PostCell : LBTAListCell<Post> {
    
    
    override var item: Post! {
        didSet {
             // align model to views
        }
    }
    
    
    override func setupViews() {
        
        backgroundColor = .red
        // setup positioning of each cell item
    }
    
    
}


class Dashboard: LBTAListController<PostCell,Post>, UICollectionViewDelegateFlowLayout {
    // all self posts

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let posts = Utilities.singleton.mockPosts()
        
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 120)
    }
    
    
}
