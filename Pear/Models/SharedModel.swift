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

class LocationObject: Decodable, Equatable, GraphQLDecodable {
  
  static func graphQLAllFields() -> String {
    return "{ coords locationName }"
  }
  
  static func == (lhs: LocationObject, rhs: LocationObject) -> Bool {
    return lhs.locationName == rhs.locationName
  }
  
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
