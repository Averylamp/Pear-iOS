//
//  ProfileCreationData.swift
//  Pear
//
//  Created by Avery Lamp on 4/22/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import Contacts

enum ProfileCreationKey: String {
  case phoneNumber
  case firstName
  case lastName
  case gender
  case boasts
  case roasts
  case questionResponses
  case vibes
}

@objc class ProfileCreationData: NSObject, GraphQLInput, AuthorGraphQLInput {
  
  var phoneNumber: String
  var firstName: String
  var lastName: String
  var gender: GenderEnum?
  var boasts: [BoastItem] = []
  var roasts: [RoastItem] = []
  var questionResponses: [QuestionResponseItem] = []
  var skipCount: Int = 0
  var vibes: [VibeItem] = []
    
  init(contact: CNContact, phoneNumber: String? = nil) {
    if phoneNumber == nil,
      var contactPhoneNumber = contact.phoneNumbers.first?.value.stringValue.filter("0123456789".contains) {
      if contactPhoneNumber.count == 11 && contactPhoneNumber.first == "1" {
        contactPhoneNumber = contactPhoneNumber.substring(fromIndex: 1)
      }
      self.phoneNumber = contactPhoneNumber
    } else {
      self.phoneNumber = phoneNumber!
    }
    self.firstName = contact.givenName
    self.lastName = contact.familyName
  }
  
  func updateAuthor(authorID: String, authorFirstName: String) {
    self.boasts.forEach({ $0.updateAuthor(authorID: authorID, authorFirstName: authorFirstName) })
    self.roasts.forEach({ $0.updateAuthor(authorID: authorID, authorFirstName: authorFirstName) })
    self.questionResponses.forEach({ $0.updateAuthor(authorID: authorID, authorFirstName: authorFirstName) })
    self.vibes.forEach({ $0.updateAuthor(authorID: authorID, authorFirstName: authorFirstName) })
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
  
  func getRandomNextQuestion() -> QuestionItem? {
    var possibleQuestions = DataStore.shared.possibleQuestions.shuffled()
    let originalQuestions = possibleQuestions.map({ $0 })
    let answeredQuestions = self.questionResponses.count
    if answeredQuestions < 2 {
      possibleQuestions = possibleQuestions.filter({ $0.tags.contains("starter")})
    } else if answeredQuestions == 2 || answeredQuestions == 4 || answeredQuestions == 5 {
      possibleQuestions = possibleQuestions.filter({ $0.questionType == .freeResponse})
      if possibleQuestions.count == 0 {
        possibleQuestions = originalQuestions.filter({ $0.questionType == .multipleChoice})
      }
    } else {
        possibleQuestions = possibleQuestions.filter({ $0.questionType == .multipleChoice})
    }
    
    if answeredQuestions == 6 {
      return nil
    }
    
    return possibleQuestions.first(where: { (possibleQuestion) -> Bool in
      return !self.questionResponses.contains(where: { $0.questionID == possibleQuestion.documentID })
    })
  }
  
}
