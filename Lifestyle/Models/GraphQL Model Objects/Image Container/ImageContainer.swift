//
//  ImageAllSizesRepresentation.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

enum ImageContainerCodingKeys: String, CodingKey {
  case images
  case imageID
  case uploadedByUser = "uploadedByUser_id"
  case original
  case large
  case medium
  case small
  case thumbnail
}

class ImageContainer: Codable, CustomStringConvertible, GraphQLDecodable {
  static func graphQLAllFields() -> String {
    return  "{ imageID uploadedByUser_id original \(ImageRepresentation.graphQLAllFields()) large \(ImageRepresentation.graphQLAllFields()) medium \(ImageRepresentation.graphQLAllFields()) small \(ImageRepresentation.graphQLAllFields()) thumbnail \(ImageRepresentation.graphQLAllFields())}"
  }
  
  let imageID: String
  var uploadedByUser: String?
  let original: ImageRepresentation
  let large: ImageRepresentation
  let medium: ImageRepresentation
  let small: ImageRepresentation
  let thumbnail: ImageRepresentation
  
  var description: String {
    return "**** Image Container **** \n" + """
    imageID: \(String(describing: self.imageID)),
    uploadedByUser: \(String(describing: self.uploadedByUser)),
    original: \(String(describing: self.original)),
    large: \(String(describing: self.large)),
    medium: \(String(describing: self.medium)),
    small: \(String(describing: self.small)),
    thumbnail: \(String(describing: self.thumbnail)),
    """
  }
  
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
  
  func toDatabaseFormat() -> [String: Any] {
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
    self.uploadedByUser = try? values.decode( String.self, forKey: .uploadedByUser)
    self.original = try values.decode( ImageRepresentation.self, forKey: .original)
    self.large = try values.decode( ImageRepresentation.self, forKey: .large)
    self.medium = try values.decode( ImageRepresentation.self, forKey: .medium)
    self.small = try values.decode( ImageRepresentation.self, forKey: .small)
    self.thumbnail = try values.decode( ImageRepresentation.self, forKey: .thumbnail)
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ImageContainerCodingKeys.self)
    try container.encode(self.imageID, forKey: .imageID)
    try container.encode(self.uploadedByUser, forKey: .uploadedByUser)
    try container.encode(self.original, forKey: .original)
    try container.encode(self.large, forKey: .large)
    try container.encode(self.medium, forKey: .medium)
    try container.encode(self.small, forKey: .small)
    try container.encode(self.thumbnail, forKey: .thumbnail)
  }
  
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
  
  func loadedImageContainer(size: ImageType? = nil) -> LoadedImageContainer {
    guard let size = size else {
      return LoadedImageContainer(container: self)
    }
    var cacheImageURL: URL?
    switch size {
    case .original:
      cacheImageURL = URL(string: self.original.imageURL)
    case .large:
      cacheImageURL = URL(string: self.large.imageURL)
    case .medium:
      cacheImageURL = URL(string: self.medium.imageURL)
    case .small:
      cacheImageURL = URL(string: self.small.imageURL)
    case .thumbnail:
      cacheImageURL = URL(string: self.thumbnail.imageURL)
    case .unknown:
      return LoadedImageContainer(container: self)
    }
    return LoadedImageContainer(container: self, imageURL: cacheImageURL, imageSize: size)
  }
  
}

extension ImageContainer: Equatable {
  
  static func == (lhs: ImageContainer, rhs: ImageContainer) -> Bool {
    return lhs.imageID == rhs.imageID &&
    lhs.description == rhs.description
  }
  
  static func compareImageLists(lhs: [ImageContainer], rhs: [ImageContainer]) -> Bool {
    if lhs.count != rhs.count {
      return false
    }
    for index in 0..<lhs.count where lhs[index] != rhs[index] {
      return false 
    }
    
    return true
  }
  
}

class LoadedImageContainer {
  var imageContainer: ImageContainer?
  var image: UIImage?
  var loadedImageSize: ImageType?
  
  init(image: UIImage, imageSize: ImageType? ) {
    self.image = image
    self.loadedImageSize = imageSize
  }
  
  /// Creates an image Container
  ///
  /// - Parameters:
  ///   - container: The Image Container to transform
  ///   - imageURL: An option imageURL to provide to start caching an image
  ///   - imageSize: An optional descriptor for the cached image, used to decide upon reloading
  init(container: ImageContainer, imageURL: URL? = nil, imageSize: ImageType? = nil) {
    self.imageContainer = container
    if let imageURL = imageURL {
      SDWebImageDownloader.shared
        .downloadImage(with: imageURL, options: .highPriority, progress: nil) { (image, _, _, _) in
          if let image = image {
            self.loadedImageSize = imageSize
            self.image = image
          }
      }
    }
  }
}
