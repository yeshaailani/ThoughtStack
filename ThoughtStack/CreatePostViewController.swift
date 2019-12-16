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
        
        var imageConv:String = uploadImageToPost(email: self.email)
        post.author = self.author.text
        post.category = self.category.text
        post.quote = self.quote.text
        let ref = database.collection("Posts")
            ref.addDocument(data: [
            "author": post.author,
            "category": post.category,
            "quote": post.quote,
            "image": imageConv,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ref: \(ref)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        email = UserDefaults.standard.string(forKey: "email")

        // Do any additional setup after loading the view.
    }
    
    func uploadImageToPost(email:String) -> String {

        guard ImageView.image != nil else {
//            self.displayMessage(success: false, message: "Please choose an image")
            print("Please choose an image!")
            return ""
        }
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

