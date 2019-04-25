//
//  ProfileAPI.swift
//  Pear
//
//  Created by Avery Lamp on 2/24/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum DetachedProfileError: Error {
  case invalidVariables
  case userNotLoggedIn
  case failedDeserialization
  case noDetachedProfilesFound
  case graphQLError(message: String)
  case unknown
  case unknownError(error: Error)
}

enum ProfileAPIError: Error {
  case graphQLError(message: String)
  case unknownError(error: Error)
  case invalidVariables
  case failedDeserialization
}

protocol ProfileAPI {
  func createNewDetachedProfile(profileCreationData: ProfileCreationData,
                                completion: @escaping(Result<PearDetachedProfile, DetachedProfileError>) -> Void)
  func checkDetachedProfiles(phoneNumber: String, completion: @escaping(Result<[PearDetachedProfile], DetachedProfileError>) -> Void)
  func attachDetachedProfile(user_id: String, detachedProfile_id: String, creatorUser_id: String,
                             approvedContent: [String: Any], completion: @escaping(Result<Bool, DetachedProfileError>) -> Void)
  func getDiscoveryFeed(user_id: String,
                        completion: @escaping(Result<[FullProfileDisplayData], DetachedProfileError>) -> Void)
}
