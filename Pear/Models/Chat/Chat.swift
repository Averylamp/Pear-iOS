//
//  Chat.swift
//  Pear
//
//  Created by Avery Lamp on 3/21/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import SwiftyJSON

enum ChatDecodingError: Error {
  case enumDecodingError
  case badDictionaryError
}

enum ChatType: String, Codable {
  case match = "MATCH"
  case endorsement = "ENDORSEMENT"
}

enum ChatKeys: String, CodingKey {
  case documentID = "document_id"
  case type
  case mongoDocumentID = "mongoDocument_id"
  case lastActivity
  case messages
  case firstPersonID = "firstPerson_id"
  case secondPersonID = "secondPerson_id"
  case firstPersonLastOpened
  case secondPersonLastOpened
}

class Chat: Codable, CustomStringConvertible {
  
  let documentID: String!
  let type: ChatType!
  let mongoDocumentID: String!
  let lastActivity: Date!
  var messages: [Message] = []
  let firstPersonID: String!
  let secondPersonID: String!
  let firstPersonLastOpened: Date!
  let secondPersonLastOpened: Date!
  
  static let messageBatchSizePaginated: Int = 60
  static let messageBatchSizeInitial: Int = 30
  
  var description: String {
    return "**** Chat ****\n" + """
    documentID: \(String(describing: self.documentID!)),
    type: \(String(describing: self.type!)),
    mongoDocumentID: \(String(describing: self.mongoDocumentID!)),
    lastActivity: \(String(describing: self.lastActivity!)),
    messageCount: \(String(describing: self.messages.count)),
    firstPersonID: \(String(describing: self.firstPersonID!)),
    secondPersonID: \(String(describing: self.secondPersonID!)),
    firstPersonLastOpened: \(String(describing: self.firstPersonLastOpened!)),
    secondPersonLastOpened: \(String(describing: self.secondPersonLastOpened!)),
    """
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: ChatKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    guard let type = ChatType.init(rawValue: try values.decode(String.self, forKey: .type)) else { throw ChatDecodingError.enumDecodingError}
    self.type = type
    self.mongoDocumentID = try values.decode(String.self, forKey: .mongoDocumentID)
    self.lastActivity = try values.decode(Timestamp.self, forKey: .lastActivity).dateValue()
    self.firstPersonID = try values.decode(String.self, forKey: .firstPersonID)
    self.secondPersonID = try values.decode(String.self, forKey: .secondPersonID)
    self.firstPersonLastOpened = try values.decode(Timestamp.self, forKey: .firstPersonLastOpened).dateValue()
    self.secondPersonLastOpened = try values.decode(Timestamp.self, forKey: .secondPersonLastOpened).dateValue()
    self.initialMessagesFetch()
  }
  
  init(documentID: String,
       type: ChatType,
       mongoDocumentID: String,
       lastActivity: Date,
       messages: [Message],
       firstPersonID: String,
       secondPersonID: String,
       firstPersonLastOpened: Date,
       secondPersonLastOpened: Date) {
    self.documentID = documentID
    self.type = type
    self.mongoDocumentID = mongoDocumentID
    self.lastActivity = lastActivity
    self.messages = messages
    self.firstPersonID = firstPersonID
    self.secondPersonID = secondPersonID
    self.firstPersonLastOpened = firstPersonLastOpened
    self.secondPersonLastOpened = secondPersonLastOpened
  }
  
}

// MARK: - Message Fetching
extension Chat {
  
  func getMessageQuery(batchSize: Int, fromMessage: Message?) -> Query {
    if let message = self.messages.first {
      return Firestore.firestore().collection("/chats/\(self.documentID!)/messages")
        .order(by: MessageKeys.timestamp.stringValue, descending: true)
        .order(by: MessageKeys.documentID.stringValue, descending: true)
        .start(at: [Timestamp(date: message.timestamp), message.documentID!])
        .limit(to: Chat.messageBatchSizeInitial)
    } else {
      return Firestore.firestore().collection("/chats/\(self.documentID!)/messages")
        .order(by: "timestamp", descending: true)
        .limit(to: Chat.messageBatchSizeInitial)
    }
    
  }
  
