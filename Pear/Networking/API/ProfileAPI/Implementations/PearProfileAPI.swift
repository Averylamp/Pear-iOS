//
//  PearProfileAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//
// swiftlint:disable file_length

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
  
  static let createNewDetachedProfileQuery: String = "mutation CreateDetachedProfile($detachedProfileInput: CreationDetachedProfileInput) { createDetachedProfile(detachedProfileInput: $detachedProfileInput) { success message detachedProfile \(PearDetachedProfile.graphQLDetachedProfileFieldsAll) }}"
  
  static let findDetachedProfilesQuery: String = "query FindDetachedProfiles($phoneNumber: String) { findDetachedProfiles(phoneNumber: $phoneNumber) \(PearDetachedProfile.graphQLDetachedProfileFieldsAll) }"
  
  // swiftlint:disable:next line_length
  static let attachDetachedProfileQuery: String = "mutation AttachDetachedProfile($user_id:ID!, $detachedProfile_id:ID!, $creatorUser_id:ID!) { approveNewDetachedProfile(user_id:$user_id, detachedProfile_id:$detachedProfile_id, creatorUser_id:$creatorUser_id){ message success } }"
  
  static let fetchCurrentFeedQuery: String = "query GetDiscoveryFeed($user_id: ID!){ getDiscoveryFeed(user_id:$user_id){ currentDiscoveryItems { user \(MatchingPearUser.graphQLMatchedUserFieldsAll) } }}"
  static let fetchMatchingUserQuery: String = "query GetMatchUser($user_id: ID!){ user(id: $user_id) { user \(MatchingPearUser.graphQLMatchedUserFieldsAll) }"
  
  // swiftlint:disable:next line_length
  static let editUserProfileQuery: String = "mutation EditUserProfile($editUserProfileInput:EditUserProfileInput!){ editUserProfile(editUserProfileInput: $editUserProfileInput){ success message}}"
  // swiftlint:disable:next line_length
  static let editDetachedProfileQuery: String = "mutation EditDetachedProfile($editDetachedProfileInput:EditDetachedProfileInput!){ editDetachedProfile(editDetachedProfileInput: $editDetachedProfileInput){ success message}}"
  
}

// MARK: Routes
extension PearProfileAPI {
  func createNewDetachedProfile(gettingStartedUserProfileData: UserProfileCreationData,
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
          "detachedProfileInput": try convertUserProfileDataToQueryVariable(userProfileData: gettingStartedUserProfileData)
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
              paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "createDetachedProfile",
                                             message: message ?? "Failed to create user",
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
                                           message: error.localizedDescription)
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
                             completion: @escaping(Result<Bool, DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.attachDetachedProfileQuery,
        "variables": [
          "user_id": user_id,
          "detachedProfile_id": detachedProfile_id,
          "creatorUser_id": creatorUser_id
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
              tags: [:],
              paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "approveNewDetachedProfile",
                                             message: message ?? "Failed to Approve Detached Profile",
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
                  let matchingPearUser = try JSONDecoder().decode(MatchingPearUser.self, from: userRawData)
                  if matchingPearUser.userProfiles.count > 0 {
                    let fullProfile = FullProfileDisplayData(matchingUser: matchingPearUser)
                    allFullProfiles.append(fullProfile)
                  }
                } catch {
                  SentryHelper.generateSentryEvent(level: .error,
                                                   apiName: "PearProfileAPI",
                                                   functionName: "getDiscoveryFeed",
                                                   message: "Failed Discovery Serialization: \(error.localizedDescription)",
                    tags: [:],
                    paylod: fullDictionary)
                  print("Failed to deserialize pear user from feed: \(error)")
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
  
  func getMatchingUser(user_id: String,
                       completion: @escaping(Result<FullProfileDisplayData, DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.fetchMatchingUserQuery,
        "variables": [
          "user_id": user_id
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
                                           functionName: "getMatchingUser",
                                           message: error.localizedDescription)
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseObjectData(data: data, functionName: "user", objectName: "user")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Fetch User: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "getMatchingUser",
                                             message: "GraphQL Error: \(helperResult)",
              tags: [:],
              paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "getMatchingUser",
                                             message: message ?? "Failed to Get user",
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let matchingPearUser = try JSONDecoder().decode(MatchingPearUser.self, from: objectData)
              if matchingPearUser.userProfiles.count > 0 {
                let fullProfile = FullProfileDisplayData(matchingUser: matchingPearUser)
                completion(.success(fullProfile))
              } else {
                completion(.failure(DetachedProfileError.unknown))
              }
              print("Successfully found Detached Profile")
            } catch {
              print("Deserialization Error: \(error)")
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearProfileAPI",
                                               functionName: "getMatchingUser",
                                               message: "DeserializationError: \(error.localizedDescription)",
                tags: [:],
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
                                       functionName: "getMatchingUser",
                                       message: error.localizedDescription)
      completion(.failure(DetachedProfileError.unknownError(error: error)))
    }
    
  }
  
  func validateUserProfileUpdates(updates: [String: Any]) -> Bool {
    let allowedKeys: [String] = ["interests", "vibes", "bio", "dos", "donts"]
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
                                       tags: [:],
                                       paylod: updates)
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
              tags: [:],
              paylod: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "editUserProfile",
                                             message: message ?? "Failed to Edit User Profile",
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
    
    guard validateUserProfileUpdates(updates: updates) else {
      print("Invalid update values")
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "editDetachedProfile",
                                       message: "Invalid Updates",
                                       tags: [:],
                                       paylod: updates)
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
              tags: [:],
              paylod: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "editDetachedProfile",
                                             message: message ?? "Failed to Edit Detached Profile",
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
  
  func convertUserProfileDataToQueryVariable(userProfileData: UserProfileCreationData) throws -> [String: Any] {
    
    guard
      
      let firstName = userProfileData.firstName,
      let phoneNumber = userProfileData.phoneNumber,
      let age = userProfileData.age,
      let gender = userProfileData.gender,
      let bio = userProfileData.bio else {
        throw DetachedProfileError.invalidVariables
    }
    
    let imageContainer = userProfileData.images
      .filter({ $0.imageContainer != nil })
      .map({ $0.imageContainer!.dictionary })
      .filter({$0 != nil})
    
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw DetachedProfileError.userNotLoggedIn
    }
    guard let creatorFirstName = DataStore.shared.currentPearUser?.firstName else {
      throw DetachedProfileError.userNotLoggedIn
    }
    
    var variablesDictionary: [String: Any] = [
      "creatorUser_id": userID,
      "creatorFirstName": creatorFirstName,
      "firstName": firstName,
      "phoneNumber": phoneNumber,
      "age": age,
      "gender": gender.rawValue,
      "interests": userProfileData.interests,
      "vibes": userProfileData.vibes,
      "bio": bio,
      "dos": userProfileData.dos,
      "donts": userProfileData.donts,
      "images": imageContainer
    ]
    
    let defaultCoordinates: [Double] = [42.3601, -71.0589]
    variablesDictionary["location"] = defaultCoordinates
    variablesDictionary["locationName"] = "Boston Area"
    
    return variablesDictionary
  }
  
}
