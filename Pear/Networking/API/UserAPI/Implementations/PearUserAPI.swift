//
//  UserUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry
import CodableFirebase

class PearUserAPI: UserAPI {
  
  static let shared = PearUserAPI()
  
  private init() {
    
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let createUserQuery: String = "mutation CreateUser($userInput: CreationUserInput) {createUser(userInput: $userInput) { success message user \(PearUser.graphQLUserFieldsAll) }}"
  
  static let getUserQuery: String = "query GetUser($userInput: GetUserInput) {getUser(userInput:$userInput){ success message user \(PearUser.graphQLUserFieldsAll) }}"
  static let fetchEndorsedUsersQuery: String = "query GetEndorsedUsers($userInput: GetUserInput) { getUser(userInput:$userInput) { success message user { endorsedProfileObjs { userObj \(MatchingPearUser.graphQLMatchedUserFieldsAll) } detachedProfileObjs \((PearDetachedProfile.graphQLDetachedProfileFieldsAll))  }  }}"
  
  func getUpdateUserQueryWithName(name: String) -> String {
    return "mutation \(name)($user_id: ID, $userInput: UpdateUserInput){ updateUser(id:$user_id, updateUserInput:$userInput){ success message } }"
  }
  
}

// MARK: - Routes
extension PearUserAPI {
  
  func getUser(uid: String, token: String, completion: @escaping (Result<PearUser, UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearUserAPI.getUserQuery,
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
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "getUser", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            if let data = data,
              let json = try? JSON(data: data) {
              print(json)
            }
            print("Failed to Get User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "getUser",
                                             message: "GraphQL Error: \(helperResult)",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "getUser",
                                             message: message ?? "Returned Failure",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let pearUser = try JSONDecoder().decode(PearUser.self, from: objectData)
              print("Successfully found Pear User")
              completion(.success(pearUser))
              // Uncomment this line to go through initial user setup
//              completion(.failure(UserAPIError.failedDeserialization))
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "getUser",
                                               message: error.localizedDescription,
                                               tags: [:],
                                               paylod: fullDictionary)
              completion(.failure(UserAPIError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearUserAPI",
                                       functionName: "getUser",
                                       message: error.localizedDescription)
      completion(.failure(UserAPIError.unknownError(error: error)))
    }
  }

  func fetchEndorsedUsers(uid: String,
                          token: String,
                          completion: @escaping
    (Result<(endorsedProfiles: [MatchingPearUser], detachedProfiles: [PearDetachedProfile]), UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearUserAPI.fetchEndorsedUsersQuery,
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
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "getUser", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Get User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "fetchEndorsedUsers",
                                             message: "GraphQL Error: \(helperResult)",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "fetchEndorsedUsers",
                                             message: message ?? "Returned Failure",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              var endorsedUsers: [MatchingPearUser] = []
              if let endorsedUsersJSON = (try JSON(data: objectData)["endorsedProfileObjs"]).array {
                for endorsedUser in endorsedUsersJSON {
                  let userJSON = endorsedUser["userObj"]
                  if let matchingUserData = try? userJSON.rawData(),
                    let matchingUserObj = try? JSONDecoder().decode(MatchingPearUser.self, from: matchingUserData) {
                    endorsedUsers.append(matchingUserObj)
                  }
                }
              }
              var detachedProfiles: [PearDetachedProfile] = []
              if let detachedProfilesJSON = (try JSON(data: objectData)["detachedProfileObjs"]).array {
                for detachedProfile in detachedProfilesJSON {
                  if let detachedProfileData = try? detachedProfile.rawData(),
                    let detachedProfileObj = try? JSONDecoder().decode(PearDetachedProfile.self, from: detachedProfileData) {
                    detachedProfiles.append(detachedProfileObj)
                  }
                }
              }
              completion(.success((endorsedProfiles: endorsedUsers, detachedProfiles: detachedProfiles)))
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "fetchEndorsedUsers",
                                               message: error.localizedDescription,
                                               tags: [:],
                                               paylod: fullDictionary)
              
              completion(.failure(UserAPIError.failedDeserialization))
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
      completion(.failure(UserAPIError.unknownError(error: error)))
    }
    
  }
  
