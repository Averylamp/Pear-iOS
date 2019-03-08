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

class ImageSizeRepresentation {
  
  let imageSize: ImageSize
  let imageURL: String
  let imageID: String
  let height: Int
  let width: Int
  
  init(imageID: String, imageSize: ImageSize, publicURL: String, height: Int, width: Int) {
    self.imageID = imageID
    self.imageSize = imageSize
    self.imageURL = publicURL
    self.height = height
    self.width = width
  }
  
  func toDatabaseFormat() -> [String: Any] {
    return [
      "imageURL": imageURL,
      "imageID": imageID,
      "imageSize": [
        "width": width,
        "height": height
      ]
    ]
  }
  
}
