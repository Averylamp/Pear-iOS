//
//  TextContentItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum ContentItemError: Error {
  case userNotAuthorized
  case decodingEnumError
}

enum TextContentItemKey: String, CodingKey {
  case documentID = "_id"
  case authorID = "author_id"
  case authorFirstName
  case content
  case hidden
}

class TextContentItem: GraphQLInput {
  let documentID: String? = nil
  var creatorFirstName: String
  var authorID: String
  var authorFirstName: String
  var content: String
  var hidden: Bool
  
  init(creatorFirstName: String, content: String, hidden: Bool = false) throws {
    self.creatorFirstName = creatorFirstName
    self.content = content
    self.hidden = hidden
    guard let creatorID = DataStore.shared.currentPearUser?.documentID,
      let creatorFirstName = DataStore.shared.currentPearUser?.firstName else {
        throw ContentItemError.userNotAuthorized
    }
    self.authorFirstName = creatorFirstName
    self.authorID = creatorID
  }
  
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      TextContentItemKey.authorID.rawValue: self.authorID,
      TextContentItemKey.authorFirstName.rawValue: self.authorFirstName,
      TextContentItemKey.content.rawValue: self.content,
      TextContentItemKey.hidden.rawValue: self.hidden
    ]
    if let docID = self.documentID {
      input[TextContentItemKey.documentID.rawValue] = docID
    }
    return input
  }
  
}