  func createNewUser(with gettingStartedUserData: UserCreationData,
                     completion: @escaping (Result<PearUser, UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      if let firebaseRemoteInstanceID = DataStore.shared.firebaseRemoteInstanceID {
        gettingStartedUserData.firebaseRemoteInstanceID = firebaseRemoteInstanceID
      }
      let fullDictionary: [String: Any] = [
        "query": PearUserAPI.createUserQuery,
        "variables": [
          "userInput": try convertUserDataToQueryVariable(userData: gettingStartedUserData)
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        print("Data task returned")
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: "createUser",
                                           message: error.localizedDescription,
                                           tags: [:],
                                           paylod: fullDictionary)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "createUser", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Create User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "createUser",
                                             message: "GraphQL Error: \(helperResult)",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "createUser",
                                             message: message ?? "Returned Error",
              tags: [:],
              paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let pearUser = try JSONDecoder().decode(PearUser.self, from: objectData)
              print("Successfully found Pear User")
              completion(.success(pearUser))
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "createUser",
                                               message: "Deserialization Error: \(error.localizedDescription)",
                                               tags: [:],
                                               paylod: fullDictionary)
              completion(.failure(UserAPIError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearUserAPI",
                                       functionName: "createUser",
                                       message: error.localizedDescription)
      completion(.failure(UserAPIError.unknownError(error: error)))
    }
  }
  
  //swiftlint:disable:next function_parameter_count
  func updateUserPreferences(userID: String,
                             genderPrefs: [String],
                             minAge: Int,
                             maxAge: Int,
                             locationName: String?,
                             completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let preferenceDictionary: [String: Any] = [
      "minAgeRange": minAge,
      "maxAgeRange": maxAge,
      "seekingGender": genderPrefs,
      "locationName": locationName as Any
    ]
    self.updateUserWithPreferenceDictionary(userID: userID,
                                            inputDictionary: preferenceDictionary,
                                            mutationName: "UpdateUserPrefernces",
                                            completion: completion)
  }
  
  func updateUserSchool(userID: String,
                        schoolName: String?,
                        schoolYear: String?,
                        completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let preferenceDictionary: [String: Any] = [
      "school": schoolName as Any,
      "schoolYear": schoolYear as Any
    ]
    self.updateUserWithPreferenceDictionary(userID: userID,
                                            inputDictionary: preferenceDictionary,
                                            mutationName: "UpdateUserSchool",
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
    
    do {
      let fullDictionary: [String: Any] = [
        "query": getUpdateUserQueryWithName(name: mutationName),
        "variables": [
          "user_id": userID,
          "userInput": inputDictionary
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        print("Data task returned")
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: mutationName,
                                           message: error.localizedDescription,
                                           tags: [:],
                                           paylod: fullDictionary)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "updateUser")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: mutationName,
                                             message: "GraphQL Error: \(helperResult)",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Update User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: mutationName,
                                             message: message ?? "Returned Failure",
                                             tags: [:],
                                             paylod: fullDictionary)
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

// MARK: - Create User Endpoint Helpers
extension PearUserAPI {
  
  func convertUserDataToQueryVariable(userData: UserCreationData) throws -> [String: Any] {
    guard
      let age = userData.age,
      let birthdate = userData.birthdate,
      let email = userData.email,
      let phoneNumber = userData.phoneNumber,
      let firstName = userData.firstName,
      let lastName = userData.lastName,
      let gender = userData.gender,
      let firebaseToken = userData.firebaseToken,
      let firebaseAuthID = userData.firebaseAuthID
      else {
        throw UserAPIError.invalidVariables
    }
    
    var variablesDictionary: [String: Any] = [
      "age": age,
      "email": email,
      "emailVerified": userData.emailVerified,
      "phoneNumber": phoneNumber,
      "phoneNumberVerified": userData.phoneNumberVerified,
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender.rawValue,
      "firebaseToken": firebaseToken,
      "firebaseAuthID": firebaseAuthID
    ]
    
    if let firebaseRemoteInstanceID = userData.firebaseRemoteInstanceID {
      variablesDictionary["firebaseRemoteInstanceID"] = firebaseRemoteInstanceID
    }
    
    if let location = userData.lastLocation {
      variablesDictionary["location"] = [location.longitude, location.latitude]
    }
    
    let birthdayFormatter = DateFormatter()
    birthdayFormatter.dateFormat = "yyyy-MM-dd"
    variablesDictionary["birthdate"] = birthdayFormatter.string(from: birthdate)
    
    if let facebookId = userData.facebookId {
      variablesDictionary["facebookId"] = facebookId
    }
    if let facebookAccessToken = userData.facebookAccessToken {
      variablesDictionary["facebookAccessToken"] = facebookAccessToken
    }
    
    if let thumbnailURL = userData.thumbnailURL {
      variablesDictionary["thumbnailURL"] = thumbnailURL
    }
    
    return variablesDictionary
  }
}
