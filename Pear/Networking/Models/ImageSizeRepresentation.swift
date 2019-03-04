//
//  ImageObjectRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

enum ImageSize: String {
    case original
    case large
    case medium
    case small
    case thumbnail
    case unknown
}

class ImageSizeRepresentation {
    
    let imageSize: ImageSize
    let publicURL: URL
    let imageID: String
    let height: Int
    let width: Int
    
    init(imageID: String, imageSize: ImageSize, publicURL: URL, height: Int, width: Int) {
        self.imageID = imageID
        self.imageSize = imageSize
        self.publicURL = publicURL
        self.height = height
        self.width = width
    }
    
}
