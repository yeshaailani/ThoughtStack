//
//  SignUpViewController.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    var imagePicker: ImagePicker!
    
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
   
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBAction func directToLogin(_ sender: Any) {
    }
    @IBAction func selectProfilePicture(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
 
    var database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
    }// end load
    
    @IBAction func signup(_ sender: Any) {
        
        if email.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            var imageConv:String = uploadImageToPost(email: self.email.text!)
//            var userUid = UserDefaults.standard.string(forKey: "uid")
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                var message = ""
                if error == nil {
                    print("You have successfully signed up")
                    message = "You have successfully signed up!"
                    
                    let ref = self.database.collection("Users")

                    ref.addDocument(data: [
                        
                        "email": self.email.text,
                        "name": self.name.text,
                        "username": self.username.text,
                        "profilePic": imageConv,
                        "eval": [],
                        "likes": []

                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ref: \(ref)")
//                            var a = ref.document().documentID
//                            print(a)
                            
                        }
                    }
//                    var firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
//                    var userRef: DocumentReference = firestore.collection("Users").document({user_id})
//                    var uid = ref.document().documentID
//                    print(userRef)
                    
                } else {
                  message = "There was an error."
                }

                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true)
            }
        }
    }
    
    func uploadImageToPost(email:String) -> String {

//        guard profilePicture.image != nil else {
//            //            self.displayMessage(success: false, message: "Please choose an image")
//            print("Please choose an image!")
//            return ""
//        }
        guard let image = profilePicture.image else {
            return ""
        }

        // convert image to base 64-bit encoding required by server
        let imageConverter = ImageConversion()
        let imageString = imageConverter.ToBase64String(img: image)
        return imageString

    }

    

}//end class


extension SignUpViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.profilePicture.image = image
    }
}

