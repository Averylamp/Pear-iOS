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
  case notEnoughProfileInformation
}

enum FullProfileOrigin {
  case gettingStartedProfile
  case detachedProfile
  case userProfile
}

class FullProfileDisplayData {
  
  var originalCreatorName: String?
  
  var firstName: String!
  var age: Int!
  var gender: String!
  var interests: [String]
  var vibes: [String]
  var bio: [BioContent]
  var dos: [DoDontContent]
  var donts: [DoDontContent]
  var imageContainers: [ImageContainer] = []
  var rawImages: [UIImage] = []
  var profileOrigin: FullProfileOrigin?
  
  init (firstName: String!,
        age: Int!,
        gender: String!,
        interests: [String],
        vibes: [String],
        bio: [BioContent],
        dos: [DoDontContent],
        donts: [DoDontContent]) {
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
    
    self.init(firstName: firstName,
              age: age,
              gender: gender.rawValue,
              interests: gsup.interests,
              vibes: gsup.vibes,
              bio: [BioContent.init(bio: bio, creatorName: creatorFirstName)],
              dos: gsup.dos.map({DoDontContent.init(phrase: $0, creatorName: creatorFirstName)}),
              donts: gsup.donts.map({DoDontContent.init(phrase: $0, creatorName: creatorFirstName)}))
    self.originalCreatorName = creatorFirstName
    self.rawImages = gsup.images.map({ $0.image })
    self.profileOrigin = .gettingStartedProfile
  }
  
  convenience init (pdp: PearDetachedProfile) {
    self.init(firstName: pdp.firstName,
              age: pdp.age,
              gender: pdp.gender,
              interests: pdp.interests,
              vibes: pdp.vibes,
              bio: [BioContent.init(bio: pdp.bio, creatorName: pdp.creatorFirstName)],
              dos: pdp.dos.map({DoDontContent.init(phrase: $0, creatorName: pdp.creatorFirstName)}),
              donts: pdp.donts.map({DoDontContent.init(phrase: $0, creatorName: pdp.creatorFirstName)}))
    self.originalCreatorName = pdp.creatorFirstName
    self.imageContainers = pdp.images
    self.profileOrigin = .detachedProfile
  }
  
  convenience init (user: PearUser, profiles: [PearUserProfile]) throws {
    guard profiles.count > 0 else {
      throw FullProfileError.notEnoughProfileInformation
    }
    
    var interests: [String] = []
    var vibes: [String] = []
    var bioContent: [BioContent] = []
    var doContent: [DoDontContent] = []
    var dontContent: [DoDontContent] = []
    
    for profile in profiles {
      profile.interests.forEach({
        if !interests.contains($0) {
          interests.append($0)
        }
      })
      profile.vibes.forEach({
        if !vibes.contains($0) {
          vibes.append($0)
        }
      })
      bioContent.append(BioContent.init(bio: profile.bio, creatorName: profile.creatorFirstName))
      doContent.append(contentsOf: profile.dos.map({ DoDontContent.init(phrase: $0, creatorName: profile.creatorFirstName) }))
      dontContent.append(contentsOf: profile.donts.map({ DoDontContent.init(phrase: $0, creatorName: profile.creatorFirstName) }))
    }
    self.init(firstName: user.firstName,
              age: user.age,
              gender: user.gender!,
              interests: interests,
              vibes: vibes,
              bio: bioContent,
              dos: doContent,
              donts: dontContent)
    if profiles.count == 1 {
      self.originalCreatorName = profiles.first?.creatorFirstName
    }
    self.imageContainers = user.displayedImages
    self.profileOrigin = .userProfile
  }
}
