//
//  MatchingPreferences.swift
//  Pear
//
//  Created by Avery Lamp on 5/17/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum MatchingPreferencesKeys: String, CodingKey {
  case seekingGender
  case maxDistance
  case minAgeRange
  case maxAgeRange
  case location
}

class MatchingPreferences: Codable, Equatable, GraphQLDecodable {
  
  static func graphQLAllFields() -> String {
    return "{ seekingGender maxDistance minAgeRange maxAgeRange }"
  }
  
  static func == (lhs: MatchingPreferences, rhs: MatchingPreferences) -> Bool {
    return lhs.seekingGender == rhs.seekingGender &&
      lhs.maxDistance == rhs.maxDistance &&
      lhs.minAgeRange == rhs.minAgeRange &&
      lhs.maxAgeRange == rhs.maxAgeRange &&
      lhs.location == rhs.location
  }
  
  func matchesDemographics(demographics: MatchingDemographics) -> Bool {
    if let gender = demographics.gender,
      !self.seekingGender.contains(gender) {
      return false
    }
    if let age = demographics.age,
      self.minAgeRange > age ||
        age > self.maxAgeRange {
      return false
    }
    return true
  }
  
  var seekingGender: [GenderEnum] = []
  var maxDistance: Int
  var minAgeRange: Int
  var maxAgeRange: Int
  var location: LocationObject?
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MatchingPreferencesKeys.self)
    let seekingGenderStrings = try values.decode([String].self, forKey: .seekingGender)
    self.seekingGender = seekingGenderStrings.compactMap({ GenderEnum.init(rawValue: $0) })
    self.maxDistance = try values.decode(Int.self, forKey: .maxDistance)
    self.minAgeRange = try values.decode(Int.self, forKey: .minAgeRange)
    self.maxAgeRange = try values.decode(Int.self, forKey: .maxAgeRange)
    if let location = try? values.decode(LocationObject.self, forKey: .location) {
      self.location = location
    }
  }
}
