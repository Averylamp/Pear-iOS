//
//  DataStore+UserDefaults.swift
//  Pear
//
//  Created by Avery Lamp on 3/30/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

extension DataStore {
  
  enum UserDefaultKeys: String {
    case skippedDetachedProfiles
    case blockedUsers
    case matchedUsers
  }
  
  func fetchListFromDefaults(type: UserDefaultKeys) -> [String] {
    if let result = UserDefaults.standard.array(forKey: type.rawValue) as? [String] {
      return result
    }
    return []
  }
  
  func saveListToDefaults(list: [String], type: UserDefaultKeys) {
    UserDefaults.standard.set(list, forKey: type.rawValue)
  }
  
  func matchedUserKey(userID: String) -> String {
    return UserDefaultKeys.matchedUsers.rawValue + "-" + userID
  }
  
  func matchedUsersFromDefaults(userID: String) -> [String] {
    if let result = UserDefaults.standard.array(forKey: matchedUserKey(userID: userID) ) as? [String] {
      return result
    }
    return []
  }
  
  func addMatchedUserToDefaults(userID: String, matchedUserID: String) {
    var existingMatchedUsers = self.matchedUsersFromDefaults(userID: userID)
    print("Adding \(matchedUserID) to \(existingMatchedUsers)")
    if existingMatchedUsers.firstIndex(of: matchedUserID) == nil {    
      existingMatchedUsers.append(matchedUserID)
    }
    UserDefaults.standard.set(existingMatchedUsers, forKey: matchedUserKey(userID: userID))
  }
  
}
