//
//  MatchingPearUser.swift
//  Pear
//
//  Created by Avery Lamp on 3/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class MatchingPearUser: Decodable, CustomStringConvertible {
  
  var documentID: String
  var firstName: String
  var lastName: String
  var fullName: String
  var thumbnailURL: String?
  var gender: String?
  var school: String?
  
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!
  
  var userProfiles: [PearUserProfile] = []
  var images: [ImageContainer] = []
  
  static let graphQLMatchedUserFieldsAll: String = "{ _id deactivated firstName lastName fullName thumbnailURL gender school birthdate age profileObjs \(PearUserProfile.graphQLUserProfileFieldsAll) displayedImages \(ImageContainer.graphQLImageFields) matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) pearPoints }"
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearUserKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.lastName = try values.decode(String.self, forKey: .lastName)
    self.fullName = try values.decode(String.self, forKey: .fullName)
    self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
    self.gender = try? values.decode(String.self, forKey: .gender)
    self.school = try? values.decode(String.self, forKey: .school)
    
    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)
    
    self.userProfiles = try values.decode([PearUserProfile].self, forKey: .profileObjs)
    self.images = try values.decode([ImageContainer].self, forKey: .displayedImages)

  }
  
  var description: String {
    return "**** Pear User **** \n" + """
    documentID: \(String(describing: documentID)),
    firstName: \(String(describing: firstName)),
    lastName: \(String(describing: lastName)),
    fullName: \(String(describing: fullName)),
    thumbnailURL: \(String(describing: thumbnailURL)),
    gender: \(String(describing: gender)),
    school: \(String(describing: school)),
    \(self.userProfiles.count) User Profiles Found,
    """
  }
}
