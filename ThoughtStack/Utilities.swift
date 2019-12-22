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
            "Well done is better than well said",
            
            "When the sword is once drawn, the passions of men observe no bounds of moderation.",

            "One individual may die for an idea, but that idea will, after his death, incarnate itself in a thousand lives.",
            "Life is lived on its own. Other’s shoulders are used only at the time of funeral.",
            "Books are as useful to a stupid person as a mirror is useful to a blind person.",
            "Life isn't measured by the number of breaths you take, but by the number of moments that take your breath away.",
            "I'm old enough to know better, but young enough to do it anyway.",
            "I love being married. It's so great to find that one special person you want to annoy for the rest of your life.",
            "If we were on a sinking ship, and there was only one life vest... I would miss you so much.",
            "The most important thing in life is not knowing everything, it's having the phone number of somebody who does!",
            "Some relationships are like Tom and Jerry, they argue and disagree all the time, but they still can't live without each other.",
            "In the end, we only regret the chances we didnt take",
            "I dont need a friend who changes when I change and nods when I nod. My shadow does that much better",
            "To be successful you have to put your heart in your business and your business in your heart",
            "Love makes everything better.",
            "Look upto the sky, you'll never find rainbows looking at your feet",
            "The only place success comes before work is in the dictionary",
            "If someone doesn't appreciate your presence, make them appreciate your absence"
            
            
        ]
        
        let quoteAuthors = [
        "Dr Seuss",
        "Voltaire",
        "Charles Swindoll",
        "Aristotle",
        "Confucius",
        "Dr Seuss",
        "Benjamin Franklin",
        "Alexander Hamilton",
        "Bose",
        "Bhagat Singh",
        "Chanakya",
        "Anon",
        "Anon",
        "Rita Rudner",
        "Anon",
        "Anon",
        "Anon",
        "Plutarch",
        "Thomas Watson Sr",
        "Anon",
        "Anon",
        "Anon",
        "Anon",
        "Anon",
        "Anon",
        "Anon",
        "Anon",
        "Anon",
        ]
        
        
        let quoteCategories : [Categories] = [
        .movies,
        .philosophical,
        .motivational,
        .famous,
        .motivational,
        .famous,
        .famous,
        .famous,
        ]
        
        
        for (index,quoteText) in quoteText.enumerated()
        {
            let params : [String: String] = [
                "quote" : quoteText,
                "author" : quoteAuthors[index],
                "category" : "famous",
                "ownerId" : userID
            ]
            tempQuotes.append(params)
        }
        
        return tempQuotes
    }()
    
    var quoteImages = [
                "cry-smile-over",
                "guilty-of-not-do",
                 "life-10-90",
                 "quality-act-habit",
        "slow-dont-matter-confucius",
                 "today-fun",
                 "well-done-well-said",
                 "alex-sword",
                 "bose-idea",
                 "bhagat-life",
                 "books-chanakya",
                 "life-measure",
                 "old-enough",
                 "love-being-married",
                 "sinking-ship",
                 "know-phone-number",
                 "tom-jerry",
                 "chances-not-taken",
                 "fake-friend",
                 "heart-in-business",
                 "love-better",
                 "rainbow-sky",
                 "success-work",
                 "presencev"
                 
           ]
    
    
    
    
    func testFIR(userId:String, startIndex : Int, endIndex : Int){
       
        print("Going to test \(quotes.count) quotes")
        
        var begin = startIndex , end = endIndex
        
        while(begin < end){
            
           FirebaseService.shared.addPost(userId : userId,post: quotes[begin],optionalImage: UIImage(named: quoteImages[begin]),completion: {
               print("Post number \(begin) added succesfully!")
           })
            
            begin += 1
//            print("Will add image \(self.quoteImages[index].count)")
        }
        
        return
    
        
    }
    
    
    func uploadPosts(){
        
        let user1 = "AG1ktoBHbl8whJ2vPVKP" , user2 = "GmL2CizP2GDPy6b8IQnN", user3 = "Jm1zuPS8m4sLZcYlKwez", user4 = "TbUemkIZtrIklb3QNAkJ"
        
        self.testFIR(userId: user1, startIndex: 0, endIndex: 6) // 0 to 5
        
        self.testFIR(userId: user2, startIndex: 6, endIndex: 12) // 6 to 12
        
        self.testFIR(userId: user3, startIndex: 12, endIndex: 18) // 0 to 6
        
        self.testFIR(userId: user4, startIndex: 18, endIndex: 24) // 0 to 6
        
        
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
            currPost.numLikes = [String]()
            posts.append(currPost)
        }
        
        
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
