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
 
 
 handle blank backend
 
 handle no posts to show for tw and dashb both
    
 make 4 seperate users each with their own set of quotes with and without images (Utilities)

 // dashboard incomplete fields
 
 
 test feed heavily....
 fix the issues with card swipes and overlays
 integrate yeshas work
 refactor

 */

class FirebaseService {
    
    private init(){}
    static let shared =  FirebaseService()
    static let placeHolderUserProfilePic = "https://firebasestorage.googleapis.com/v0/b/thoughtstack-91089.appspot.com/o/profile-pics%2Fplaceholder.jpg?alt=media&token=91b4c2f4-2946-4a08-950c-6c7a708ed996" //changed path of placeholder, was giving error
    
    static let maxImageUploadSize : Int64 = 12 * 1024 * 1024 // max size object 12 MB
    
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
    
    func addUser(params : [String : Any],optionalProfilePic: UIImage? = nil,completion: @escaping () -> ()) {
    
        /*
         Add user and an optional profile pic. If profile pic is not included then a link to
         placeholder image is uploaded to the storage so that some image always shows up for
         the user's profile pic
         */
        
        var user = params
        
        if let image = optionalProfilePic {
            self.uploadProfilePicImage(image: image, completion: { error, downloadURL in
            
                print("Attached profile pic to user!")
                user[UserFields.profilePicImageURL.rawValue] = downloadURL
                
                let userId = self.reference(to: .users).document().documentID
                
                self.reference(to: .users).document(userId).setData(user){ error in
                    if error == nil {
                        completion()
                    }
                }
            
                Utilities.singleton.save(email: user[UserFields.email.rawValue] as! String, userId: userId) // save to persistent storage!
                
            })
        }
        else
        {
            user[UserFields.profilePicImageURL.rawValue] = FirebaseService.placeHolderUserProfilePic
            
            print("User without profile pic!")
            let userId = reference(to: .users).document().documentID
            
            reference(to: .users).document(userId).setData(user){ error in
                
                if error == nil {
                    print("Attached user without a profile pic")
                    completion()
                    Utilities.singleton.save(email: user[UserFields.email.rawValue] as! String, userId: userId)
                }
                
            }
        }
        

    }
    
