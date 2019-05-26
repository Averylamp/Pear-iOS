//
//  UpdateProfileData.swift
//  Pear
//
//  Created by Avery Lamp on 5/2/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum UpdateProfileError: Error {
  case userNotLoggedIn
}

enum UpdateProfileType {
  case detachedProfile
  case userProfile
}

enum UpdateProfileKeys: String {
  case boasts
  case roasts
  case bio
  case questionResponses
}

class UpdateProfileData: GraphQLInput {
  
  var documentID: String
  let initialBio: BioItem?
  var updatedBio: BioItem?
  let initialRoasts: [RoastItem]
  var updatedRoasts: [RoastItem]
  let initialBoasts: [BoastItem]
  var updatedBoasts: [BoastItem]
  let initialQuestionResponses: [QuestionResponseItem]
  var updatedQuestionResponses: [QuestionResponseItem]
  let updateProfileType: UpdateProfileType
  
  init(documentID: String,
       bio: BioItem?,
       roasts: [RoastItem],
       boasts: [BoastItem],
       questionResponses: [QuestionResponseItem],
       type: UpdateProfileType) {
    self.documentID = documentID
    self.initialBio = bio
    self.updatedBio = bio
    self.initialRoasts = roasts
    self.updatedRoasts = roasts
    self.initialBoasts = boasts
    self.updatedBoasts = boasts
    self.initialQuestionResponses = questionResponses
    self.updatedQuestionResponses = questionResponses
    self.updateProfileType = type
  }
  
  init(pearUser: PearUser) throws {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Could not create Update Profile Data")
      throw UpdateProfileError.userNotLoggedIn
    }
    self.documentID = pearUser.documentID
    let filteredBios = pearUser.bios.filter({ $0.authorID == userID })
    self.initialBio = filteredBios.first?.copy() as? BioItem
    self.updatedBio = filteredBios.first?.copy() as? BioItem
    self.initialRoasts = pearUser.roasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? RoastItem})
    self.updatedRoasts = pearUser.roasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? RoastItem})
    self.initialBoasts = pearUser.boasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? BoastItem})
    self.updatedBoasts = pearUser.boasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? BoastItem})
    self.initialQuestionResponses = pearUser.questionResponses.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? QuestionResponseItem})
    self.updatedQuestionResponses = pearUser.questionResponses.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? QuestionResponseItem})
    self.updateProfileType = .userProfile
  }
  
  init(detachedProfile: PearDetachedProfile) throws {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Could not create Update Profile Data")
      throw UpdateProfileError.userNotLoggedIn
    }
    self.documentID = detachedProfile.documentID
    self.initialBio = detachedProfile.bio?.copy() as? BioItem
    self.updatedBio = detachedProfile.bio?.copy() as? BioItem
    self.initialRoasts = detachedProfile.roasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? RoastItem})
    self.updatedRoasts = detachedProfile.roasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? RoastItem})
    self.initialBoasts = detachedProfile.boasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? BoastItem})
    self.updatedBoasts = detachedProfile.boasts.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? BoastItem})
    self.initialQuestionResponses = detachedProfile.questionResponses.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? QuestionResponseItem})
    self.updatedQuestionResponses = detachedProfile.questionResponses.filter({ $0.authorID == userID }).compactMap({ $0.copy() as? QuestionResponseItem})
    self.updateProfileType = .detachedProfile
  }
  
  func checkForChanges() -> Bool {
    if self.initialBio != self.updatedBio {
      return true
    }
    
    if self.initialRoasts.count != self.updatedRoasts.count {
      return true
    } else {
      for index in 0..<self.initialRoasts.count where self.initialRoasts[index] != self.updatedRoasts[index] {
        return true
      }
    }
    
    if self.initialBoasts.count != self.updatedBoasts.count {
      return true
    } else {
      for index in 0..<self.initialBoasts.count where self.initialBoasts[index] != self.updatedBoasts[index] {
        return true
      }
    }
    
    if self.initialQuestionResponses.count != self.updatedQuestionResponses.count {
      return true
    } else {
      for index in 0..<self.initialQuestionResponses.count where self.initialQuestionResponses[index] != self.updatedQuestionResponses[index] {
        return true
      }
    }
    
    return false
  }
  
  func saveChanges(completion: @escaping ((_ success: Bool) -> Void)) {
    guard let pearUser = DataStore.shared.currentPearUser else {
      print("not logged in!")
      return
    }
    guard let pearUserFirstName = pearUser.firstName else {
      print("user has no first name")
      return
    }
    self.updatedQuestionResponses.forEach({ $0.updateAuthor(authorID: pearUser.documentID, authorFirstName: pearUserFirstName) })
    switch self.updateProfileType {
    case .detachedProfile:
      var updates = self.toGraphQLInput()
      updates["_id"] = self.documentID
      updates["creatorUser_id"] = DataStore.shared.currentPearUser?.documentID ?? ""
      PearProfileAPI.shared.updateDetachedProfile(updates: updates) { (result) in
        switch result {
        case .success(let success):
          print("Update Succeeded")
          completion(success)
        case .failure(let error):
          print("Update Failed: \(error)")
          completion(false)
        }
      }
    case .userProfile:
      var updates = self.toGraphQLInput()
      updates["endorser_id"] = DataStore.shared.currentPearUser?.documentID ?? ""
      updates["user_id"] = self.documentID
      PearProfileAPI.shared.updateEndorsedProfile(updates: updates) { (result) in
        switch result {
        case .success(let success):
          print("Update Succeeded")
          completion(success)
        case .failure(let error):
          print("Update Failed: \(error)")
          completion(false)
        }
      }
    }
  }
  
  func toGraphQLInput() -> [String: Any] {
    var input: [String: Any] = [
      UpdateProfileKeys.boasts.rawValue: self.updatedBoasts.map({ $0.toGraphQLInput() }),
      UpdateProfileKeys.roasts.rawValue: self.updatedRoasts.map({ $0.toGraphQLInput() }),
      UpdateProfileKeys.questionResponses.rawValue: self.updatedQuestionResponses.map({ $0.toGraphQLInput() })
    ]
    if let bio = updatedBio {
      input[UpdateProfileKeys.bio.rawValue] = bio.toGraphQLInput()
    }
    return input
  }
  
}
