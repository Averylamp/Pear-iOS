//
//  DisoveryAPI.swift
//  Pear
//
//  Created by Avery Lamp on 5/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum DiscoveryAPIError: Error {
  case unknownError(error: Error?)
  case invalidVariables
  case failedDeserialization
  case unauthenticated
  case graphQLError(message: String)
}

protocol DiscoveryAPI {
  func getDiscoveryFeed(userID: String, last: Int, completion: @escaping(Result<[FullProfileDisplayData], DiscoveryAPIError>) -> Void)
  func skipDiscoveryItem(userID: String, discoveryItemID: String, completion: @escaping(Result<Bool, DiscoveryAPIError>) -> Void)
}
