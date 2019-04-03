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
  func createNewUser(with gettingStartedUserData: UserCreationData, completion: @escaping (Result<PearUser, UserAPIError>) -> Void)
  func getUser(uid: String, token: String, completion: @escaping (Result<PearUser, UserAPIError>) -> Void)
  func fetchEndorsedUsers(uid: String,
                          token: String,
                          completion: @escaping (Result<
    (endorsedProfiles: [MatchingPearUser], detachedProfiles: [PearDetachedProfile]), UserAPIError>) -> Void)
  
  // swiftlint:disable:next function_parameter_count
  func updateUserPreferences(userID: String,
                             genderPrefs: [String],
                             minAge: Int,
                             maxAge: Int,
                             locationName: String?,
                             completion: @escaping(Result<Bool, UserAPIError>) -> Void)
}
