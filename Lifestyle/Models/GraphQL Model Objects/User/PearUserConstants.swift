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
  case age
  case birthdate

  case questionResponses
  
  case school
  case schoolYear
  case schoolEmail
  case schoolEmailVerified

  case displayedImages
  case bankImages

  case isSeeking
  case pearPoints
  
  case endorsedUserIDs = "endorsedUser_ids"
  case endorserIDs = "endorser_ids"
  case detachedProfileIDs = "detachedProfile_ids"
  
  case matchingDemographics
  case matchingPreferences
  
}
