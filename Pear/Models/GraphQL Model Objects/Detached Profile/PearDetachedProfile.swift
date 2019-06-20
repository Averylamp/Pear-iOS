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
    return "{ _id creatorUser_id creatorFirstName creatorThumbnailURL firstName lastName phoneNumber age gender questionResponses \(QuestionResponseItem.graphQLAllFields()) images \(ImageContainer.graphQLAllFields()) matchingPreferences \(MatchingPreferences.graphQLAllFields()) matchingDemographics \(MatchingDemographics.graphQLAllFields()) school schoolYear }"
  }
  
  var documentID: String!
  var creatorUserID: String!
  var creatorFirstName: String!
  var creatorThumbnailURL: String?
  var firstName: String!
  var lastName: String?
  var phoneNumber: String!
  var age: Int?
  var gender: GenderEnum?
  
  var questionResponses: [QuestionResponseItem] = []
  
  var images: [ImageContainer]
  
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!
  
  var school: String?
  var schoolYear: String?

  var description: String {
    return "**** Pear Detached Profile **** \n" + """
    documentID: \(String(describing: documentID)),
    creatorUserID: \(String(describing: creatorUserID)),
    creatorFirstName: \(String(describing: creatorFirstName)),
    creatorThumbnailURL: \(String(describing: creatorThumbnailURL)),
    firstName: \(String(describing: firstName)),
    phoneNumber: \(String(describing: phoneNumber)),
    age: \(String(describing: age)),
    gender: \(String(describing: gender)),
    questionResponses: \(String(describing: self.questionResponses))
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
    self.creatorThumbnailURL = try? values.decode(String.self, forKey: .creatorThumbnailURL)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.lastName = try? values.decode(String.self, forKey: .lastName)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.age = try? values.decode(Int.self, forKey: .age)
    if let genderString = try? values.decode(String.self, forKey: .gender),
      let gender = GenderEnum.init(rawValue: genderString) {
      self.gender = gender
    }
    
    self.questionResponses = try values.decode([QuestionResponseItem].self, forKey: .questionResponses)
    
    let images = try values.decode([ImageContainer].self, forKey: .images)
    self.images = images
    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)
    self.school = try? values.decode(String.self, forKey: .school)
    self.schoolYear = try? values.decode(String.self, forKey: .schoolYear)

  }
  
}
