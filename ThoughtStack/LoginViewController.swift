//
//  ViewController.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoredirect()
        self.autofill()
        
        let fields = [email,password]
        
        for field in fields {
            field?.delegate = self
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func autofill(){
        self.email.text = "abhi@gmail.com"
        self.password.text = "123456"
    }
    
    
    func autoredirect(){
        
        if let creds = Utilities.singleton.load() {
            
            if let email = creds[UserFields.email.rawValue], let userId = creds[UserFields.userId.rawValue] {
                
                self.redirect()
            }
            
        }
        
    }
    
    func redirect(){
        self.present(UINavigationController(rootViewController: TabBar()), animated: true)
    }
    
    
    @IBAction func login(_ sender: Any) {
        
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { user,error in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    FirebaseService.shared.getUserIDFromEmail(email: self.email.text!, completion: { userId, error in
                        
                        if error == nil && userId != nil {
                            print("Saving to persistent storage!")
                            Utilities.singleton.save(email: self.email.text!, userId: userId!)
                            self.redirect()
                        }
                    })
                    
                    print("logged in :)")
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: "Auth error:Couldnt login", preferredStyle: .alert)
                    
                    print("Auth error",error?.localizedDescription)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}// end class

