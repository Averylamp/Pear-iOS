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
  
  func filteringDisabledForSelfFromDefaults() -> Bool {
    return UserDefaults.standard.bool(forKey: UserDefaultKeys.isFilteringForSelfDisabled.rawValue)
  }
  
  func filteredEndorsedUsersFromDefaults() -> [String] {
    if let result = UserDefaults.standard.array(forKey: UserDefaultKeys.notFilteringForEndorsedUsers.rawValue) as? [String] {
      return result
    }
    return []
  }
  
  func filteredDetachedProfilesFromDefaults() -> [String] {
    if let result = UserDefaults.standard.array(forKey: UserDefaultKeys.notFilteringForDetachedProfiles.rawValue) as? [String] {
      return result
    }
    return []
  }
  
  func updateFilteringDisabledForSelfInDefault(disabled: Bool) {
    UserDefaults.standard.set(disabled, forKey: UserDefaultKeys.isFilteringForSelfDisabled.rawValue)
  }
  
  func updateFilteredEndorsedUsersInDefault(filteredEndorsedUserIDs: [String]) {
    UserDefaults.standard.set(filteredEndorsedUserIDs, forKey: UserDefaultKeys.notFilteringForEndorsedUsers.rawValue)
  }
  
  func updateFilteredDetachedProfilesInDefault(filteredDetachedProfileIDs: [String]) {
    UserDefaults.standard.set(filteredDetachedProfileIDs, forKey: UserDefaultKeys.notFilteringForDetachedProfiles.rawValue)
  }
  
}
