//
//  Chat.swift
//  Pear
//
//  Created by Avery Lamp on 3/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum ChatType: String, Codable {
  case MATCH
  case ENDORSEMENT
}

enum ChatKeys: String, CodingKey {
  case documentID
  case type
  case mongoDocumentID = "mondoDocument_id"
  case lastActivity
  case messages
  case firstPersonID = "firstPerson_id"
  case secondPersonID = "secondPerson_id"
  case firstPersonLastOpened
  case secondPersonLastOpened
}

class Chat: Codable, CustomStringConvertible {
  
  let documentID: String!
  let type: ChatType!
  let mongoDocumentID: String!
  let lastActivity: Date!
  var messages: [Message] = []
  let firstPersonID: String!
  let secondPersonID: String!
  let firstPersonLastOpened: Date!
  let secondPersonLastOpened: Date!
  
  var description: String {
    return "**** Chat ****\n" + """
    documentID: \(String(describing: self.documentID)),
    type: \(String(describing: self.type)),
    mongoDocumentID: \(String(describing: self.mongoDocumentID)),
    lastActivity: \(String(describing: self.lastActivity)),
    messageCount: \(String(describing: self.messages.count)),
    firstPersonID: \(String(describing: self.firstPersonID)),
    secondPersonID: \(String(describing: self.secondPersonID)),
    firstPersonLastOpened: \(String(describing: self.firstPersonLastOpened)),
    secondPersonLastOpened: \(String(describing: self.secondPersonLastOpened)),
    """
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: ChatKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.type = try values.decode(ChatType.self, forKey: .type)
    self.mongoDocumentID = try values.decode(String.self, forKey: .mongoDocumentID)
    self.lastActivity = try values.decode(Date.self, forKey: .lastActivity)
    self.firstPersonID = try values.decode(String.self, forKey: .firstPersonID)
    self.secondPersonID = try values.decode(String.self, forKey: .secondPersonID)
    self.firstPersonLastOpened = try values.decode(Date.self, forKey: .firstPersonLastOpened)
    self.secondPersonLastOpened = try values.decode(Date.self, forKey: .secondPersonLastOpened)
    
  }
}
