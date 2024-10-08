//
//  Match.swift
//  Pear
//
//  Created by Avery Lamp on 3/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import CodableFirebase
import FirebaseFirestore

enum MatchDecodingError: Error {
  case enumDecodingError
}

enum MatchRequestResponse: String {
  case undecided
  case rejected
  case accepted
}

protocol MatchDelegate: class {
  func chatObjectFetched(chat: Chat)
}

class Match: CustomStringConvertible, Codable {
  
  let documentID: String
  let sentByUser: PearUser
  let sentForUser: PearUser
  let receivedByUser: PearUser
  let sentForUserStatus: MatchRequestResponse
  let sentForUserStatusLastUpdated: Date
  let receivedByUserStatus: MatchRequestResponse
  var receivedByUserStatusLastUpdated: Date
  let firebaseChatDocumentID: String
  let firebaseChatDocumentPath: String
  var chat: Chat?
  var otherUser: PearUser
  var currentUserStatus: MatchRequestResponse
  var otherUserStatus: MatchRequestResponse
  var currentUserLastUpdated: Date
  
  var description: String {
    return "**** Match Object **** \n" + """
    sentByUser: \(String(describing: self.sentByUser))
    sentForUser: \(String(describing: self.sentForUser))
    receivedByUser: \(String(describing: self.receivedByUser))
    sentForUserStatus: \(String(describing: self.sentForUserStatus))
    sentForUserStatusLastUpdated: \(String(describing: self.sentForUserStatusLastUpdated))
    receivedByUserStatus: \(String(describing: self.receivedByUserStatus))
    receivedByUserStatusLastUpdated: \(String(describing: self.receivedByUserStatusLastUpdated))
    firebaseChatDocumentID: \(String(describing: self.firebaseChatDocumentID))
    chat: \(String(describing: self.chat))
    chatPath: \(String(describing: self.firebaseChatDocumentPath))
    """
  }
  
  static let graphQLMatchFields = "{ _id sentByUser \(PearUser.graphQLAllFields()) sentForUser \(PearUser.graphQLAllFields()) receivedByUser \(PearUser.graphQLAllFields()) sentForUserStatus sentForUserStatusLastUpdated receivedByUserStatus receivedByUserStatusLastUpdated firebaseChatDocumentID firebaseChatDocumentPath }"
  
  func fetchFirebaseChatObject(completion: ((Match?) -> Void)?) {
    PearChatAPI.shared.getFirebaseChatObject(firebaseDocumentPath: self.firebaseChatDocumentPath) { (result) in
      switch result {
      case .success(let chat):
        self.chat = chat
        if let completion = completion {
          completion(self)
        }
      case .failure(let error):
        print("Failure finding Chat object: \(error)")
        if let completion = completion {
          completion(nil)
        }
      }
    }
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MatchKeys.self)
    
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.sentByUser = try values.decode(PearUser.self, forKey: .sentByUser)
    self.sentForUser = try values.decode(PearUser.self, forKey: .sentForUser)
    self.receivedByUser = try values.decode(PearUser.self, forKey: .receivedByUser)
    guard let userStatus = MatchRequestResponse.init(rawValue: try values.decode(String.self, forKey: .sentForUserStatus)) else {
      throw MatchDecodingError.enumDecodingError
    }
    self.sentForUserStatus = userStatus
    let sentStatusLastUpdatedString = try? values.decode(String.self, forKey: .sentForUserStatusLastUpdated)
    if let sentStatusLastUpdatedString = sentStatusLastUpdatedString, let sentStatusLastUpdatedDouble = Double(sentStatusLastUpdatedString) {
      self.sentForUserStatusLastUpdated = Date(timeIntervalSince1970: sentStatusLastUpdatedDouble / 1000)
    } else {
      print("Failed to get sent for user status last updated")
      self.sentForUserStatusLastUpdated = Date()
    }
    
    let receivedStatusLastUpdatedString = try? values.decode(String.self, forKey: .receivedByUserStatusLastUpdated)
    if let receivedStatusLastUpdatedString = receivedStatusLastUpdatedString, let receivedStatusLastUpdatedDouble = Double(receivedStatusLastUpdatedString) {
      self.receivedByUserStatusLastUpdated = Date(timeIntervalSince1970: receivedStatusLastUpdatedDouble / 1000)
    } else {
      print("Failed to get received by user status last updated")
      self.receivedByUserStatusLastUpdated = Date()
    }
    
    guard let receivedUserStatus = MatchRequestResponse.init(rawValue: try values.decode(String.self, forKey: .receivedByUserStatus)) else {
      throw MatchDecodingError.enumDecodingError
    }
    self.receivedByUserStatus = receivedUserStatus
    
    let receivedByUserStatusLastUpdatedString = try? values.decode(String.self, forKey: .receivedByUserStatusLastUpdated)
    if let receivedByUserStatusLastUpdatedString = receivedByUserStatusLastUpdatedString,
      let receivedByUserStatusLastUpdatedDouble = Double(receivedByUserStatusLastUpdatedString) {
      self.receivedByUserStatusLastUpdated = Date(timeIntervalSince1970: receivedByUserStatusLastUpdatedDouble / 1000)
    } else {
      print("Failed to get sent for received by user status last updated")
      self.receivedByUserStatusLastUpdated = Date()
    }
    
    self.firebaseChatDocumentID = try values.decode(String.self, forKey: .firebaseChatDocumentID)
    self.firebaseChatDocumentPath = try values.decode(String.self, forKey: .firebaseChatDocumentPath)
    
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Could not find user")
      throw MatchesAPIError.unknown
    }
    
    self.otherUser = self.sentForUser.documentID == userID ? self.receivedByUser : self.sentForUser
    self.currentUserStatus = self.sentForUser.documentID == userID ? self.sentForUserStatus : self.receivedByUserStatus
    self.otherUserStatus = self.sentForUser.documentID == userID ? self.receivedByUserStatus : self.sentForUserStatus
    self.currentUserLastUpdated = self.sentForUser.documentID == userID ? self.sentForUserStatusLastUpdated : self.receivedByUserStatusLastUpdated
  }
  
}

extension Match {
  
  enum MatchKeys: String, CodingKey {
    case documentID = "_id"
    case sentByUser
    case sentForUser
    case receivedByUser
    case sentForUserStatus
    case sentForUserStatusLastUpdated
    case receivedByUserStatus
    case receivedByUserStatusLastUpdated
    case firebaseChatDocumentID
    case firebaseChatDocumentPath
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: MatchKeys.self)
    try container.encode(documentID, forKey: .documentID)
    try container.encode(self.sentByUser, forKey: .sentByUser)
    
  }
  
}
