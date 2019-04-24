//
//  PearProfileAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry

class PearProfileAPI: ProfileAPI {
  
  static let shared = PearProfileAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let createNewDetachedProfileQuery: String = "mutation CreateDetachedProfile($detachedProfileInput: CreationDetachedProfileInput!) { createDetachedProfile(detachedProfileInput: $detachedProfileInput) { success message detachedProfile \(PearDetachedProfile.graphQLAllFields()) }}"
  
  static let findDetachedProfilesQuery: String = "query FindDetachedProfiles($phoneNumber: String!) { findDetachedProfiles(phoneNumber: $phoneNumber) \(PearDetachedProfile.graphQLAllFields()) }"
  
  // swiftlint:disable:next line_length
  static let attachDetachedProfileQuery: String = "mutation AttachDetachedProfile($approveDetachedProfileInput: ApproveDetachedProfileInput!) { approveNewDetachedProfile(approveDetachedProfileInput: $approveDetachedProfileInput){ message success } }"
  
  static let fetchCurrentFeedQuery: String = "query GetDiscoveryFeed($user_id: ID!){ getDiscoveryFeed(user_id:$user_id){ currentDiscoveryItems { user \(PearUser.graphQLAllFields()) timestamp } }}"
//  static let fetchMatchingUserQuery: String = "query GetMatchUser($user_id: ID!){ user(id: $user_id) { user \(PearUser.graphQLMatchedUserFieldsAll) }"
  
  // swiftlint:disable:next line_length
  static let editUserProfileQuery: String = "mutation EditUserProfile($editUserProfileInput:EditUserProfileInput!){ editUserProfile(editUserProfileInput: $editUserProfileInput){ success message}}"
  // swiftlint:disable:next line_length
  static let editDetachedProfileQuery: String = "mutation EditDetachedProfile($editDetachedProfileInput:EditDetachedProfileInput!){ editDetachedProfile(editDetachedProfileInput: $editDetachedProfileInput){ success message}}"
  
}

// MARK: Routes
extension PearProfileAPI {
  func createNewDetachedProfile(gettingStartedUserProfileData: ProfileCreationData,
                                completion: @escaping (Result<PearDetachedProfile, DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.createNewDetachedProfileQuery,
        "variables": [
          "detachedProfileInput": try convertUserProfileDataToQueryVariable(profileData: gettingStartedUserProfileData)
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(DetachedProfileError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "createDetachedProfile", objectName: "detachedProfile")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Create User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "createDetachedProfile",
                                             message: "GraphQL Error: \(helperResult)",
                                             responseData: data,
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "createDetachedProfile",
                                             message: message ?? "Failed to create user",
                                             responseData: data,
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let detachedProfile = try JSONDecoder().decode(PearDetachedProfile.self, from: objectData)
              print("Successfully found Detached Profile")
              completion(.success(detachedProfile))
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearProfileAPI",
                                               functionName: "createDetachedProfile",
                                               message: "DeserializationError: \(error.localizedDescription)",
                                               responseData: data,
                                               paylod: fullDictionary)
              completion(.failure(DetachedProfileError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "createDetachedProfile",
                                       message: error.localizedDescription)
      completion(.failure(DetachedProfileError.unknownError(error: error)))
    }
    
  }
  
  func checkDetachedProfiles(phoneNumber: String, completion: @escaping(Result<[PearDetachedProfile], DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.findDetachedProfilesQuery,
        "variables": [
          "phoneNumber": phoneNumber
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(DetachedProfileError.unknownError(error: error)))
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearProfileAPI",
                                           functionName: "findDetachedProfiles",
                                           message: error.localizedDescription,
                                           responseData: data)
          return
        } else {
          if  let data = data,
            let json = try? JSON(data: data) {
            do {
              if let profiles = json["data"]["findDetachedProfiles"].array {
                var detachedProfiles: [PearDetachedProfile] = []
                for profile in profiles {
                  let pearDetachedProfileData = try profile.rawData()
                  let pearDetachedUser = try JSONDecoder().decode(PearDetachedProfile.self, from: pearDetachedProfileData)
                  detachedProfiles.append(pearDetachedUser)
                }
                completion(.success(detachedProfiles))
              } else {
                completion(.failure(DetachedProfileError.noDetachedProfilesFound))
              }
            } catch {
              print("Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearProfileAPI",
                                               functionName: "findDetachedProfiles",
                                               message: error.localizedDescription,
                                               responseData: data,
                                               tags: [:],
                                               paylod: fullDictionary)
              completion(.failure(DetachedProfileError.unknownError(error: error)))
              return
            }
          } else {
            print("Failed Detached Profile Conversions")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "findDetachedProfiles",
                                             message: "Failed to convert inputs",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "findDetachedProfiles",
                                       message: error.localizedDescription)
      completion(.failure(DetachedProfileError.unknownError(error: error)))
    }
    
  }
  
