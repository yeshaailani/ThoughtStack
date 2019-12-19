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
    
    
    /*
     Issues:
     1. Quotes taking too much space for some reason
     */
    
    
    let profilePicSize = CGFloat(32)
    var userProfilePic = UIImageView(image: UIImage(named:"user-filled"), contentMode: .scaleAspectFill)
    
    let userName : UILabel = {let label = UILabel(text: "ownerName", font: .boldSystemFont(ofSize: 16), textColor: .black, textAlignment: .left, numberOfLines: 1)
//        label.backgroundColor = .systemPink
        return label
    }() // owner can be nickname/hashtag
    
    let quoteText : UILabel = {
        let label = UILabel(text:"postText", font: .systemFont(ofSize: 14),textColor: .black,textAlignment: .left,numberOfLines: 3)
//        label.backgroundColor = .blue
        return label
    }()

    let quoteAuthor : UILabel = {let label = UILabel(text:"quoteAuthor", font: .systemFont(ofSize: 13),textColor: .black,textAlignment: .right,numberOfLines: 1)
//        label.backgroundColor = .yellow
        return label
    }()

    let quoteImage : UIImageView = {
        let imageView = UIImageView(image: UIImage(),contentMode: .scaleAspectFit)
//        imageView.backgroundColor = .purple
        imageView.isHighlighted = true
        return imageView
    }()
    
    let likeButton = UIButton(image: UIImage(named:"ic_like")!, tintColor: .lightGray, target: nil, action: nil)
    
    let numLikes : UILabel = {let label = UILabel(text:"x ratings", font: .systemFont(ofSize: 18),textColor: .lightGray,textAlignment: .left)
//        label.backgroundColor = .magenta
        return label
    }()
    
    override func setupViews() {
        super.setupViews()

        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        userProfilePic.layer.cornerRadius = profilePicSize / 2
        userProfilePic.layer.borderWidth = 1
        userProfilePic.layer.borderColor = UIColor.white.cgColor
        userProfilePic.clipsToBounds = true
        
        quoteImage.clipsToBounds = true
        quoteImage.layer.cornerRadius = 16
                
        
        stack(
        hstack(userProfilePic.withWidth(profilePicSize).withHeight(profilePicSize),userName,spacing:8,alignment:.center).withMargins(.left(8)).withHeight(80), // 96
            stack(quoteText,quoteAuthor,spacing: 4,alignment:.fill).withMargins(.allSides(8)).withHeight(80), // 80
            stack(quoteImage.withHeight(200)).withMargins(.init(top: 0, left: 8, bottom: 0, right: 8)), // 200
            hstack(likeButton.withWidth(60),numLikes,spacing: 4,alignment:.center).withMargins(.init(top: 5, left: 8, bottom: 5, right: 0)).withHeight(56), // 66
              alignment: .fill
        )
        

    }
    
    override var item: Post! {
        didSet {
            
            userName.text = item.postOwnerUserName ?? "username"
            userProfilePic.image = item.postOwnerProfilePic ?? UIImage(named:"user-outline")!
            quoteText.text = item.quote.trimmingCharacters(in: .whitespacesAndNewlines)
            quoteAuthor.text = item.author
            
            if let image = item.image
            {
                quoteImage.image = image
                quoteImage.isHidden = false
            }else
            {
                quoteImage.isHidden = true
            }
            
            numLikes.text = String(item.numLikes)

        }
    }
    

}


class Dashboard: LBTAListController<PostCell,Post>, UICollectionViewDelegateFlowLayout {
    // all self posts
    var userId : String
    var lastpostCount : Int
    let spinner = SpinnerViewController()
    let normalPostSize : CGFloat = 250
    let imagePostSize : CGFloat = 450
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = Utilities.singleton.getMockQuotes()
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
        parent?.navigationItem.title = "Dashboard"
        
        checkPostCount()
    }
        

}


class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height + CGFloat(16))
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
