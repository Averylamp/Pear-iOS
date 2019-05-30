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
    case filterForEventId
    case filterForUserId
    case isFilteringForSelfDisabled
    case notFilteringForEndorsedUsers
    case notFilteringForDetachedProfiles
    case hasCreatedUser
    case hasCompletedOnboarding
    case hasCompletedDiscoveryOnboarding
    case hasBeenInBostonArea
    case hasSetGenderPreferences
  }
  
  func fetchListFromDefaults(type: UserDefaultKeys) -> [String] {
    if let result = UserDefaults.standard.array(forKey: type.rawValue) as? [String] {
      return result
    }
    return []
  }
  
  func fetchFlagFromDefaults(flag: UserDefaultKeys) -> Bool {
    return UserDefaults.standard.bool(forKey: flag.rawValue)
  }
  
  func setFlagToDefaults(value: Bool, flag: UserDefaultKeys) {
    UserDefaults.standard.set(value, forKey: flag.rawValue)
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

  func filteringForEventIdFromDefaults() -> String? {
    return UserDefaults.standard.string(forKey: UserDefaultKeys.filterForEventId.rawValue)
  }
  
  func filteringForUserIdFromDefaults() -> String? {
    return UserDefaults.standard.string(forKey: UserDefaultKeys.filterForUserId.rawValue)
  }
  
  func updateFilterForEventId(eventID: String) {
    UserDefaults.standard.set(eventID, forKey: UserDefaultKeys.filterForEventId.rawValue)
  }
  
  func unsetFilterForEventId() {
    UserDefaults.standard.removeObject(forKey: UserDefaultKeys.filterForEventId.rawValue)
  }
  
  func updateFilterForUserId(userID: String) {
    UserDefaults.standard.set(userID, forKey: UserDefaultKeys.filterForUserId.rawValue)
  }
  
  func updateFilterForMeUserId() {
    if let user = DataStore.shared.currentPearUser {
      UserDefaults.standard.set(user.documentID, forKey: UserDefaultKeys.filterForUserId.rawValue)
    }
  }
  
}
