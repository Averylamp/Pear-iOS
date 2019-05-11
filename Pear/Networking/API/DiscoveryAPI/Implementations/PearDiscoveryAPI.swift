//
//  PearDiscoveryAPI.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry

class PearDiscoveryAPI: DiscoveryAPI {
  
  static let shared = PearDiscoveryAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = ["Content-Type": "application/json"]
  
  static let getDiscoveryFeedQuery: String = "query GetDiscoveryFeed($user_id: ID!){ getDiscoveryFeed(user_id:$user_id){ currentDiscoveryItems { user \(PearUser.graphQLAllFields()) timestamp } }}"
  
}

// MARK: - Get Discovery Feed
extension PearDiscoveryAPI {
  
  func getDiscoveryFeed(userID: String, last: Int, completion: @escaping (Result<[FullProfileDisplayData], DiscoveryAPIError>) -> Void) {
    let variables: [String: Any] = [
      "user_id": userID,
      "last": last
    ]
    do {
      let request = try APIHelpers.getRequestWith(query: PearDiscoveryAPI.getDiscoveryFeedQuery,
                                              variables: variables)
      let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
        if let error = error {
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "GetDiscoveryFeed",
                                           functionName: "GetDiscoveryFeed",
                                           message: "\(String(describing: error.localizedDescription))",
                                           responseData: data,
                                           tags: [:],
                                           paylod: variables)
        } else {
          if let data = data,
            let json = try? JSON(data: data),
            let discoveryUser = json["data"]["getDiscoveryFeed"]["currentDiscoveryItems"].array {
            var allFullProfiles: [FullProfileDisplayData] = []
            for userData in discoveryUser {
              do {
                let rawData = try userData["user"].rawData()
                let pearUser = try JSONDecoder().decode(PearUser.self, from: rawData)
                let pearUserDisplayData = FullProfileDisplayData(user: pearUser)
                allFullProfiles.append(pearUserDisplayData)
              } catch {
                print("Error converting single user" )
              }
            }
            completion(.success(allFullProfiles))
          } else {
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearDiscoveryAPI",
                                             functionName: "GetDiscoveryFeed",
                                             message: "Failed Discovery Serialization",
                                             responseData: data,
                                             tags: [:],
                                             paylod: [:])
          }
        }
      }
      dataTask.resume()
      
    } catch {
      print("Error Creating API Request: \(error)")
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearDiscoveryAPI",
                                       functionName: "GetDiscoveryFeed",
                                       message: "\(String(describing: error.localizedDescription))")
    }
  }
  
}

// MARK: - Skip Discovery Item
extension PearDiscoveryAPI {
  
  func skipDiscoveryItem(userID: String, discoveryItemID: String, completion: @escaping (Result<Bool, DiscoveryAPIError>) -> Void) {
    
  }
  
}
