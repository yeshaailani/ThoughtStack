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
    
    //@IBOutlet weak var profilePicture: UIImageView?
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
   
    var database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()


    }// end load
    
    @IBAction func signup(_ sender: Any) {
        if email.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
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
                        "profilePic": "-1",
                        
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
    

}//end class
