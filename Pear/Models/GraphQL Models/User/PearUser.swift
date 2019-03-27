//
//  PearUser.swift
//  Pear
//
//  Created by Avery Lamp on 2019-3-4.
//  Copyright © 2019 Pear. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class PearUser: Decodable, CustomStringConvertible {
  
  var documentID: String!
  var deactivated: Bool!
  var firebaseToken: String!
  var firebaseAuthID: String!
  var facebookId: String?
  var facebookAccessToken: String?
  var email: String!
  var emailVerified: Bool!
  var phoneNumber: String!
  var phoneNumberVerified: Bool!
  var firstName: String!
  var lastName: String!
  var fullName: String!
  var thumbnailURL: String?
  var gender: String?
  var age: Int!
  var birthdate: Date!
  
  var school: String?
  var schoolEmail: String?
  var schoolEmailVerified: String?
  
  var isSeeking: Bool!
  var pearPoints: Int!
  
  var displayedImages: [ImageContainer] = []
  var bankImages: [ImageContainer] = []
  
  var userProfiles: [PearUserProfile] = []
  var endorsedProfiles: [PearUserProfile] = []
  var detachedProfiles: [PearDetachedProfile] = []
  
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!
  
  var requestedMatches: [Match] = []
  var currentMatches: [Match] = []
  
  static let graphQLUserFieldsAll: String = "{ _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate school schoolEmail schoolEmailVerified isSeeking displayedImages \(ImageContainer.graphQLImageFields) bankImages \(ImageContainer.graphQLImageFields) pearPoints profileObjs \(PearUserProfile.graphQLUserProfileFieldsAll) endorsedProfileObjs \(PearUserProfile.graphQLUserProfileFieldsAll) detachedProfileObjs \((PearDetachedProfile.graphQLDetachedProfileFieldsAll))  requestedMatches \(Match.graphQLMatchFields) currentMatches \(Match.graphQLMatchFields) matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) }"
  static let graphQLUserFieldsUserOnly: String = "{ _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate school schoolEmail schoolEmailVerified isSeeking displayedImages \(ImageContainer.graphQLImageFields) bankImages \(ImageContainer.graphQLImageFields) pearPoints matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) }"
  static let graphQLUserFieldsMatchingUser: String = "{ _id deactivated firebaseToken firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate school schoolEmail schoolEmailVerified isSeeking displayedImages \(ImageContainer.graphQLImageFields)  pearPoints profileObjs \(PearUserProfile.graphQLUserProfileFieldsAll)  matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) }"
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearUserKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.deactivated = try values.decode(Bool.self, forKey: .deactivated)
    self.firebaseToken = try values.decode(String.self, forKey: .firebaseToken)
    self.firebaseAuthID = try values.decode(String.self, forKey: .firebaseAuthID)
    self.facebookId = try? values.decode(String.self, forKey: .facebookId)
    self.facebookAccessToken = try? values.decode(String.self, forKey: .facebookAccessToken)
    self.email = try values.decode(String.self, forKey: .email)
    self.emailVerified = try values.decode(Bool.self, forKey: .emailVerified)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.phoneNumberVerified = try values.decode(Bool.self, forKey: .phoneNumberVerified)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.lastName = try values.decode(String.self, forKey: .lastName)
    self.fullName = try values.decode(String.self, forKey: .fullName)
    self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
    self.gender = try? values.decode(String.self, forKey: .gender)
    let birthdateValue = try? values.decode(String.self, forKey: .birthdate)
    if let birthdateValue = birthdateValue, let birthdateNumberValue = Double(birthdateValue) {
      self.birthdate = Date(timeIntervalSince1970: birthdateNumberValue / 1000)
    }
    self.age = try values.decode(Int.self, forKey: .age)
    
    self.school = try? values.decode(String.self, forKey: .school)
    self.schoolEmail = try? values.decode(String.self, forKey: .schoolEmail)
    self.schoolEmailVerified = try? values.decode(String.self, forKey: .schoolEmailVerified)
    
    self.isSeeking = try? values.decode(Bool.self, forKey: .isSeeking)
    self.pearPoints = try values.decode(Int.self, forKey: .pearPoints)
    
    self.displayedImages = try values.decode([ImageContainer].self, forKey: .displayedImages)
    self.bankImages = try values.decode([ImageContainer].self, forKey: .bankImages)
    
    if let userProfiles = try? values.decode([PearUserProfile].self, forKey: .profileObjs) {
      self.userProfiles = userProfiles
    }
    if let endorsedProfiles = try? values.decode([PearUserProfile].self, forKey: .endorsedProfileObjs) {
      self.endorsedProfiles = endorsedProfiles
    }
    if let detachedProfiles = try? values.decode([PearDetachedProfile].self, forKey: .detachedProfileObjs) {
      self.detachedProfiles = detachedProfiles
    }
    
    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)
    
    if let requestedMatches = try? values.decode([Match].self, forKey: .requestedMatches) {
      self.requestedMatches = requestedMatches
    }
    if let currentMatches = try? values.decode([Match].self, forKey: .currentMatches) {
      self.currentMatches = currentMatches
    }

  }
  
  var description: String {
    return "**** Pear User **** \n" + """
    documentID: \(String(describing: documentID)),
    deactivated: \(String(describing: deactivated)),
    firebaseToken: \(String(describing: firebaseToken)),
    firebaseAuthID: \(String(describing: firebaseAuthID)),
    facebookId: \(String(describing: facebookId)),
    facebookAccessToken: \(String(describing: facebookAccessToken)),
    email: \(String(describing: email)),
    emailVerified: \(String(describing: emailVerified)),
    phoneNumber: \(String(describing: phoneNumber)),
    phoneNumberVerified: \(String(describing: phoneNumberVerified)),
    firstName: \(String(describing: firstName)),
    lastName: \(String(describing: lastName)),
    fullName: \(String(describing: fullName)),
    thumbnailURL: \(String(describing: thumbnailURL)),
    gender: \(String(describing: gender)),
    school: \(String(describing: school)),
    schoolEmail: \(String(describing: schoolEmail)),
    schoolEmailVerified: \(String(describing: schoolEmailVerified)),
    birthdate: \(String(describing: birthdate)),
    age: \(String(describing: age)),
    \(self.userProfiles.count) User Profiles Found,
    \(self.endorsedProfiles.count) Endorsed Profiles Found,
    \(self.detachedProfiles.count) Detached Profiles Found,
    """
  }
}
