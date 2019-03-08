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
  case failedDeserialization
  case graphQLError(message: String)
}

class PearProfileAPI: ProfileAPI {
  
  static let shared = PearProfileAPI()
  
  private init() {
    fatalError("Please only use the singleton of this object")
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  // swiftlint:disable:next line_length
  static let createNewDetachedProfileQuery: String = "mutation CreateDetachedProfile($detachedProfileInput: CreationDetachedProfileInput) { createDetachedProfile(detachedProfileInput: $detachedProfileInput) { success message detachedProfile { creatorUser_id bio phoneNumber }}}"
  
}

// MARK: Routes
extension PearProfileAPI {
  func createNewDetachedProfile(gettingStartedUserProfileData: GettingStartedUserProfileData,
                                completion: @escaping (Result<PearDetachedProfile, Error>) -> Void) {
    
  }
}
