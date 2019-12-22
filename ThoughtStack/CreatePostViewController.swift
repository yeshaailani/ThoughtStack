//
//  CreatePostViewController.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/7/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

// logout didnt work


class CreatePostViewController: UIViewController,UITextFieldDelegate {
    
    var imagePicker: ImagePicker!
    var email:String!
    var spinner = SpinnerViewController()
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var author: UITextField!
    @IBOutlet weak var quote: UITextField!

    var database = Firestore.firestore()
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
         self.imagePicker.present(from: sender)
    }
    
    func alertUser(message : String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func resetForm() {
        ImageView.image = nil
        let tf = [quote,category,author]
        for text in tf {
            text?.text = ""
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
    
    
    @IBAction func createPost(_ sender: Any) {
       
        
        if self.author.text == "" || self.category.text == "" || self.quote.text == "" {
            self.alertUser(message: "Please enter all the fields!")
        }
        else
        {
        
            let creds = Utilities.singleton.load()
            
            if let email = creds?[UserFields.email.rawValue], let userId = creds?[UserFields.userId.rawValue]
            {
            
                self.setUpSpinner()
                let postData : [String:Any] = [
                    PostFields.author.rawValue : author.text!,
                    PostFields.category.rawValue : category.text!,
                    PostFields.quote.rawValue : quote.text!,
                    PostFields.likes.rawValue : [String](),
                    PostFields.ownerId.rawValue : userId
                ]
                
                FirebaseService.shared.addPost(userId: userId, post: postData, optionalImage: ImageView.image, completion: {
                    self.tearDownSpinner()
                    self.showAlertBox(message: "Post Successfully uploaded!")
                    self.resetForm()
                    
                });
            
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        let textFields = [quote,category,author]
        
        for textField in textFields {
            textField?.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.parent?.navigationItem.title = "Create Post"
        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"logout")!, style: .plain, target: self, action: #selector(logout))
        self.parent?.navigationItem.rightBarButtonItem = nil
                  
    }
    
    
    @objc func logout(){
        
        do{
            print("Logging out!")
            try Auth.auth().signOut()
            Utilities.singleton.clearCache() // remove from persistent storage
            self.parent?.dismiss(animated: true, completion: nil)
            
        }catch let error as NSError {
            print("Logout Error",error.localizedRecoverySuggestion)
        }
        
        
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

