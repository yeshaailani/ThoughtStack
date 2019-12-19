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
    
    
    
    func configure(){
        FirebaseApp.configure()
    }
    
    private func reference(to tableref : TableReferences) -> CollectionReference{
        let val = Firestore.firestore().collection(tableref.rawValue)
        return val
    }
    
    private func storage(to storage : StorageReferences) -> StorageReference
    {
        let val = Storage.storage().reference(withPath: storage.rawValue)
        return val
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
    
    func addPost(post: [String : Any],optionalImage : UIImage? = nil){
        
        var data = post
        
        if let image = optionalImage {
            self.uploadPostImage(image: image, completion: {error,downloadURL in
                
                if let _ = error {
                    print(error?.localizedDescription)
                    return
                }
                
                print("sending quote with image")
                
                if downloadURL != nil
                {
                    data["imageURL"] = downloadURL
                    self.reference(to: .posts).addDocument(data: data)
                    print("Added post with an image! \(downloadURL)")
                }
                
            })
        }else
        {
            print("Added post without any image!")
            self.reference(to: .posts).addDocument(data: data)
        }
        
    }
    
    private func uploadPostImage(image: UIImage, completion: @escaping (Error?,String?) -> Void){
        
        
       let pngData = image.pngData() // get pngdata
       let jpgData = image.jpegData(compressionQuality: 0.2) // get jpgdata
       let data : Data
       let ext : String
        
       var metadata = StorageMetadata()
        
        if let _ = pngData {
            data = pngData!
            ext = ".png"
            
            
        }else if let _ = jpgData {
            data = jpgData!
            ext = ".jpg"
            
        }
        else{
            print("Unsupported file")
            return
        }
        
        metadata.contentType = ext
        
        let postsRef = storage(to: .posts).child(Date().millisecondsSince1970)
        
        let _ = postsRef.putData(data, metadata: metadata) { metadata,error in
            
            if let _ = error {
                print("upload error",error?.localizedDescription)
                completion(error,nil)
                return
            }
            
            guard let metadata = metadata else {
              print("couldnt get metadata")
              completion(error,nil)
              return
            }
            
            postsRef.downloadURL(completion: { downloadURL, error in
                completion(error,downloadURL?.absoluteString)
            })
            
        }
            
    }
    
    private func uploadProfilePicImage(image: UIImage, completion: @escaping (Error?,String?) -> Void){
        let pngData = image.pngData() // get pngdata
        let jpgData = image.jpegData(compressionQuality: 0.2) // get jpgdata
        let data : Data
        let ext : String
         
        var metadata = StorageMetadata()
         
         if let _ = pngData {
             data = pngData!
             ext = ".png"
             
             
         }else if let _ = jpgData {
             data = jpgData!
             ext = ".jpg"
             
         }
         else{
             print("Unsupported file")
             return
         }
         
         metadata.contentType = ext
         
        let postsRef = storage(to: .profile_pics).child(Date().millisecondsSince1970)
         
         let _ = postsRef.putData(data, metadata: metadata) { metadata,error in
             
             if let _ = error {
                 print("upload error",error?.localizedDescription)
                 completion(error,nil)
                 return
             }
             
             guard let metadata = metadata else {
               print("couldnt get metadata")
               completion(error,nil)
               return
             }
             
             postsRef.downloadURL(completion: { downloadURL, error in
                 completion(error,downloadURL?.absoluteString)
             })
             
         }
    }
    
    
    func getAllPosts(userID : String) -> [Post] {

        /*
         Initially get all post ids. Then filter out
         1. your post ids
         2. evaluated post ids
         
         Finally get all posts loaded in the model.
         
         */
        
        
        var posts = [Post]()
        
        
        
        
        return posts
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

extension Date {
    var millisecondsSince1970:String {
        return String(Int64((self.timeIntervalSince1970 * 1000.0).rounded()))
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
