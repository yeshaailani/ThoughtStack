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
    var post = Post()
    var email:String!
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var author: UITextField!
    @IBOutlet weak var quote: UITextField!

    var database = Firestore.firestore()
    
        @IBAction func selectImage(_ sender: UIButton) {
             self.imagePicker.present(from: sender)
        }
    
    @IBAction func createPost(_ sender: Any) {
        var userUid = UserDefaults.standard.string(forKey: "email")
        var imageConv:String = uploadImageToPost(email: self.email)
        
        if self.author.text == "" || self.category.text == "" || self.quote.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter all the fields!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            
        
        
    
        let ref = database.collection("Posts")
            ref.addDocument(data: [
            "pid": "-1",
            "owner":userUid,
            "author": self.author.text,
            "category": self.category.text,
            "quote": self.quote.text,
            "image": imageConv,
            "likesCount": 0
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                let alertController = UIAlertController(title: "Success!", message: "Post Successfully uploaded!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                print("Document added with ref: \(ref)")
            }
        }
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        email = UserDefaults.standard.string(forKey: "email")
    }//end load
    
    func uploadImageToPost(email:String) -> String {

//        guard ImageView.image != nil else {
////            self.displayMessage(success: false, message: "Please choose an image")
//            print("Please choose an image!")
//            return ""
//        }
        guard let image = ImageView.image else {
            return ""
        }

        // convert image to base 64-bit encoding required by server
        let imageConverter = ImageConversion()
        let imageString = imageConverter.ToBase64String(img: image)
        return imageString

    }

}//end class

extension CreatePostViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.ImageView.image = image
    }
}

