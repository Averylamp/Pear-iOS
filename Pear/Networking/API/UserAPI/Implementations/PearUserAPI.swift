//
//  UserUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UserCreationError: Error {
   case invalidVariables
   case failedDeserialization
   case graphQLError(message: String)
}

class PearUserAPI: UserAPI {
   
   static let shared = PearUserAPI()
   
   private init() {
      fatalError("Please only use the singleton of this object")
   }
   
   let defaultHeaders: [String: String] = [
      "Content-Type": "application/json"
   ]
   
   static let createUserQuery: String = "mutation CreateUser($userInput: CreationUserInput) {createUser(userInput: $userInput) { success message user \(PearUser.graphQLUserFields) }}"
   
   static let getUserQuery: String = "mutation GetUser($userInput: GetUserInput) {getUser(userInput:$userInput){ success message user \(PearUser.graphQLUserFields) }}"
}

// MARK: - Routes
extension PearUserAPI {
   
   func getUser(uid: String, token: String, completion: @escaping (Result<PearUser, Error>) -> Void) {
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
               completion(.failure(error))
               return
            } else {
               if  let data = data,
                  let json = try? JSON(data: data),
                  let getUserResponse = json["data"]["getUser"].dictionary {
                  do {
                     let pearUserData = try getUserResponse["user"]?.rawData()
                     if let pearUserData = pearUserData {
                        let pearUser = try JSONDecoder().decode(PearUser.self, from: pearUserData)
                        print("Successfully found Pear User")
                        completion(.success(pearUser))
                        return
                     } else {
                        print("Failed to get Pear User Data")
                        completion(.failure(UserCreationError.failedDeserialization))
                        return
                     }
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
   
   func createNewUser(with gettingStartedUserData: GettingStartedUserData, completion: @escaping (Result<PearUser, Error>) -> Void) {
      let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                        timeoutInterval: 15.0)
      request.httpMethod = "POST"
      request.allHTTPHeaderFields = defaultHeaders
      
      do {
         let queryData = try convertUserDataToQueryVariable(userData: gettingStartedUserData)
         request.httpBody = queryData
         
         let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
            print("Data task returned")
            if let error = error {
               print(error as Any)
               completion(.failure(error))
               return
            } else {
               if  let data = data,
                  let json = try? JSON(data: data) {
                  print(json)
               }
               if  let data = data,
                  let json = try? JSON(data: data),
                  let getUserResponse = json["data"]["createUser"].dictionary {
                  do {
                     let pearUserData = try getUserResponse["user"]?.rawData()
                     if let pearUserData = pearUserData {
                        let pearUser = try JSONDecoder().decode(PearUser.self, from: pearUserData)
                        print("Successfully found Pear User")
                        completion(.success(pearUser))
                        return
                     } else {
                        print("Failed to get Pear User Data")
                        completion(.failure(UserCreationError.failedDeserialization))
                        return
                     }
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

// MARK: - Create User Endpoint Helpers
extension PearUserAPI {
   
   func convertUserDataToQueryVariable(userData: GettingStartedUserData) throws -> Data {
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
            throw UserCreationError.invalidVariables
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
      
      let fullDictionary: [String: Any] = [
         "query": PearUserAPI.createUserQuery,
         "variables": [
            "userInput": variablesDictionary
         ]
      ]
      print(fullDictionary)
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      return data
   }
}