    func addPost(userId: String,post: [String : Any],optionalImage : UIImage? = nil, completion: @escaping () -> Void){
        
        /*
        Add post and an optional post pic. If post pic is not included, just the remaining section is stored in firestore. If it is included, then the image is stored in firebase storage and its downloadURL is stored in firestore
        */

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
                    completion()
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
            
            completion()
            
            
        }
        
    }
    
    
    // following two methods upload the image to proper destinations and return downloadURLs
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
        
        // Takes downloadURL as input and returns corresponding image as output
        
        Storage.storage().reference(forURL: downloadURL).getData(maxSize: FirebaseService.maxImageUploadSize, completion: { data,error in
            
            if error == nil && data != nil {
                let imageData = data!
//                print("Image downloaded!")
                completion(UIImage(data:imageData),nil)
            }else
            {
                print("Error retrieving the image",error?.localizedDescription ?? "")
                completion(nil,error)
            }
            
            
        })
    
    }
    
    
    fileprivate func getAllPosts(completion : @escaping ([String]?,Error?) -> Void ) {

        /*
         returns every post-id in existence.
         Treats each postid as a seperate post regardless of whether that postId maps to proper post.
         
         
         NOTE: Its important that the data stored on the backend follows the proper predefined schematic as per our app's models, else the app misbehaves
         */
        
        reference(to: .posts).getDocuments(completion: { (querySnapshot, error) in
        if error != nil || querySnapshot == nil {
            print("Error getting documents: \(error?.localizedDescription ?? "")")
            completion(nil,error)
            return
        } else {
            
            var postIds = [String]()
    
            for document in querySnapshot!.documents {
                let profileId = document.documentID
                postIds.append(profileId)
            }
//            print("Total quotes \(postIds.count)")
            completion(postIds,nil)
        }
        })
        
    }
    
    fileprivate func getPostByIds(postIds: [String], completion : @escaping([Post]?,Error?) -> Void){
        
        // takes a list of post-ids, converts it into post models and attaches images if any to it.
        
        var posts = [Post]()
        let postDispatchGroup = DispatchGroup()
        
        for postId in postIds {
            
            postDispatchGroup.enter()
            
            reference(to: .posts).document(postId).getDocument(completion: {post,error in
    
                if error == nil && post != nil {
                    
                    
                    if post!.data() == nil {
                        // something didnt match up on the backend, so ignore the post
                        return
                    }
                    
                    if let data = post!.data() {
                        var currentPost = Post(parameters: data)
                        currentPost.postID = postId // this line is critical dont touch
                        
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
                            print("Return image qa: \(currentPost.author) count:\(posts.count)")
                            postDispatchGroup.leave()
                            
                        })
                            
                        }
                        else {
                            posts.append(currentPost)
                            print("Return nonimage qa: \(currentPost.author) count:\(posts.count)")
                        }
                        
                    }
                    
                    
                }
                
            postDispatchGroup.leave()
                
            })
            
        }
        
        postDispatchGroup.notify(queue: .main) {
            print("Reached notify group with \(posts.count)")
            if (posts.count == postIds.count) // potential for bugs here if backend has lots of false posts (postids that dont represent actual posts)
            {
                print("Post retrieval with images complete! count:\(posts.count)")
                completion(posts,nil)
                return
            }
        
        }
                                        
        print("All non image quotes done!")

      
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
            let nickName = data?[UserFields.nickName.rawValue] as? String ?? "(user-deleted)"
            
            let downloadURL = data?[UserFields.profilePicImageURL.rawValue] as? String ??
            FirebaseService.placeHolderUserProfilePic
            
            self.downloadImage(downloadURL: downloadURL, completion: { image,error in
                
                if image == nil || error != nil {
                    print("error couldnt get profile info for post model",error?.localizedDescription ?? "")
                    completion(nil,nil,error)
                }
                
//                print("Returning username \(nickName) and profilePicImageNull \( (image?.size ?? CGSize.zero) == CGSize.zero)")
                completion(nickName,image,nil)
            })
        })
        
    }
    
    func getCurrentUser(userId:String,completion: @escaping (User?,Error?) -> Void ){
        // return user model from userId
        
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
                print("User \(currentUser.nickName) found with ppic as:\(currentUser.profilePicImageURL?.count ?? 0 > 0)")
                
                completion(currentUser,nil)
            }
        
        }
        
    }
    
    func userLikedPost(userId:String, postId:String){
        /*
         Take foll steps on right swipe for post:
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
         On left swipe for post
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
         when user taps undo:
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
                    print("Error adding post to likes/eval posts!",error?.localizedDescription ?? "")
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
        
    }
        
    func getUsersDashboard(userId : String, completion: @escaping ([Post]?,Error?)-> Void) {
        /*
         When user taps dashboard tab:
         1. get current user
         2. get all postids from his self Posts
         3. get post model from those ids and attach image to each post model
         4. attach current user's profile pic and username to each post model
         
         */
        
        
        self.getCurrentUser(userId: userId, completion: {user,error in
            
            if error == nil && user != nil {
                
                let currentUser = user!
                
                if currentUser.selfPosts.count > 0
                {
                    self.getPostByIds(postIds: currentUser.selfPosts, completion: { posts, error in
                        
                        self.downloadImage(downloadURL: user?.profilePicImageURL ?? FirebaseService.placeHolderUserProfilePic, completion: {profilePic,error in
                        
                            let commonProfilePic = profilePic ?? UIImage(named:"user-filled")!
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
         
        Initially get all post ids. Then filter out
        1. post ids present in selfPosts of user model
        2. post ids present in evaluatedPosts of user model
        3. post ids previously liked
        
        For the remaining post ids, attach images and then return

        */
        
        self.getAllPosts(completion: { posts,error in

            self.getCurrentUser(userId: userId, completion: { user,error in
                
                if error != nil || user == nil || posts == nil {
                    print("Couldnt get post/user",error?.localizedDescription)
                    completion(nil,error)
                    return
                }
                
                print("All \(posts?.count) UE: \(user!.evaluatedPosts.count) US: \(user!.selfPosts.count)")
                
                let feedPostIds = posts!.filter{ currentPost in
                    if user!.evaluatedPosts.contains(currentPost) || user!.selfPosts.contains(currentPost) || user!.likes.contains(currentPost){
                        return false // remove all quotes u have seen/created/liked
                    }
                    return true
                }
                
                print("Remaining: \(feedPostIds.count)")
                
                self.getPostByIds(postIds: feedPostIds, completion: { posts, error in
                    
                    if error != nil || posts == nil {
                        print("error retrieving feed")
                        return
                    }
                    
                    let feedPosts = posts!
    
                    let imageDispatchGroup = DispatchGroup()
                    
                    for post in feedPosts {
                    
                        imageDispatchGroup.enter()
                        
                        self.getPostOwners(userId: post.ownerID, completion: {
                            nickName,profilePic,error in
                            
                            if error != nil {
                                return
                            }
                            
                            post.postOwnerUserName = nickName!
                            post.postOwnerProfilePic = profilePic
                            imageDispatchGroup.leave()
                        })
                        
                    }
                    
                    
                    imageDispatchGroup.notify(queue: .main){
                        if (posts!.count == feedPosts.count)
                        {
                            print("All settled. Profile pics attached! \(feedPosts.count)")
                        completion(posts,nil)
                        return
                        }
                    }
                    
                })
                

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
    
    
    // following methods return count for dashboard / feed / thoughtwallet to keep track of incoming new posts and when its appropriate to call get methods for each
    
    func getDashboardPostCount(userId:String, completion: @escaping (Int?,Error?)-> Void){
        reference(to: .users).document(userId).getDocument(completion: { snapshot,error in
            
            print("User id: \(userId)")
            // address empty dashboard
            
            if error == nil {
                
                
                if snapshot == nil || snapshot?.data() == nil {
                    print("Either user hasnt posted anything or the field doesnt exist")
                    completion(0,nil)
                    return
                }
                
                let selfPostJSON = snapshot!.data()!
                let selfPosts = selfPostJSON[UserFields.selfPosts.rawValue] as? [String]
                
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
                
                if snapshot == nil || snapshot!.data() == nil {
                    // error handling
                    print("TW either has zero posts or the field doesnt exist on backend")
                    completion(0,nil)
                    return
                }
                
                let selfPosts = snapshot!.data()![UserFields.likes.rawValue] as? [String]
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
    
    func getTotalPostCount(completion: @escaping (Int?,Error?)->Void){
        reference(to: .posts).getDocuments(completion: { snapshot,error in
            
            if error != nil {
                print("Couldnt get total post count!")
                completion(nil,error)
                return
            }
            
            if snapshot == nil || snapshot?.documents == nil {
                // error handling
                print("Zero posts altogether")
                completion(0,nil)
                return
            }
        
            let postCount = snapshot?.documents.count ?? 0
            print("Total posts on server \(postCount)")
            completion(postCount,nil)
        })
    }
    
    // get userId corresponding to email to store in persistent storage
    func getUserIDFromEmail(email:String,completion : @escaping (String?,Error?) -> Void){
        reference(to: .users).whereField(UserFields.email.rawValue, isEqualTo:email).getDocuments(completion:
            { (snapshot,error) in
                
                if error != nil {
                    print("Error retrieving user!",error?.localizedDescription)
                    completion(nil,error)
                    return
                }
                for document in snapshot!.documents {
                    
                    let userId = document.documentID
                    print("Found user for \(email)!")
                    completion(userId,nil)
                    return
                    
                }
                
                print("No user found for \(email)") // use these to check for uniqueness
                completion(nil,nil)
                               
            
        })
        }
    
    func checkNickNameUniqueNess(nickName:String,completion: @escaping (Bool?,Error?) -> Void){
        
        reference(to: .users).whereField(UserFields.nickName.rawValue, isEqualTo: nickName).getDocuments(completion: { snapshot,error in
            
            if error != nil {
                print("error getting nickname",error?.localizedDescription)
                completion(nil,error)
                return
            }
            
            
            let userCount = snapshot?.documents.count ?? 0
            
            if userCount == 0 {
             print("Nickname is unique")
             completion(true,nil)
             return
            }
             print("Not a unique nickname")
            completion(false,nil)
            return
                    
        });
        
        
    }

}
extension Date {
    var millisecondsSince1970:String {
        return String(Int64((self.timeIntervalSince1970 * 1000.0).rounded()))
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
