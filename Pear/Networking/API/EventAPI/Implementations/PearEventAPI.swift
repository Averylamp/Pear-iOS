//
//  PearEventAPI.swift
//  Pear
//
//  Created by Brian Gu on 5/27/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry

class PearEventAPI: EventAPI {
  
  static let shared = PearEventAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let getEventQuery: String = "query GetEventById($event_id: ID!) { getEventById(event_id: $event_id) \(PearEvent.graphQLAllFields() ) }"
  
  static let getEventsForUserQuery: String = "query GetEndorsedUsers($userInput: GetUserInput!) { getUser(userInput:$userInput) { success message user { events \(PearEvent.graphQLAllFields()) } }}"
  
}

// MARK: - Routes
extension PearEventAPI {
  
  func getEvent(eventID: String, completion: @escaping (Result<PearEvent, EventAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    let fullDictionary: [String: Any] = [
      "query": PearEventAPI.getEventQuery,
      "variables": [
        "event_id": eventID
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearEventAPI",
                                           functionName: "getEvent",
                                           message: "\(String(describing: error.localizedDescription))",
                                           responseData: data,
                                           tags: [:],
                                           payload: fullDictionary)
          print (error as Any)
          completion(.failure(EventAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data) {
            do {
              let rawData = try json["data"]["getEventById"].rawData()
              let pearEvent = try JSONDecoder().decode(PearEvent.self, from: rawData)
              print(pearEvent)
            } catch {
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearEventAPI",
                                               functionName: "getEvent",
                                               message: "couldn't deserialize event",
                                               responseData: data,
                                               tags: [:],
                                               payload: fullDictionary)
              print("Error converting event")
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearEventAPI",
                                       functionName: "getEvent",
                                       message: "\(String(describing: error.localizedDescription))")
      completion(.failure(EventAPIError.unknownError(error: error)))
    }
  }
  
  func getEventsForUser(uid: String,
                        token: String,
                        completion: @escaping
    (Result<[PearEvent], EventAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearEventAPI.getEventsForUserQuery,
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
          completion(.failure(EventAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "getUser", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Get User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearEventAPI",
                                             functionName: "getEventsForUser",
                                             message: "GraphQL Error: \(String(describing: helperResult))",
              responseData: data,
              tags: [:],
              payload: fullDictionary)
            completion(.failure(EventAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "fetchEndorsedUsers",
                                             message: message ?? "Returned Failure",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(EventAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              print(objectData)
              var events: [PearEvent] = []
              if let eventsJSON = (try JSON(data: objectData)["events"]).array {
                for event in eventsJSON {
                  if let eventData = try? event.rawData(),
                    let eventObj = try? JSONDecoder().decode(PearEvent.self, from: eventData) {
                    events.append(eventObj)
                  }
                }
              }
              print("foundobjectdata events")
              print(events)
              completion(.success(events))
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "fetchEndorsedUsers",
                                               message: error.localizedDescription,
                                               responseData: data,
                                               tags: [:],
                                               payload: fullDictionary)
              
              completion(.failure(EventAPIError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearUserAPI",
                                       functionName: "fetchEndorsedUsers",
                                       message: error.localizedDescription)
      completion(.failure(EventAPIError.unknownError(error: error)))
    }
    
  }
  
}
