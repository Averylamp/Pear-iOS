//
//  ProfileCreationData.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum ProfileCreationKey: String {
  case phoneNumber
  case firstName
  case lastName
  case boasts
  case roasts
  case questionResponses
  case vibes
}

class ProfileCreationData: GraphQLInput {
  
  var phoneNumber: String
  var firstName: String
  var lastName: String
  var boasts: [BoastItem] = []
  var roasts: [RoastItem] = []
  var questionResponses: [QuestionResponseItem] = []
  var vibes: [VibeItem] = []
  
  init(contactListItem: ContactListItem) {
    self.phoneNumber = contactListItem.phoneNumber
    self.firstName = contactListItem.firstName
    self.lastName = contactListItem.lastName
  }
  
  func toGraphQLInput() -> [String: Any] {
    let input: [String: Any] = [
      ProfileCreationKey.phoneNumber.rawValue: self.phoneNumber as Any,
      ProfileCreationKey.firstName.rawValue: self.firstName as Any,
      ProfileCreationKey.lastName.rawValue: self.lastName as Any,
      ProfileCreationKey.boasts.rawValue: self.boasts.map({ $0.toGraphQLInput() }),
      ProfileCreationKey.roasts.rawValue: self.roasts.map({ $0.toGraphQLInput() }),
      ProfileCreationKey.questionResponses.rawValue: self.questionResponses.map({ $0.toGraphQLInput() }),
      ProfileCreationKey.vibes.rawValue: self.vibes.map({ $0.toGraphQLInput() })
    ]
    return input
  }
  
}
