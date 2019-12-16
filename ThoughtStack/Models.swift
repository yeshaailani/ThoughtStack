//
//  Models.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import Foundation


enum Categories : String {
    case motivational
    case philosophical
    case funny
    case movies
    case famous
    case romance
}


class User {

    var userID : Int?
    let name : String
    let nickName : String
    let email : String
    var profilePic : String?
    var evaluatedPosts : [String]
    var selfPosts : [String]
    var likes : [String]

    init(parameters : [String: Any]) {
        name = parameters["name"] as? String ?? ""
        email = parameters["email"] as? String ?? ""
        nickName = parameters["nickName"] as? String ?? ""
        profilePic = parameters["profilePic"] as? String
        evaluatedPosts = [String]()
        selfPosts = [String]()
        likes = [String]()
    }
        
}


class Post {
    
    var postID : Int?
    let quote : String
    let author : String
    var category : String
    let imageURL : String?
    let ownerID : Int
    
    init(parameters : [String: String]) {
        quote = parameters["quote"] ?? ""
        author = parameters["author"] ?? ""
        category = parameters["category"] ?? ""
        ownerID = Int(parameters["ownerId"] ?? "-1")!
    }
    
    func updateImageURL(_ url : String){
        self.imageURL = url
    }
}

enum StorageReferences : String {
    case profile_pics = "profile-pics/"
    case posts = "posts/"
}

enum TableReferences : String {
    case users = "Users"
    case posts = "Posts"
}
