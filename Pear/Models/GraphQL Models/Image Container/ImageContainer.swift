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

class ImageContainer: Codable, CustomStringConvertible {
  
  static let graphQLImageFields: String = "{ imageID uploadedByUser_id original \(ImageRepresentation.graphQLImageRepresentationFields) large \(ImageRepresentation.graphQLImageRepresentationFields) medium \(ImageRepresentation.graphQLImageRepresentationFields) small \(ImageRepresentation.graphQLImageRepresentationFields) thumbnail \(ImageRepresentation.graphQLImageRepresentationFields)}"
  
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

extension ImageContainer {
  
  static func fakeImage() -> ImageContainer? {
    
    let data: [String: Any] = [
      "small": [
        "width": 300,
        "height": 400,
        "imageType": "small",
        // swiftlint:disable:next line_length
        "imageURL": "https://storage.googleapis.com/pear-images/images/d4bf5b213bdde9c11029995cd65c942a/small/d4bf5b213bdde9c11029995cd65c942a.jpg?GoogleAccessId=image-bucket-admin%40pear-59123.iam.gserviceaccount.com&Expires=1615417542&Signature=NlRh9aEy5bHmYlqko1ml5IqcKfhDcYc%2FkMuCfdxp%2BI0nb2Z%2BuQ8eIZ3Fra1gjdgPjEHmkn5va%2BnNCkpPG7r3nBTJ6KSpezlpB3yaWnim0jzMdaEmpi89NON5tLWPCpsd0rQ65wg1SqcLpk4a2bx7D98MTAFure1tGam1Wa1eUnMYGeQKPrCZ3%2BzbpKvStc%2FxWukPcgjquqmrb1g6YNtXb6bKYKOCpe1tg75aaQQh%2FE1Rb7hn%2FIuIaAJbEOVsNvCLNJ3ENFOjJQ7qM0jltold%2FxkRf6VQIUdKWtmmvh11vd59CGH06xuhRker3YWSJRWYWPTODYB%2Fd%2FmhZX%2BfA81IbQ%3D%3D"
      ],
      "imageID": "d4bf5b213bdde9c11029995cd65c942a",
      "uploadedByUser_id": "5c86bf34eb8c93ea8759d025",
      "original": [
        "width": 1600,
        "height": 2133,
        "imageType": "original",
        // swiftlint:disable:next line_length
        "imageURL": "https://storage.googleapis.com/pear-images/images/d4bf5b213bdde9c11029995cd65c942a/original/d4bf5b213bdde9c11029995cd65c942a.jpg?GoogleAccessId=image-bucket-admin%40pear-59123.iam.gserviceaccount.com&Expires=1615417542&Signature=UhRcZ8fofGJAO3BUMRyqvBNwb1WXH0J1fLxYJDUVIFVbjKLOxDB1JnWRJIB0nhI30YBwGjXTbO5oBI94dkpoL1SfG1YqlN3upnDTvg7NKCaEGRJdMbEvd%2BxJYyVDxzrH2jxstdbIPvuQRh3lX%2BOV3PaFMoFc%2BbviCjmHjwfhv3pFrVl5amdl1BE%2FM2GiUseTkcfj3n%2BWP%2FBkRWmHXGzEHgUOxcyLnp6qlCdYdy24q0T7Odjub02rxS8JpalQ4tKcJk8T4S3cCZeHHStNo18S6QhviD3gCP2MOTn107pf3WGRjJrXE2YtSPP3TM%2BHFsUlNjPgR2GVrWR2gySfx6Kl6w%3D%3D"
      ],
      "medium": [
        "width": 600,
        "height": 800,
        "imageType": "medium",
        // swiftlint:disable:next line_length
        "imageURL": "https://storage.googleapis.com/pear-images/images/d4bf5b213bdde9c11029995cd65c942a/medium/d4bf5b213bdde9c11029995cd65c942a.jpg?GoogleAccessId=image-bucket-admin%40pear-59123.iam.gserviceaccount.com&Expires=1615417542&Signature=htyIaGBu%2B2at%2B%2FPtoz47J6NbmESHiPLvWjwyMQpUrtNjJonnwweZiPUJ2rlw3qFaDXEh1v5%2FTYLUXGLvjOGvyAFxZyUa5LvaoWkTQlAS%2F0wIAeI5Jm7Ws4QxjuX1q%2FdZN8HmofFyKbNA8ZPc%2B3szjIOj%2BLenzI3ds6QYmo0KsBioCVAYksUO2UavYdvS8Z023Ir5MN%2BVUZjHavv6UX871UA2EhexcC%2BUziRmKTRcZ9YnNV5l5ckxH9HsATMwijuCYYBKVKg6JlQVKElIKh3sRT%2F8XjYLjj2CCX%2FuRUT2Ffls9bN%2Fcuc3umJ1IyCwsuOG6CNIofbLsaH8kFS45Y9eww%3D%3D"
      ],
      "thumbnail": [
        "width": 150,
        "height": 200,
        "imageType": "thumbnail",
        // swiftlint:disable:next line_length
        "imageURL": "https://storage.googleapis.com/pear-images/images/d4bf5b213bdde9c11029995cd65c942a/thumb/d4bf5b213bdde9c11029995cd65c942a.jpg?GoogleAccessId=image-bucket-admin%40pear-59123.iam.gserviceaccount.com&Expires=1615417542&Signature=eKwOh0q82%2FCLV74cDK9NEhj8qHpKDc4tcqMprOht2diCaLGM9o2mMgpPeAo25CaLC5Fj7Pvka9GMCw0HKXYW7l%2BIBBmQasHDynbE149Fx7ecjGleVRWIH87DAdt%2F64i%2Bh8Yv9WgMoIYNYUUm1cf7%2FCT3EM2HeFs9I2pH0mDg1GrigvMWrlp9nbqgiFzN5nBR%2Bg%2F9FPJ9FO0neqPyAQUwGQgy2806PdJgig5rErOJ4gfGCFFmAetin%2BGkkxOtzy%2FU8FeOUCYP0R7Hc9f%2Fvw6X5%2F3fpgxaywwKoYrITIzkbH3FTRZ%2BEvVi5Bid6w3f%2FYULyaomjSvEP0jtfllC%2BG5l3g%3D%3D"
      ],
      "large": [
        "width": 1000,
        "height": 1333,
        "imageType": "large",
        // swiftlint:disable:next line_length
        "imageURL": "https://storage.googleapis.com/pear-images/images/d4bf5b213bdde9c11029995cd65c942a/large/d4bf5b213bdde9c11029995cd65c942a.jpg?GoogleAccessId=image-bucket-admin%40pear-59123.iam.gserviceaccount.com&Expires=1615417542&Signature=HEJW7Pk%2BNOC1409kxm9bZ3sFyhSnEkr3tsQle5oDjBDe22qmniVeFpxLvsLCg%2BA1SHItte0sUC%2B4oG2GmxnK436MIR6F%2Bgw6k6tm6D3an1kQlM9r7uq5fK8y6uUR5CHW3Z0P4ndNFOblZWUzWMg08OfyVC8ROI03ysP5LkUQOLjtI0Asa2ePLSjc7QkkrUw1VSujlQEHEnG8ha%2BY3pq3HKK3abDZJWO7BUE8qCu8YDw6w%2BuIdiErxPQNuOdXMqK27C1GDnVdS97dwLwLMAcC%2BzRTmbfydcTTwNId7VhlpRhbhvvOdS5QLrGTyC1RuoKY09fdyeu6hyylmkG6VMKNKg%3D%3D"
      ]
    ]
    
    return try? JSONDecoder().decode(ImageContainer.self, from: JSONSerialization.data(withJSONObject: data, options: .prettyPrinted))
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
      SDWebImageDownloader.shared()
        .downloadImage(with: imageURL, options: .highPriority, progress: nil) { (image, _, _, _) in
          if let image = image {
            self.loadedImageSize = imageSize
            self.image = image
          }
      }
    }
  }
}
