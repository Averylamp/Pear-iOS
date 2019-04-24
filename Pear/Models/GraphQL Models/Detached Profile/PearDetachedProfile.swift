//
//  PearDetachedProfile.swift
//  Pear
//
//  Created by Avery Lamp on 3/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
class PearDetachedProfile: Decodable, CustomStringConvertible, GraphQLDecodable {
  static func graphQLAllFields() -> String {
    return "{ _id creatorUser_id creatorFirstName firstName lastName phoneNumber age gender bio \(BioItem.graphQLAllFields()) boasts \(BoastItem.graphQLAllFields()) roasts \(RoastItem.graphQLAllFields()) questionResponses \(QuestionResponseItem.graphQLAllFields()) vibes \(VibeItem.graphQLAllFields()) images \(ImageContainer.graphQLImageFields) matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) school schoolYear }"
  }
  
  var documentID: String!
  var creatorUserID: String!
  var creatorFirstName: String!
  var firstName: String!
  var lastName: String?
  var phoneNumber: String!
  var age: Int?
  var gender: GenderEnum?
  
  var bios: [BioItem] = []
  var boasts: [BoastItem] = []
  var roasts: [RoastItem] = []
  var questionResponses: [QuestionResponseItem] = []
  var vibes: [VibeItem] = []
  
  var images: [ImageContainer]
  
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!
  
  var school: String?
  var schoolYear: String?

  static let graphQLDetachedProfileFieldsAll = "{ _id creatorUser_id creatorFirstName firstName lastName phoneNumber age gender bio \(BioItem.graphQLAllFields()) boasts \(BoastItem.graphQLAllFields()) roasts \(RoastItem.graphQLAllFields()) questionResponses \(QuestionResponseItem.graphQLAllFields()) vibes \(VibeItem.graphQLAllFields()) images \(ImageContainer.graphQLImageFields) matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) school schoolYear }"
  
  var description: String {
    return "**** Pear Detached Profile **** \n" + """
    documentID: \(String(describing: documentID)),
    creatorUserID: \(String(describing: creatorUserID)),
    creatorFirstName: \(String(describing: creatorFirstName)),
    firstName: \(String(describing: firstName)),
    phoneNumber: \(String(describing: phoneNumber)),
    age: \(String(describing: age)),
    gender: \(String(describing: gender)),
    bios: \(String(describing: self.bios))
    boasts: \(String(describing: self.boasts))
    roasts: \(String(describing: self.roasts))
    questionResponses: \(String(describing: self.questionResponses))
    vibes: \(String(describing: self.vibes))
    school: \(String(describing: school)),
    schoolYear: \(String(describing: schoolYear)),
    images: \(images.count) found,
    """
    
  }
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearDetachedProfileKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.creatorUserID = try values.decode(String.self, forKey: .creatorUserID)
    self.creatorFirstName = try values.decode(String.self, forKey: .creatorFirstName)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.lastName = try? values.decode(String.self, forKey: .lastName)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.age = try? values.decode(Int.self, forKey: .age)
    if let genderString = try? values.decode(String.self, forKey: .gender),
      let gender = GenderEnum.init(rawValue: genderString) {
      self.gender = gender
    }
    
    self.bios = try values.decode([BioItem].self, forKey: .bios)
    self.boasts = try values.decode([BoastItem].self, forKey: .boasts)
    self.roasts = try values.decode([RoastItem].self, forKey: .roasts)
    self.questionResponses = try values.decode([QuestionResponseItem].self, forKey: .questionResponses)
    self.vibes = try values.decode([VibeItem].self, forKey: .vibes)
    
    let images = try values.decode([ImageContainer].self, forKey: .images)
    self.images = images
    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)
    self.school = try? values.decode(String.self, forKey: .school)
    self.schoolYear = try? values.decode(String.self, forKey: .schoolYear)

  }
  
}
