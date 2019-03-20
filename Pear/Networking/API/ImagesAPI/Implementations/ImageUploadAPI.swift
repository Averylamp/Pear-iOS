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
  
  func uploadNewImage(with image: UIImage, userID: String, completion: @escaping (Result<ImageContainer, ImageAPIError>) -> Void) {
    
    var scaleRatio: CGFloat = 1.0
    if image.size.width > image.size.height {
      scaleRatio = image.size.height > 1700 ? 1700 / image.size.height : scaleRatio
    } else {
      scaleRatio = image.size.width > 1700 ? 1700 / image.size.width : scaleRatio
    }
    
    let finalImage: UIImage!
    if scaleRatio < 1.0 {
      finalImage = image.imageWith(newSize: CGSize(width: image.size.width * scaleRatio,
                                                  height: image.size.height * scaleRatio))
    } else {
      finalImage = image
    }
    
    let headers: [String: String] = [
      "Content-Type": "application/json",
      "x-api-key": NetworkingConfig.imageAPIKey
    ]
    
    let request = NSMutableURLRequest(url: NetworkingConfig.imageAPIHost as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 25.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    let imageString: String = finalImage.jpegData(compressionQuality: 0.8)!.base64EncodedString()
    do {
      
      request.httpBody = try JSONSerialization
        .data(withJSONObject: ["image": imageString], options: .prettyPrinted)
      
      let session = URLSession.shared
      let dataTask = session
        .dataTask(with: request as URLRequest, completionHandler: { (data, _, error) -> Void in
          if let error = error {
            print(error as Any)
            completion(.failure(ImageAPIError.unknownError(error: error)))
          } else {
            if let data = data {
              do {
                let imageContainer = try JSONDecoder().decode(ImageContainer.self, from: data)
                imageContainer.uploadedByUser = userID
                completion(.success(imageContainer))
              } catch {
                completion(.failure(ImageAPIError.unknownError(error: error)))
              }
            } else {
              completion(.failure(ImageAPIError.failedDeserialization))
            }
          }
        })
      
      dataTask.resume()
    } catch {
      completion(.failure(ImageAPIError.unknownError(error: error)))
    }
  }
  
}
