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

class PearUser: Decodable, CustomStringConvertible, GraphQLDecodable {
  
  static func graphQLCurrentUserFields() -> String {
    return "{ _id deactivated firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate bios \(BioItem.graphQLAllFields()) boasts \(BoastItem.graphQLAllFields()) roasts \(RoastItem.graphQLAllFields()) questionResponses \(QuestionResponseItem.graphQLAllFields()) vibes \(VibeItem.graphQLAllFields()) school schoolYear schoolEmail schoolEmailVerified displayedImages \(ImageContainer.graphQLAllFields()) bankImages \(ImageContainer.graphQLAllFields()) isSeeking pearPoints endorsedUser_ids endorser_ids detachedProfile_ids matchingPreferences \(MatchingPreferences.graphQLAllFields()) matchingDemographics \(MatchingDemographics.graphQLAllFields()) }"  }
  
  static func graphQLAllFields() -> String {
    return "{ _id deactivated firebaseAuthID facebookId facebookAccessToken email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate bios \(BioItem.graphQLAllFields()) boasts \(BoastItem.graphQLAllFields()) roasts \(RoastItem.graphQLAllFields()) questionResponses \(QuestionResponseItem.graphQLAllFields()) vibes \(VibeItem.graphQLAllFields()) school schoolYear schoolEmail schoolEmailVerified displayedImages \(ImageContainer.graphQLAllFields()) isSeeking pearPoints endorsedUser_ids endorser_ids detachedProfile_ids matchingPreferences \(MatchingPreferences.graphQLAllFields()) matchingDemographics \(MatchingDemographics.graphQLAllFields()) }"
    
  }
  
  var documentID: String!
  var deactivated: Bool!
  var firebaseAuthID: String!
  var facebookId: String?
  var facebookAccessToken: String?
  var email: String?
  var emailVerified: Bool?
  var phoneNumber: String!
  var phoneNumberVerified: Bool!
  var firstName: String?
  var lastName: String?
  func fullName() -> String {
      var returnName = ""
      if let firstName = firstName {
        returnName += firstName
      }
      if let lastName = lastName {
        if returnName.count > 0 {
          returnName += " " + lastName
        } else {
          returnName += lastName
        }
      }
      if returnName.count == 0 {
        returnName = "No Name"
      }
      return returnName
  }
  var thumbnailURL: String?
  var gender: GenderEnum?
  var age: Int?
  var birthdate: Date?
  
  var bios: [BioItem] = []
  var boasts: [BoastItem] = []
  var roasts: [RoastItem] = []
  var questionResponses: [QuestionResponseItem] = []
  var vibes: [VibeItem] = []
  
  var school: String?
  var schoolYear: String?
  var schoolEmail: String?
  var schoolEmailVerified: String?
  
  var displayedImages: [ImageContainer] = []
  var bankImages: [ImageContainer] = []
  
  var isSeeking: Bool!
  var pearPoints: Int!
  
  var endorsedUserIDs: [String] = []
  var endorserIDs: [String] = []
  var detachedProfileIDs: [String] = []
  
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearUserKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.deactivated = try values.decode(Bool.self, forKey: .deactivated)
    self.firebaseAuthID = try values.decode(String.self, forKey: .firebaseAuthID)
    self.facebookId = try? values.decode(String.self, forKey: .facebookId)
    self.facebookAccessToken = try? values.decode(String.self, forKey: .facebookAccessToken)
    self.email = try? values.decode(String.self, forKey: .email)
    self.emailVerified = try? values.decode(Bool.self, forKey: .emailVerified)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.phoneNumberVerified = try values.decode(Bool.self, forKey: .phoneNumberVerified)
    self.firstName = try? values.decode(String.self, forKey: .firstName)
    self.lastName = try? values.decode(String.self, forKey: .lastName)
    self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
    if let genderString = try? values.decode(String.self, forKey: .gender),
      let gender = GenderEnum.init(rawValue: genderString) {
      self.gender = gender
    }
    let birthdateValue = try? values.decode(String.self, forKey: .birthdate)
    if let birthdateValue = birthdateValue, let birthdateNumberValue = Double(birthdateValue) {
      self.birthdate = Date(timeIntervalSince1970: birthdateNumberValue / 1000)
    }
    self.age = try? values.decode(Int.self, forKey: .age)
    
    self.boasts = try values.decode([BoastItem].self, forKey: .boasts)
    self.roasts = try values.decode([RoastItem].self, forKey: .roasts)
    self.questionResponses = try values.decode([QuestionResponseItem].self, forKey: .questionResponses)
    self.vibes = try values.decode([VibeItem].self, forKey: .vibes)
    self.bios = try values.decode([BioItem].self, forKey: .bios)
    
    self.school = try? values.decode(String.self, forKey: .school)
    self.schoolYear = try? values.decode(String.self, forKey: .schoolYear)
    self.schoolEmail = try? values.decode(String.self, forKey: .schoolEmail)
    self.schoolEmailVerified = try? values.decode(String.self, forKey: .schoolEmailVerified)
    
    self.isSeeking = try values.decode(Bool.self, forKey: .isSeeking)
    self.pearPoints = try values.decode(Int.self, forKey: .pearPoints)
    
    self.endorsedUserIDs = try values.decode([String].self, forKey: .endorsedUserIDs)
    self.endorserIDs = try values.decode([String].self, forKey: .endorserUserIDs)
    self.detachedProfileIDs = try values.decode([String].self, forKey: .detachedProfileIDs)
    
    self.displayedImages = try values.decode([ImageContainer].self, forKey: .displayedImages)
    if let bankImages = try? values.decode([ImageContainer].self, forKey: .bankImages) {
      self.bankImages = bankImages
    }

    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)
    
  }
  
  var description: String {
    return "**** Pear User **** \n" + """
    documentID: \(String(describing: documentID)),
    deactivated: \(String(describing: deactivated)),
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
    bios: \(String(describing: self.bios))
    boasts: \(String(describing: self.boasts))
    roasts: \(String(describing: self.roasts))
    questionResponses: \(String(describing: self.questionResponses))
    vibes: \(String(describing: self.vibes))
    
    """
  }
}