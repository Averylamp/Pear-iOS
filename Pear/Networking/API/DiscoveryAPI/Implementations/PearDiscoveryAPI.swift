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
  
  static let getDiscoveryFeedQuery: String = "query GetDiscoveryFeed($user_id: ID!){ getDiscoveryFeed(user_id:$user_id){ currentDiscoveryItems { user \(PearUser.graphQLAllFields()) timestamp _id } }}"
  // swiftlint:disable:next line_length
  static let skipDiscoveryItemMutation: String = "mutation SkipDiscoveryItem($user_id:ID!, $discoveryItem_id: ID!){ skipDiscoveryItem(user_id:$user_id, discoveryItem_id:$discoveryItem_id){ success message }}"
  
}

// MARK: - Get Discovery Feed
extension PearDiscoveryAPI {
  
  func getDiscoveryFeed(userID: String, last: Int, completion: @escaping (Result<[FullProfileDisplayData], DiscoveryAPIError>) -> Void) {
    let variables: [String: Any] = [
      "user_id": userID,
      "last": last
    ]
    do {
      let (request, fullDictionary) = try APIHelpers.getRequestWith(query: PearDiscoveryAPI.getDiscoveryFeedQuery,
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
                if let discoveryItemID = userData["_id"].string {
                  pearUserDisplayData.discoveryItemID = discoveryItemID
                } else {
                  print(userData)
                }
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
            completion(.failure(DiscoveryAPIError.unknownError(error: nil)))
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
    let variables: [String: Any] = [
      "user_id": userID,
      "discoveryItem_id": discoveryItemID
    ]
    do {
      let (request, fullDictionary) = try APIHelpers.getRequestWith(query: PearDiscoveryAPI.skipDiscoveryItemMutation,
                                                  variables: variables)
      let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
        if let error = error {
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "SkipDiscoveryItem",
                                           functionName: "SkipDiscoveryItem",
                                           message: "\(String(describing: error.localizedDescription))",
            responseData: data,
            tags: [:],
            paylod: variables)
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "skipDiscoveryItem")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update Detached Profile Request: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "GetDiscoveryFeed",
                                             functionName: "SkipDiscoveryItem",
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DiscoveryAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create Match Request: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "GetDiscoveryFeed",
                                             functionName: "SkipDiscoveryItem",
                                             message: message ?? "Unknown message",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DiscoveryAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Skip Discovery Item Message: \(String(describing: message))")
            completion(.success(true))
          }

        }
      }
      dataTask.resume()
      
    } catch {
      print("Error Creating API Request: \(error)")
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearDiscoveryAPI",
                                       functionName: "SkipDiscoveryItem",
                                       message: "\(String(describing: error.localizedDescription))")
    }

  }
  
}
