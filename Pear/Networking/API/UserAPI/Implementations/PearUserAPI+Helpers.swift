//
//  PearUserAPI+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 5/28/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Sentry
import CodableFirebase

// MARK: - General Helpers
extension PearUserAPI {

  func getCurrentUserID()throws  -> String {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      throw UpdateUserAPIError.currentUserNotFound
    }
    return userID
  }
  
}

// MARK: - Create User Endpoint Helpers
extension PearUserAPI {
  
}
