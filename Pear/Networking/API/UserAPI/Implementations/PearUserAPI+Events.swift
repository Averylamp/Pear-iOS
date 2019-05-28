//
//  PearUserAPI+Events.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry
import CodableFirebase

extension PearUserAPI {
  
  func addEventCode(code: String,
                    completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    var variables: [String: Any] = ["code": code]
    do {
      let userID = try self.getCurrentUserID()
      variables["user_id"] = userID
      let (request, fullDictionary) = try APIHelpers.getRequestWith(query: PearUserAPI.addEventCodeQuery,
                                                                    variables: variables)
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: "AddEventCode",
                                           message: error.localizedDescription,
                                           responseData: data,
                                           tags: [:],
                                           payload: fullDictionary)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "addEventCode")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "AddEventCode",
                                             message: "GraphQL Error: \(String(describing: helperResult))",
              responseData: data,
              tags: [:],
              payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Update User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "AddEventCode",
                                             message: message ?? "Returned Failure",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully Added Event code to User: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
      
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearUserAPI",
                                       functionName: "AddEventCode",
                                       message: error.localizedDescription)
      completion(.failure(UserAPIError.unknownError(error: error)))
      
    }
  }

  func getUserFromQRCode(userID: String,
                         completion: @escaping(Result<PearUser, UserAPIError>) -> Void) {
    let variables: [String: Any] = ["user_id": userID]
    do {
      let (request, fullDictionary) = try APIHelpers.getRequestWith(query: PearUserAPI.getUserFromIDQuery,
                                                                    variables: variables)
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: "GetUserFromID",
                                           message: error.localizedDescription,
                                           responseData: data,
                                           tags: [:],
                                           payload: fullDictionary)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data),
            let userData = try? json["data"]["user"].rawData(),
            let user = try? JSONDecoder().decode(PearUser.self, from: userData) {
            completion(.success(user))
          } else {
            completion(.failure(UserAPIError.errorWithMessage(message: "Could not find that user")))
          }
        }
      }
      dataTask.resume()
      
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearUserAPI",
                                       functionName: "GetUserFromID",
                                       message: error.localizedDescription)
      completion(.failure(UserAPIError.unknownError(error: error)))
      
    }

  }
  
}
