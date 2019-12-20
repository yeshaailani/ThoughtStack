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
    var profilePicImageURL : String?
    var evaluatedPosts : [String]
    var selfPosts : [String]
    var likes : [String]

    init(parameters : [String: Any]) {
        name = parameters["name"] as? String ?? ""
        email = parameters["email"] as? String ?? ""
        nickName = parameters["nickName"] as? String ?? ""
        profilePicImageURL = parameters["profilePicImageURL"] as? String ?? ""
        evaluatedPosts = [String]()
        selfPosts = [String]()
        likes = [String]()
    }
    
    func updateProfilePic(_ profilePic : String){
        self.profilePicImageURL = profilePic
    }
        
}

class Post {
    
    var postID : String?
    let quote : String
    let author : String
    var category : String
    let imageURL : String?
    let ownerID : String
    var numLikes : [String]
    
    
    var image : UIImage? // for convenience.
    
    // the foll two properties are redundant, but lbta framework needs these values to be retrieved from posts model itself and I have no other way to send these values from my list controller. Thats the reason these two are here. DO NOT REFACTOR
    var postOwnerUserName : String?
    var postOwnerProfilePic : UIImage?
    
    init(parameters : [String: Any]) {
        quote = parameters["quote"] as? String ?? ""
        author = parameters["author"] as? String ?? ""
        category = parameters["category"] as? String ?? ""
        ownerID = parameters["ownerId"] as? String ?? "-1"
        numLikes = parameters["numLikes"] as? [String] ?? [String]() // check if numlikes are getting used
        imageURL = parameters["imageURL"] as? String
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
