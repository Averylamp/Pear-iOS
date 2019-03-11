//
//  ImageObjectRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
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

class ImageRepresentation {
  
  let imageSize: ImageSize
  let imageURL: String
  let height: Int
  let width: Int
  
  init(imageSize: ImageSize, imageURL: String, height: Int, width: Int) {
    self.imageSize = imageSize
    self.imageURL = imageURL
    self.height = height
    self.width = width
  }
  
  convenience init?(dictionary: [String: Any], imageSize: ImageSize) {
    guard let imageURL = dictionary["imageURL"] as?  String,
      let width = dictionary["width"] as? Int,
      let height = dictionary["height"] as? Int else {
        print("Failed to create Image Representation from dictionary")
        return nil
    }
    
    self.init(imageSize: imageSize, imageURL: imageURL, height: height, width: width)
  }
  
  func toDatabaseFormat() -> [String: Any] {
    return [
      "imageURL": imageURL,
      "width": width,
      "height": height
    ]
  }
  
}
