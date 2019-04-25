//
//  VibeItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum VibeKey: String, CodingKey {
  case documentID = "_id"
  case authorID = "author_id"
  case authorFirstName
  case content
  case color
  case icon
  case hidden
}

class VibeItem: Decodable, GraphQLInput, AuthorGraphQLInput, GraphQLDecodable {
  
  static func graphQLAllFields() -> String {
    return "{ _id author_id authorFirstName content color \(Color.graphQLAllFields()) icon \(IconAsset.graphQLAllFields()) hidden }"
  }
  
  let documentID: String? = nil
  var authorID: String
  var authorFirstName: String
  var content: String
  var color: Color?
  var icon: IconAsset?
  var hidden: Bool = false
  
  init(questionResponse: QuestionSuggestedResponse) {
    self.content = questionResponse.responseBody
    self.color = questionResponse.color
    self.icon = questionResponse.icon
    self.authorID = ""
    self.authorFirstName = ""
  }
  
  func updateAuthor(authorID: String, authorFirstName: String) {
    self.authorID = authorID
    self.authorFirstName = authorFirstName
  }

  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      VibeKey.authorID.rawValue: authorID,
      VibeKey.authorFirstName.rawValue: authorFirstName,
      VibeKey.content.rawValue: content,
      VibeKey.hidden.rawValue: hidden
    ]
    if let documentID = self.documentID {
      input[VibeKey.documentID.rawValue] = documentID
    }

    if let color = self.color {
      input[VibeKey.color.rawValue] = color.toGraphQLInput()
    }
    if let icon = self.icon {
      input[VibeKey.icon.rawValue] = icon.toGraphQLInput()
    }
    return input

  }
  
}
