//
//  Utilities.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/7/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static let singleton = Utilities()
    private init(){}
    
    lazy var quotes : [[String:String]]  =  {
        
        var tempQuotes = [[String : String]]()
        let userID = "oG7weadM3FHXhb9XyJBC"
        
        let quoteText = [
            "Dont cry because its over, smile because it happened.",
            "Every man is guilty of the good he did not do",
            "Life is 10% what happens to you and 90% how you react to it.",
            "Quality is not an act, it is a habit",
            "It does not matter how slowly you go as long as you do not stop",
            "Today is good, today is fun. Tommorow is another one.",
            "Well done is better than well said"
        ]
        
        let quoteAuthors = [
        "Dr Seuss",
        "Voltaire",
        "Charles Swindoll",
        "Aristotle",
        "Confucius",
        "Dr Seuss",
        "Benjamin Franklin"
        ]
        
        
        let quoteCategories : [Categories] = [
        .movies,
        .philosophical,
        .motivational,
        .famous,
        .motivational,
        .famous,
        .famous
        ]
        
        
        for (index,quoteText) in quoteText.enumerated()
        {
            let params : [String: String] = [
                "quote" : quoteText,
                "author" : quoteAuthors[index],
                "category" : quoteCategories[index].rawValue,
                "ownerId" : userID
            ]
            tempQuotes.append(params)
        }
        
        return tempQuotes
    }()
    
    var quoteImages = [
//         "slow-dont-matter-confucius",
        "cry-smile-over",
               "guilty-of-not-do11",
                 "life-10-90",
                 "quality-act-habit",
                 "slow-dont-matter-confucius",
                 "today-fun",
                 "well-done-well-said",
           ]
    
    func testFIR(){
       
        print("Going to test \(quotes.count) quotes")
        for (index,quote) in quotes.enumerated() {
            FirebaseService.shared.addPost(userId : "oG7weadM3FHXhb9XyJBC",post: quote,optionalImage: UIImage(named: quoteImages[index]),completion: {
            
                print("Post added succesfully!")
            
            })
        }
        
    }
    
    
    func getTimeStamp(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func getMockQuotes() -> [Post] {
        
        var posts = [Post]()
        
        let mockUserName = "prabhu150", mockProfilePic = UIImage(named: "goku")
        
        for (index,quote) in quotes.enumerated()
        {
            let currPost = Post(parameters: quote)
            currPost.image = UIImage(named: quoteImages[index])
            currPost.postOwnerUserName = mockUserName
            currPost.postOwnerProfilePic = mockProfilePic
//            currPost.numLikes = Int(arc4random_uniform(UInt32(20)))
            currPost.numLikes = [String]()
            posts.append(currPost)
        }
        
        posts[0].postID = "HKNpoo196Jwt79JZNVW6"
        posts[2].postID = "NBlcwSG2zbfnshkQeEkI"
        
        return posts
        
    }
    
    
    // MARK: Persistent data
    
    func save(email:String, userId: String) {
        UserDefaults.standard.set(email, forKey : UserFields.email.rawValue)
        UserDefaults.standard.set(userId, forKey : UserFields.userId.rawValue)
    }
    
    func load() -> [String:String]? {
        
        if let email = UserDefaults.standard.string(forKey:UserFields.email.rawValue), let userId =  UserDefaults.standard.string(forKey:UserFields.userId.rawValue){
            let result = [UserFields.email.rawValue: email,UserFields.userId.rawValue : userId]
            return result
        }
        
        return nil
    }
    
    func clearCache(){
        
        let keys = [UserFields.userId.rawValue,UserFields.email.rawValue]
        
        for key in keys
        {
            UserDefaults.standard.removeObject(forKey:key)
        }
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
