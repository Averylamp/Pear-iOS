//
//  PearDetachedProfile.swift
//  Pear
//
//  Created by Avery Lamp on 3/8/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class PearDetachedProfile: Codable, CustomStringConvertible {
  
  var documentID: String!
  var creatorUserID: String!
  var firstName: String!
  var phoneNumber: String!
  var age: Int!
  var gender: String!
  var interests: [String]
  var vibes: [String]
  var bio: String!
  var dos: [String]
  var donts: [String]
  var imageIDs: [String]
//  var images: String!
  
    static let graphQLDetachedProfileFields = "{ _id creatorUser_id firstName phoneNumber age gender interests vibes bio dos donts imageIDs images \(GraphQLQueryStrings.imageSizesFull) matchingDemographics \(GraphQLQueryStrings.matchingDemographicsFull) matchingPreferences \(GraphQLQueryStrings.matchingPreferencesFull) }"
  
  var description: String {
    return "**** Pear Detached Profile **** \n" + """
    documentID: \(String(describing: documentID)),
    creatorUserID: \(String(describing: creatorUserID)),
    firstName: \(String(describing: firstName)),
    phoneNumber: \(String(describing: phoneNumber)),
    age: \(String(describing: age)),
    gender: \(String(describing: gender)),
    interests: \(String(describing: interests)),
    vibes: \(String(describing: vibes)),
    bio: \(String(describing: bio)),
    dos: \(String(describing: dos)),
    donts: \(String(describing: donts)),
    imageIDs: \(String(describing: imageIDs)),
    """
    
  }
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearDetachedProfileKeys.self)
    print(values)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.creatorUserID = try values.decode(String.self, forKey: .creatorUserID)
    self.firstName = try values.decode(String.self, forKey: .firstName)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.age = try values.decode(Int.self, forKey: .age)
    self.gender = try values.decode(String.self, forKey: .gender)
    self.interests = try values.decode([String].self, forKey: .interests)
    self.vibes = try values.decode([String].self, forKey: .vibes)
    self.bio = try values.decode(String.self, forKey: .bio)
    self.dos = try values.decode([String].self, forKey: .dos)
    self.donts = try values.decode([String].self, forKey: .donts)
    self.imageIDs = try values.decode([String].self, forKey: .imageIDs)
    
  }
  
}