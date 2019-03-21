//
//  Message.swift
//  Pear
//
//  Created by Avery Lamp on 3/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

enum MessageDecodingError: Error {
  case enumDecodingError
}

enum MessageType: String, Codable {
  case SERVER_MESSAGE
  case MATCHMAKER_REQUEST
  case PERSONAL_REQUEST
  case USER_MESSAGE
}

enum MessageContentType: String, Codable {
  case TEXT
  case POKE
  case IMAGE
  case GIF
}

enum MessageKeys: String, CodingKey {
  case documentID
  case senderID = "sender_id"
  case type
  case contentType
  case content
  case timestamp
}

class Message: Codable, CustomStringConvertible {
 
  let documentID: String!
  let senderID: String?
  let type: MessageType!
  let contentType: MessageContentType!
  let content: String!
  let timestamp: Date!
  
  var description: String {
    return "**** Message ****\n" + """
    documentID: \(String(describing: self.documentID!)),
    senderID: \(String(describing: self.senderID)),
    type: \(String(describing: self.type!)),
    contentType: \(String(describing: self.contentType!)),
    content: \(String(describing: self.content!)),
    timestamp: \(String(describing: self.timestamp!)),
    """
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MessageKeys.self)
   
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.senderID = try? values.decode(String.self, forKey: .senderID)
    guard let type = MessageType.init(rawValue: try values.decode(String.self, forKey: .type)) else { throw MessageDecodingError.enumDecodingError }
    self.type = type
    guard let contentType = MessageContentType.init(rawValue: try values.decode(String.self, forKey: .contentType)) else { throw MessageDecodingError.enumDecodingError }
    self.contentType = contentType
    self.content = try values.decode(String.self, forKey: .content)
    self.timestamp = try values.decode(Timestamp.self, forKey: .timestamp).dateValue()
    
  }
  
}
