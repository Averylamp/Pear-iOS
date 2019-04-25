//
//  QuestionResponseItem.swift
//  Pear
//
//  Created by Avery Lamp on 4/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
enum QuestionResponseItemKey: String, CodingKey {
  case documentID = "_id"
  case authorID = "author_id"
  case authorFirstName
  case questionID = "question_id"
  case question
  case responseBody
  case responseTitle
  case color
  case icon
  case hidden
}

class QuestionResponseItem: Decodable, GraphQLInput, AuthorGraphQLInput, GraphQLDecodable {
  static func graphQLAllFields() -> String {
    return "{ _id author_id authorFirstName question_id question \(QuestionItem.graphQLAllFields()) responseBody responseTitle color \(Color.graphQLAllFields()) icon \(IconAsset.graphQLAllFields()) hidden }"
  }
  
  var documentID: String?
  var authorID: String
  var authorFirstName: String
  var questionID: String
  var question: QuestionItem
  var responseBody: String
  var responseTitle: String?
  var color: Color?
  var icon: IconAsset?
  var hidden: Bool
  
  init( documentID: String?,
        question: QuestionItem,
        responseBody: String,
        responseTitle: String?,
        color: Color?,
        icon: IconAsset?) throws {
    
    self.documentID = documentID
    self.authorID = ""
    self.authorFirstName = ""
    guard let questionID = question.documentID else {
      print("Question without ID cant be saved")
      throw QuestionItemError.missingEssentialInformation
    }
    self.questionID = questionID
    self.question = question
    self.responseBody = responseBody
    self.responseTitle = responseTitle
    self.color = color
    self.icon = icon
    self.hidden = false
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: QuestionResponseItemKey.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.authorID = try values.decode(String.self, forKey: .authorID)
    self.authorFirstName = try values.decode(String.self, forKey: .authorFirstName)
    self.questionID = try values.decode(String.self, forKey: .questionID)
    self.question = try values.decode(QuestionItem.self, forKey: .question)
    self.responseBody = try values.decode(String.self, forKey: .responseBody)
    self.responseTitle = try? values.decode(String.self, forKey: .responseTitle)
    self.color = try? values.decode(Color.self, forKey: .color)
    self.icon = try? values.decode(IconAsset.self, forKey: .icon)
    self.hidden = try values.decode(Bool.self, forKey: .hidden)
  }
  
  func updateAuthor(authorID: String, authorFirstName: String) {
    self.authorID = authorID
    self.authorFirstName = authorFirstName
  }
  
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      QuestionResponseItemKey.authorID.rawValue: authorID,
      QuestionResponseItemKey.authorFirstName.rawValue: authorFirstName,
      QuestionResponseItemKey.questionID.rawValue: questionID,
      QuestionResponseItemKey.question.rawValue: question.toGraphQLInput(),
      QuestionResponseItemKey.responseBody.rawValue: responseBody,
      QuestionResponseItemKey.hidden.rawValue: hidden
    ]
    if let documentID = self.documentID {
      input[QuestionResponseItemKey.documentID.rawValue] = documentID
    }
    if let responseTitle = self.responseTitle {
      input[QuestionResponseItemKey.responseTitle.rawValue] = responseTitle
    }
    if let color = self.color {
      input[QuestionResponseItemKey.color.rawValue] = color
    }
    if let icon = self.icon {
      input[QuestionResponseItemKey.icon.rawValue] = icon
    }
    return input
  }
  
}