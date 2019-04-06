//
//  MatchesAPI.swift
//  Pear
//
//  Created by Avery Lamp on 4/4/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum MatchesAPIError: Error {
  case userNotLoggedIn
  case failedDeserialization
  case graphQLError(message: String)
  case unknown
  case unknownError(error: Error)
}

protocol MatchesAPI {
  func createMatchRequest(sentByUserID: String,
                          sentForUserID: String,
                          receivedByUserID: String,
                          requestText: String?,
                          completion: @escaping(Result<Bool, MatchesAPIError>) -> Void)
  func getMatchesForUser(uid: String, token: String, completion: @escaping (Result<[Match], MatchesAPIError>) -> Void)

}
