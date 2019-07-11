//
//  PearUser.swift
//  Pear
//
//  Created by Avery Lamp on 2019-3-4.
//  Copyright © 2019 Pear. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class PearUser: CustomStringConvertible, GraphQLDecodable, Codable {
  
  static func graphQLCurrentUserFields() -> String {
    return "{ _id deactivated firebaseAuthID email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate questionResponses \(QuestionResponseItem.graphQLAllFields()) school schoolYear schoolEmail schoolEmailVerified displayedImages \(ImageContainer.graphQLAllFields()) bankImages \(ImageContainer.graphQLAllFields()) isSeeking pearPoints endorsedUser_ids endorser_ids detachedProfile_ids matchingPreferences \(MatchingPreferences.graphQLAllFields()) matchingDemographics \(MatchingDemographics.graphQLAllFields()) }"  }
  
  static func graphQLAllFields() -> String {
    return "{ _id deactivated firebaseAuthID email emailVerified phoneNumber phoneNumberVerified firstName lastName fullName thumbnailURL gender age birthdate questionResponses \(QuestionResponseItem.graphQLAllFields()) school schoolYear schoolEmail schoolEmailVerified displayedImages \(ImageContainer.graphQLAllFields()) isSeeking pearPoints endorsedUser_ids endorser_ids detachedProfile_ids matchingPreferences \(MatchingPreferences.graphQLAllFields()) matchingDemographics \(MatchingDemographics.graphQLAllFields()) }"
    
  }
  
  var documentID: String!
  var deactivated: Bool!
  var firebaseAuthID: String!
  var email: String?
  var emailVerified: Bool?
  var phoneNumber: String!
  var phoneNumberVerified: Bool!
  var firstName: String?
  var lastName: String?
  func fullName() -> String {
      var returnName = ""
      if let firstName = firstName {
        returnName += firstName
      }
      if let lastName = lastName {
        if returnName.count > 0 {
          returnName += " " + lastName
        } else {
          returnName += lastName
        }
      }
      if returnName.count == 0 {
        returnName = "No Name"
      }
      return returnName
  }
  var thumbnailURL: String?
  var gender: GenderEnum?
  var age: Int?
  var birthdate: Date?
  
  var questionResponses: [QuestionResponseItem] = []
  
  var school: String?
  var schoolYear: String?
  var schoolEmail: String?
  var schoolEmailVerified: String?
  
  var displayedImages: [ImageContainer] = []
  var bankImages: [ImageContainer] = []
  
  var isSeeking: Bool!
  var pearPoints: Int!
  
  var endorsedUserIDs: [String] = []
  var endorserIDs: [String] = []
  var detachedProfileIDs: [String] = []
  
  var matchingDemographics: MatchingDemographics!
  var matchingPreferences: MatchingPreferences!
  
  init() {
    fatalError("Should never be called to generate")
  }
  
  var description: String {
    return "**** Pear User **** \n" + """
    documentID: \(String(describing: documentID)),
    deactivated: \(String(describing: deactivated)),
    firebaseAuthID: \(String(describing: firebaseAuthID)),
    email: \(String(describing: email)),
    emailVerified: \(String(describing: emailVerified)),
    phoneNumber: \(String(describing: phoneNumber)),
    phoneNumberVerified: \(String(describing: phoneNumberVerified)),
    firstName: \(String(describing: firstName)),
    lastName: \(String(describing: lastName)),
    fullName: \(String(describing: fullName)),
    thumbnailURL: \(String(describing: thumbnailURL)),
    gender: \(String(describing: gender)),
    school: \(String(describing: school)),
    schoolEmail: \(String(describing: schoolEmail)),
    schoolEmailVerified: \(String(describing: schoolEmailVerified)),
    birthdate: \(String(describing: birthdate)),
    age: \(String(describing: age)),
    questionResponses: \(String(describing: self.questionResponses))
    
    """
  }
  
  func toSlackStorySummary(profileStats: Bool = false, currentUserStats: Bool = false) -> String {
    var text = ""
    let ppiFirstName = SlackHelper.colors[abs(self.documentID.hash) % SlackHelper.colors.count]
    text += ppiFirstName.firstCapitalized + " "
    let ppiLastName = SlackHelper.animalNames[abs(self.documentID.hash) % SlackHelper.animalNames.count]
    text += ppiLastName.firstCapitalized + ". "
    if let age = self.age {
      text += "(\(age)) "
    }
    if let gender = self.gender {
      text += gender.toString() + " "
    }
    if profileStats == true {
      text += "\n"
      let profileStats = "Images: \(self.displayedImages.count), Prompts: \(self.questionResponses.count), Friends: \(self.endorsedUserIDs.count)"
      text += profileStats
    }
    if currentUserStats == true {
      text +=  "\n"
      let unreadMessages = DataStore.shared.currentMatches.filter({ if
        let lastMessage = $0.chat?.messages.last,
        let lastOpened = $0.chat?.lastOpenedDate
      {
        let unread = lastOpened.compare(lastMessage.timestamp) == .orderedAscending
        return unread
        }
        return false
      }).count
      let userStats = "App Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String), \(DataStore.shared.detachedProfiles.count > 0 ? "Detached Profiles: \(DataStore.shared.detachedProfiles.count)" : "") "
      text += userStats
    }
    return text
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: PearUserKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.deactivated = try values.decode(Bool.self, forKey: .deactivated)
    self.firebaseAuthID = try values.decode(String.self, forKey: .firebaseAuthID)
    self.email = try? values.decode(String.self, forKey: .email)
    self.emailVerified = try? values.decode(Bool.self, forKey: .emailVerified)
    self.phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
    self.phoneNumberVerified = try values.decode(Bool.self, forKey: .phoneNumberVerified)
    self.firstName = try? values.decode(String.self, forKey: .firstName)
    self.lastName = try? values.decode(String.self, forKey: .lastName)
    self.thumbnailURL = try? values.decode(String.self, forKey: .thumbnailURL)
    self.gender = try? values.decode(GenderEnum.self, forKey: .gender)
    let birthdateValue = try? values.decode(String.self, forKey: .birthdate)
    if let birthdateValue = birthdateValue, let birthdateNumberValue = Double(birthdateValue) {
      self.birthdate = Date(timeIntervalSince1970: birthdateNumberValue / 1000)
    }
    self.age = try? values.decode(Int.self, forKey: .age)
    
    self.questionResponses = try values.decode([QuestionResponseItem].self, forKey: .questionResponses)

    self.school = try? values.decode(String.self, forKey: .school)
    self.schoolYear = try? values.decode(String.self, forKey: .schoolYear)
    self.schoolEmail = try? values.decode(String.self, forKey: .schoolEmail)
    self.schoolEmailVerified = try? values.decode(String.self, forKey: .schoolEmailVerified)
    
    self.isSeeking = try values.decode(Bool.self, forKey: .isSeeking)
    self.pearPoints = try values.decode(Int.self, forKey: .pearPoints)
    
    self.endorsedUserIDs = try values.decode([String].self, forKey: .endorsedUserIDs)
    self.endorserIDs = try values.decode([String].self, forKey: .endorserIDs)
    self.detachedProfileIDs = try values.decode([String].self, forKey: .detachedProfileIDs)
    
    self.displayedImages = try values.decode([ImageContainer].self, forKey: .displayedImages)
    if let bankImages = try? values.decode([ImageContainer].self, forKey: .bankImages) {
      self.bankImages = bankImages
    }
    
    self.matchingDemographics = try values.decode(MatchingDemographics.self, forKey: .matchingDemographics)
    self.matchingPreferences = try values.decode(MatchingPreferences.self, forKey: .matchingPreferences)
    
  }

}

