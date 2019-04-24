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

class TextContentItem: Decodable, GraphQLDecodable, GraphQLInput, AuthorGraphQLInput {
  static func graphQLAllFields() -> String {
    return "{ _id author_id authorFirstName content hidden }"
  }
  
  let documentID: String? = nil
  var authorID: String
  var authorFirstName: String
  var content: String
  var hidden: Bool
  
  init(content: String, hidden: Bool = false) {
    self.content = content
    self.hidden = hidden
    self.authorFirstName = ""
    self.authorID = ""
  }
  
  func updateAuthor(authorID: String, authorFirstName: String) {
    self.authorID = authorID
    self.authorFirstName = authorFirstName
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
