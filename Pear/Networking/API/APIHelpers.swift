//
//  APIHelpers.swift
//  Pear
//
//  Created by Avery Lamp on 3/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum GraphQLInterpretationObjectResponse {
  case dataNotFound
  case notJsonSerializable
  case couldNotFindSuccessOrMessage
  case failure(message: String?)
    case foundObjectData(data: Data)
  case didNotFindObjectData
}

enum GraphQLInterpretationSuccessResponse {
  case dataNotFound
  case notJsonSerializable
  case couldNotFindSuccessOrMessage
  case failure(message: String?)
  case success(message: String?)
  }

class APIHelpers {
  
  static func getRequestWith(query: String, variables: [String: Any], headers: [String: String] = ["Content-Type": "application/json"]) throws -> URLRequest {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    let fullDictionary: [String: Any] = [
      "query": query,
      "variables": variables
    ]
    let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
    request.httpBody = data
    return request as URLRequest
  }
  
  static func printDataDump(data: Data?) {
    if let data = data,
      let json = try? JSON(data: data) {
      print(json)
    }
  }
  
  static func dataDumpToString(data: Data?) -> String? {
    if let data = data,
      let json = try? JSON(data: data) {
      return String(describing: json)
    }
    return nil
  }
  
  static func interpretGraphQLResponseObjectData(data: Data?, functionName: String, objectName: String) -> GraphQLInterpretationObjectResponse {
    guard let data = data else {
      return .dataNotFound
    }
    guard let json = try? JSON(data: data) else {
     return .notJsonSerializable
    }
    guard let responseJson = json["data"][functionName].dictionary,
      let success = responseJson["success"]?.bool else {
      return .couldNotFindSuccessOrMessage
    }
    
    let message = responseJson["message"]?.string
    
    if !success {
      return .failure(message: message)
    }
    
    guard let objectJson = responseJson[objectName],
    let objectData =  try? objectJson.rawData() else {
      return .didNotFindObjectData
    }
    return .foundObjectData(data: objectData)
  }
  
  static func interpretGraphQLResponseSuccess(data: Data?, functionName: String) -> GraphQLInterpretationSuccessResponse {
    guard let data = data else {
      return .dataNotFound
    }
    guard let json = try? JSON(data: data) else {
      return .notJsonSerializable
    }
    guard let responseJson = json["data"][functionName].dictionary,
      let success = responseJson["success"]?.bool else {
        return .couldNotFindSuccessOrMessage
    }
    
    let message = responseJson["message"]?.string
    
    if success {
      return .success(message: message)
    } else {
      return .failure(message: message)
    }
  }
  
}
