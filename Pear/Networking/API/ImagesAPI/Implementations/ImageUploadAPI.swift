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
import FirebasePerformance

class ImageUploadAPI: ImageAPI {
  
  static let shared = ImageUploadAPI()
  
  private init() {
    
  }
  
  func uploadNewImage(with image: UIImage,
                      userID: String,
                      completion: @escaping (Result<ImageContainer, ImageAPIError>) -> Void) {
    let trace = Performance.startTrace(name: "Image Upload")
    var scaleRatio: CGFloat = 1.0
    if image.size.width > image.size.height {
      scaleRatio = image.size.height > 1700 ? 1700 / image.size.height : scaleRatio
    } else {
      scaleRatio = image.size.width > 1700 ? 1700 / image.size.width : scaleRatio
    }
    
    let finalImage: UIImage!
    if scaleRatio < 1.0 ,
      let resizedImage = image.resizeImageUsingVImage(size: CGSize(width: image.size.width * scaleRatio,
                                                                   height: image.size.height * scaleRatio)) {
      print("Scaling Image")
      trace?.incrementMetric("Image Resized", by: 1)
      finalImage = resizedImage
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
      let payload = ["image": imageString]
      
      request.httpBody = try JSONSerialization
        .data(withJSONObject: payload, options: .prettyPrinted)
      
      let session = URLSession.shared
      let dataTask = session
        .dataTask(with: request as URLRequest, completionHandler: { (data, _, error) -> Void in
          if let error = error {
            print("Image Upload Error: \(error)")
            trace?.incrementMetric("Image Upload Error", by: 1)
            trace?.stop()
            completion(.failure(ImageAPIError.unknownError(error: error)))
          } else {
            trace?.incrementMetric("Image Request Successful", by: 1)
            if let data = data {
              do {
                let imageContainer = try JSONDecoder().decode(ImageContainer.self, from: data)
                imageContainer.uploadedByUser = userID
                trace?.incrementMetric("Image Decoding Successful", by: 1)
                trace?.stop()
                completion(.success(imageContainer))
              } catch {
                trace?.incrementMetric("Image Decoding Unsuccessful", by: 1)
                trace?.stop()
                completion(.failure(ImageAPIError.unknownError(error: error)))
              }
            } else {
              trace?.incrementMetric("Image Request Data Missing", by: 1)
              trace?.stop()
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
