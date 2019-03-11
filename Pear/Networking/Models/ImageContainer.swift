//
//  ImageAllSizesRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

class ImageContainer {
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
}
