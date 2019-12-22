//
//  CreatePost.swift
//  ThoughtStack
//
//  Created by Vegeta on 12/22/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import UIKit
import TinyConstraints


class CreatePost: UIViewController {
    
    
    
    var optionalImageView = UIImageView()
    
    var quote : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Please enter quote"
        textfield.backgroundColor = .lightGray
        textfield.layer.borderWidth = 0.7
        textfield.layer.borderColor = UIColor.black.cgColor
        return textfield
    }()
    var author : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Please enter author name"
        textfield.backgroundColor = .lightGray
        textfield.layer.borderWidth = 0.7
        textfield.layer.borderColor = UIColor.black.cgColor

        return textfield
    }()
    
    var category : UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Please enter category"
        textfield.backgroundColor = .lightGray
        textfield.layer.borderWidth = 0.7
        textfield.layer.borderColor = UIColor.black.cgColor

        return textfield
    }()// change to dropdown later
    
    var attachButton : UIButton = {
        let button = UIButton()
        button.setTitle("Attach Image",for:.normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        return button
    }()
    
    var containerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var createButton : UIButton = {
        let button = UIButton()
        button.setTitle("Create Post",for:.normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .purple
        return button
    }()
    
    var padding = UIView()
    
    let userId : String
    
    
    init(userId : String){
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.navigationController?.title = "Create Post"
    }
    
    func setupViews(){
    
      let views = [containerView,optionalImageView,quote,author,category,attachButton,createButton,padding]
        for view in views {
            self.view.addSubview(view)
        }
    }
    
    func setupConstraints(){
        
        let width = self.view.frame.width, height = self.view.frame.height
        containerView.edgesToSuperview()
        containerView.backgroundColor = .blue
        
        optionalImageView.top(to: containerView,offset: 16)
        optionalImageView.height(100)
        optionalImageView.backgroundColor = .red
        //        optionalImageView.isHidden = true

        
        let textFields = [quote,author,category]
        
        for text in textFields {
            text.height(25)
            text.width(width)
        }
        

        attachButton.height(40)
        createButton.height(40)
        
        
        padding.height(32)
        padding.topToBottom(of: createButton)
        
        
        attachButton.addTarget(self, action: #selector(attachImage), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    containerView.stack([optionalImageView,quote,author,category,attachButton,createButton,padding],spacing: 8)
    
    }
    
    
    @objc func attachImage() {
        print("Will attach image")
    }
    
    
    @objc func submitTapped() {
        print("Submit tapped!")
    }
    
    
}
