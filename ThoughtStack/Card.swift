//
//  Card.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/19/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import TinyConstraints


/* Issues:
 
 Breaking constraints on author. Can be fixed by adding additional view.
 
 */



class Card: UIView {
    
    // MARK: Properties
    let quote : String
    var quoteImage : UIImage?
    var quoteOptionalImageView : UIImageView?
    let userProfilePic : UIImage
    let userName : String
    let quoteAuthor : String
    let font = "Times New Roman"

    init(frame: CGRect, post : Post){
        
        quote = post.quote
        quoteImage = post.image
        quoteAuthor = post.author
        
        self.userName = post.postOwnerUserName ?? "userName"
        self.userProfilePic = post.postOwnerProfilePic ?? UIImage(named:"user-outline")!
        // just to be safe
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
       view.backgroundColor = .white
        return view
    }()
    
    lazy var cardContainer : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    
    lazy var quoteText : UILabel = {
            
        return UILabel(text: self.quote, font: UIFont(name: font, size: 16), textColor: .black, textAlignment: .center, numberOfLines: 5)
        
       }()
    
    lazy var author : UILabel = {
        return UILabel(text: self.quoteAuthor, font: UIFont(name: font, size: 14), textColor: .blue, textAlignment: .right, numberOfLines: 1)
    }()

    
    lazy var profileContainer : UIStackView = {
       
        let profilePic = UIImageView(image: self.userProfilePic, contentMode: .scaleAspectFill)
        let profilePicSize = CGFloat(64)
        profilePic.size(.init(width: profilePicSize, height: profilePicSize))
        profilePic.clipsToBounds = true
        profilePic.layer.masksToBounds = true
        profilePic.layer.borderColor = UIColor.darkText.cgColor
        profilePic.layer.cornerRadius = profilePicSize / 6
        profilePic.layer.borderWidth = 1.0
        
        let userName = UILabel(text: self.userName, font: UIFont(name: "Times New Roman", size: 18), textColor: .black, textAlignment: .left, numberOfLines: 1)
        
        var stack = UIStackView(arrangedSubviews: [profilePic,userName])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.padLeft(8)
        stack.padRight(8)
        
        return stack
    }()


    
    func setupViews(){
        
        var totalViews = [containerView,cardContainer,profileContainer,quoteText,author]
        
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
        
        let width = self.frame.width, height = self.frame.height, imageHeight = CGFloat(200)
        let widthOffset = width * 0.05, heightOffset = height * 0.1
        let cardWidth = width - 2 * widthOffset, cardHeight = 0.8 * height
        var arrangedSubviews = [UIView]()
                
        cardContainer.edgesToSuperview()
        cardContainer.layer.cornerRadius = cardHeight / 24
        cardContainer.clipsToBounds = true
        cardContainer.layer.masksToBounds = true
        cardContainer.layer.borderColor = UIColor.black.cgColor
        cardContainer.layer.borderWidth = 1.0
        
        if let quoteImageView = quoteOptionalImageView {

            quoteImageView.top(to:cardContainer)
            quoteImageView.edges(to: cardContainer,excluding: [.top,.bottom],insets:.zero)
            quoteImageView.height(imageHeight)
            
            profileContainer.centerX(to:cardContainer)
            profileContainer.topToBottom(of: quoteImageView,offset: 8)
            profileContainer.edges(to: quoteImageView, excluding: .init(arrayLiteral: [.top,.bottom]), insets:.zero)
            arrangedSubviews.append(quoteImageView)
        }else
        {
            profileContainer.centerX(to:cardContainer)
            profileContainer.top(to: cardContainer,offset: 8) // this might not be needed due to foll line
            profileContainer.edges(to: cardContainer, excluding: .init(arrayLiteral: [.top,.bottom]), insets:.zero)
        }
        
        
        quoteText.centerX(to:profileContainer)
        quoteText.topToBottom(of: profileContainer,offset:8)
        quoteText.edges(to: profileContainer, excluding: .init(arrayLiteral: [.top,.bottom]), insets: TinyEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        
        author.trailing(to: cardContainer,offset: -16)
        author.bottom(to: cardContainer,offset: -8)
        
        arrangedSubviews += [profileContainer,quoteText,author]
        cardContainer.stack(arrangedSubviews,axis:.vertical)
        
    }
    
    
}
