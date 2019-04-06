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
  static let getUserMatchesQuery: String = "query GetUserMatches($userInput: GetUserInput) {getUser(userInput:$userInput){ success message user { requestedMatches \(Match.graphQLMatchFields) } }}"
  
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
          if let data = data,
            let json = try? JSON(data: data) {
            print(json)
          }
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "createMatchRequest")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Create Match Request: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearMatchAPI",
                                             functionName: "createMatchRequest",
                                             message: "GraphQL Error: \(helperResult)",
                                             tags: ["function": "createMatcheRequest"],
                                             paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create Match Request: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearMatchAPI",
                                             functionName: "createMatchRequest",
                                             message: message ?? "Failed to Approve Detached Profile",
              tags: ["function": "createMatcheRequest"],
              paylod: fullDictionary)
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
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearMatchAPI",
                                       functionName: "createMatchRequest",
                                       message: "Unknown Error: \(error.localizedDescription)",
                                       tags: ["function": "createMatcheRequest"])
      completion(.failure(MatchesAPIError.unknownError(error: error)))
    }
    
  }
  
  func getMatchesForUser(uid: String, token: String, completion: @escaping (Result<[Match], MatchesAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearMatchesAPI.getUserMatchesQuery,
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
          completion(.failure(MatchesAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data) {
            print(json)
          }
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "getUser", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Get Matches for User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearMatchAPI",
                                             functionName: "getMatchesForUser",
                                             message: "GraphQL Error: \(helperResult)",
                                             paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get Matches for User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearMatchAPI",
                                             functionName: "getMatchesForUser",
                                             message: "Failure: \(helperResult)",
                                             paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let json = try JSON(data: objectData)
              guard let requestedMatches = json["requestedMatches"].array else {
                print("Unable to find requested matches")
                completion(.failure(.failedDeserialization))
                return
              }
              var allMatchRequests: [Match] = []
              for requestedMatch in requestedMatches {
                do {
                  let matchData = try requestedMatch.rawData()
                  let matchObject = try JSONDecoder().decode(Match.self, from: matchData)
                  print(matchObject)
                  allMatchRequests.append(matchObject)
                } catch {
                  
                }
              }
              print(requestedMatches)
              //              completion(.success(pearUser))
            } catch {
              print("Deserialization Error: \(error)")
              completion(.failure(MatchesAPIError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      completion(.failure(MatchesAPIError.unknownError(error: error)))
    }
    
  }
  
}