// MARK: - Encoding
extension PearUser {
 
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: PearUserKeys.self)
    try container.encode(self.documentID, forKey: .documentID)
    try container.encode(self.deactivated, forKey: .deactivated)
    try container.encode(self.firebaseAuthID, forKey: .firebaseAuthID)
    try container.encode(self.email, forKey: .email)
    try container.encode(self.emailVerified, forKey: .emailVerified)
    try container.encode(self.phoneNumber, forKey: .phoneNumber)
    try container.encode(self.phoneNumberVerified, forKey: .phoneNumberVerified)
    try container.encode(self.firstName, forKey: .firstName)
    try container.encode(self.lastName, forKey: .lastName)
    try container.encode(self.thumbnailURL, forKey: .thumbnailURL)
    try container.encode(self.gender, forKey: .gender)
    if let birthdayValue = self.birthdate?.timeIntervalSince1970 {
      try container.encode(birthdayValue * 1000.0, forKey: .birthdate)
    }
    try container.encode(self.age, forKey: .age)
    try container.encode(self.questionResponses, forKey: .questionResponses)
    try container.encode(self.school, forKey: .school)
    try container.encode(self.schoolYear, forKey: .schoolYear)
    try container.encode(self.schoolEmail, forKey: .schoolEmail)
    try container.encode(self.schoolEmailVerified, forKey: .schoolEmailVerified)
    try container.encode(self.isSeeking, forKey: .isSeeking)
    try container.encode(self.pearPoints, forKey: .pearPoints)
    try container.encode(self.endorsedUserIDs, forKey: .endorsedUserIDs)
    try container.encode(self.endorserIDs, forKey: .endorserIDs)
    try container.encode(self.detachedProfileIDs, forKey: .detachedProfileIDs)
    try container.encode(self.displayedImages, forKey: .displayedImages)
    try container.encode(self.bankImages, forKey: .bankImages)
    try container.encode(self.matchingDemographics, forKey: .matchingDemographics)
    try container.encode(self.matchingPreferences, forKey: .matchingPreferences)
  }

}

// MARK: - Helpers
extension PearUser {
  
  func getThumbnailURL() -> URL? {
    if let urlString = self.thumbnailURL,
      let url = URL(string: urlString) {
      return url
    }
    if let urlString = self.displayedImages.first?.thumbnail.imageURL,
      let url = URL(string: urlString) {
      return url
    }
    return nil
  }
  
}
