//
//  CreatePostViewController.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/7/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CreatePostViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    var email:String!
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var author: UITextField!
    @IBOutlet weak var quote: UITextField!

    var database = Firestore.firestore()
    
    @IBAction func selectImage(_ sender: UIButton) {
         self.imagePicker.present(from: sender)
    }
    
    func alertUser(message : String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func createPost(_ sender: Any) {
       
        
        if self.author.text == "" || self.category.text == "" || self.quote.text == "" {
            self.alertUser(message: "Please enter all the fields!")
        }
        else
        {
        
            let creds = Utilities.singleton.load()
            
            if let email = creds?[UserFields.email.rawValue], let userId = creds?[UserFields.userId.rawValue]
            {
            
                let postData : [String:Any] = [
                    PostFields.author.rawValue : author.text!,
                    PostFields.category.rawValue : category.text!,
                    PostFields.quote.rawValue : quote.text!,
                    PostFields.likes.rawValue : [String](),
                    PostFields.ownerId.rawValue : userId
                ]
                
                FirebaseService.shared.addPost(userId: userId, post: postData, optionalImage: ImageView.image, completion: {
                    self.showAlertBox(message: "Post Successfully uploaded!")
                });
            
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
    }
    
    
    func showAlertBox(message:String)
    {
        let alertController = UIAlertController(title: "Success!", message:message , preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
       
    }

}//end class

extension CreatePostViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.ImageView.image = image
    }
}

