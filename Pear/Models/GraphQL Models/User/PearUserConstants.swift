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
  case birthdate
  case age

  case school
  case schoolEmail
  case schoolEmailVerified

  case isSeeking
  case pearPoints

  case displayedImages
  case bankImages

  case profileObjs = "profileObjs"
  case endorsedProfileObjs = "endorsedProfileObjs"
  case detachedProfileObjs = "detachedProfileObjs"
  
  case matchingDemographics
  case matchingPreferences
  
  case requestedMatches
  case currentMatches

}
