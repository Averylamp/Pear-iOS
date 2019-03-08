//
//  ImageAllSizesRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

class ImageAllSizesRepresentation {
  let imageID: String
  let original: ImageSizeRepresentation
  let large: ImageSizeRepresentation
  let medium: ImageSizeRepresentation
  let small: ImageSizeRepresentation
  let thumbnail: ImageSizeRepresentation
  
  init?(original: ImageSizeRepresentation,
        large: ImageSizeRepresentation,
        medium: ImageSizeRepresentation,
        small: ImageSizeRepresentation,
        thumbnail: ImageSizeRepresentation) {
    self.imageID = original.imageID
    self.original = original
    self.large = large
    self.medium = medium
    self.small = small
    self.thumbnail = thumbnail
    
    if  large.imageID != original.imageID ||
      medium.imageID != original.imageID ||
      small.imageID != original.imageID ||
      thumbnail.imageID != original.imageID {
      return nil
    }
    
  }
  
  static func convertArrayToDatabaseFormat(images: [ImageAllSizesRepresentation])-> (imageIDs: [String], imageSizes: [String: Any]) {
    var imageIDs: [String] = []
    var imageSizes: [String: Any] = [
      "original": [],
      "large": [],
      "medium": [],
      "small": [],
      "thumbnail": []
    ]
    
    for image in images {
      imageIDs.append(image.imageID)
      if var original = imageSizes["original"] as? [[String: Any]] {
        original.append(image.original.toDatabaseFormat())
      }
      if var large = imageSizes["large"] as? [[String: Any]] {
        large.append(image.large.toDatabaseFormat())
      }
      if var medium = imageSizes["medium"] as? [[String: Any]] {
        medium.append(image.medium.toDatabaseFormat())
      }
      if var small = imageSizes["small"] as? [[String: Any]] {
        small.append(image.small.toDatabaseFormat())
      }
      if var thumbnail = imageSizes["thumbnail"] as? [[String: Any]] {
        thumbnail.append(image.thumbnail.toDatabaseFormat())
      }
    }
    return (imageIDs: imageIDs, imageSizes: imageSizes)
  }
}