  func attachDetachedProfile(user_id: String, detachedProfile_id: String, creatorUser_id: String,
                             approvedContent: [String: Any], completion: @escaping(Result<Bool, DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    var allInputs = approvedContent
    allInputs["user_id"] = user_id
    allInputs["detachedProfile_id"] = detachedProfile_id
    allInputs["creatorUser_id"] = creatorUser_id
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.attachDetachedProfileQuery,
        "variables": [
          "approveDetachedProfileInput": allInputs
        ]
      ]
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(DetachedProfileError.unknownError(error: error)))
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "approveNewDetachedProfile")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Approve Detached Profile: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "approveNewDetachedProfile",
                                             message: "GraphQL Error: \(helperResult)",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "approveNewDetachedProfile",
                                             message: message ?? "Failed to Approve Detached Profile",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully attached Detached Profile: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "approveNewDetachedProfile",
                                       message: "Unknown Error: \(error.localizedDescription)")
      completion(.failure(DetachedProfileError.unknownError(error: error)))
    }
    
  }
  
  func getDiscoveryFeed(user_id: String,
                        completion: @escaping(Result<[FullProfileDisplayData], DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.fetchCurrentFeedQuery,
        "variables": [
          "user_id": user_id
        ]
      ]
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearProfileAPI",
                                           functionName: "getDiscoveryFeed",
                                           message: "Unknown Error: \(error.localizedDescription)",
                                           responseData: data,
                                           tags: [:],
                                           paylod: fullDictionary)
          completion(.failure(DetachedProfileError.unknownError(error: error)))
          return
        } else {
          if  let data = data,
            let json = try? JSON(data: data) {
            print("Retreived Feed")
            if let discoveryUsers = json["data"]["getDiscoveryFeed"]["currentDiscoveryItems"].array {
              var allFullProfiles: [FullProfileDisplayData] = []
              for userData in discoveryUsers {
                do {
                  let userRawData = try userData["user"].rawData()
                  let pearUser = try JSONDecoder().decode(PearUser.self, from: userRawData)
                  if pearUser.endorserIDs.count > 0 {
                    let fullProfile = FullProfileDisplayData(user: pearUser)
                    if let timestamp = userData["timestamp"].string,
                      let timestampValue = Double(timestamp) {
                      fullProfile.discoveryTimestamp = Date(timeIntervalSince1970: timestampValue / 1000.0)
                    }
                    allFullProfiles.append(fullProfile)
                  }
                } catch {
                  SentryHelper.generateSentryEvent(level: .error,
                                                   apiName: "PearProfileAPI",
                                                   functionName: "getDiscoveryFeed",
                                                   message: "Failed Discovery Serialization: \(error.localizedDescription)",
                                                   responseData: data,
                                                   tags: [:],
                                                   paylod: fullDictionary)
                  print("Failed to deserialize pear user from feed: \(error)")
                  print(userData)
                }
              }
              completion(.success(allFullProfiles))
            }            
          } else {
            print("Failed Discovery Feed Conversions")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "getDiscoveryFeed",
                                             message: "Failed Data Serialization",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "getDiscoveryFeed",
                                       message: error.localizedDescription)
      completion(.failure(DetachedProfileError.unknownError(error: error)))
    }
  }
    
  func validateDetachedProfileUpdates(updates: [String: Any]) -> Bool {
    let allowedKeys: [String] = ["firstName", "lastName", "boasts", "roasts", "questionResponses", "vibes", "bio", "dos", "donts", "interests", "images", "school", "schoolYear"]
    var allowed = true
    updates.forEach { (item) in
      if !allowedKeys.contains(item.key) {
        print(item)
        allowed = false
      }
    }
    return allowed
  }
  
  func validateUserProfileUpdates(updates: [String: Any]) -> Bool {
    let allowedKeys: [String] = ["boasts", "roasts", "questionResponses", "vibes", "bio", "dos", "donts", "interests"]
    var allowed = true
    updates.forEach { (item) in
      if !allowedKeys.contains(item.key) {
        print(item)
        allowed = false
      }
    }
    return allowed
  }
  
  func editUserProfile(profileDocumentID: String,
                       userID: String,
                       updates: [String: Any],
                       completion: @escaping (Result<Bool, ProfileAPIError>) -> Void) {
    return
    /*
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    guard validateUserProfileUpdates(updates: updates) else {
      print("Invalid update values")
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "editUserProfile",
                                       message: "Invalid Updates",
                                       responseData: nil,
                                       tags: [:],
                                       paylod: updates)
      completion(.failure(ProfileAPIError.invalidVariables))
      return
    }
    var finalUpdates = updates
    finalUpdates["creatorUser_id"] = userID
    finalUpdates["_id"] = profileDocumentID
    let fullDictionary: [String: Any] = [
      "query": PearProfileAPI.editUserProfileQuery,
      "variables": [
        "editUserProfileInput": finalUpdates
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ProfileAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data) {
            print(json)
          }
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "editUserProfile")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Edit User Profile: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "editUserProfile",
                                             message: "GraphQL Error: \(helperResult)",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "editUserProfile",
                                             message: message ?? "Failed to Edit User Profile",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully attached Detached Profile: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "editUserProfile",
                                       message: error.localizedDescription)
      completion(.failure(ProfileAPIError.unknownError(error: error)))
    }
 */
  }
  
  func editDetachedProfile(profileDocumentID: String,
                           userID: String,
                           updates: [String: Any],
                           completion: @escaping (Result<Bool, ProfileAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    guard validateDetachedProfileUpdates(updates: updates) else {
      print("Invalid update values")
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "editDetachedProfile",
                                       message: "Invalid Updates",
                                       responseData: nil,
                                       tags: [:],
                                       paylod: updates)
      completion(.failure(ProfileAPIError.invalidVariables))
      return
    }
    var finalUpdates = updates
    finalUpdates["creatorUser_id"] = userID
    finalUpdates["_id"] = profileDocumentID
    let fullDictionary: [String: Any] = [
      "query": PearProfileAPI.editDetachedProfileQuery,
      "variables": [
        "editDetachedProfileInput": finalUpdates
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ProfileAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data) {
            print(json)
          }
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "editDetachedProfile")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Edit Detached Profile: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "editDetachedProfile",
                                             message: "GraphQL Error: \(helperResult)",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "editDetachedProfile",
                                             message: message ?? "Failed to Edit Detached Profile",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Successfully Edited Detached Profile: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "editDetachedProfile",
                                       message: error.localizedDescription)
      completion(.failure(ProfileAPIError.unknownError(error: error)))
    }
  }
  
}

// MARK: Create Detached Profile Endpoint Helpers
extension PearProfileAPI {
  
  func convertUserProfileDataToQueryVariable(profileData: ProfileCreationData) throws -> [String: Any] {
    
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw DetachedProfileError.userNotLoggedIn
    }
    guard let creatorFirstName = DataStore.shared.currentPearUser?.firstName else {
      throw DetachedProfileError.userNotLoggedIn
    }
    
    let variablesDictionary: [String: Any] = [
      "creatorUser_id": userID,
      "creatorFirstName": creatorFirstName,
      "firstName": profileData.firstName,
      "lastName": profileData.lastName,
      "phoneNumber": profileData.phoneNumber,
      "boasts": profileData.boasts,
      "roasts": profileData.roasts,
      "questionResponses": profileData.questionResponses,
      "vibes": profileData.vibes
    ]
    
    return variablesDictionary
  }
  
}
