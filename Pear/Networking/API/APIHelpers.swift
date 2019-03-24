//
//  APIHelpers.swift
//  Pear
//
//  Created by Avery Lamp on 3/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum GraphQLResponse {
  case dataNotFound
  case notJsonSerializable
  case couldNotFindSuccessOrMessage
  case failure(message: String?)
  case foundObjectData(data: Data)
  case didNotFindObjectData
}

class APIHelpers {
  
  static func interpretGraphQLResponse(data: Data?, functionName: String, objectName: String) -> GraphQLResponse {
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
  
}
