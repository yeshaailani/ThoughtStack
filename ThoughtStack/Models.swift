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
        name = parameters[UserFields.name.rawValue] as? String ?? "Some User"
        email = parameters[UserFields.email.rawValue] as? String ?? "someEmail@gmail.com"
        nickName = parameters[UserFields.nickName.rawValue] as? String ?? "someNickname"
        profilePicImageURL = parameters[UserFields.profilePicImageURL.rawValue] as? String
        evaluatedPosts = parameters[UserFields.evaluatedPosts.rawValue] as? [String] ?? [String]()
        selfPosts = parameters[UserFields.selfPosts.rawValue] as? [String] ?? [String]()
        likes = parameters[UserFields.likes.rawValue] as? [String] ?? [String]()
    }

        
}

class Post {
    
    var postID : String!
    let quote : String
    let author : String
    var category : String
    let imageURL : String?
    let ownerID : String
    var numLikes : [String]
    var image : UIImage? // for convenience.
    var timeStamp : String
    
    
    // the foll two properties are redundant, but lbta framework needs these values to be retrieved from posts model itself and I have no other way to send these values from my list controller. Thats the reason these two are here. DO NOT REFACTOR
    var postOwnerUserName : String?
    var postOwnerProfilePic : UIImage?
    
    init(parameters : [String: Any]) {
        postID = parameters[PostFields.postId.rawValue] as? String
        quote = parameters[PostFields.quote.rawValue] as? String ?? ""
        author = parameters[PostFields.author.rawValue] as? String ?? ""
        category = parameters[PostFields.category.rawValue] as? String ?? ""
        ownerID = parameters[PostFields.ownerId.rawValue] as? String ?? "-1"
        numLikes = parameters[PostFields.likes.rawValue] as? [String] ?? [String]() // check if numlikes are getting used
        imageURL = parameters[PostFields.imageURL.rawValue] as? String
        timeStamp = parameters[PostFields.timeStamp.rawValue] as? String ?? "-1"
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
enum UserFields : String {
    case userId
    case email
    case name
    case nickName
    case evaluatedPosts
    case likes
    case profilePicImageURL
    case selfPosts
}

enum PostFields : String {
    case postId
    case author
    case category
    case imageURL
    case ownerId
    case quote
    case likes
    case timeStamp
}
