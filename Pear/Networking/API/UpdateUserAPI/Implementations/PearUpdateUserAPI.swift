//
//  PearUpdateUserAPI.swift
//  Pear
//
//  Created by Avery Lamp on 5/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry
import CodableFirebase

class PearUpdateUserAPI: UpdateUserAPI {
  
  static let shared = PearUpdateUserAPI()
  
  private init() {
    
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  func getUpdateUserQueryWithName(name: String) -> String {
    return "mutation \(name)($userInput: UpdateUserInput!){ updateUser(updateUserInput:$userInput){ success message } }"
  }
  
}

// MARK: - Routes
extension PearUpdateUserAPI {
  
  func updateUserName(firstName: String?,
                      lastName: String?,
                      completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    do {
      let userID = try self.getCurrentUserID()
      self.updateUserWithPreferenceDictionary(userID: userID,
                                              inputDictionary: ["firstName": firstName as Any,
                                                                "lastName": lastName as Any],
                                              mutationName: "UpdateUserName", completion: completion)
    } catch UpdateUserAPIError.currentUserNotFound {
      completion(.failure(.currentUserNotFound))
    } catch {
      completion(.failure(.unknownError(error: error)))
    }
  }
}

// MARK: - Generic Update Function
extension PearUpdateUserAPI {
  
  private func getCurrentUserID()throws  -> String {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw UpdateUserAPIError.currentUserNotFound
    }
    return userID
  }
  
  private func updateUserWithPreferenceDictionary(userID: String,
                                                  inputDictionary: [String: Any],
                                                  mutationName: String = "UpdateUser",
                                                  completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    var variables = inputDictionary
    variables["user_id"] = userID
    do {
      let (request, fullDictionary) = try APIHelpers.getRequestWith(query: getUpdateUserQueryWithName(name: mutationName),
                                                                    variables: variables)
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUpdateUserAPI",
                                           functionName: mutationName,
                                           message: error.localizedDescription,
                                           responseData: data,
                                           tags: [:],
                                           paylod: fullDictionary)
          completion(.failure(UpdateUserAPIError.unknownError(error: error)))
          return
        } else {
          APIHelpers.printDataDump(data: data)
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "updateUser")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUpdateUserAPI",
                                             functionName: mutationName,
                                             message: "GraphQL Error: \(String(describing: helperResult))",
              responseData: data,
              tags: [:],
              paylod: fullDictionary)
            completion(.failure(UpdateUserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Update User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUpdateUserAPI",
                                             functionName: mutationName,
                                             message: message ?? "Returned Failure",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UpdateUserAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully Updated User: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
      
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearUpdateUserAPI",
                                       functionName: mutationName,
                                       message: error.localizedDescription)
      completion(.failure(UpdateUserAPIError.unknownError(error: error)))
      
    }
  }

}
