//
//  SharedModel.swift
//  Pear
//
//  Created by Avery Lamp on 3/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import MapKit

enum DecodingError: Error {
  case coordinateDecodingError
  case enumError
}

enum GenderEnum: String {
  case male
  case female
  case nonbinary
  
  static func stringFromEnumString(string: String) -> String? {
    return GenderEnum(rawValue: string)?.toString()
  }
  
  func toString() -> String {
    switch self {
    case .male:
      return "Male"
    case .female:
      return "Female"
    case .nonbinary:
      return "Non Binary"
    }
  }
  
}

enum LocationKeys: String, CodingKey {
  case coords
  case locationName
}

class LocationObject: Decodable {
  
  static let graphQLLocationFields = "{ coords locationName }"
  
  let locationName: String?
  let locationCoordinate: CLLocationCoordinate2D?
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LocationKeys.self)
    self.locationName = try? values.decode(String.self, forKey: .locationName)
    if let coordFloats = try? values.decode([Double].self, forKey: .coords) {
      guard coordFloats.count == 2 else {
        throw DecodingError.coordinateDecodingError
      }
      let latitude = coordFloats[0]
      let longitude = coordFloats[1]
      self.locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
    } else {
      self.locationCoordinate = nil
    }
  }
  
}

enum MatchingPreferencesKeys: String, CodingKey {
  case seekingGender
  case maxDistance
  case minAgeRange
  case maxAgeRange
  case location
}

class MatchingPreferences: Decodable {
  
  static let graphQLMatchingPreferencesFields = "{ seekingGender maxDistance minAgeRange maxAgeRange location \(LocationObject.graphQLLocationFields) }"
  
  func matchesDemographics(demographics: MatchingDemographics) -> Bool {
    return self.seekingGender.contains(demographics.gender) &&
      self.minAgeRange <= demographics.age &&
      demographics.age <= self.maxAgeRange
  }
  
  var seekingGender: [GenderEnum] = []
  var maxDistance: Int
  var minAgeRange: Int
  var maxAgeRange: Int
  var location: LocationObject!
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MatchingPreferencesKeys.self)
    let seekingGenderStrings = try values.decode([String].self, forKey: .seekingGender)
    self.seekingGender = seekingGenderStrings.compactMap({ GenderEnum.init(rawValue: $0) })
    self.maxDistance = try values.decode(Int.self, forKey: .maxDistance)
    self.minAgeRange = try values.decode(Int.self, forKey: .minAgeRange)
    self.maxAgeRange = try values.decode(Int.self, forKey: .maxAgeRange)
    self.location = try values.decode(LocationObject.self, forKey: .location)
  }
}

enum MatchingDemographicsKeys: String, CodingKey {
  case gender
  case age
  case location
}

class MatchingDemographics: Decodable {
  
  static let graphQLMatchingDemographicsFields = "{ gender age location \(LocationObject.graphQLLocationFields) }"
  
  var gender: GenderEnum
  var age: Int!
  var location: LocationObject!
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MatchingDemographicsKeys.self)
    guard let gender = GenderEnum.init(rawValue: try values.decode(String.self, forKey: .gender)) else {
      throw DecodingError.enumError
    }
    self.gender = gender
    self.age = try values.decode(Int.self, forKey: .age)
    self.location = try values.decode(LocationObject.self, forKey: .location)
  }
}
