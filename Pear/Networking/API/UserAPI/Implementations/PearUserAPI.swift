//
//  UserUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

// swiftlint:disable file_length
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
  
  static let getFakeUserQuery: String = "query{ user(id:\"5ca7ecaa35db345290275f50\") \(PearUser.graphQLAllFields()) }"
  static let getUserQuery: String = "query GetUser($userInput: GetUserInput!) {getUser(userInput:$userInput){ success message user \(PearUser.graphQLCurrentUserFields()) }}"
  static let fetchEndorsedUsersQuery: String = "query GetEndorsedUsers($userInput: GetUserInput!) { getUser(userInput:$userInput) { success message user { endorsedUsers \(PearUser.graphQLAllFields()) detachedProfiles \((PearDetachedProfile.graphQLAllFields()))  }  }}"
  static let getExistingUsersQuery: String = "query GetAlreadyOnPear($phoneNumbers:[String!]!){alreadyOnPear(phoneNumbers: $phoneNumbers)}"
  
  func getUpdateUserQueryWithName(name: String) -> String {
    return "mutation \(name)($userInput: UpdateUserInput!){ updateUser(updateUserInput:$userInput){ success message } }"
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
            print("Failed to Get User: \(helperResult)")
            if DataStore.shared.fetchFlagFromDefaults(flag: .hasCreatedUser) {
              #if PROD
              SentryHelper.generateSentryEvent(level: .error,
                                               apiName: "PearUserAPI",
                                               functionName: "getUser",
                                               message: "GraphQL Error: \(helperResult)",
                                               responseData: data,
                                               tags: [:],
                                               paylod: fullDictionary)
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
                                               paylod: fullDictionary)
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
                                                 paylod: fullDictionary)
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
  
  func getFakeUser(completion: @escaping (Result<PearUser, UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    do {
      let fullDictionary: [String: Any] = [ "query": PearUserAPI.getFakeUserQuery ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(UserAPIError.unknownError(error: error)))
          return
        } else {
          if let data = data,
            let json = try? JSON(data: data), let userData = try? json["data"]["user"].rawData(),
              let user = try? JSONDecoder().decode(PearUser.self, from: userData) {
              completion(.success(user))
          } else {
            completion(.failure(UserAPIError.failedDeserialization))
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
                                             message: "GraphQL Error: \(helperResult)",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Get User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "fetchEndorsedUsers",
                                             message: message ?? "Returned Failure",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: message ?? "")))
          case .foundObjectData(let objectData):
            do {
              var endorsedUsers: [PearUser] = []
              if let endorsedUsersJSON = (try JSON(data: objectData)["endorsedProfileObjs"]).array {
                for endorsedUser in endorsedUsersJSON {
                  let userJSON = endorsedUser["userObj"]
                  if let matchingUserData = try? userJSON.rawData(),
                    let matchingUserObj = try? JSONDecoder().decode(PearUser.self, from: matchingUserData) {
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
                                               responseData: data,
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
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Create User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: "createUser",
                                             message: message ?? "Returned Error",
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
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
  
  func updateUserGender(userID: String,
                        gender: GenderEnum,
                        completion: @escaping(Result<Bool, UserAPIError>) -> Void) {
    let genderDictionary: [String: Any] = [
      "gender": gender.toString()
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
                                             responseData: data,
                                             tags: [:],
                                             paylod: fullDictionary)
            completion(.failure(UserAPIError.graphQLError(message: "\(helperResult)")))
          case .failure(let message):
            print("Failed to Update User: \(message ?? "")")
            SentryHelper.generateSentryEvent(level: .error,
                                             apiName: "PearUserAPI",
                                             functionName: mutationName,
                                             message: message ?? "Returned Failure",
                                             responseData: data,
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
  
  func getExistingUsers(checkNumbers: [String], completion: @escaping(Result<[String], UserAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = defaultHeaders
    let fullDictionary: [String: Any] = [
      "query": PearUserAPI.getExistingUsersQuery,
      "variables": [
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
                                           paylod: fullDictionary)
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

// MARK: - Create User Endpoint Helpers
extension PearUserAPI {
  
  func convertUserDataToQueryVariable(userData: OldUserCreationData) throws -> [String: Any] {
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
