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
  static let editEndorsedProfileQuery: String = "mutation EditEndorsedProfile($editEndorsementInput:EditEndorsementInput!){ editEndorsement(editEndorsementInput: $editEndorsementInput){ success message}}"
  // swiftlint:disable:next line_length
  static let editDetachedProfileQuery: String = "mutation EditDetachedProfile($editDetachedProfileInput:EditDetachedProfileInput!){ editDetachedProfile(editDetachedProfileInput: $editDetachedProfileInput){ success message}}"
  
}

// MARK: Routes
extension PearProfileAPI {
  func createNewDetachedProfile(profileCreationData: ProfileCreationData,
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
          "detachedProfileInput": try convertUserProfileDataToQueryVariable(profileData: profileCreationData)
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      print(String(data: data, encoding: .utf8) ?? "")
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        APIHelpers.printDataDump(data: data)
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
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             payload: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "createDetachedProfile",
                                             message: message ?? "Failed to create user",
                                             responseData: data,
                                             payload: fullDictionary)
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
                                               payload: fullDictionary)
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
                                               payload: fullDictionary)
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
                                             payload: fullDictionary)
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
  
  func attachDetachedProfile(detachedProfile: PearDetachedProfile, completion: @escaping(Result<Bool, DetachedProfileError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    do {
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.attachDetachedProfileQuery,
        "variables": [
          "approveDetachedProfileInput": try convertApprovalInputDataToQueryVariable(detachedProfile: detachedProfile)
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
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Approve Detached Profile: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "approveNewDetachedProfile",
                                             message: message ?? "Failed to Approve Detached Profile",
                                             responseData: data,
                                             tags: [:],
                                             payload: fullDictionary)
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
                                           payload: fullDictionary)
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
                                                   payload: fullDictionary)
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
                                             payload: fullDictionary)
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
  
  func updateDetachedProfile(updates: [String: Any], completion: @escaping(Result<Bool, ProfileAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    let fullDictionary: [String: Any] = [
      "query": PearProfileAPI.editDetachedProfileQuery,
      "variables": [
        "editDetachedProfileInput": updates
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ProfileAPIError.unknownError(error: error)))
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearProfileAPI",
                                           functionName: "updateDetachedProfile",
                                           message: error.localizedDescription,
                                           responseData: data)
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "editDetachedProfile")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update Detached Profile Request: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "updateDetachedProfile",
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             payload: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create Match Request: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "updateDetachedProfile",
                                             message: message ?? "Failed to Update",
                                             responseData: data,
                                             payload: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Update Profile Network Message: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "updateDetachedProfile",
                                       message: error.localizedDescription)
      completion(.failure(ProfileAPIError.unknownError(error: error)))
    }
  }
  
  func updateEndorsedProfile(updates: [String: Any], completion: @escaping(Result<Bool, ProfileAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    let fullDictionary: [String: Any] = [
      "query": PearProfileAPI.editEndorsedProfileQuery,
      "variables": [
        "editEndorsementInput": updates
      ]
    ]
    
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ProfileAPIError.unknownError(error: error)))
          SentryHelper.generateSentryEvent(level: .error,
                                           apiName: "PearProfileAPI",
                                           functionName: "updateEndorsedUserProfile",
                                           message: error.localizedDescription,
                                           responseData: data)
          return
        } else {
          let helperResult = APIHelpers.interpretGraphQLResponseSuccess(data: data, functionName: "editEndorsement")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage:
            print("Failed to Update Detached Profile Request: \(helperResult)")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "updateEndorsedUserProfile",
                                             message: "GraphQL Error: \(String(describing: helperResult))",
                                             responseData: data,
                                             payload: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create Match Request: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearProfileAPI",
                                             functionName: "updateEndorsedUserProfile",
                                             message: message ?? "Failed to Update",
                                             responseData: data,
                                             payload: fullDictionary)
            completion(.failure(ProfileAPIError.graphQLError(message: message ?? "")))
          case .success(let message):
            print("Update Profile Network Message: \(String(describing: message))")
            completion(.success(true))
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      SentryHelper.generateSentryEvent(level: .error,
                                       apiName: "PearProfileAPI",
                                       functionName: "updateEndorsedUserProfile",
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
    guard let creatorFirstName = DataStore.shared.currentPearUser?.firstName  else {
      throw DetachedProfileError.userNotLoggedIn
    }
    
    var variablesDictionary: [String: Any] = [
      "creatorUser_id": userID,
      "creatorFirstName": creatorFirstName,
      "firstName": profileData.firstName,
      "lastName": profileData.lastName,
      "phoneNumber": profileData.phoneNumber,
      "boasts": profileData.boasts.map({ $0.toGraphQLInput() }),
      "roasts": profileData.roasts.map({ $0.toGraphQLInput() }),
      "questionResponses": profileData.questionResponses.map({ $0.toGraphQLInput() }),
      "vibes": profileData.vibes.map({ $0.toGraphQLInput() })
    ]
    
    if let gender = profileData.gender {
      variablesDictionary["gender"] = gender.rawValue
    }
    
    return variablesDictionary
  }
  
  func convertApprovalInputDataToQueryVariable(detachedProfile: PearDetachedProfile) throws -> [String: Any] {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw DetachedProfileError.userNotLoggedIn
    }
    let variablesDictionary: [String: Any] = [
      "user_id": userID,
      "detachedProfile_id": detachedProfile.documentID as Any,
      "creatorUser_id": detachedProfile.creatorUserID as Any,
      "boasts": detachedProfile.boasts.map({ $0.toGraphQLInput() }),
      "roasts": detachedProfile.roasts.map({ $0.toGraphQLInput() }),
      "questionResponses": detachedProfile.questionResponses.map({ $0.toGraphQLInput() }),
      "vibes": detachedProfile.vibes.map({ $0.toGraphQLInput() })
    ]
    return variablesDictionary
  }
  
}
