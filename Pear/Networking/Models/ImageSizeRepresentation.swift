//
//  ImageObjectRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

enum ImageSize: String{
    case original = "original"
    case large = "large"
    case medium = "medium"
    case small = "small"
    case thumbnail = "thumbnail"
}

class ImageSizeRepresentation {
    
    let imageSize: ImageSize
    let publicURL: URL
    let imageID: String
    
    init(imageID: String, imageSize: ImageSize, publicURL: URL) {
        self.imageID = imageID
        self.imageSize = imageSize
        self.publicURL = publicURL
    }
    
}
