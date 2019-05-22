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
    self.updateUserWithDictionary(inputDictionary: ["firstName": (firstName?.trimmed() ?? nil) as Any,
                                                    "lastName": (lastName?.trimmed() ?? nil) as Any],
                                  mutationName: "UpdateUserName",
                                  completion: completion)
  }
  
  func updateUserAge(birthdate: Date,
                     completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    var inputs: [String: Any] = [:]
    let birthdayFormatter = DateFormatter()
    birthdayFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    birthdayFormatter.dateFormat = "yyyy-MM-dd"
    inputs["birthdate"] = birthdayFormatter.string(from: birthdate)
    if let age = Calendar.init(identifier: .gregorian)
      .dateComponents([.year], from: birthdate, to: Date()).year {
      inputs["age"] = age
    }
    self.updateUserWithDictionary(inputDictionary: inputs,
                                  mutationName: "UpdateUserAge",
                                  completion: completion)
  }
  
  func updateUserGender(gender: GenderEnum,
                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    self.updateUserWithDictionary(inputDictionary: ["gender": gender.rawValue as Any],
                                  mutationName: "UpdateUserGender", completion: completion)
  }
  
  func updateUserSchool(schoolName: String?,
                        schoolYear: String?,
                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    self.updateUserWithDictionary(inputDictionary: ["school": (schoolName?.trimmed() ?? nil) as Any,
                                                    "schoolYear": (schoolYear?.trimmed() ?? nil) as Any],
                                  mutationName: "UpdateUserSchool",
                                  completion: completion)
  }
  
  func updateUserDemographicsItems<E: RawRepresentable>(items: [E],
                                                        keyName: String,
                                                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
    where E.RawValue == String {
    let mutationName = "UpdateUser\(keyName.firstCapitalized)"
      self.updateUserWithDictionary(inputDictionary: [keyName: items.map({ $0.rawValue })],
                                    mutationName: mutationName,
                                    completion: completion)
  }

  func updateUserDemographicsItem<E: RawRepresentable>(item: E,
                                                       keyName: String,
                                                       completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void)
    where E.RawValue == String {
      let mutationName = "UpdateUser\(keyName.firstCapitalized)"
      self.updateUserWithDictionary(inputDictionary: [keyName: item.rawValue],
                                    mutationName: mutationName,
                                    completion: completion)
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
  
  /// Update Current User With Variables
  ///
  /// - Parameters:
  ///   - inputDictionary: Fields to update
  ///   - mutationName: Mutation name for analytics
  ///   - completion: completion handler
  private func updateUserWithDictionary(inputDictionary: [String: Any],
                                        mutationName: String,
                                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    do {
      let userID = try self.getCurrentUserID()
      self.updateUserWithDictionary(userID: userID,
                                    inputDictionary: inputDictionary,
                                    mutationName: mutationName, completion: completion)
    } catch UpdateUserAPIError.currentUserNotFound {
      completion(.failure(.currentUserNotFound))
    } catch {
      completion(.failure(.unknownError(error: error)))
    }
  }
  
  /// Update User With Variables
  ///
  /// - Parameters:
  ///   - userID: userID To update
  ///   - inputDictionary: Fields to update
  ///   - mutationName: Mutation name for analytics
  ///   - completion: completion handler
  private func updateUserWithDictionary(userID: String,
                                        inputDictionary: [String: Any],
                                        mutationName: String = "UpdateUser",
                                        completion: @escaping(Result<Bool, UpdateUserAPIError>) -> Void) {
    var variables = inputDictionary
    variables["user_id"] = userID
    do {
      let (request, fullDictionary) = try APIHelpers.getRequestWith(query: getUpdateUserQueryWithName(name: mutationName),
                                                                    variables: ["userInput": variables])
      
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
