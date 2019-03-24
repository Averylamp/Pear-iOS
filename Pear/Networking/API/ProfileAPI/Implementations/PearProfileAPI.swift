//
//  PearProfileAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class PearProfileAPI: ProfileAPI {
  
  static let shared = PearProfileAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let createNewDetachedProfileQuery: String = "mutation CreateDetachedProfile($detachedProfileInput: CreationDetachedProfileInput) { createDetachedProfile(detachedProfileInput: $detachedProfileInput) { success message detachedProfile \(PearDetachedProfile.graphQLDetachedProfileFields) }}"
  
  static let findDetachedProfilesQuery: String = "query FindDetachedProfiles($phoneNumber: String) { findDetachedProfiles(phoneNumber: $phoneNumber) \(PearDetachedProfile.graphQLDetachedProfileFields) }"
  
  // swiftlint:disable:next line_length
  static let attachDetachedProfileQuery: String = "mutation AttachDetachedProfile($user_id:ID!, $detachedProfile_id:ID!, $creatorUser_id:ID!) { approveNewDetachedProfile(user_id:$user_id, detachedProfile_id:$detachedProfile_id, creatorUser_id:$creatorUser_id){ message success } }"
  
  static let fetchCurrentFeedQuery: String = "query GetDiscoveryFeed($user_id: ID!){ getDiscoveryFeed(user_id:$user_id){ currentDiscoveryItems { user \(PearUser.graphQLUserFields) } }}"
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
          let helperResult = APIHelpers.interpretGraphQLResponse(data: data, functionName: "createDetachedProfile", objectName: "detachedProfile")
          switch helperResult {
          case .dataNotFound, .notJsonSerializable, .couldNotFindSuccessOrMessage, .didNotFindObjectData:
            print("Failed to Create User: \(helperResult)")
            completion(.failure(DetachedProfileError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            completion(.failure(DetachedProfileError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              let detachedProfile = try JSONDecoder().decode(PearDetachedProfile.self, from: objectData)
              print("Successfully found Detached Profile")
              completion(.success(detachedProfile))
            } catch {
              print("Deserialization Error: \(error)")
              completion(.failure(DetachedProfileError.failedDeserialization))
            }
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
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
          return
        } else {
          if  let data = data,
            let json = try? JSON(data: data) {
            do {
              if let profiles = json["data"]["findDetachedProfiles"].array {
                var detachedProfiles: [PearDetachedProfile] = []
                print("\(profiles.count) Detached profiles found matching your phone number")
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
              completion(.failure(DetachedProfileError.unknownError(error: error)))
              return
            }
          } else {
            print("Failed Conversions")
            completion(.failure(DetachedProfileError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
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
          if  let data = data,
            let json = try? JSON(data: data) {
            print("Finished Attaching Detached Profile")
            if let success = json["data"]["approveNewDetachedProfile"]["success"].bool {
              completion(.success(success))
              return
            } else {
              completion(.failure(DetachedProfileError.unknown))
            }
            
          } else {
            print("Failed Conversions")
            completion(.failure(DetachedProfileError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
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
                  if let userRawData = try? userData["user"].rawData() {
                    let pearUser = try JSONDecoder().decode(PearUser.self, from: userRawData)
                    if pearUser.userProfiles.count > 0,
                      let fullProfile = try? FullProfileDisplayData(user: pearUser, profiles: pearUser.userProfiles) {
                      allFullProfiles.append(fullProfile)
                    }
                  }
                } catch {
                  print("Failed to deserialize pear user from feed: \(error)")
                  print(userData)
                }
              }
              completion(.success(allFullProfiles))
            }            
          } else {
            print("Failed Conversions")
            completion(.failure(DetachedProfileError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch let error as DetachedProfileError {
      
      print("Invalid variables for detached profile error")
      completion(.failure(DetachedProfileError.unknownError(error: error)))
    } catch {
      print(error)
      completion(.failure(DetachedProfileError.unknownError(error: error)))
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
