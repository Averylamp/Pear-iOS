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
import Sentry

class PearImageAPI: ImageAPI {
  
  static let shared = PearImageAPI()
  
  private init() {
    
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let getImagesQuery: String = "query GetUserImages($userInput: GetUserInput) {getUser(userInput:$userInput){ success message user { displayedImages \(ImageContainer.graphQLImageFields) bankImages \(ImageContainer.graphQLImageFields) } }}"
  
  static let updateImagesQuery: String = "mutation UpdateUserPhotos($userInput:UpdateUserPhotosInput) { updateUserPhotos(updateUserPhotosInput:$userInput){ success message }}"
  
  func generateSentryEvent(level: SentrySeverity = .warning,
                           message: String,
                           tags: [String: String] = [:],
                           paylod: [String: Any] = [:]) {
    let iamgeErrorEvent = Event(level: level)
    iamgeErrorEvent.message = message
    var allTags: [String: String] = ["API": "ImageUploadAPI"]
    tags.forEach({ allTags[$0.key] = $0.value })
    iamgeErrorEvent.tags = allTags
    iamgeErrorEvent.extra = paylod
    Client.shared?.send(event: iamgeErrorEvent, completion: nil)
  }
  
}

// MARK: - Routes
extension PearImageAPI {
  
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
    
    let orientationUp = (image.imageOrientation == .up ||
      image.imageOrientation == .down ||
      image.imageOrientation == .upMirrored ||
      image.imageOrientation == .downMirrored) ? true : false
    
    let finalImage: UIImage!
    if scaleRatio < 1.0 ,
      let resizedImage = image
        .resizeImageUsingVImage(size: CGSize(width: (orientationUp ? image.size.width : image.size.height) * scaleRatio,
                                             height: (orientationUp ? image.size.height: image.size.width)  * scaleRatio)) {
      print("Scaling Image from : \(image.size) to \(resizedImage.size)")
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
            self.generateSentryEvent(level: .error, message: error.localizedDescription, tags: [:], paylod: payload)
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
                self.generateSentryEvent(level: .error, message: error.localizedDescription, tags: [:], paylod: payload)
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
      self.generateSentryEvent(level: .error, message: error.localizedDescription, tags: [:])
      completion(.failure(ImageAPIError.unknownError(error: error)))
    }
  }
  
  func getImages(uid: String,
                 token: String,
                 completion: @escaping (Result<(displayedImages: [ImageContainer], imageBank: [ImageContainer]), ImageAPIError>) -> Void) {
    
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearImageAPI.getImagesQuery,
        "variables": [
          "userInput": [
            "firebaseToken": token,
            "firebaseAuthID": uid
          ]
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ImageAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "getUser", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Get User: \(helperResult)")
            completion(.failure(ImageAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            completion(.failure(ImageAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let imagesJSON = try JSON(data: objectData)
              let displayedImagesData = try imagesJSON["displayedImages"].rawData()
              let displayedImages = try JSONDecoder().decode([ImageContainer].self, from: displayedImagesData)
              let bankImagesData = try imagesJSON["bankImages"].rawData()
              let bankImages = try JSONDecoder().decode([ImageContainer].self, from: bankImagesData)
              print("Successfully found Both image Sets")
              completion(.success((displayedImages: displayedImages, imageBank: bankImages)))
            } catch {
              print("Deserialization Error: \(error)")
              completion(.failure(ImageAPIError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      completion(.failure(ImageAPIError.unknownError(error: error)))
    }
    
  }
  
  func updateImages(userID: String,
                    displayedImages: [ImageContainer],
                    additionalImages: [ImageContainer], completion: @escaping (Result<Bool, ImageAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearImageAPI.updateImagesQuery,
        "variables": [
          "userInput": [
            "user_id": userID,
            "displayedImages": displayedImages.compactMap({ $0.dictionary }),
            "additionalImages": additionalImages.compactMap({ $0.dictionary })
          ]
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ImageAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "updateUserPhotos")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Approve Detached Profile: \(helperResult)")
            self.generateSentryEvent(level: .error, message: "GraphQL Error: \(helperResult)",
              tags: ["function": "updateUserPhotos"], paylod: fullDictionary)
            completion(.failure(ImageAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            self.generateSentryEvent(level: .error, message: message ?? "Failed to Approve Detached Profile",
                                     tags: ["function": "updateUserPhotos"], paylod: fullDictionary)
            completion(.failure(ImageAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully attached Detached Profile: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      completion(.failure(ImageAPIError.unknownError(error: error)))
    }

  }
  
}
