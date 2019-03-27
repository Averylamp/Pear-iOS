//
//  PearDetachedProfileConstants.swift
//  Pear
//
//  Created by Avery Lamp on 3/9/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum PearDetachedProfileKeys: String, CodingKey {
  
  case documentID = "_id"
  case creatorUserID = "creatorUser_id"
  case ownerUserID = "user_id"
  case creatorFirstName
  case firstName
  case phoneNumber
  case age
  case gender
  case interests
  case vibes
  case bio
  case dos
  case donts
  case images
  case matchingDemographics
  case matchingPreferences
}
