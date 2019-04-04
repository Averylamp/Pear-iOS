//
//  PearDetachedProfile.swift
//  Pear
//
//  Created by Avery Lamp on 3/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
class PearDetachedProfile: Decodable, CustomStringConvertible {
  
  var documentID: String!
  var creatorUserID: String!
  var creatorFirstName: String!
  var firstName: String!
  var phoneNumber: String!
  var age: Int!
  var gender: String!
  var interests: [String]
  var vibes: [String]
  var bio: String!
  var dos: [String]
  var donts: [String]
  var images: [ImageContainer]
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!

  static let graphQLDetachedProfileFieldsAll = "{ _id creatorUser_id creatorFirstName firstName phoneNumber age gender interests vibes bio dos donts images \(ImageContainer.graphQLImageFields) matchingPreferences \(MatchingPreferences.graphQLMatchingPreferencesFields) matchingDemographics \(MatchingDemographics.graphQLMatchingDemographicsFields) }"
  
  var description: String {
    return "**** Pear Detached Profile **** \n" + """
    documentID: \(String(describing: documentID)),
    creatorUserID: \(String(describing: creatorUserID)),
    creatorFirstName: \(String(describing: creatorFirstName)),
    firstName: \(String(describing: firstName)),
    phoneNumber: \(String(describing: phoneNumber)),
    age: \(String(describing: age)),
    gender: \(String(describing: gender)),
    interests: \(String(describing: interests)),
    vibes: \(String(describing: vibes)),
    bio: \(String(describing: bio)),
    dos: \(String(describing: dos)),
    donts: \(String(describing: donts)),
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
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.age = try values.decode(Int.self, forKey: .age)
    self.gender = try values.decode(String.self, forKey: .gender)
    self.interests = try values.decode([String].self, forKey: .interests).map({ $0.firstCapitalized })
    self.vibes = try values.decode([String].self, forKey: .vibes)
    self.bio = try values.decode(String.self, forKey: .bio).trimmingCharacters(in: .whitespacesAndNewlines)
    self.bio =  "\"\(self.bio!.firstCapitalized)\""
    self.dos = try values.decode([String].self, forKey: .dos).map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      .map({ "\"\($0.firstCapitalized)\""})
    self.donts = try values.decode([String].self, forKey: .donts).map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      .map({ "\"\($0.firstCapitalized)\""})
    let images = try values.decode([ImageContainer].self, forKey: .images)
    self.images = images
    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)

  }
  
}
