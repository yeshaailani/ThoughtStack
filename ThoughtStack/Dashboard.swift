//
//  Feed.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//
import UIKit
import LBTATools


class PostCell : LBTAListCell<Post> {
        
    let profilePicSize = CGFloat(32)
    var userProfilePic = UIImageView(image: UIImage(named:"user-filled"), contentMode: .scaleAspectFill)
    
    let userName : UILabel = {let label = UILabel(text: "ownerName", font: .boldSystemFont(ofSize: 16), textColor: .black, textAlignment: .left, numberOfLines: 1)
        return label
    }() // owner can be nickname/hashtag
    
    let quoteText : UILabel = {
        let label = UILabel(text:"postText", font: .systemFont(ofSize: 14),textColor: .black,textAlignment: .left,numberOfLines: 3)
        return label
    }()

    let quoteAuthor : UILabel = {let label = UILabel(text:"quoteAuthor", font: .systemFont(ofSize: 13),textColor: .black,textAlignment: .right,numberOfLines: 1)
        return label
    }()

    let quoteImage : UIImageView = {
        let imageView = UIImageView(image: UIImage(),contentMode: .scaleAspectFit)
        imageView.isHighlighted = true
        return imageView
    }()
    
    let likeButton = UIButton(image: UIImage(named:"ic_like")!, tintColor: .lightGray, target: nil, action: nil)
    
    let numLikes : UILabel = {let label = UILabel(text:"x ratings", font: .systemFont(ofSize: 18),textColor: .lightGray,textAlignment: .left)
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
            
            numLikes.text = String(item.numLikes.count)

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
    lazy var emptyPostInfo = UIView()
    
    var userName : String?
    var userProfilePic : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkPostCount()
    }
    
    func noMorePostsLeft(){
        
        self.view.addSubview(emptyPostInfo)
        
        self.emptyPostInfo.centerInSuperview()
        self.emptyPostInfo.size(.init(width: 200, height: 200))
        
        let emptyPostText = UILabel(text: "No posts to display", font: .boldSystemFont(ofSize: 16), textColor: .black, textAlignment: .center, numberOfLines: 1)
        
        self.emptyPostInfo.addSubview(emptyPostText)
        emptyPostText.center(in: emptyPostInfo)
        
        
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
        
        FirebaseService.shared.getDashboardPostCount(userId: userId, completion: { postCount,error in
            
             let newPostCount = postCount ?? 0
             print("Old posts count \(self.lastpostCount) New posts count: \(newPostCount)")
            
             if newPostCount != self.lastpostCount {
                
                self.setUpSpinner()
                
                FirebaseService.shared.getUsersDashboard(userId: self.userId, completion: { posts,error in
                    
                    if error != nil || posts == nil || posts!.count == 0 {
                        print("Couldnt get dashboard",error?.localizedDescription ?? "")
                        self.tearDownSpinner()
                        self.noMorePostsLeft()
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

    func setupNavigation() {
           
        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"wallet-outline")!, style: .plain, target: self, action: #selector(walletTapped))
           
           self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"logout")!, style: .plain, target: self, action: #selector(logoutTapped))
           
           self.parent?.navigationItem.title = "Dashboard"
           
       }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.navigationItem.title = "Dashboard"
        self.checkPostCount()
        self.setupNavigation()
    }
    
    @objc func logoutTapped() {
        print("Logout has been tapped!")
        // auth logic here
    }
            
    @objc func walletTapped(){
        self.parent?.navigationController?.pushViewController(ThoughtWallet(userId: self.userId), animated: true)
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
