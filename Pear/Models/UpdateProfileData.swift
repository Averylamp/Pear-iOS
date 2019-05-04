//
//  UpdateProfileData.swift
//  Pear
//
//  Created by Avery Lamp on 5/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum UpdateProfileError: Error {
  case userNotLoggedIn
}

enum UpdateProfileType {
  case detachedProfile
  case userProfile
}

class UpdateProfileData {
  
  var documentID: String
  let initialBio: BioItem?
  var updatedBio: BioItem?
  let initialRoasts: [RoastItem]
  var updatedRoasts: [RoastItem]
  let initialBoasts: [BoastItem]
  var updatedBoasts: [BoastItem]
  let updateProfileType: UpdateProfileType
  
  init(documentID: String,
       bio: BioItem?,
       roasts: [RoastItem],
       boasts: [BoastItem],
       type: UpdateProfileType) {
    self.documentID = documentID
    self.initialBio = bio
    self.updatedBio = bio
    self.initialRoasts = roasts
    self.updatedRoasts = roasts
    self.initialBoasts = boasts
    self.updatedBoasts = boasts
    self.updateProfileType = type
  }
  
  init(pearUser: PearUser) throws {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Could not create Update Profile Data")
      throw UpdateProfileError.userNotLoggedIn
    }
    self.documentID = pearUser.documentID
    let filteredBios = pearUser.bios.filter({ $0.authorID == userID })
    self.initialBio = filteredBios.first
    self.updatedBio = filteredBios.first
    self.initialRoasts = pearUser.roasts.filter({ $0.authorID == userID })
    self.updatedRoasts = pearUser.roasts.filter({ $0.authorID == userID })
    self.initialBoasts = pearUser.boasts.filter({ $0.authorID == userID })
    self.updatedBoasts = pearUser.boasts.filter({ $0.authorID == userID })
    self.updateProfileType = .userProfile
  }
  
  init(detachedProfile: PearDetachedProfile) throws {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Could not create Update Profile Data")
      throw UpdateProfileError.userNotLoggedIn
    }
    self.documentID = detachedProfile.documentID
    self.initialBio = detachedProfile.bio
    self.updatedBio = detachedProfile.bio
    self.initialRoasts = detachedProfile.roasts.filter({ $0.authorID == userID })
    self.updatedRoasts = detachedProfile.roasts.filter({ $0.authorID == userID })
    self.initialBoasts = detachedProfile.boasts.filter({ $0.authorID == userID })
    self.updatedBoasts = detachedProfile.boasts.filter({ $0.authorID == userID })
    self.updateProfileType = .detachedProfile
  }
  
  func checkForChanges() -> Bool {
    if self.initialBio != self.updatedBio {
      return true
    }
    
    if self.initialRoasts.count != self.updatedRoasts.count {
      return true
    } else {
      for index in 0..<self.initialRoasts.count where self.initialRoasts[index] != self.updatedRoasts[index] {
        return true
      }
    }
    
    if self.initialBoasts.count != self.updatedBoasts.count {
      return true
    } else {
      for index in 0..<self.initialBoasts.count where self.initialBoasts[index] != self.updatedBoasts[index] {
        return true
      }
    }
    
    return false
  }
  
}
