//
//  PearMatchesAPI.swift
//  Pear
//
//  Created by Avery Lamp on 4/4/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry

class PearMatchesAPI: MatchesAPI {
  
  static let shared = PearMatchesAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  // swiftlint:disable:next line_length
  static let createMatchRequestQuery: String = "mutation CreateMatchRequest($requestInput: CreateMatchRequestInput!) { createMatchRequest(requestInput: $requestInput) { success message } }"
  
  func generateSentryEvent(level: SentrySeverity = .warning,
                           message: String,
                           tags: [String: String] = [:],
                           paylod: [String: Any] = [:]) {
    let userErrorEvent = Event(level: level)
    userErrorEvent.message = message
    var allTags: [String: String] = ["API": "PearMatchesAPI"]
    tags.forEach({ allTags[$0.key] = $0.value })
    userErrorEvent.tags = allTags
    userErrorEvent.extra = paylod
    Client.shared?.send(event: userErrorEvent, completion: nil)
  }
}

// MARK: - Routes
extension PearMatchesAPI {
 
  func createMatchRequest(sentByUserID: String,
                          sentForUserID: String,
                          receivedByUserID: String,
                          requestText: String?,
                          completion: @escaping(Result<Bool, MatchesAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearMatchesAPI.createMatchRequestQuery,
        "variables": [
          "requestInput": [
            "sentByUser_id": sentByUserID,
            "sentForUser_id": sentForUserID,
            "receivedByUser_id": receivedByUserID,
            "requestText": requestText as Any
          ]
        ]
      ]
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(MatchesAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "createMatchRequest")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Create Match Request: \(helperResult)")
            self.generateSentryEvent(level: .error, message: "GraphQL Error: \(helperResult)",
              tags: ["function": "createMatcheRequest"], paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create Match Request: \(message ?? "")")
            self.generateSentryEvent(level: .error, message: message ?? "Failed to Approve Detached Profile",
                                     tags: ["function": "createMatcheRequest"], paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully Create Match Request: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      self.generateSentryEvent(level: .error, message: "Unknown Error: \(error.localizedDescription)",
        tags: ["function": "createMatcheRequest"], paylod: [:])
      completion(.failure(MatchesAPIError.unknownError(error: error)))
    }
   
  }
  
}
