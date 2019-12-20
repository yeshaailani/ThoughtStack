import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCore

/*
use merge:true for updating existing documents to reflect current data
*/
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
        
}

class Post {
    
    var postID : Int?
    let quote : String
    let author : String
    var category : String
    let imageURL : String?
    let ownerID : String
    var numLikes : Int // this is an array on the backend, which can be changed on client side to show all users that liked a certain post
    
    // for convenience these two are in the model, this isnt reflected on backend
    var image : UIImage?
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

class MockFirebase {
    
    private init(){self.configure()}
    static let shared =  MockFirebase()
    
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
    
    
    func getAllPosts(userId : String, completion: @escaping (Error?,[Post]?) -> Void) {

        
        reference(to:.posts).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                
        }
        
        
        /*
         Initially get all post ids. Then filter out
         1. your post ids
         2. evaluated post ids
         

         Finally get all posts loaded in the model.
         */
        
        
        
        
        
        
    }
    
    func userLikedPost(userId:String, postId:String){
        /*
         
         add post id to list of user's liked posts
         add post id to user's evaluated posts
         
         add user id to list of post's likes
         
         */
        
    }
    
    
    func userDislikedPost(userId:String, postId: String){
        /*
         add postID to user's list of evaluated posts
         */
    }
    
    
    func userHitUndo(userId:String,postId: String){
        /*
         remove postid from user's evaluated posts
         
         
         check if user liked that post before?
         
         if no, return
         if yes, remove post id from users likes
         and remove user id from posts likes
         
         */
    }
    
    func getUsersPosts(userId : String) -> [Post] {
        
        /*
        get all posts whose owner is userId
         */
        
        var posts = [Post]()
        return posts
    }
    
    func getUsersThoughtWallet(userId:String) -> [Post]{
        
        /*
         get all posts whose postids match those present in likes array
         */
        
        var posts = [Post]()
        return posts
    }
    
    
    func deletePost(userId:Post, postID:Post){
        /*
         remove a post from current users
         */
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
    
}
let userId = "oG7weadM3FHXhb9XyJBC"