  func initialMessagesFetch() {
    let messageQuery = getMessageQuery(batchSize: Chat.messageBatchSizeInitial, fromMessage: nil)
    self.fetchMessageQuery(query: messageQuery)
  }
  
  func fetchEarlierMessages() {
    let messageQuery = getMessageQuery(batchSize: Chat.messageBatchSizePaginated, fromMessage: self.messages.first)
    self.fetchMessageQuery(query: messageQuery)
  }
  
  func fetchMessageQuery(query: Query) {
    query.getDocuments { (snapshot, error) in
      if let error = error {
        print("Error getting message query documents: \(error)")
        return
      }
      
      if let snapshot = snapshot {
        for document in snapshot.documents {
          do {
            print(document.data())
            let message = try FirestoreDecoder().decode(Message.self, from: document.data())
            print(message)
          } catch {
            print("Error Deserializing Message Object")
            print(error)
          }
        }
      }
      
    }
    
  }
  
}

extension Chat {
  
  static func createFakeChat1() -> Chat {
    let documentID = String.randomStringWithLength(len: 20)
    let mongoDocumentID = String.randomStringWithLength(len: 20)
    let firstPersonID = String.randomStringWithLength(len: 20)
    let secondPersonID = String.randomStringWithLength(len: 20)
    
    let matchmakerID = String.randomStringWithLength(len: 20)
    
    let type = ChatType.match
    let lastActivity = Date()
    let messages = [Message.fakeServerMessage(), Message.fakeMatchmakerRequest(senderID: matchmakerID), Message.fakeUserMessage(senderID: firstPersonID, message: "what's up?")]
    let firstPersonLastOpened = Date()
    let secondPersonLastOpened = Date()
    
    return Chat(documentID: documentID,
                type: type,
                mongoDocumentID: mongoDocumentID,
                lastActivity: lastActivity,
                messages: messages,
                firstPersonID: firstPersonID,
                secondPersonID: secondPersonID,
                firstPersonLastOpened: firstPersonLastOpened,
                secondPersonLastOpened: secondPersonLastOpened)
  }
  
  static func createFakeChat2() -> Chat {
    let documentID = String.randomStringWithLength(len: 20)
    let mongoDocumentID = String.randomStringWithLength(len: 20)
    let firstPersonID = String.randomStringWithLength(len: 20)
    let secondPersonID = String.randomStringWithLength(len: 20)
    
    let type = ChatType.match
    let lastActivity = Date()
    let messages = [Message.fakeServerMessage(), Message.fakePersonalRequest(senderID: secondPersonID), Message.fakeUserMessage(senderID: firstPersonID, message: "hey there!")]
    let firstPersonLastOpened = Date()
    let secondPersonLastOpened = Date()
    
    return Chat(documentID: documentID,
                type: type,
                mongoDocumentID: mongoDocumentID,
                lastActivity: lastActivity,
                messages: messages,
                firstPersonID: firstPersonID,
                secondPersonID: secondPersonID,
                firstPersonLastOpened: firstPersonLastOpened,
                secondPersonLastOpened: secondPersonLastOpened)
  }
  
  static func createFakeChat3() -> Chat {
    let documentID = String.randomStringWithLength(len: 20)
    let mongoDocumentID = String.randomStringWithLength(len: 20)
    let firstPersonID = String.randomStringWithLength(len: 20)
    let secondPersonID = String.randomStringWithLength(len: 20)
    
    let type = ChatType.match
    let lastActivity = Date()
    let messages = [Message.fakeServerMessage(), Message.fakeUserMessage(senderID: firstPersonID, message: "Pear me please!")]
    let firstPersonLastOpened = Date()
    let secondPersonLastOpened = Date()
    
    return Chat(documentID: documentID,
                type: type,
                mongoDocumentID: mongoDocumentID,
                lastActivity: lastActivity,
                messages: messages,
                firstPersonID: firstPersonID,
                secondPersonID: secondPersonID,
                firstPersonLastOpened: firstPersonLastOpened,
                secondPersonLastOpened: secondPersonLastOpened)
  }
}
