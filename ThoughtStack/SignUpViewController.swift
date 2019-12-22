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

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    var imagePicker: ImagePicker!
    var spinner = SpinnerViewController()
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword : UITextField!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    @IBAction func directToLogin(_ sender: Any) {
    }
    @IBAction func selectProfilePicture(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func autoredirect(){
     
        if let creds = Utilities.singleton.load() {
            
            print("E: \(creds[UserFields.email.rawValue]) U:\(creds[UserFields.userId.rawValue]) ")
            
            if let email = creds[UserFields.email.rawValue], let userId = creds[UserFields.userId.rawValue] {
                self.redirect()
            }
            
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoredirect()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.autoFill()
        
        let fields = [
        name,
        username,
        email,
        password,
        confirmPassword
        ]
        
        for field in fields {
            field?.delegate = self
        }
        
    }// end load
    
    func autoFill(){
        name.text = "Abhijeet"
        username.text = "prabhu" + "99199"
        password.text = "123456"
        confirmPassword.text = "123456"
        email.text = username.text!  + "@gmail.com"
        profilePicture.image = nil
    }
    
    func validateFields() -> String? {
        
        var message : String?
        
        let fields = [
        name,
        username,
        email,
        password,
        confirmPassword
        ]
        
        
        
        for field in fields {
            if field?.text == "" {
                return "Please enter all fields"
            }
        }
        
        if password.text?.count ?? 0 < 6 {
            return "Minimum password size: 6 characters"
        }
        
        if password.text != confirmPassword.text {
            return "Passwords dont match"
        }
        
        
        return nil

    }
    
    func alertUser(message : String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func signup(_ sender: Any) {
        
        print("Attempting signup!")
        
        if let message = self.validateFields() {
            self.alertUser(message: message)
            
        } else {
            
            // check username and email uniqueness
            FirebaseService.shared.checkNickNameUniqueNess(nickName: username.text!, completion: {result,error in
                
                
                if error != nil || result == nil {
                    print("Couldnt check nickname",error?.localizedDescription)
                    return
                }
                
                if result! == false
                {
                    self.alertUser(message: "Please pick a unique nickname. That one is taken.")
                }else
                {
                    
                    FirebaseService.shared.getUserIDFromEmail(email: self.email.text!, completion: {
                        userId,error in
                        
                        if error != nil {
                                           print("Couldnt check email",error?.localizedDescription)
                                           return
                        }else if userId != nil {
                            
                            self.alertUser(message: "Please pick a different email. That one is taken.")
                        }else
                        {
                            print("Email,nickname are both unique. Signing up user!")
                            self.signUpUser()
                        }
                        

                    })
                    
                    
                    
                }
                
                
            })
            
        }
    }

    func signUpUser(){
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            if error == nil {
                    
               
                let currentUser : [String:Any] = [
                    UserFields.email.rawValue: self.email.text,
                    UserFields.name.rawValue: self.name.text,
                    UserFields.nickName.rawValue: self.username.text,
                    UserFields.selfPosts.rawValue : [String](),
                    UserFields.evaluatedPosts.rawValue: [String](),
                    UserFields.likes.rawValue: [String]()
                    ]
                
                FirebaseService.shared.addUser(params: currentUser,optionalProfilePic: self.profilePicture.image,completion : {
                    
                    self.setUpSpinner()
                    print("You have successfully signed up. Signing in current user...")
                    self.signInUser()
                })
                
                
                
            } else {

                let err = "Firebase Auth error"
                print(err,error?.localizedDescription)
                self.alertUser(message: "Couldnt login. Firebase Auth Error!")
            }

        }
    }
    func tearDownSpinner(){
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
    func setUpSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func redirect(){
//           let nav = UINavigationController(rootViewController: TabBar())
//           nav.modalPresentationStyle = .overFullScreen
//            self.parent?.present(nav, animated: true, completion: nil)
        self.present(UINavigationController(rootViewController: TabBar()), animated: true)
   }
    
    func signInUser(){
        
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { user,error in
            
            if error == nil {
                
                //Print into the console if successfully logged in
                print("You have successfully logged in")
                
                            
                //Go to the HomeViewController if the login is sucessful
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostViewController")
//
//                self.present(vc!, animated: true, completion: nil)
                
                self.redirect()
//                self.navigationController?.pushViewController(CreatePostViewController(), animated: true)
//
                print("logged in :)")
                
            } else {
                
                //Tells the user that there is an error and then gets firebase to tell them the error
                print("Auth error",error?.localizedDescription)
                self.alertUser(message: "Couldnt login! Reason: Auth error")
            }
            
            self.tearDownSpinner()
        }
        
        
    }
    
    

}//end class


extension SignUpViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.profilePicture.image = image
    }
}

