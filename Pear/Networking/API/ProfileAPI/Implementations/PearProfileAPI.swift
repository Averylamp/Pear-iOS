//
//  PearProfileAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ProfileCreationError: Error {
  case invalidVariables
  case userNotLoggedIn
  case failedDeserialization
  case graphQLError(message: String)
}

class PearProfileAPI: ProfileAPI {
  
  static let shared = PearProfileAPI()
  
  private init() {
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let createNewDetachedProfileQuery: String = "mutation CreateDetachedProfile($detachedProfileInput: CreationDetachedProfileInput) { createDetachedProfile(detachedProfileInput: $detachedProfileInput) { success message detachedProfile \(PearDetachedProfile.graphQLDetachedProfileFields) }}"
  
  static let findDetachedProfilesQuery: String = "query FindDetachedProfiles($phoneNumber: String) { findDetachedProfiles(phoneNumber: $phoneNumber) \(PearDetachedProfile.graphQLDetachedProfileFields) }"

}

// MARK: Routes
extension PearProfileAPI {
  func createNewDetachedProfile(gettingStartedUserProfileData: GettingStartedUserProfileData,
                                completion: @escaping (Result<PearDetachedProfile, Error>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.createNewDetachedProfileQuery,
        "variables": [
          "detachedProfileInput": try converUserProfileDataToQueryVariable(userProfileData: gettingStartedUserProfileData)
        ]
      ]
      
      print(fullDictionary)
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(error))
          return
        } else {
          if  let data = data,
            let json = try? JSON(data: data) {
              print(json)
            do {
//              let pearUserData = try getUserResponse["user"]?.rawData()
//              if let pearUserData = pearUserData {
//                let pearUser = try JSONDecoder().decode(PearUser.self, from: pearUserData)
//                print("Successfully found Pear User")
//                completion(.success(pearUser))
//                return
//              } else {
//                print("Failed to get Pear User Data")
//                completion(.failure(UserCreationError.failedDeserialization))
//                return
//              }
              completion(.failure(UserCreationError.failedDeserialization))
            } catch {
              print("Error: \(error)")
              completion(.failure(error))
              return
            }
          } else {
            print("Failed Conversions")
            completion(.failure(UserCreationError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch let error as UserCreationError {
      
      print("Invalid variables for user creation error")
      completion(.failure(error))
    } catch {
      print(error)
      completion(.failure(error))
    }
    
  }
  
  func checkDetachedProfiles(phoneNumber: String, completion: @escaping(Result<[PearDetachedProfile], Error>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
//    request.addValue(phoneNumber, forHTTPHeaderField: "phoneNumber")
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearProfileAPI.findDetachedProfilesQuery,
        "variables": [
          "phoneNumber": phoneNumber
        ]
      ]
      
      print(fullDictionary)
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(error))
          return
        } else {
          if  let data = data,
            let json = try? JSON(data: data) {
            print(json)
            if let profiles = json.array {
              print("\(profiles.count) Detached profiles found matching your phone number")
            }
            do {
              
            } catch {
              print("Error: \(error)")
              completion(.failure(error))
              return
            }
          } else {
            print("Failed Conversions")
            completion(.failure(UserCreationError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch let error as UserCreationError {
      
      print("Invalid variables for user creation error")
      completion(.failure(error))
    } catch {
      print(error)
      completion(.failure(error))
    }

  }
  
}

// MARK: Create Detached Profile Endpoint Helpers
extension PearProfileAPI {
  
  func converUserProfileDataToQueryVariable(userProfileData: GettingStartedUserProfileData) throws -> [String: Any] {
    
    guard
   
      let firstName = userProfileData.firstName,
      let phoneNumber = userProfileData.phoneNumber,
      let age = userProfileData.age,
      let gender = userProfileData.gender,
      let bio = userProfileData.bio else {
        throw ProfileCreationError.invalidVariables
    }

    let (imageIDs, imageSizes) = ImageAllSizesRepresentation
      .convertArrayToDatabaseFormat(images: userProfileData.images
        .filter({ $0.imageSizesRepresentation != nil })
        .map({ $0.imageSizesRepresentation! }))
    
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw ProfileCreationError.userNotLoggedIn
    }
    
    let variablesDictionary: [String: Any] = [
      "creatorUser_id": userID,
      "firstName": firstName,
      "phoneNumber": phoneNumber,
      "age": age,
      "gender": gender.rawValue,
      "interests": userProfileData.interests,
      "vibes": userProfileData.vibes,
      "bio": bio,
      "dos": userProfileData.dos,
      "donts": userProfileData.donts,
      "imageIDs": imageIDs,
      "images": imageSizes
    ]
    
    return variablesDictionary
  }
  
}