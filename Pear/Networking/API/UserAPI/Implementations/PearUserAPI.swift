//
//  UserUploadAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 sam. All rights reserved.
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
        
    }
    
    let defaultHeaders: [String: String] = [
        "Content-Type": "application/json"
    ]
    
    static let createUserQuery: String = "mutation CreateUser($userInput: CreationUserInput) {createUser(userInput: $userInput) { success message \(PearUser.graphQLUserFields) }}"
    
    static let getUserQuery: String = "mutation GetUser($userInput: GetUserInput) {getUser(userInput:$userInput){ success message \(PearUser.graphQLUserFields) }}"
}

// MARK: - Routes
extension PearUserAPI {
    
    func getUser(uid: String, token: String, completion: @escaping (Result<PearUser, Error>) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "\(Config.graphQLHost)")! as URL,
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
                    return
                } else {
                    if  let data = data,
                        let json = try? JSON(data: data),
                        let getUserResponse = json["data"]["getUser"].dictionary,
                        let success = getUserResponse["success"]?.bool,
                        let message = getUserResponse["message"]?.string,
                        let pearUserDictionary = try? getUserResponse["user"]?.dictionaryObject,
                        let pearUserData = try? getUserResponse["user"]?.rawData() {
                        do {
                            print(pearUserDictionary)
                            let pearUser = try JSONDecoder().decode(PearUser.self, from: pearUserData!)
                            completion(.success(pearUser))
                            return
                        } catch {
                            print("Error: \(error)")
                            completion(.failure(error))
                            return
                        }
                        //                        guard let unwrappedPearUser = pearUser else {
                        //                            print("Failed to deserialize: \(error as Any)")
                        //                            if let error = error {
                        //                                completion(.failure(error))
                        //                            } else {
                        //                                completion(.failure(UserCreationError.failedDeserialization))
                        //                            }
                        //                            return
                        //                        }
                        //                        completion(.success(unwrappedPearUser))
                        completion(.failure(UserCreationError.failedDeserialization))
                        return
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
        let request = NSMutableURLRequest(url: NSURL(string: "\(Config.graphQLHost)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders
        
        do {
            let queryData = try convertUserDataToQueryVariable(userData: gettingStartedUserData)
            request.httpBody = queryData
            
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let error = error {
                    print(error as Any)
                    return
                } else {
                    print(response as Any)
                    print(data as Any)
                    if let data = data, let json = try? JSON(data: data) {
                        print(json)
                    } else {
                        print("Failed Conversions")
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
        guard let firstName = userData.firstName,
            let lastName = userData.lastName,
            let email = userData.email,
            let age = userData.age,
            let phoneNumber = userData.phoneNumber,
            let firebaseUID = userData.firebaseAuthID,
            let firebaseToken = userData.firebaseToken else {
                throw UserCreationError.invalidVariables
        }
        
        var variablesDictionary: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "age": age,
            "email": email,
            "emailVerified": userData.emailVerified,
            "phoneNumber": phoneNumber,
            "phoneNumberVerified": userData.phoneNumberVerified,
            "firebaseAuthID": firebaseUID,
            "firebaseToken": firebaseToken
        ]
        
        if let facebookId = userData.facebookId {
            variablesDictionary["facebookId"] = facebookId
        }
        if let facebookAccessToken = userData.facebookAccessToken {
            variablesDictionary["facebookAccessToken"] = facebookAccessToken
        }
        //        if let birthdate = userData.birthdate {
        //            variablesDictionary["birthdate"] = Int(birthdate.timeIntervalSince1970)
        //        }
        
        let fullDictionary: [String: Any] = [
            "query": PearUserAPI.createUserQuery,
            "variables": [
                "userInput": variablesDictionary
            ]
        ]
        
        let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
        return data
    }
}