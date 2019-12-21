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



/*
 
 TODO:
 
 
 load username and profile pic of every user when u are showing his post.
 test feed heavily....
 fix the issues with card swipes and overlays
 integrate yeshas work
 refactor
 
 
 handle empty dashboard,feed,thoughtwallet
 

 */

class FirebaseService {
    
    private init(){}
    static let shared =  FirebaseService()
    static let placeHolderUserProfilePic = "https://firebasestorage.googleapis.com/v0/b/thoughtstackswift-a8167.appspot.com/o/profile-pics%2Fplaceholder.jpg?alt=media&token=40e85e25-48a7-4849-b680-4a972a8940c7"
    
    static let maxImageUploadSize : Int64 = 2 * 1024 * 1024 // 2 MB
    
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
    
    func addUser(params : [String : Any],optionalProfilePic: UIImage? = nil) {
    
        /*
        let params : [String : Any] = [
            UserFields.name.rawValue : "abhi",
            UserFields.email.rawValue : "abc@gm.com",
            UserFields.nickName.rawValue : "abc15",
            UserFields.profilePicImageURL.rawValue : -1,
            UserFields.evaluatedPosts.rawValue : [String](),
            UserFields.likes.rawValue : [String](),
            UserFields.selfPosts.rawValue : [String]()
        ];
        */
        var user = params
        
        
        if let image = optionalProfilePic {
            self.uploadProfilePicImage(image: image, completion: { error, downloadURL in
            
                print("Attached profile pic to user!")
                user[UserFields.profilePicImageURL.rawValue] = downloadURL
                self.reference(to: .users).addDocument(data: user)
            })
        }
        else
        {
            user[UserFields.profilePicImageURL.rawValue] = FirebaseService.placeHolderUserProfilePic
            
            print("Adding user without a profile pic")
            reference(to: .users).addDocument(data: user)
        }
        

    }
    
    func addPost(userId: String,post: [String : Any],optionalImage : UIImage? = nil){
        
        var data = post
        
        data[PostFields.timeStamp.rawValue] = Date().millisecondsSince1970 // added for sort by recent
        
        if let image = optionalImage {
            self.uploadPostImage(image: image, completion: {error,downloadURL in
                
                if let _ = error {
                    print("Upload post error" + (error?.localizedDescription ?? ""))
                    return
                }
                
                print("Attaching image to quote")
                
                if downloadURL != nil
                {
                    data[PostFields.imageURL.rawValue] = downloadURL
            
                    let newPostId = self.reference(to: .posts).document().documentID
                    
                    self.reference(to: .posts).document(newPostId).setData(data)
                    
                    self.reference(to: .users).document(userId).updateData([
                        UserFields.selfPosts.rawValue : FieldValue.arrayUnion([newPostId])
                    ])
                
                    print("Added post with an image! \(String(describing: downloadURL))")
                }
                
            })
        }else
        {
            print("Added post without any image!")

            let newPostId = self.reference(to: .posts).document().documentID
            self.reference(to: .posts).document(newPostId).setData(data)
            self.reference(to: .users).document(userId).updateData([
                UserFields.selfPosts.rawValue : FieldValue.arrayUnion([newPostId])
            ])
        }
        
    }
    
    private func uploadPostImage(image: UIImage, completion: @escaping (Error?,String?) -> Void){
        
        
       let pngData = image.pngData() // get pngdata
       let jpgData = image.jpegData(compressionQuality: 0.2) // get jpgdata
       let data : Data
       let ext : String
        
        let metadata = StorageMetadata()
        
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
                print("upload error",error?.localizedDescription ?? "")
                completion(error,nil)
                return
            }
            
            guard metadata != nil else {
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
         
        let metadata = StorageMetadata()
         
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
                 print("upload error",error?.localizedDescription ?? "")
                 completion(error,nil)
                 return
             }
             
            guard metadata != nil else {
               print("couldnt get metadata")
               completion(error,nil)
               return
             }
             
