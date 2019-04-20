//
//  LatestRoastBoastItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/19/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum RoastBoastType: String {
  case roast
  case boast
}

class LatestRoastBoastItem {
  
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
  
}
