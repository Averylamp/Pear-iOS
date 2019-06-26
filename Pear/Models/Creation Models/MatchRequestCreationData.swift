//
//  MatchRequestCreationData.swift
//  Pear
//
//  Created by Brian Gu on 6/25/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class MatchRequestCreationData: GraphQLInput {
  
  var sentByUserID: String
  var sentForUserID: String
  var receivedByUserID: String
  var requestText: String?
  var photo: ImageContainer?
  var prompt: QuestionResponseItem?
  
  init(sentByUserID: String,
       sentForUserID: String,
       receivedByUserID: String,
       requestText: String? = nil,
       photo: ImageContainer? = nil,
       prompt: QuestionResponseItem? = nil) {
    self.sentByUserID = sentByUserID
    self.sentForUserID = sentForUserID
    self.receivedByUserID = receivedByUserID
    self.requestText = requestText
    self.photo = photo
    self.prompt = prompt
  }
  
  func toGraphQLInput() -> [String: Any] {
    var requestInput: [String: Any] = [
      "sentByUser_id": self.sentByUserID,
      "sentForUser_id": self.sentForUserID,
      "receivedByUser_id": self.receivedByUserID
    ]
    if let requestText = self.requestText {
      requestInput["requestText"] = requestText
    }
    if let photo = self.photo {
      requestInput["likedPhoto"] = photo.dictionary
    } else if let prompt = self.prompt {
      requestInput["likedPrompt"] = prompt.toGraphQLInput()
    }
    return requestInput
  }
  
}
