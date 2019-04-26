//
//  UserAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum UserAPIError: Error {
  case unknownError(error: Error)
  case invalidVariables
  case failedDeserialization
  case unauthenticated
  case graphQLError(message: String)
}

protocol UserAPI {
  func createNewUser(userCreationData: UserCreationData, completion: @escaping (Result<PearUser, UserAPIError>) -> Void)
  func getUser(uid: String, token: String, completion: @escaping (Result<PearUser, UserAPIError>) -> Void)
  func getExistingUsers(checkNumbers: [String], completion: @escaping(Result<[String], UserAPIError>) -> Void)
  func fetchEndorsedUsers(uid: String,
                          token: String,
                          completion: @escaping (Result<
    (endorsedProfiles: [PearUser], detachedProfiles: [PearDetachedProfile]), UserAPIError>) -> Void)
  
  // swiftlint:disable:next function_parameter_count
  func updateUserPreferences(userID: String,
                             genderPrefs: [String],
                             minAge: Int,
                             maxAge: Int,
                             locationName: String?,
                             isSeeking: Bool?,
                             completion: @escaping(Result<Bool, UserAPIError>) -> Void)
  
  func updateUser(userID: String,
                  updates: [String: Any],
                  completion: @escaping(Result<Bool, UserAPIError>) -> Void)
  
  func getFakeUser(completion: @escaping (Result<PearUser, UserAPIError>) -> Void)
}
