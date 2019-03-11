//
//  ImageUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class ImageUploadAPI: ImageAPI {
  
  static let shared = ImageUploadAPI()
  
  private init() {
    
  }
  
  func uploadNewImage(with image: UIImage, completion: @escaping (Result<ImageContainer, ImageAPIError>) -> Void) {
    
    let headers: [String: String] = [
      "Content-Type": "application/json"
    ]
    
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.imageAPIHost)/upload_image")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    let imageString: String = image.jpegData(compressionQuality: 0.8)!.base64EncodedString()
    do {
      
      request.httpBody = try JSONSerialization
        .data(withJSONObject: ["image": imageString], options: .prettyPrinted)
      
      let session = URLSession.shared
      let dataTask = session
        .dataTask(with: request as URLRequest, completionHandler: { (data, _, error) -> Void in
          if error != nil {
            print(error as Any)
          } else {
            if let data = data, let json = JSON(rawValue: data), let returnData = json["size_map"].dictionary {
            
              guard let imageID = returnData["imageID"]?.string,
              let originalImageDictionary = returnData["original"]?.dictionaryObject,
              let originalImage = ImageRepresentation(dictionary: originalImageDictionary, imageSize: .original),
              let largeImageDictionary = returnData["large"]?.dictionaryObject,
              let largeImage = ImageRepresentation(dictionary: largeImageDictionary, imageSize: .large),
              let mediumImageDictionary = returnData["medium"]?.dictionaryObject,
              let mediumImage = ImageRepresentation(dictionary: mediumImageDictionary, imageSize: .medium),
              let smallImageDictionary = returnData["small"]?.dictionaryObject,
              let smallImage = ImageRepresentation(dictionary: smallImageDictionary, imageSize: .small),
              let thumbnailImageDictionary = returnData["thumbnail"]?.dictionaryObject,
                let thumbnailImage = ImageRepresentation(dictionary: thumbnailImageDictionary, imageSize: .thumbnail) else {
                  print("Missing required field for image deserialization")
                  completion(.failure(ImageAPIError.failedDeserialization))
                  return
              }
              
              let imageContainer = ImageContainer(imageID: imageID, original: originalImage, large: largeImage, medium: mediumImage, small: smallImage, thumbnail: thumbnailImage)
              
              print(json)
              completion(.success(imageContainer))
              return
            }
          }
        })
      
      dataTask.resume()
    } catch {
      //            completion( .failure(error))
    }
    
  }
  
}
