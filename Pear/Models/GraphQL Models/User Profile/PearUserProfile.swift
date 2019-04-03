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
  var ownerUserID: String!
  var creatorUserID: String!
  var creatorFirstName: String!
  var interests: [String]
  var vibes: [String]
  var bio: String!
  var dos: [String]
  var donts: [String]
  
  var fullOwnerDisplay: FullProfileDisplayData?
  
  static let graphQLUserProfileFieldsAll = "{ _id creatorUser_id user_id creatorFirstName interests vibes bio dos donts }"
  
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

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: PearDetachedProfileKeys.self)
    try container.encode(self.documentID, forKey: .documentID)
    try container.encode(self.creatorUserID, forKey: .creatorUserID)
    try container.encode(self.ownerUserID, forKey: .ownerUserID)
    try container.encode(self.creatorFirstName, forKey: .creatorFirstName)
    try container.encode(self.interests, forKey: .interests)
    try container.encode(self.vibes, forKey: .vibes)
    try container.encode(self.bio, forKey: .bio)
    try container.encode(self.dos, forKey: .dos)
    try container.encode(self.donts, forKey: .donts)
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearDetachedProfileKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.creatorUserID = try values.decode(String.self, forKey: .creatorUserID)
    self.ownerUserID = try values.decode(String.self, forKey: .ownerUserID)
    self.creatorFirstName = try values.decode(String.self, forKey: .creatorFirstName)
    self.interests = try values.decode([String].self, forKey: .interests).map({ $0.firstCapitalized })
    self.vibes = try values.decode([String].self, forKey: .vibes)
    self.bio = try values.decode(String.self, forKey: .bio).trimmingCharacters(in: .whitespacesAndNewlines)
    self.bio =  "\"\(self.bio!.firstCapitalized)\""
    self.dos = try values.decode([String].self, forKey: .dos).map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      .map({ "\"\($0.firstCapitalized)\""})
    self.donts = try values.decode([String].self, forKey: .donts).map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      .map({ "\"\($0.firstCapitalized)\""})
  }
  
}
