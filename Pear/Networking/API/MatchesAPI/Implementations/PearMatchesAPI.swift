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
import Firebase

enum MatchesRequestType: String {
  case matchRequests
  case currentMatches
}

class PearMatchesAPI: MatchesAPI {
  
  static let shared = PearMatchesAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  // swiftlint:disable:next line_length
  static let createMatchRequestQuery: String = "mutation CreateMatchRequest($requestInput: CreateMatchRequestInput!) { createMatchRequest(requestInput: $requestInput) { success message } }"
  static let getUserCurrentMatchesQuery: String = "query GetUserMatches($userInput: GetUserInput) {getUser(userInput:$userInput){ success message user { currentMatches \(Match.graphQLMatchFields) } }}"
  static let getUserMatchRequests: String = "query GetUserMatches($userInput: GetUserInput) {getUser(userInput:$userInput){ success message user { requestedMatches \(Match.graphQLMatchFields) } }}"
  
  static let sendMessageNotificationQuery: String = "query SendNotification($fromUser_id:ID!, toUser_ID!) { notifyNewMessage(fromUser_id:$fromUser_id, toUser_id:$toUser_id) }"
  
  static func getMatchDecisionRequest(accepted: Bool) -> String {
    let requestFunction = accepted ? "acceptRequest" : "rejectRequest"
    let functionHeader = accepted ? "AcceptMatchRequest" : "RejectMatchRequest"
    return "mutation \(functionHeader)($user_id: ID!, $match_id: ID!) { \(requestFunction)(user_id:$user_id, match_id:$match_id) { success message match \(Match.graphQLMatchFields) } }"
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

    do {
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
            if sentByUserID == sentForUserID {
              Analytics.logEvent("sent_personal_request", parameters: nil)
            } else {
              Analytics.logEvent("sent_matchmaker_request", parameters: nil)
            }
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
  
  func getMatchesForUser(uid: String,
                         token: String,
                         matchType: MatchesRequestType,
                         completion: @escaping (Result<[Match], MatchesAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 25.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    let query = matchType == .currentMatches ? PearMatchesAPI.getUserCurrentMatchesQuery : PearMatchesAPI.getUserMatchRequests
    
    let fullDictionary: [String: Any] = [
      "query": query,
      "variables": [
        "userInput": [
          "firebaseToken": token,
          "firebaseAuthID": uid
        ]
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(MatchesAPIError.unknownError(error: error)))
          return
        } else {
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
              let matchesKey = matchType == .currentMatches ? "currentMatches" : "requestedMatches"
              guard let requestedMatches = json[matchesKey].array else {
                print("Unable to find requested matches")
                completion(.failure(.failedDeserialization))
                return
              }
              
              var allMatchRequests: [Match] = []
              var matchesToLoad = requestedMatches.count
              if matchesToLoad == 0 {
                completion(.success([]))
                return
              }
              print("\(matchesToLoad) Matches to load for: \(matchType)")
              for requestedMatch in requestedMatches {
                do {                  
                  let matchData = try requestedMatch.rawData()
                  let matchObject = try JSONDecoder().decode(Match.self, from: matchData)
                  matchObject.fetchFirebaseChatObject(completion: { (match) in
                    if let matchObj = match {
                      allMatchRequests.append(matchObj)
                    } else {
                      print("Unable to find match object")
                    }
                    matchesToLoad -= 1
                    print("Fetched Match Object \(matchType): \(matchesToLoad) left")
                    if matchesToLoad == 0 {
                      allMatchRequests.sort(by: { (lft, rht) -> Bool in
                        var lftTime: Date!
                        var rhtTime: Date!
                        if lft.receivedByUser.documentID == uid {
                          lftTime = lft.receivedByUserStatusLastUpdated
                        } else {
                          lftTime = lft.sentForUserStatusLastUpdated
                        }
                        if rht.receivedByUser.documentID == uid {
                          rhtTime = rht.receivedByUserStatusLastUpdated
                        } else {
                          rhtTime = rht.sentForUserStatusLastUpdated
                        }
                        return lftTime.compare(rhtTime) == .orderedDescending
                      })
                      completion(.success(allMatchRequests))
                    }
                  })
                } catch {
                  print("Failure deserializing match object: \(error)")
                }
              }
              
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
  
  func decideOnMatchRequest(uid: String,
                            matchID: String,
                            accepted: Bool,
                            completion: @escaping(Result<Match, MatchesAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 25.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    
    let requestFunction = accepted ? "acceptRequest" : "rejectRequest"
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearMatchesAPI.getMatchDecisionRequest(accepted: accepted),
        "variables": [
          "user_id": uid,
          "match_id": matchID
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
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: requestFunction, objectName: "match")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Create User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearMatchAPI",
                                             functionName: requestFunction,
                                             message: "GraphQL Error: \(helperResult)",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearMatchAPI",
                                             functionName: requestFunction,
                                             message: message ?? "Returned Error",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(MatchesAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let matchObj = try JSONDecoder().decode(Match.self, from: objectData)
              print("Successfully found Pear User")
              matchObj.fetchFirebaseChatObject(completion: { (match) in
                if let matchObj = match {
                  completion(.success(matchObj))
                } else {
                  completion(.failure(MatchesAPIError.unknown))
                }
              })
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearMatchAPI",
                                               functionName: requestFunction,
                                               message: "Deserialization Error: \(error.localizedDescription)",
                tags: [:],
                paylod: fullDictionary)
              completion(.failure(MatchesAPIError.failedDeserialization))
            }
          }

        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearMatchAPI",
                                       functionName: requestFunction,
                                       message: "Unknown Error: \(error.localizedDescription)",
        tags: [:])
      completion(.failure(MatchesAPIError.unknownError(error: error)))
    }
    
  }
  
  func sendNotification(fromID: String,
                        toID: String,
                        completion: @escaping(Result<Bool, MatchesAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    let fullDictionary: [String: Any] = [
      
      "query": PearMatchesAPI.sendMessageNotificationQuery,
      "variables": [
        "fromUser_id": fromID,
        "toUser_id": toID
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(MatchesAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data),
            let success = json["data"]["notifyNewMessage"].bool {
            completion(.success(success))
          } else {
            completion(.failure(MatchesAPIError.failedDeserialization))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearMatchAPI",
                                       functionName: "sendNotification",
                                       message: "Unknown Error: \(error.localizedDescription)")
      completion(.failure(MatchesAPIError.unknownError(error: error)))
    }
  }
}
