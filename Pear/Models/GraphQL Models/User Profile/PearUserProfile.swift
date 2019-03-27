//
//  PearUserProfile.swift
//  Pear
//
//  Created by Avery Lamp on 3/12/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class PearUserProfile: Codable, CustomStringConvertible {
  
  var documentID: String!
  var creatorUserID: String!
  var creatorFirstName: String!
  var interests: [String]
  var vibes: [String]
  var bio: String!
  var dos: [String]
  var donts: [String]
  
  static let graphQLUserProfileFieldsAll = "{ _id creatorUser_id creatorFirstName interests vibes bio dos donts }"
  
  var description: String {
    return "**** Pear Detached Profile **** \n" + """
    documentID: \(String(describing: documentID)),
    creatorUserID: \(String(describing: creatorUserID)),
    creatorFirstName: \(String(describing: creatorFirstName)),
    interests: \(String(describing: interests)),
    vibes: \(String(describing: vibes)),
    bio: \(String(describing: bio)),
    dos: \(String(describing: dos)),
    donts: \(String(describing: donts)),
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
    self.interests = try values.decode([String].self, forKey: .interests)
    self.vibes = try values.decode([String].self, forKey: .vibes)
    self.bio = try values.decode(String.self, forKey: .bio)
    self.dos = try values.decode([String].self, forKey: .dos)
    self.donts = try values.decode([String].self, forKey: .donts)
  }
  
}
