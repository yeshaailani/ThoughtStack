//
//  FirebaseService.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/7/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCore
import UIKit

class FirebaseService {
    
    private init(){}
    static let shared =  FirebaseService()
    let testBranch = "test-abhi/"
    
    func configure(){
        FirebaseApp.configure()
    }
    
    private func reference(to tableref : TableReferences) -> CollectionReference{
        return Firestore.firestore().collection(tableref.rawValue)
    }
    
    private func storage(to storage : StorageReferences) -> StorageReference
    {
        return Storage.storage().reference(withPath: storage.rawValue)
    }
    
    func addUser(params : [String : Any]) {
        
        let params : [String : Any] = [
            "name" : "abhi",
            "email" : "abc@gm.com",
            "nickName" : "abc15",
            "profilePic" : -1,
        ];
        
        reference(to: .users).addDocument(data: params)
        
    }
    
    func addPost(post data : [String : Any]){
        
        // check if post contains an image, if it does call following line inside
        // successful completion handler part.
        reference(to: .posts).addDocument(data: data)
    }
    
    
    func getUserByID(userID : String){
        
    }
    
    func uploadImage(completion: @escaping (Error?,String?) -> Void){
        
    }
    
    
    /*
     Firebase objectives:
     
     create insert update delete
     
     create -> adduser,addpost done
     update -> left swipe, right swipe, undo, delete from tw/selffeed
     delete -> someone deletes their post
    
     find all posts by pid
     
     if all pids exist, then return those posts.
     
     does firebase throw error for pid not found or does it simply return nil?
     
     
     Handle delete:
     
     when you delete from dashboard:
     1. remove item from content list of model and reflect that on front end
     2. remove item id from content list of current user on backend
     3. remove that item from posts table using item id.
     
     when you delete from thoughtwallet:
     1. remove item from likes list of model and reflect that on front end
     2. remove item id from likes list of current user on backend
     
     this wont affect feed at all since that will always retrieve latest list of ids from the backend
     
     when others tw is loaded:
     1. get list of ids from current users likes list.
     2. if firebase doesnt throw exception, simply display the items u can find and make others nil
     3. if it does, then
     get list of ids for every post in the table and cross reference the two lists
     4. if user likes a post that currently doesnt exist then remove the item from his likes list on the front end
     5. once both lists are cross referenced, if needed update the current users likes on the backend
     6. display the posts u see
     
     
     feed being loaded:
     
     1. get all pids from posts table
     2. filter out those that have already been evaluated
     3. display the list
     
     
     dashboard being loaded:
     
        
     
     Handle Undos:
     
     
     */
    
    
    
    
}
