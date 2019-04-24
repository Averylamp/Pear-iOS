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
  case detachedProfile
  case pearUser
}

class FullProfileDisplayData: Equatable {
  
  var userID: String?
  var firstName: String?
  var age: Int?
  var gender: GenderEnum?
  var bios: [BioItem] = []
  var boasts: [BoastItem] = []
  var roasts: [RoastItem] = []
  var questionResponses: [QuestionResponseItem] = []
  var vibes: [VibeItem] = []
  var imageContainers: [ImageContainer] = []
  var profileOrigin: FullProfileOrigin?
  var originObject: Any?
  var locationName: String?
  var locationCoordinates: CLLocationCoordinate2D?
  var school: String?
  var schoolYear: String?
  var matchingDemographics: MatchingDemographics?
  var matchingPreferences: MatchingPreferences?
  var discoveryTimestamp: Date?
  var profileNumber: Int?
  
  convenience init(user: PearUser) {
    self.init()
    self.userID = user.documentID
    self.firstName = user.firstName
    self.age = user.age
    self.gender = user.gender
    self.bios = user.bios
    self.boasts = user.boasts
    self.roasts = user.roasts
    self.questionResponses = user.questionResponses
    self.vibes = user.vibes
    self.imageContainers = user.displayedImages
    self.profileOrigin = .pearUser
    self.originObject = user
    self.locationName = user.matchingDemographics.location?.locationName
    self.locationCoordinates = user.matchingDemographics.location?.locationCoordinate
    self.school = user.school
    self.schoolYear = user.schoolYear
    self.matchingDemographics = user.matchingDemographics
    self.matchingPreferences = user.matchingPreferences
    self.profileNumber = user.endorserIDs.count
    
  }
  
  convenience init(detachedProfile: PearDetachedProfile) {
    self.init()
    self.userID = detachedProfile.documentID
    self.firstName = detachedProfile.firstName
    self.age = detachedProfile.age
    self.gender = detachedProfile.gender
    if let bio = detachedProfile.bio {
      self.bios = [bio]
    }
    self.boasts = detachedProfile.boasts
    self.roasts = detachedProfile.roasts
    self.questionResponses = detachedProfile.questionResponses
    self.vibes = detachedProfile.vibes
    self.imageContainers = detachedProfile.images
    self.profileOrigin = .detachedProfile
    self.originObject = detachedProfile
    self.locationName = detachedProfile.matchingDemographics.location?.locationName
    self.locationCoordinates = detachedProfile.matchingDemographics.location?.locationCoordinate
    self.school = detachedProfile.school
    self.schoolYear = detachedProfile.schoolYear
    self.matchingDemographics = detachedProfile.matchingDemographics
    self.matchingPreferences = detachedProfile.matchingPreferences
    self.profileNumber = 0
  }
  
//  convenience init (user: PearUser) {
//    var interests: [String] = []
//    var vibes: [String] = []
//    var bioContent: [BioContent] = []
//    var doContent: [DoDontContent] = []
//    var dontContent: [DoDontContent] = []
//
//    for profile in user.userProfiles {
//      profile.interests.forEach({
//        if !interests.contains($0) {
//          interests.append($0)
//        }
//      })
//      profile.vibes.forEach({
//        if !vibes.contains($0) {
//          vibes.append($0)
//        }
//      })
//      bioContent.append(BioContent.init(bio: profile.bio, creatorName: profile.creatorFirstName))
//      doContent.append(contentsOf: profile.dos.map({ DoDontContent.init(phrase: $0, creatorName: profile.creatorFirstName) }))
//      dontContent.append(contentsOf: profile.donts.map({ DoDontContent.init(phrase: $0, creatorName: profile.creatorFirstName) }))
//    }
//    self.init(firstName: user.firstName,
//              age: user.matchingDemographics.age,
//              gender: user.matchingDemographics.gender.toString(),
//              interests: interests,
//              vibes: vibes,
//              bio: bioContent,
//              dos: doContent,
//              donts: dontContent)
//    self.userID = user.documentID
//    self.imageContainers = user.displayedImages
//    self.profileOrigin = .pearUser
//    self.originObject = user
//    self.school = user.school
//    self.schoolYear = user.schoolYear
//    self.locationName = user.matchingDemographics.location.locationName
//    self.matchingDemographics = user.matchingDemographics
//    self.matchingPreferences = user.matchingPreferences
//  }
  static func == (lhs: FullProfileDisplayData, rhs: FullProfileDisplayData) -> Bool {
//    return lhs.userID == rhs.userID &&
//      lhs.originalCreatorName == rhs.originalCreatorName &&
//      lhs.firstName == rhs.firstName &&
//      lhs.age == rhs.age &&
//      lhs.gender == rhs.gender &&
//      lhs.interests == rhs.interests &&
//      lhs.vibes == rhs.vibes &&
//      lhs.dos.map({$0.phrase}) == rhs.dos.map({$0.phrase}) &&
//      lhs.donts.map({$0.phrase}) == rhs.donts.map({$0.phrase}) &&
//      lhs.bio.map({$0.bio}) == rhs.bio.map({$0.bio}) &&
//      ImageContainer.compareImageLists(lhs: lhs.imageContainers, rhs: rhs.imageContainers)
    return true
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
