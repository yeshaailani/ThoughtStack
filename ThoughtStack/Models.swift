//
//  Models.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import Foundation
import UIKit

enum Categories : String {
    case motivational
    case philosophical
    case funny
    case movies
    case famous
    case romance
}


class User {

    var userID : String?
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
        evaluatedPosts = [String]()
        selfPosts = [String]()
        likes = [String]()
    }
    
    func updateProfilePic(_ profilePic : String){
        self.profilePic = profilePic
    }
        
}


class Post {
    
    var postID : Int?
    let quote : String
    let author : String
    var category : String
    let imageURL : String?
    let ownerID : String
    var image : UIImage?
    var numLikes : Int
    
    // for convenience these two are in the model, this isnt reflected on backend
    var postOwnerUserName : String?
    var postOwnerProfilePic : UIImage?
    
    init(parameters : [String: String]) {
        quote = parameters["quote"] ?? ""
        author = parameters["author"] ?? ""
        category = parameters["category"] ?? ""
        ownerID = parameters["ownerId"] ?? "-1"
        imageURL = nil
        numLikes = 0
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
