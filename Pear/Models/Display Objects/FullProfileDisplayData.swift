//
//  FullProfileDisplayData.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum FullProfileError: Error {
  case conversionError
  case notEnoughProfileInformation
}

enum FullProfileOrigin {
  case gettingStartedProfile
  case detachedProfile
  case userProfile
  case matchingUser
  case pearUser
}

class FullProfileDisplayData: Equatable {
  
  var userID: String?
  var originalCreatorName: String?
  var firstName: String!
  var age: Int?
  var gender: String!
  var interests: [String]
  var vibes: [String]
  var bio: [BioContent]
  var dos: [DoDontContent]
  var donts: [DoDontContent]
  var imageContainers: [ImageContainer] = []
  var rawImages: [UIImage] = []
  var profileOrigin: FullProfileOrigin?
  var originObject: Any?
  var locationName: String?
  var locationCoordinates: CLLocationCoordinate2D?
  var school: String?
  var schoolYear: String?
  var matchingDemographics: MatchingDemographics?
  var matchingPreferences: MatchingPreferences?
  
  init (firstName: String!,
        age: Int?,
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
  
  convenience init (gsup: UserProfileCreationData, creatorFirstName: String) throws {
    guard let firstName = gsup.firstName,
      let gender = gsup.gender,
      let bio = gsup.bio
      else {
        print("Failed to ensure fields")
        throw FullProfileError.conversionError
    }
    
    self.init(firstName: firstName,
              age: nil,
              gender: gender.toString(),
              interests: gsup.interests,
              vibes: gsup.vibes,
              bio: [BioContent.init(bio: bio, creatorName: creatorFirstName)],
              dos: gsup.dos.map({DoDontContent.init(phrase: $0, creatorName: creatorFirstName)}),
              donts: gsup.donts.map({DoDontContent.init(phrase: $0, creatorName: creatorFirstName)}))
    self.originalCreatorName = creatorFirstName
    self.rawImages = gsup.images.compactMap({ $0.image })
    self.profileOrigin = .gettingStartedProfile
  }
  
  convenience init (matchingUser: MatchingPearUser) {
    var interests: [String] = []
    var vibes: [String] = []
    var bioContent: [BioContent] = []
    var doContent: [DoDontContent] = []
    var dontContent: [DoDontContent] = []
    
    for profile in matchingUser.userProfiles {
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
    self.init(firstName: matchingUser.firstName,
              age: matchingUser.matchingDemographics.age,
              gender: matchingUser.matchingDemographics.gender.toString(),
              interests: interests,
              vibes: vibes,
              bio: bioContent,
              dos: doContent,
              donts: dontContent)
    self.userID = matchingUser.documentID
    self.imageContainers = matchingUser.images
    self.profileOrigin = .matchingUser
    self.originObject = matchingUser
    self.school = matchingUser.school
    self.schoolYear = matchingUser.schoolYear
    self.locationName = matchingUser.matchingDemographics.location.locationName
    self.matchingDemographics = matchingUser.matchingDemographics
    self.matchingPreferences = matchingUser.matchingPreferences
  }
  
  convenience init (user: PearUser) {
    var interests: [String] = []
    var vibes: [String] = []
    var bioContent: [BioContent] = []
    var doContent: [DoDontContent] = []
    var dontContent: [DoDontContent] = []
    
    for profile in user.userProfiles {
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
              age: user.matchingDemographics.age,
              gender: user.matchingDemographics.gender.toString(),
              interests: interests,
              vibes: vibes,
              bio: bioContent,
              dos: doContent,
              donts: dontContent)
    self.userID = user.documentID
    self.imageContainers = user.displayedImages
    self.profileOrigin = .pearUser
    self.originObject = user
    self.school = user.school
    self.schoolYear = user.schoolYear
    self.locationName = user.matchingDemographics.location.locationName
    self.matchingDemographics = user.matchingDemographics
    self.matchingPreferences = user.matchingPreferences
  }
  
  convenience init (pdp: PearDetachedProfile) {
    self.init(firstName: pdp.firstName,
              age: nil,
              gender: GenderEnum.stringFromEnumString(string: pdp.gender),
              interests: pdp.interests,
              vibes: pdp.vibes,
              bio: [BioContent.init(bio: pdp.bio, creatorName: pdp.creatorFirstName)],
              dos: pdp.dos.map({DoDontContent.init(phrase: $0, creatorName: pdp.creatorFirstName)}),
              donts: pdp.donts.map({DoDontContent.init(phrase: $0, creatorName: pdp.creatorFirstName)}))
    self.originalCreatorName = pdp.creatorFirstName
    self.imageContainers = pdp.images
    self.profileOrigin = .detachedProfile
    self.originObject = pdp
    self.matchingDemographics = pdp.matchingDemographics
    self.matchingPreferences = pdp.matchingPreferences
  }
  
  static func == (lhs: FullProfileDisplayData, rhs: FullProfileDisplayData) -> Bool {
    return lhs.userID == rhs.userID &&
    lhs.originalCreatorName == rhs.originalCreatorName &&
    lhs.firstName == rhs.firstName &&
    lhs.age == rhs.age &&
    lhs.gender == rhs.gender &&
    lhs.interests == rhs.interests &&
    lhs.vibes == rhs.vibes &&
    lhs.dos.map({$0.phrase}) == rhs.dos.map({$0.phrase}) &&
    lhs.donts.map({$0.phrase}) == rhs.donts.map({$0.phrase}) &&
    lhs.bio.map({$0.bio}) == rhs.bio.map({$0.bio})
  }
 
  static func compareListsForNewItems(oldList: [FullProfileDisplayData], newList: [FullProfileDisplayData]) -> Bool {
    var newItems = false
    for prof1 in newList {
      var foundMatch = false
      for prof2 in oldList where prof1 == prof2 {
        foundMatch = true
      }
      if !foundMatch {
        newItems = true
      }
    }
    if newList.count < oldList.count {
      return true
    }
    return newItems
  }
  
}
