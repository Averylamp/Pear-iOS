//
//  UpdateProfileData.swift
//  Pear
//
//  Created by Avery Lamp on 5/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum UpdateProfileType {
  case detachedProfile
  case userProfile
}

class UpdateProfileData {
  
  let initialBio: BioItem?
  var updatedBio: BioItem?
  let initialRoasts: [RoastItem]
  var updatedRoasts: [RoastItem]
  let initialBoasts: [BoastItem]
  var updatedBoasts: [BoastItem]
  
  init(bio: BioItem?,
       roasts: [RoastItem],
       boasts: [BoastItem]) {
    self.initialBio = bio
    self.updatedBio = bio
    self.initialRoasts = roasts
    self.updatedRoasts = roasts
    self.initialBoasts = boasts
    self.updatedBoasts = boasts
  }
  
  func checkForChanges() -> Bool {
    
    return false
  }
  
}
