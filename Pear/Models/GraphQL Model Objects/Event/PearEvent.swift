//
//  PearEvent.swift
//  Pear
//
//  Created by Brian Gu on 5/27/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

class PearEvent: Decodable, CustomStringConvertible, GraphQLDecodable {
  
  static func graphQLAllFields() -> String {
    return "{ _id name startTime endTime }"
  }
  
  var documentID: String!
  var name: String!
  var startTime: Date!
  var endTime: Date!
  
  var description: String {
    return "**** Pear Event **** \n" + """
    documentID: \(String(describing: documentID))
    name: \(String(describing: name))
    startTime: \(String(describing: startTime))
    endTime: \(String(describing: endTime))
    """
  }
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearEventKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.name = try values.decode(String.self, forKey: .name)
    if let startTimeString = try? values.decode(String.self, forKey: .startTime),
      let startTimeValue = Double(startTimeString) {
      self.startTime = Date(timeIntervalSince1970: startTimeValue / 1000.0)
    }
    if let endTimeString = try? values.decode(String.self, forKey: .endTime),
      let endTimeValue = Double(endTimeString) {
      self.endTime = Date(timeIntervalSince1970: endTimeValue / 1000.0)
    }
  }
  
}
