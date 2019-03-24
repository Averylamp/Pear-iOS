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
  case unseen
  case seen
  case rejected
  case accepted
  
}

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
}

class Match: Decodable, CustomStringConvertible {
  
  let documentID: String!
  let sentByUser: PearUser!
  let sentForUser: PearUser!
  let receivedByUser: PearUser!
  let sentForUserStatus: MatchRequestResponse!
  let sentForUserStatusLastUpdated: Date!
  let receivedByUserStatus: MatchRequestResponse!
  let receivedByUserStatusLastUpdated: Date!
  let firebaseChatDocumentID: String!
  var chat: Chat?
  
  var description: String {
    return "**** Match Object **** \n" + """
    sentByUser: \(String(describing: self.sentByUser!))
    sentForUser: \(String(describing: self.sentForUser!))
    receivedByUser: \(String(describing: self.receivedByUser!))
    sentForUserStatus: \(String(describing: self.sentForUserStatus!))
    sentForUserStatusLastUpdated: \(String(describing: self.sentForUserStatusLastUpdated!))
    receivedByUserStatus: \(String(describing: self.receivedByUserStatus!))
    receivedByUserStatusLastUpdated: \(String(describing: self.receivedByUserStatusLastUpdated!))
    firebaseChatDocumentID: \(String(describing: self.firebaseChatDocumentID!))
    chat: \(String(describing: self.chat!))
    """
  }
  
  static let graphQLMatchFields = "{ _id sentByUser \(MatchedPearUser.graphQLMatchedUserFields) sentForUser \(MatchedPearUser.graphQLMatchedUserFields) receivedByUser \(MatchedPearUser.graphQLMatchedUserFields) sentForUserStatus sentForUserStatusLastUpdated receivedByUserStatus receivedByUserStatusLastUpdated firebaseChatDocumentID }"
  
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
    self.sentForUserStatusLastUpdated = try values.decode(Timestamp.self, forKey: .sentForUserStatusLastUpdated).dateValue()
    guard let receivedUserStatus = MatchRequestResponse.init(rawValue: try values.decode(String.self, forKey: .receivedByUserStatus)) else {
      throw MatchDecodingError.enumDecodingError
    }
    self.receivedByUserStatus = receivedUserStatus
    self.receivedByUserStatusLastUpdated = try values.decode(Timestamp.self, forKey: .receivedByUserStatusLastUpdated).dateValue()
    self.firebaseChatDocumentID = try values.decode(String.self, forKey: .firebaseChatDocumentID)
//    self.firebaseChatDocumentID = "DZxANxQpVXZSrcpKJpHG"
    
    self.fetchFirebaseChatObject()
  }
  
  func fetchFirebaseChatObject() {
    PearChatAPI.shared.getFirebaseChatObject(firebaseDocumentID: self.firebaseChatDocumentID) { (result) in
      switch result {
      case .success(let chat):
        self.chat = chat
      case .failure(let error):
        print("Failure finding Chat object: \(error)")
        
      }
    }
    
  }
  
}
