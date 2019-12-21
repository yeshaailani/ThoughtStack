//
//  Card.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/19/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import TinyConstraints


// TODO: fix the profile pic and username within the card itself

class Card: UIView {
    
    // MARK: Properties
    let quote : String
    var quoteImage : UIImage?
    var quoteOptionalImageView : UIImageView?
    let userProfilePic : UIImage
    let userName : String
    let quoteAuthor : String
    let font = "Times New Roman"

    init(frame: CGRect, post : Post, userName : String = "prabhu150" , userProfilePic : UIImage = UIImage(named:"user-outline")!){
        
        quote = post.quote
        quoteImage = post.image
        quoteAuthor = post.author
        self.userName = userName
        self.userProfilePic = userProfilePic
        print("reached init for card whose author is \(quoteAuthor)")
        super.init(frame:frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: Views
   
    lazy var containerView : UIView = {
       let view = UIView()
       view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var cardContainer : UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    
           
    lazy var quoteText : UILabel = {
            
        return UILabel(text: self.quote, font: UIFont(name: font, size: 16), textColor: .black, textAlignment: .center, numberOfLines: 3)
        
       }()
    
    lazy var author : UILabel = {
        return UILabel(text: self.quoteAuthor, font: UIFont(name: font, size: 14), textColor: .blue, textAlignment: .right, numberOfLines: 1)
    }()

    
    lazy var profileContainer : UIStackView = {
       
        let profilePic = UIImageView(image: self.userProfilePic, contentMode: .scaleAspectFill)
        let profilePicSize = CGFloat(32)
        profilePic.size(.init(width: profilePicSize, height: profilePicSize))
        profilePic.clipsToBounds = true
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.white.cgColor
        profilePic.layer.cornerRadius = profilePicSize / 2
        profilePic.layer.borderWidth = 1.0
        
        
        let userName = UILabel(text: self.userName, font: UIFont(name: "Times New Roman", size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
        
        var stack = UIStackView(arrangedSubviews: [profilePic,userName])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.padLeft(8)
        stack.padRight(8)
        
        return stack
    }()


    lazy var likeButton = UIButton(image: UIImage(named:"btn_like_normal")!, tintColor: .green, target: self, action: #selector(likePost))
    
    lazy var skipButton = UIButton(image: UIImage(named:"btn_skip_normal")!, tintColor: .red, target: self, action: #selector(skipPost))
    
    lazy var logoutButton = UIBarButtonItem(image: UIImage(named:"logout")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(logout))
    
    
    @objc func logout(){
        print("logout tapped!")
    }
    
    @objc func likePost() {
        print("Like tapped!")
    }
    
    @objc func skipPost() {
        print("Skip tapped!")
    }
    
    func setupViews(){
        
        var totalViews = [containerView,cardContainer,likeButton,skipButton,profileContainer,quoteText,author]
        
        if let image = quoteImage {
            self.quoteOptionalImageView = UIImageView(image:image,contentMode: .scaleAspectFit)
            totalViews.append(quoteOptionalImageView!)
        }
        
        for curr_view in totalViews {
            self.addSubview(curr_view)
        }
        
        constrainViews()
    }
    
    func constrainViews() {
        
        let width = self.frame.width, height = self.frame.height
        let widthOffset = width * 0.05, heightOffset = height * 0.05
        let cardWidth = width - 2 * widthOffset, cardHeight = 0.8 * height
        var arrangedSubviews = [UIView]()
        
        containerView.edgesToSuperview()
        containerView.size(self.frame.size)
        
        
        cardContainer.edges(to: containerView, excluding: .bottom, insets: .init(top: 1.75 * heightOffset, left: widthOffset, bottom: 0, right: widthOffset))
        
        cardContainer.layer.cornerRadius = cardHeight / 24
        cardContainer.clipsToBounds = true
        cardContainer.layer.masksToBounds = true
        cardContainer.layer.borderColor = UIColor.white.cgColor
        cardContainer.layer.borderWidth = 1.0
        
        
        profileContainer.centerX(to:cardContainer)
        
        if let quoteImageView = quoteOptionalImageView {
            quoteImageView.centerX(to: containerView)
            quoteImageView.top(to: cardContainer)
            quoteImageView.width(cardWidth)
            quoteImageView.aspectRatio(16/9)
            quoteImageView.height(min: nil, max: cardHeight)
            profileContainer.topToBottom(of: quoteImageView)
            profileContainer.edges(to: quoteImageView, excluding: .init(arrayLiteral: [.top,.bottom]), insets:.zero)
            arrangedSubviews.append(quoteImageView)
        }else
        {
            profileContainer.top(to: cardContainer)
            profileContainer.edges(to: cardContainer, excluding: .init(arrayLiteral: [.top,.bottom]), insets:.zero)
        }
        
        
        quoteText.centerX(to:profileContainer)
        quoteText.topToBottom(of: profileContainer,offset:8)
        quoteText.edges(to: profileContainer, excluding: .init(arrayLiteral: [.top,.bottom]), insets:.zero)
        
        
        author.trailing(to: cardContainer,offset: -8)
        author.topToBottom(of: quoteText)
        
        let padding = UIView()
        padding.height(8)
   
        arrangedSubviews += [profileContainer,quoteText,author,padding]
        cardContainer.stack(arrangedSubviews,axis:.vertical,width: cardWidth,height: cardHeight,spacing:8)
        
        containerView.stack([cardContainer], axis: .vertical, width: width, height: height,spacing: 2)
        
    }
    
    
}
