//
//  UserConstants.swift
//  SubtleAsianMatches
//
//  Created by Avery on 1/6/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum PearUserKeys: String, CodingKey {
  case documentID = "_id"
  case deactivated
  case firebaseToken
  case firebaseAuthID
  case facebookId
  case facebookAccessToken
  case email
  case emailVerified
  case phoneNumber
  case phoneNumberVerified
  case firstName
  case lastName
  case fullName
  case thumbnailURL
  case gender
  case locationName
  case locationCoordinates
  case school
  case schoolEmail
  case schoolEmailVerified
  case birthdate
  case age
  case profileIDs = "profile_ids"
  case profileObjs = "profileObjs"
  case endorsedProfileIDs = "endorsedProfile_ids"
  case endorsedProfileObjs = "endorsedProfileObjs"
  case detachedProfileIDs = "detachedProfile_ids"
  case detachedProfileObjs = "detachedProfileObjs"
  
  case matchingDemographics
  case matchingPreferences
  
  case userStats
  case displayedImages = "displayedImages"
  
  case userMatchesID = "userMatches_id"
  case userMatches
  case discoveryIDs = "discovery_id"
  case discoveryObj = "discovery_obj"
  case pearPoints
}

struct PearUserStatsKeys {
  static let totalNumberOfMatchRequests = "totalNumberOfMatchRequests"
  static let totalNumberOfMatches = "totalNumberOfMatches"
  static let totalNumberOfProfilesCreated = "totalNumberOfProfilesCreated"
  static let totalNumberOfEndorsementsCreated = "totalNumberOfEndorsementsCreated"
  static let conversationTotalNumber = "conversationTotalNumber"
  static let conversationTotalNumberFirstMessage = "conversationTotalNumberFirstMessage"
  static let conversationTotalNumberTenMessages = "conversationTotalNumberTenMessages"
  static let conversationTotalNumberHundredMessages = "conversationTotalNumberHundredMessages"
}

struct PearUserDemographicsKeys {
  static let ethnicities = "ethnicities"
  static let religion = "religion"
  static let political = "political"
  static let smoking = "smoking"
  static let drinking = "drinking"
  static let height = "height"
}

struct PearPreferencesKeys {
  static let ethnicities = "ethnicities"
  static let seekingGender = "seekingGender"
  static let seekingReason = "seekingReason"
  static let reasonDealbreaker = "reasonDealbreaker"
  static let seekingEthnicity = "seekingEthnicity"
  static let ethnicityDealbreaker = "ethnicityDealbreaker"
  static let maxDistance = "maxDistance"
  static let distanceDealbreaker = "distanceDealbreaker"
  static let minAgeRange = "minAgeRange"
  static let maxAgeRange = "maxAgeRange"
  static let ageDealbreaker = "ageDealbreaker"
  static let minHeightRange = "minHeightRange"
  static let maxHeightRange = "maxHeightRange"
  static let heightDealbreaker = "heightDealbreaker"
}
