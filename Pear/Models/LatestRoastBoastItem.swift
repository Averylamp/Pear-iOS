//
//  LatestRoastBoastItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/19/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum RoastBoastError: Error {
  case enumDeserialization
}

enum RoastBoastType: String {
  case roast
  case boast
}

enum LatestRoastBoastItemKeys: String, CodingKey {
  case userFirstName
  case creatorFirstName
  case contentText
  case timestamp
  case type
}

class LatestRoastBoastItem: Decodable, Equatable {
  
  var userFirstName: String
  var creatorFirstName: String
  var contentText: String
  var timestamp: Date
  var type: RoastBoastType
  
  init(userFirstName: String,
       creatorFirstName: String,
       contentText: String,
       timestamp: Date,
       type: RoastBoastType) {
    self.userFirstName = userFirstName
    self.creatorFirstName = creatorFirstName
    self.contentText = contentText
    self.timestamp = timestamp
    self.type = type
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LatestRoastBoastItemKeys.self)
    self.userFirstName = try values.decode(String.self, forKey: .userFirstName)
    self.creatorFirstName = try values.decode(String.self, forKey: .creatorFirstName)
    self.contentText = try values.decode(String.self, forKey: .contentText)
    self.timestamp = try values.decode(Timestamp.self, forKey: .timestamp).dateValue()
    
      let typeString = try values.decode(String.self, forKey: .type)
    guard let type = RoastBoastType(rawValue: typeString) else {
      print("Failed to decode type")
      throw RoastBoastError.enumDeserialization
    }
    self.type = type
  }
  
  func copy() -> LatestRoastBoastItem {
    return LatestRoastBoastItem(userFirstName: userFirstName,
                                creatorFirstName: creatorFirstName,
                                contentText: contentText,
                                timestamp: timestamp,
                                type: type)
  }
  
  static func == (lhs: LatestRoastBoastItem, rhs: LatestRoastBoastItem) -> Bool {
    return lhs.userFirstName == rhs.userFirstName &&
    lhs.creatorFirstName == rhs.creatorFirstName &&
    lhs.contentText == rhs.contentText &&
    lhs.type == rhs.type
  }
  
}
