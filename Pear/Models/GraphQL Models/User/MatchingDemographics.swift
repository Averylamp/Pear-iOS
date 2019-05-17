//
//  MatchingDemographics.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum MatchingDemographicsKeys: String, CodingKey {
  case gender
  case age
  case location
}

class MatchingDemographics: Decodable, Equatable, GraphQLDecodable {
  static func graphQLAllFields() -> String {
   return "{ gender age location \(LocationObject.graphQLAllFields()) }"
  }
  
  static func == (lhs: MatchingDemographics, rhs: MatchingDemographics) -> Bool {
    return lhs.gender == rhs.gender &&
      lhs.age == rhs.age &&
      lhs.location == rhs.location
  }
  
  var gender: GenderEnum?
  var age: Int?
  var location: LocationObject?
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MatchingDemographicsKeys.self)
    if let genderString = try? values.decode(String.self, forKey: .gender),
      let gender = GenderEnum.init(rawValue: genderString) {
      self.gender = gender
    }
    if let age = try? values.decode(Int.self, forKey: .age) {
      self.age = age
    }
    if let location = try? values.decode(LocationObject.self, forKey: .location) {
      self.location = location
    }
  }
}
