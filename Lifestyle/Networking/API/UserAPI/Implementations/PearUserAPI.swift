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
  
  static let createUserQuery: String = "mutation CreateUser($userInput: CreationUserInput!) {createUser(userInput: $userInput) { success message user \(PearUser.graphQLAllFields()) }}"
  
  static let getUserQuery: String = "query GetUser($userInput: GetUserInput!) {getUser(userInput:$userInput){ success message user \(PearUser.graphQLCurrentUserFields()) }}"
  static let fetchEndorsedUsersQuery: String = "query GetEndorsedUsers($userInput: GetUserInput!) { getUser(userInput:$userInput) { success message user { endorsedUsers \(PearUser.graphQLAllFields()) detachedProfiles \((PearDetachedProfile.graphQLAllFields()))  }  }}"
  // swiftlint:disable:next line_length
  static let getExistingUsersQuery: String = "query GetAlreadyOnPear($myPhoneNumber: String!, $phoneNumbers:[String!]!){alreadyOnPear(myPhoneNumber: $myPhoneNumber, phoneNumbers: $phoneNumbers)}"
  
  func getUpdateUserQueryWithName(name: String) -> String {
    return "mutation \(name)($userInput: UpdateUserInput!){ updateUser(updateUserInput:$userInput){ success message } }"
  }
  
  static let addEventCodeQuery: String = "mutation AddEventCode($user_id: ID!, $code: String!) { addEventCode(user_id: $user_id, code: $code) { success message } }"
  static let getUserFromIDQuery: String = "query GetUserFromID($user_id: ID!) { user(id: $user_id)  \(PearUser.graphQLAllFields()) }"
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
            print("Failed to Get User: \(helperResult)")
            if DataStore.shared.fetchFlagFromDefaults(flag: .hasCreatedUser) {
              #if PROD
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "getUser",
                                               message: "GraphQL Error: \(String(describing: helperResult))",
                                               responseData: data,
                                               tags: [:],
                                               payload: fullDictionary)
              #endif
            }
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            if DataStore.shared.fetchFlagFromDefaults(flag: .hasCreatedUser) {
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "getUser",
                                               message: message ?? "Returned Failure",
                                               responseData: data,
                                               tags: [:],
                                               payload: fullDictionary)
            }
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let pearUser = try JSONDecoder().decode(PearUser.self, from: objectData)
              print("Successfully found Pear User")
              #if PROD
              DataStore.shared.setFlagToDefaults(value: true, flag: .hasCreatedUser)
              #endif
              completion(.success(pearUser))
              // Uncomment this line to go through initial user setup
//              completion(.failure(UserAPIError.failedDeserialization))
            } catch {
              print("Deserialization Error: \(error)")
              if DataStore.shared.fetchFlagFromDefaults(flag: .hasCreatedUser) {
                SentryHelper.generateSentryEvent(level: .error,
                                                 apiName: "PearUserAPI",
                                                 functionName: "getUser",
                                                 message: error.localizedDescription,
                                                 responseData: data,
                                                 tags: [:],
                                                 payload: fullDictionary)
              }
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
    (Result<(endorsedProfiles: [PearUser],
    detachedProfiles: [PearDetachedProfile]), UserAPIError>) -> Void) {
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
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "fetchEndorsedUsers",
                                             message: message ?? "Returned Failure",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              var endorsedUsers: [PearUser] = []
              if let endorsedUsersJSON = (try JSON(data: objectData)["endorsedUsers"]).array {
                for endorsedUser in endorsedUsersJSON {
                  if let matchingUserData = try? endorsedUser.rawData(),
                    let matchingUserObj = try? JSONDecoder().decode(PearUser.self, from: matchingUserData) {
                    endorsedUsers.append(matchingUserObj)
                  }
                }
              }
              var detachedProfiles: [PearDetachedProfile] = []
              if let detachedProfilesJSON = (try JSON(data: objectData)["detachedProfiles"]).array {
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
                                               responseData: data,
                                               tags: [:],
                                               payload: fullDictionary)
              
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
  
  func createNewUser(userCreationData: UserCreationData,
                     completion: @escaping (Result<PearUser, UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      if let firebaseRemoteInstanceID = DataStore.shared.firebaseRemoteInstanceID {
        userCreationData.firebaseRemoteInstanceID = firebaseRemoteInstanceID
      }
      
      let fullDictionary: [String: Any] = [
        "query": PearUserAPI.createUserQuery,
        "variables": [
          "userInput": try userCreationData.toGraphQLInput()
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        APIHelpers.printDataDump(data: data)
        print("Data task returned")
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: "createUser",
                                           message: error.localizedDescription,
                                           responseData: data,
                                           tags: [:],
                                           payload: fullDictionary)
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
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "createUser",
                                             message: message ?? "Returned Error",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let pearUser = try JSONDecoder().decode(PearUser.self, from: objectData)
              print("Successfully found Pear User")
              #if PROD
              DataStore.shared.setFlagToDefaults(value: true, flag: .hasCreatedUser)
              #endif
              completion(.success(pearUser))
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "createUser",
                                               message: "Deserialization Error: \(String(describing: error.localizedDescription))",
                                               responseData: data,
                                               tags: [:],
                                               payload: fullDictionary)
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
  
  func getExistingUsers(checkNumbers: [String], completion: @escaping(Result<[String], UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    guard let userPhoneNumber = DataStore.shared.currentPearUser?.phoneNumber else {
      print("User not logged in")
      completion(.failure(UserAPIError.unauthenticated))
      return
    }
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    let fullDictionary: [String: Any] = [
      "query": PearUserAPI.getExistingUsersQuery,
      "variables": [
        "myPhoneNumber": userPhoneNumber,
        "phoneNumbers": checkNumbers
      ]
    ]
    do {
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        print("Data task returned")
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearUserAPI",
                                           functionName: "getExistingUsers",
                                           message: error.localizedDescription,
                                           responseData: data,
                                           tags: [:],
                                           payload: fullDictionary)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data),
            let foundNumberJsons = json["data"]["alreadyOnPear"].array {
            let foundNumbers = foundNumberJsons.compactMap({ $0.string })
            completion(.success(foundNumbers))
          } else {
           completion(.failure(UserAPIError.graphQLError(message: "Wasnt able to find numbers")))
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

}
