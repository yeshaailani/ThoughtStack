//
//  ImageConversion.swift
//  ThoughtStack
//
//  Created by Yesha Ailani on 12/14/19.
//  Copyright © 2019 Yesha Ailani. All rights reserved.
//

import Foundation
import UIKit

struct ImageConversion {
    func ToBase64String(img: UIImage) -> String {
        
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func ToImage(imageBase64String:String) -> UIImage {
        if !imageBase64String.isEmpty {
            if let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0)) {
                if let image = UIImage(data: imageData) {
                    return image
                }
            }
        }
        return UIImage(named: "no_image_error") ?? UIImage()
        
    }
}

