//
//  PearUserAPI+Updates.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry
import CodableFirebase

// MARK: - User Update Routes
extension PearUserAPI {
  
  func updateUserFirstName(userID: String,
                           firstName: String,
                           completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let preferenceDictionary: [String: Any] = [
      "firstName": firstName
    ]
    self.updateUserWithPreferenceDictionary(userID: userID,
                                            inputDictionary: preferenceDictionary,
                                            mutationName: "UpdateUserFirstName",
                                            completion: completion)
  }
  
  //swiftlint:disable:next function_parameter_count
  func updateUserPreferences(userID: String,
                             genderPrefs: [String],
                             minAge: Int,
                             maxAge: Int,
                             locationName: String?,
                             isSeeking: Bool?,
                             completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    var preferenceDictionary: [String: Any] = [
      "minAgeRange": minAge,
      "maxAgeRange": maxAge,
      "seekingGender": genderPrefs,
      "locationName": locationName as Any
    ]
    if let isSeeking = isSeeking {
      preferenceDictionary["isSeeking"] = isSeeking
    }
    self.updateUserWithPreferenceDictionary(userID: userID,
                                            inputDictionary: preferenceDictionary,
                                            mutationName: "UpdateUserPrefernces",
                                            completion: completion)
  }
  
  func updateUserSchool(userID: String,
                        schoolName: String?,
                        schoolYear: String?,
                        completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    var preferenceDictionary = [String: Any]()
    if let schoolName = schoolName {
      preferenceDictionary["school"] = schoolName
    }
    if let schoolYear = schoolYear {
      preferenceDictionary["schoolYear"] = schoolYear
    }
    self.updateUserWithPreferenceDictionary(userID: userID,
                                            inputDictionary: preferenceDictionary,
                                            mutationName: "UpdateUserSchool",
                                            completion: completion)
  }
  
  func updateUserBirthdateAge(userID: String,
                              age: Int,
                              birthdate: Date,
                              completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let birthdayFormatter = DateFormatter()
    birthdayFormatter.dateFormat = "yyyy-MM-dd"
    let birthdateAgeDictionary: [String: Any] = [
      "age": age,
      "birthdate": birthdayFormatter.string(from: birthdate)
    ]
    self.updateUserWithPreferenceDictionary(userID: userID, inputDictionary: birthdateAgeDictionary, mutationName: "UpdateUserAgeBirthdate", completion: completion)
  }
  
  func updateUserGender(userID: String,
                        gender: GenderEnum,
                        completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let genderDictionary: [String: Any] = [
      "gender": gender.rawValue
    ]
    self.updateUserWithPreferenceDictionary(userID: userID, inputDictionary: genderDictionary, mutationName: "UpdateUserGender", completion: completion)
  }
  
  func updateUser(userID: String,
                  updates: [String: Any],
                  completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    self.updateUserWithPreferenceDictionary(userID: userID,
                                            inputDictionary: updates,
                                            mutationName: "FullUserUpdate",
                                            completion: completion)
  }
  
  func updateUserWithPreferenceDictionary(userID: String,
                                          inputDictionary: [String: Any],
                                          mutationName: String = "UpdateUser",
                                          completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    var allInputs = inputDictionary
    allInputs["user_id"] = userID
    let fullDictionary: [String: Any] = [
      "query": getUpdateUserQueryWithName(name: mutationName),
      "variables": [
        "userInput": allInputs
      ]
    ]
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: mutationName,
                                           message: error.localizedDescription,
                                           responseData: data,
                                           tags: [:],
                                           payload: fullDictionary)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          APIHelpers.printDataDump(data: data)
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "updateUser")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: mutationName,
                                             message: "GraphQL Error: \(String(describing: helperResult))",
              responseData: data,
              tags: [:],
              payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Update User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: mutationName,
                                             message: message ?? "Returned Failure",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
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
                                       apiName: "PearUserAPI",
                                       functionName: mutationName,
                                       message: error.localizedDescription)
      completion(.failure(UserAPIError.unknownError(error: error)))
    }
  }
  
}
