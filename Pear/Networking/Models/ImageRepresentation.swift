//
//  ImageObjectRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum ImageType: String {
  case original
  case large
  case medium
  case small
  case thumbnail
  case unknown
}

enum ImageRepresentationCodingKeys: String, CodingKey {
  case imageURL
  case height
  case width
  case imageType
}

class ImageRepresentation: Codable {
  
  static let graphQLImageRepresentationFields: String = "{ imageURL imageType width height }"
  
  let imageType: ImageType
  let imageURL: String
  let height: Int
  let width: Int
  
  init(imageType: ImageType, imageURL: String, height: Int, width: Int) {
    self.imageType = imageType
    self.imageURL = imageURL
    self.height = height
    self.width = width
  }
  
  convenience init?(dictionary: [String: Any]) {
    guard let imageURL = dictionary[ImageRepresentationCodingKeys.imageURL.rawValue] as?  String,
      let width = dictionary[ImageRepresentationCodingKeys.width.rawValue] as? Int,
      let height = dictionary[ImageRepresentationCodingKeys.height.rawValue] as? Int,
      let rawImageType = dictionary[ImageRepresentationCodingKeys.imageType.rawValue] as? String,
      let imageType = ImageType(rawValue: rawImageType) else {
        print("Failed to create Image Representation from dictionary")
        return nil
    }
    
    self.init(imageType: imageType, imageURL: imageURL, height: height, width: width)
  }
  
  func toDatabaseFormat() -> [String: Any] {
    return [
      "imageURL": imageURL,
      "width": width,
      "height": height
    ]
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: ImageRepresentationCodingKeys.self)
    self.imageURL = try values.decode( String.self, forKey: .imageURL)
    self.height = try values.decode( Int.self, forKey: .height)
    self.width = try values.decode( Int.self, forKey: .width)
    guard let imageType = ImageType(rawValue: try values.decode(String.self, forKey: .imageType)) else {
      throw ImageAPIError.failedDeserialization
    }
    self.imageType = imageType
  }
  
  func encode(to encoder: Encoder) throws {
    
  }
  
}
