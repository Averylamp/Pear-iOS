//
//  DataStore+UserDefaults.swift
//  Pear
//
//  Created by Avery Lamp on 3/30/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum UserDefaultKeys: String {
  case lastDynamicLinkCode
  case skippedDetachedProfiles
  case blockedUsers
  case matchedUsers
  
  // Filters
  case filterMatchingDemographics
  case filterMatchingPreferences
  case filterUserID
  case filterUserName
  
  // Flags
  case hasCreatedUser
  case hasCompletedOnboarding
  case hasCompletedDiscoveryOnboarding
  case hasBeenInBostonArea
  
  // Counters
  case userSessionNumber
  
  // Dates
  case userLastSlackStoryDate
  
  // Caches
  case cachedPearUser
  case cachedMatches
}

// MARK: - DataStore + User Defaults Convenience Functions
extension DataStore {
  
  // Bool
  func fetchFlagFromDefaults(flag: UserDefaultKeys) -> Bool {
    return UserDefaults.standard.bool(forKey: flag.rawValue)
  }
  
  func setFlagToDefaults(value: Bool, flag: UserDefaultKeys) {
    UserDefaults.standard.set(value, forKey: flag.rawValue)
  }
  
  // Date
  func fetchDateFromDefaults(flag: UserDefaultKeys) -> Date? {
    let lastTimeInt = UserDefaults.standard.double(forKey: flag.rawValue)
    if lastTimeInt == 0 {
      return nil
    }
    return Date(timeIntervalSince1970: lastTimeInt)
  }
  
  func setDateToDefaults(flag: UserDefaultKeys, date: Date) {
    UserDefaults.standard.set(date.timeIntervalSince1970, forKey: flag.rawValue)
  }
  
  // String
  func fetchStringFromDefaults(flag: UserDefaultKeys) -> String? {
    return UserDefaults.standard.string(forKey: flag.rawValue)
  }
  
  func saveStringToDefaults(string: String, flag: UserDefaultKeys) {
    UserDefaults.standard.set(string, forKey: flag.rawValue)
  }
  
  // [String]
  func fetchListFromDefaults(type: UserDefaultKeys) -> [String] {
    if let result = UserDefaults.standard.array(forKey: type.rawValue) as? [String] {
      return result
    }
    return []
  }
  
  func saveListToDefaults(list: [String], type: UserDefaultKeys) {
    UserDefaults.standard.set(list, forKey: type.rawValue)
  }
  
}

extension DataStore {
  
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

// MARK: - Caching
extension DataStore {
  
}

// MARK: - Filters
extension DataStore {
  
  func setFiltersToUser(user: PearUser) {
    guard let encodedMatchingDemographics = try? JSONEncoder().encode(user.matchingDemographics),
      let encodedMatchingPreferences = try? JSONEncoder().encode(user.matchingPreferences) else {
        print("Failed to encode matching Demographics/Preferences")
        return
    }
    UserDefaults.standard.set(encodedMatchingDemographics, forKey: UserDefaultKeys.filterMatchingDemographics.rawValue)
    UserDefaults.standard.set(encodedMatchingPreferences, forKey: UserDefaultKeys.filterMatchingPreferences.rawValue)
    UserDefaults.standard.set(user.documentID, forKey: UserDefaultKeys.filterUserID.rawValue)
    UserDefaults.standard.set(user.firstName ?? "Your friend", forKey: UserDefaultKeys.filterUserName.rawValue)
  }
  
  // swiftlint:disable:next large_tuple
  func getCurrentFilters() -> (userID: String,
    userName: String,
    userMatchingDemographics: MatchingDemographics,
    userMatchingPreferences: MatchingPreferences) {
      guard let filterUserID = UserDefaults.standard.string(forKey: UserDefaultKeys.filterUserID.rawValue) else {
        print("No User fount in current Filters")
        if let currentUser = DataStore.shared.currentPearUser {
          self.setFiltersToUser(user: currentUser)
          return self.getCurrentFilters()
        } else {
          fatalError("Failed to deserialize Current Pear User")
        }
      }
      guard let filterUserName = UserDefaults.standard.string(forKey: UserDefaultKeys.filterUserName.rawValue) else {
        fatalError("Failed to deserialize filter user name")
      }
      guard let matchingDemographicsData = UserDefaults.standard.data(forKey: UserDefaultKeys.filterMatchingDemographics.rawValue),
        let matchingDemographics = try? JSONDecoder().decode(MatchingDemographics.self, from: matchingDemographicsData),
        let matchingPreferencesData = UserDefaults.standard.data(forKey: UserDefaultKeys.filterMatchingPreferences.rawValue),
        let matchingPreferences = try? JSONDecoder().decode(MatchingPreferences.self, from: matchingPreferencesData)
        else {
          fatalError("Failed to deserialize Current Pear User")
      }
      return (userID: filterUserID,
              userName: filterUserName,
              userMatchingDemographics: matchingDemographics,
              userMatchingPreferences: matchingPreferences)
  }
  
}