             postsRef.downloadURL(completion: { downloadURL, error in
                 completion(error,downloadURL?.absoluteString)
             })
             
         }
    }
    
    private func downloadImage(downloadURL : String, completion: @escaping (UIImage?,Error?)->Void){
        
        Storage.storage().reference(forURL: downloadURL).getData(maxSize: FirebaseService.maxImageUploadSize, completion: { data,error in
            
            if error == nil && data != nil {
                let imageData = data!
                print("Profile pic retrieved!")
                completion(UIImage(data:imageData),nil)
            }else
            {
                print("Error retrieving the image",error?.localizedDescription ?? "")
                completion(nil,error)
            }
            
            
        })
    
    }
    
    
    fileprivate func getAllPosts(userId : String, completion : @escaping ([Post]?,Error?) -> Void ) {

        /*
         returns every post in existence (minus their images if any)
         */
        
        reference(to: .posts).getDocuments(completion: { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
            completion(nil,nil)
        } else {
            
            var posts = [Post]()
            
            for document in querySnapshot!.documents {
                let data = document.data()
                
                let post = Post(parameters: data) // see if it maps properly and find some way to attach postId
                post.postID = document.documentID
                posts.append(post)
            }
            print("Total quotes \(posts.count)")
            completion(posts,nil)
        }
        })
        
    }
    
    
    fileprivate func getPostByIds(postIds: [String], completion : @escaping([Post]?,Error?) -> Void){
        
        var posts = [Post]()
        let postDispatchGroup = DispatchGroup()
        
        for postId in postIds {
            
            reference(to: .posts).document(postId).getDocument(completion: {post,error in
               
                if error == nil && post != nil {
                    
                    let currentPost = Post(parameters: post?.data() ?? [String:Any]()) // fix later
                    
                    print("found qa:\(currentPost.author)")
                    
                    if currentPost.imageURL != nil {
                        
                    postDispatchGroup.enter()
                        
                        self.downloadImage(downloadURL: currentPost.imageURL!, completion: {
                            image,error in
                            
                            if error != nil && image == nil {
                                print("error downloading image")
                                completion(nil,error)
                                return
                            }
                            currentPost.image = image!
                            posts.append(currentPost)
                            postDispatchGroup.leave()
                            
                        })
                        
                    }
                    else {
                        posts.append(currentPost)
                        print("got quote without image")
                    }
                    
                    postDispatchGroup.notify(queue: .main) {
                        print("Post retrieval with images complete! count:\(posts.count)")
                        completion(posts,nil)
                    }
                     
        
                }
                // TODO: handle errors later
            })
            
        }
        
        print("Non image quotes done")
        
        
        
        
    }
    
    fileprivate func getPostOwners(userId: String, completion: @escaping (String?,UIImage?,Error?)->Void ){
        // this function returns username, profilepic of a given userid to be attached to the post model so it can be displayed in one go.
        
        
        reference(to: .users).document(userId).getDocument(completion: { snap,error in
            
            if error != nil || snap == nil {
                print("error couldnt get profile info for post model",error?.localizedDescription ?? "")
                completion(nil,nil,error)
                return
            }
            
            let data = snap!.data()
            let nickName = data?[UserFields.nickName.rawValue] as? String ?? UserFields.nickName.rawValue
            
            let downloadURL = data?[UserFields.profilePicImageURL.rawValue] as? String ??
            FirebaseService.placeHolderUserProfilePic
            
            
            self.downloadImage(downloadURL: downloadURL, completion: { image,error in
                
                if image == nil || error != nil {
                    print("error couldnt get profile info for post model",error?.localizedDescription ?? "")
                    completion(nil,nil,error)
                }
                
                print("Returning username and profilePicImage info")
                completion(nickName,image,nil)
            })
            
            
            
        })
        
        
    }
    
    func getCurrentUser(userId:String,completion: @escaping (User?,Error?) -> Void ){
        
        reference(to: .users).document(userId).getDocument{ snapshot,error in
        
            if error != nil || snapshot == nil {
                print("error getting user",error?.localizedDescription ?? "")
                completion(nil,error)
                return
            }
            
            else {
                
                let data = snapshot?.data()
                
                if data == nil {
                    print("error getting user")
                    completion(nil,nil)
                    return
                }
                
                let currentUser = User(parameters: data!)
                print("User \(currentUser.name) found!")
                completion(currentUser,nil)
            }
        
        }
        
    }
    
    func userLikedPost(userId:String, postId:String){
        /*
         
         add post id to list of user's liked posts
         add post id to user's evaluated posts
         add user id to list of post's likes
         
         */
        
        reference(to: .users).document(userId).updateData([
            UserFields.evaluatedPosts.rawValue : FieldValue.arrayUnion([postId]),
            UserFields.likes.rawValue : FieldValue.arrayUnion([postId]),
            ],completion: { error in
                
                if error != nil {
                    print("Error adding post to likes/eval posts!")
                    return
                }
                
                print("User liked and evaluated post!")
                
                self.reference(to: .posts).document(postId).updateData([
                    PostFields.likes.rawValue : FieldValue.arrayUnion([userId])
                    ], completion: { error in
                        
                        if error != nil {
                            print("Error adding user id to post likes")
                            return
                        }
                        print("Post likes updated!")
                })
        })
            
    }
    
    func userDislikedPost(userId:String, postId: String){
        /*
         add postID to user's list of evaluated posts
         */
        reference(to: .users).document(userId).updateData([
            UserFields.evaluatedPosts.rawValue : FieldValue.arrayUnion([postId]),
            ],completion: { error in
                
                if error != nil {
                    print("Error adding post to eval posts!")
                    return
                }
                
                print("User evaluated post!")
                
        })
    }
    
    func userHitUndo(userId:String,postId: String){
        /*
         remove postid from user's evaluated posts
         check if user liked that post before?
         
         if no, return
         if yes, remove post id from users likes
         and remove user id from posts likes
         */
        
        
        reference(to: .users).document(userId).updateData([
            UserFields.evaluatedPosts.rawValue : FieldValue.arrayRemove([postId]),
            ],completion: { error in
                
                if error != nil {
                    print("Error adding post to likes/eval posts!",error?.localizedDescription)
                    return
                }

                print("User undid his choice")
        })
        
        
        reference(to: .users).document(userId).getDocument(completion: { snapshot,error in
            
            if error != nil || snapshot == nil{
                print("cant have user!",error?.localizedDescription)
                return
            }
            
            let user = User(parameters: snapshot!.data() ?? [String:Any]()) // ensure backend doesnt have any invalid values
            
            if user.likes.contains(postId) {
                self.reference(to: .users).document(userId).updateData([
                    UserFields.likes.rawValue : FieldValue.arrayRemove([postId])
                ])
                
                self.reference(to: .posts).document(postId).updateData([PostFields.likes.rawValue:FieldValue.arrayRemove([userId])])
            }
        })
        
    } // Issues with this
        
    func getUsersDashboard(userId : String, completion: @escaping ([Post]?,Error?)-> Void) {
        /*
         1. get current user
         2. get all posts from his self Posts
         3. attach post image to each post model
         4. attach profile pic and username to each post model
         
         */
        
        
        self.getCurrentUser(userId: userId, completion: {user,error in
            
            if error == nil && user != nil {
                
                let currentUser = user!
                
                if currentUser.selfPosts.count > 0
                {
                    self.getPostByIds(postIds: currentUser.selfPosts, completion: { posts, error in
                        
                        self.downloadImage(downloadURL: user?.profilePicImageURL ?? FirebaseService.placeHolderUserProfilePic, completion: {profilePic,error in
                        
                            let commonProfilePic = profilePic!
                            let commonUserName = user?.nickName
                            
                            for post in posts! {
                                post.postOwnerUserName = commonUserName
                                post.postOwnerProfilePic = commonProfilePic
                            }
                            
                            completion(posts,nil)
                            
                        })
                        
                        
                    })
                }else
                {
                    completion([Post](),nil) // empty wallet
                }
                
            }else
            {
                print("couldnt get thoughtwallet")
                completion(nil,error)
            }
            
            
        })
        
    }

    func getUserFeed(userId : String, completion: @escaping ([Post]?,Error?)-> Void){
        /*
         
         TESTING REQUIRED!
         
        Initially get all post ids. Then filter out
        1. post ids present in selfPosts of user model
        2. post ids present in evaluatedPosts of user model
        
        For the post ids u currently have, attach images and then return

        */
        
        self.getAllPosts(userId: userId, completion: { posts,error in
            print("Got all quotes \(posts!.count)")
            self.getCurrentUser(userId: userId, completion: { user,error in
                
                if error != nil || user == nil || posts == nil {
                    print("Couldnt get post/user")
                    completion(nil,error)
                    return
                }
                
                let feedPosts = posts!.filter{ currentPost in
                    if user!.evaluatedPosts.contains(currentPost.postID) || user!.selfPosts.contains(currentPost.postID){
                        return false // remove all quotes u have seen/created
                    }
                    return true
                }
                
                
                print("Got feed quotes \(feedPosts.count)")
                
                let imageDispatchGroup = DispatchGroup() // REFACTOR ATTACHING IMAGES TO SEPERATE METHOD
                let storage = Storage.storage()
                    
                    
                    for post in feedPosts {
                                          
                            if post.imageURL == nil {
                                continue // no image for current post
                            }
                            
                        imageDispatchGroup.enter()
                   
                        storage.reference(forURL:post.imageURL!).getData(maxSize: 2*1024*1024, completion: {
                                data,error in
                                
                                if error != nil || data == nil {
                                    print("error attaching image to post",error?.localizedDescription ?? "")
                                    return
                                }
                                
                                print("Attached image for post with author \(post.author)")
                                post.image = UIImage(data:data!)
                            print("image of size \(post.image?.size) loaded")
                                imageDispatchGroup.leave()
                            })
                        
                        }
                    
                    imageDispatchGroup.notify(queue: .main){
                        print("Image retrieval complete!")
                        completion(feedPosts,nil)
                    }
            })
            
            
        })
    }
    
    func getUsersThoughtWallet(userId : String, completion: @escaping ([Post]?,Error?)-> Void) {
        
        /*
         get all posts that current user has liked
        */
    
        self.getCurrentUser(userId: userId, completion: {user,error in
            
            if error == nil && user != nil {
                
                let currentUser = user!
                
                if currentUser.likes.count > 0
                {
                    self.getPostByIds(postIds: currentUser.likes, completion: { posts, error in
                    
                        
                        if error != nil || posts == nil {
                            // error handling here
                            
                            completion(nil,error)
                            return
                        }
                        
                        let postDispatchGroup = DispatchGroup()
                        
                        for post in posts! {
                            
                            postDispatchGroup.enter()
                            self.getPostOwners(userId: post.ownerID, completion: { nickName,profilePic,error in
                                
                                if error != nil || nickName == nil || profilePic == nil {
                                    print("error with post owners")
                                    return
                                }
                                
                                post.postOwnerUserName = nickName
                                post.postOwnerProfilePic = profilePic
                                postDispatchGroup.leave()
                                
                            })
                        
                        }
                        
                        postDispatchGroup.notify(queue: .main){
                            print("Got all posts alongwith their owners!")
                            completion(posts,nil)
                        }
                        
                        
                        
                    })
                }else
                {
                    completion([Post](),nil) // empty wallet
                }
                
            }else
            {
                print("couldnt get thoughtwallet")
                completion(nil,error)
            }
            
            
        })
        
        
        
    }
    
    func deletePost(userId:String, postID:Post){
        /*
         remove a post from current users
         */
    }
    
    func getDashboardPostCount(userId:String, completion: @escaping (Int?,Error?)-> Void){
        reference(to: .users).document(userId).getDocument(completion: { snapshot,error in
            
            
            if error == nil {
                
                let selfPosts = snapshot?.data()![UserFields.selfPosts.rawValue] as? [String]
                let postCount = selfPosts?.count ?? 0
                print("Currently dashboard has \(postCount) posts")
                completion(postCount,nil)
                return
                
            }else
            {
                print("Error: Couldnt get post count dashboard",error?.localizedDescription)
                completion(nil,error)
            }
            
        })
    }
    
    func getThoughtWalletPostCount(userId:String, completion: @escaping (Int?,Error?)-> Void){
        reference(to: .users).document(userId).getDocument(completion: { snapshot,error in
            
            if error == nil {
                let selfPosts = snapshot?.data()![UserFields.likes.rawValue] as? [String]
                let postCount = selfPosts?.count ?? 0
                print("Currently thoughtwallet has \(postCount) posts")
                completion(postCount,nil)
                return
                
            }else
            {
                print("Error: Couldnt get post count dashboard",error?.localizedDescription)
                completion(nil,error)
            }
            
        })
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
