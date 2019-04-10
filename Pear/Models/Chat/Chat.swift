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
  case documentID = "documentID"
  case documentPath
  case type
  case lastActivity
  case messages
  case firstPersonID = "firstPerson_id"
  case secondPersonID = "secondPerson_id"
  case firstPersonLastOpened
  case secondPersonLastOpened
}

class Chat: Codable, CustomStringConvertible {
  
  let documentID: String
  let documentPath: String
  let type: ChatType
  let lastActivity: Date
  var messages: [Message] = []
  let firstPersonID: String
  let secondPersonID: String
  let firstPersonLastOpened: Date
  let secondPersonLastOpened: Date
  
  static let messageBatchSizePaginated: Int = 60
  static let messageBatchSizeInitial: Int = 30
  
  var description: String {
    return "**** Chat ****\n" + """
    documentID: \(String(describing: self.documentID)),
    documentPath: \(String(describing: self.documentPath)),
    type: \(String(describing: self.type)),
    lastActivity: \(String(describing: self.lastActivity)),
    messageCount: \(String(describing: self.messages.count)),
    firstPersonID: \(String(describing: self.firstPersonID)),
    secondPersonID: \(String(describing: self.secondPersonID)),
    firstPersonLastOpened: \(String(describing: self.firstPersonLastOpened)),
    secondPersonLastOpened: \(String(describing: self.secondPersonLastOpened)),
    """
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: ChatKeys.self)
    self.documentID = try values.decode(String.self, forKey: .documentID)
    self.documentPath = try values.decode(String.self, forKey: .documentPath)
    guard let type = ChatType.init(rawValue: try values.decode(String.self, forKey: .type)) else { throw ChatDecodingError.enumDecodingError}
    self.type = type
    self.lastActivity = try values.decode(Timestamp.self, forKey: .lastActivity).dateValue()
    self.firstPersonID = try values.decode(String.self, forKey: .firstPersonID)
    self.secondPersonID = try values.decode(String.self, forKey: .secondPersonID)
    self.firstPersonLastOpened = try values.decode(Timestamp.self, forKey: .firstPersonLastOpened).dateValue()
    self.secondPersonLastOpened = try values.decode(Timestamp.self, forKey: .secondPersonLastOpened).dateValue()
  }
  
  func addMessage(message: Message) {
    if !self.messages.contains(where: { $0.documentID == message.documentID}) {
      self.messages.append(message)
      self.messages.sort { $0.timestamp.compare($1.timestamp) == .orderedAscending }
    }
  }
  
}

// MARK: - Message Fetching
extension Chat {
  
  func getMessageQuery(batchSize: Int, fromMessage: Message?) -> Query {
    if let message = self.messages.first {
      return Firestore.firestore().collection("/\(self.documentPath)/messages")
        .order(by: MessageKeys.timestamp.stringValue, descending: true)
        .order(by: MessageKeys.documentID.stringValue, descending: true)
        .start(at: [Timestamp(date: message.timestamp), message.documentID])
        .limit(to: Chat.messageBatchSizeInitial)
    } else {
      return Firestore.firestore().collection("/\(self.documentPath)/messages")
        .order(by: "timestamp", descending: true)
        .limit(to: Chat.messageBatchSizeInitial)
    }
  }
  
  func initialMessagesFetch(completion: ((Chat?) -> Void)?) {
    let messageQuery = getMessageQuery(batchSize: Chat.messageBatchSizeInitial, fromMessage: nil)
    self.fetchMessageQuery(query: messageQuery, completion: completion)
  }
  
  func fetchEarlierMessages(completion: ((Chat?) -> Void)?) {
    let messageQuery = getMessageQuery(batchSize: Chat.messageBatchSizePaginated, fromMessage: self.messages.first)
    self.fetchMessageQuery(query: messageQuery, completion: completion)
  }
  
  func fetchMessageQuery(query: Query, completion: ((Chat?) -> Void)?) {
    query.getDocuments { (snapshot, error) in
      if let error = error {
        print("Error getting message query documents: \(error)")
        if let completion = completion {
          completion(nil)
        }
        return
      }
      
      if let snapshot = snapshot {
        for document in snapshot.documents {
          do {
            let message = try FirestoreDecoder().decode(Message.self, from: document.data())
            guard let userID = DataStore.shared.currentPearUser?.documentID else {
              print("User not found")
              return
            }
            message.configureMessageForID(userID: userID)
            self.addMessage(message: message)
          } catch {
            print("Error Deserializing Message Object")
            print(error)
          }
        }
        if let completion = completion {
          completion(self)
        }
      }
      
    }
    
  }
  
}
