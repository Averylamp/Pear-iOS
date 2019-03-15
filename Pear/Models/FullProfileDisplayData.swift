//
//  FullProfileDisplayData.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

enum FullProfileError: Error {
  case conversionError
}

class FullProfileDisplayData {
  
  var creatorFirstName: String!
  var firstName: String!
  var age: Int!
  var gender: String!
  var interests: [String]
  var vibes: [String]
  var bio: String!
  var dos: [String]
  var donts: [String]
  var imageContainers: [ImageContainer] = []
  var rawImages: [UIImage] = []
  
  init (creatorFirstName: String!,
        firstName: String!,
        age: Int!,
        gender: String!,
        interests: [String],
        vibes: [String],
        bio: String!,
        dos: [String],
        donts: [String]) {
    self.creatorFirstName = creatorFirstName
    self.firstName = firstName
    self.age = age
    self.gender = gender
    self.interests = interests
    self.vibes = vibes
    self.bio = bio
    self.dos = dos
    self.donts = donts
  }
  
  convenience init (gsup: GettingStartedUserProfileData, creatorFirstName: String) throws {
    guard let firstName = gsup.firstName,
      let age = gsup.age,
      let gender = gsup.gender,
      let bio = gsup.bio
      else {
        print("Failed to ensure fields")
        throw FullProfileError.conversionError
    }
    
    self.init(creatorFirstName: creatorFirstName,
              firstName: firstName,
              age: age,
              gender: gender.rawValue,
              interests: gsup.interests,
              vibes: gsup.vibes,
              bio: bio,
              dos: gsup.dos,
              donts: gsup.donts)
    self.rawImages = gsup.images.map({ $0.image })
  }
  
  convenience init (pdp: PearDetachedProfile) {
    self.init(creatorFirstName: pdp.creatorFirstName,
              firstName: pdp.firstName,
              age: pdp.age,
              gender: pdp.gender,
              interests: pdp.interests,
              vibes: pdp.vibes,
              bio: pdp.bio,
              dos: pdp.dos,
              donts: pdp.donts)
    self.imageContainers = pdp.images
  }
  
  convenience init (user: PearUser, profile: PearUserProfile) {
    self.init(creatorFirstName: profile.creatorFirstName,
              firstName: user.firstName,
              age: user.age,
              gender: user.gender!,
              interests: profile.interests,
              vibes: profile.vibes,
              bio: profile.bio,
              dos: profile.dos,
              donts: profile.donts)
    self.imageContainers = user.displayedImages
  }
}
