//
//  PearUserProfileConstants.swift
//  Pear
//
//  Created by Avery Lamp on 3/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum PearUserProfileKeys: String, CodingKey {
  
  case documentID = "_id"
  case creatorUserID = "creatorUser_id"
  case creatorFirstName
  case interests
  case vibes
  case bio
  case dos
  case donts
  case images
  case matchingDemographics
  case matchingPreferences
}
