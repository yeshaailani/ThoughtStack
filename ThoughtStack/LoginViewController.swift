//
//  ViewController.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/6/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoredirect()
        self.autofill()
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
        let nav = UINavigationController(rootViewController: TabBar())
        nav.modalPresentationStyle = .overFullScreen
        self.parent?.present(nav, animated: true, completion: nil)
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
                        }
                        
                        
                    })
                    
                    //Go to the HomeViewController if the login is sucessful
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreatePostViewController")
//                    self.present(vc!, animated: true, completion: nil)
                    
                    self.present(UINavigationController(rootViewController: TabBar()), animated: true)
                    
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
    
    
//    @IBAction func logOutAction(sender: AnyObject) {
//        if FIRAuth.auth()?.currentUser != nil {
//            do {
//                try FIRAuth.auth()?.signOut()
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
//                present(vc, animated: true, completion: nil)
//
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        }
//    }



}// end class

