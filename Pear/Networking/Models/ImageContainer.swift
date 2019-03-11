//
//  ImageAllSizesRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

enum ImageContainerCodingKeys: String, CodingKey {
  case imageID
  case original
  case large
  case medium
  case small
  case thumbnail
}

class ImageContainer: Codable {
  
  static let graphQLImageFields: String = "{ imageID original \(ImageRepresentation.graphQLImageRepresentationFields) large \(ImageRepresentation.graphQLImageRepresentationFields) medium \(ImageRepresentation.graphQLImageRepresentationFields) small \(ImageRepresentation.graphQLImageRepresentationFields) thumbnail \(ImageRepresentation.graphQLImageRepresentationFields)}"
  
  let imageID: String
  let original: ImageRepresentation
  let large: ImageRepresentation
  let medium: ImageRepresentation
  let small: ImageRepresentation
  let thumbnail: ImageRepresentation
  
  init(imageID: String,
       original: ImageRepresentation,
       large: ImageRepresentation,
       medium: ImageRepresentation,
       small: ImageRepresentation,
       thumbnail: ImageRepresentation) {
    self.imageID = imageID
    self.original = original
    self.large = large
    self.medium = medium
    self.small = small
    self.thumbnail = thumbnail
  }
  
  func toDatabseFormat() -> [String: Any] {
    let imageContainerRepresentation: [String: Any] = [
      "imageID": self.imageID,
      "original": self.original.toDatabaseFormat(),
      "large": self.large.toDatabaseFormat(),
      "medium": self.medium.toDatabaseFormat(),
      "small": self.small.toDatabaseFormat(),
      "thumbnail": self.thumbnail.toDatabaseFormat()
    ]
    
    return imageContainerRepresentation
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: ImageContainerCodingKeys.self)
    self.imageID = try values.decode( String.self, forKey: .imageID)
    self.original = try values.decode( ImageRepresentation.self, forKey: .original)
    self.large = try values.decode( ImageRepresentation.self, forKey: .large)
    self.medium = try values.decode( ImageRepresentation.self, forKey: .medium)
    self.small = try values.decode( ImageRepresentation.self, forKey: .small)
    self.thumbnail = try values.decode( ImageRepresentation.self, forKey: .thumbnail)
  }
  
}
