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
    case graphQLError(message: String)
}

class UserCreateAPI: UserAPI {

    static let shared = UserCreateAPI()

    private init() {

    }

    static let createUserQuery: String = "mutation CreateUser($userInput: CreationUserInput) {\n  createUser(userInput: $userInput) {\n    success\n    message\n    user {\n      _id\n      deactivated\n      firebaseToken\n      firebaseAuthID\n      facebookId\n      facebookAccessToken\n      email\n      phoneNumber\n      phoneNumberVerified\n      firstName\n      lastName\n      thumbnailURL\n      gender\n      locationName\n      locationCoordinates\n      school\n      schoolEmail\n      schoolEmailVerified\n      birthdate\n      age\n      profile_ids\n\n      endorsedProfile_ids\n\n      userPreferences {\n        seekingGender\n      }\n      userStatData {\n        totalNumberOfMatches\n        totalNumberOfMatches\n      }\n      userDemographics {\n        ethnicities\n      }\n      userMatches_id\n      discovery_id\n      pearPoints\n    }\n  }\n}\n"

    func convertUserDataToQueryVariable(userData: GettingStartedUserData) throws -> Data {
        guard let firstName = userData.firstName,
            let lastName = userData.lastName,
            let email = userData.email,
            let age = userData.age,
            let phoneNumber = userData.phoneNumber else {
                throw UserCreationError.invalidVariables
        }

        var variablesDictionary: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "emailVerified": userData.emailVerified,
            "age": age,
            "phoneNumber": phoneNumber,
            "phoneNumberVerified": userData.phoneNumberVerified
        ]

        if let firebaseToken = userData.firebaseToken {
            variablesDictionary["firebaseToken"] = firebaseToken
        }
        if let firebaseAuthID = userData.firebaseAuthID {
            variablesDictionary["firebaseAuthID"] = firebaseAuthID
        }
        if let facebookId = userData.facebookId {
            variablesDictionary["facebookId"] = facebookId
        }
        if let facebookAccessToken = userData.facebookAccessToken {
            variablesDictionary["facebookAccessToken"] = facebookAccessToken
        }
        if let birthdate = userData.birthdate {
            variablesDictionary["birthdate"] = Int(birthdate.timeIntervalSince1970)
        }

        let fullDictionary: [String: Any] = [
            "query": UserCreateAPI.createUserQuery,
            "variables": [
                "userInput": variablesDictionary
            ]
        ]

        print(fullDictionary)

        let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
        return data
    }

    func createNewUser(with gettingStartedUserData: GettingStartedUserData, completion: @escaping (Result<PearUser, Error>) -> Void) {
        let headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "\(Config.graphQLHost)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers

        do {
            let queryData = try convertUserDataToQueryVariable(userData: gettingStartedUserData)
            request.httpBody = queryData

            let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let error = error {
                    print(error as Any)
                    return
                } else {
                    print(response)
                    print(data)
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
