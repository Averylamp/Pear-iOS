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

class FullProfileDisplayData: Equatable, CustomStringConvertible {
  var description: String {
    return "**** Full Profile Display Data ****" + """
    userID: \(String(describing: self.userID))
    firstName: \(String(describing: self.firstName))
    age: \(String(describing: self.age))
    gender: \(String(describing: self.gender))
    bios: \(String(describing: self.bios))
    boasts: \(String(describing: self.boasts))
    roasts: \(String(describing: self.roasts))
    questionResponses: \(String(describing: self.questionResponses))
    vibes: \(String(describing: self.vibes))
    Image Count: \(String(describing: self.imageContainers.count))
    profileOrigin: \(String(describing: self.profileOrigin))
    locationName: \(String(describing: self.locationName))
    locationCoordinates: \(String(describing: self.locationCoordinates))
    school: \(String(describing: self.school))
    schoolYear: \(String(describing: self.schoolYear))
    matchingDemographics: \(String(describing: self.matchingDemographics))
    matchingPreferences: \(String(describing: self.matchingPreferences))
    discoveryTimestamp: \(String(describing: self.discoveryTimestamp))
    profileNumber: \(String(describing: self.profileNumber))
    """
  }
  
  var discoveryItemID: String?
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
  
  static func == (lhs: FullProfileDisplayData, rhs: FullProfileDisplayData) -> Bool {
    
    return lhs.userID == rhs.userID &&
           lhs.firstName == rhs.firstName &&
           lhs.age == rhs.age &&
           lhs.gender == rhs.gender &&
           lhs.bios == rhs.bios &&
           lhs.boasts == rhs.boasts &&
           lhs.roasts == rhs.roasts &&
           lhs.questionResponses == rhs.questionResponses &&
           lhs.vibes == rhs.vibes &&
           lhs.imageContainers == rhs.imageContainers &&
           lhs.profileOrigin == rhs.profileOrigin &&
           lhs.locationName == rhs.locationName &&
           lhs.school == rhs.school &&
           lhs.schoolYear == rhs.schoolYear &&
           lhs.matchingDemographics == rhs.matchingDemographics &&
           lhs.matchingPreferences == rhs.matchingPreferences &&
           lhs.profileNumber == rhs.profileNumber
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
