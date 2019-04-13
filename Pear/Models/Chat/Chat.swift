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

protocol ChatDelegate: class {
  func receivedNewMessages()
}

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

class Chat: Decodable, CustomStringConvertible {
  
  weak var delegate: ChatDelegate?
  
  let documentID: String
  let documentPath: String
  let type: ChatType
  let lastActivity: Date
  var messages: [Message] = []
  let firstPersonID: String
  let secondPersonID: String
  let firstPersonLastOpened: Date
  let secondPersonLastOpened: Date
  var lastOpenedDate: Date
  
  var isSubscribed = false
  
  static let messageBatchSizePaginated: Int = 100
  static let messageBatchSizeInitial: Int = 100
  
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
    
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get user")
      throw MatchesAPIError.failedDeserialization
    }
    self.lastOpenedDate = self.firstPersonID == userID ? self.firstPersonLastOpened : self.secondPersonLastOpened
    self.subscribeToMessages()
  }
  
  func addMessage(message: Message, feedback: Bool = false) -> Bool {
    if !self.messages.contains(where: { $0.documentID == message.documentID}) {
      self.messages.append(message)
      self.messages.sort { if $0.timestamp.compare($1.timestamp) == .orderedAscending {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .medium)
        return true
      } else if $0.timestamp.compare($1.timestamp) == .orderedDescending {
        return false
        }
        return $0.documentID < $1.documentID
      }
      if feedback {
        HapticFeedbackGenerator.generateHapticFeedbackImpact(style: .medium)
      }
      return true
    }
    return false
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
  
  func getSubscriptionMessageQuery(fromMessage: Message?) -> Query {
    if let message = self.messages.first {
      return Firestore.firestore().collection("/\(self.documentPath)/messages")
        .order(by: MessageKeys.timestamp.stringValue, descending: false)
        .order(by: MessageKeys.documentID.stringValue, descending: false)
        .start(at: [Timestamp(date: message.timestamp), message.documentID])
    } else {
      return Firestore.firestore().collection("/\(self.documentPath)/messages")
        .order(by: "timestamp", descending: true)
    }
  }
  
  func subscribeToMessages() {
    guard !isSubscribed else {
      print("Already subscribed to messages")
      return
    }
    self.isSubscribed = true
    let subscriptionQuery = self.getSubscriptionMessageQuery(fromMessage: self.messages.last)
    subscriptionQuery.addSnapshotListener { (snapshot, error) in
      if let error = error {
        print("Error getting message query documents: \(error)")
        return
      }
      
      if let snapshot = snapshot {
        var messagesReceived = false
        for document in snapshot.documents {
          do {
            let message = try FirestoreDecoder().decode(Message.self, from: document.data())
            guard let userID = DataStore.shared.currentPearUser?.documentID else {
              print("User not found")
              return
            }
            message.configureMessageForID(userID: userID)
            if self.addMessage(message: message, feedback: true) {
              messagesReceived = true
            }
          } catch {
            print("Error Deserializing Message Object")
            print(error)
          }
        }
        if messagesReceived {
          if let delegate = self.delegate {
            delegate.receivedNewMessages()
          }
          NotificationCenter.default.post(name: .refreshChatsTab, object: nil)
        }
      }
      
    }
  }
  
  func sendMessage(text: String, completion: ((Error?) -> Void)?) {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Pear user not found:")
      return
    }
    let otherUserID = userID == firstPersonID ? secondPersonID : firstPersonID
    let messageRef = Firestore.firestore().collection("\(self.documentPath)/messages").document()
    messageRef.setData([
      "documentID": messageRef.documentID,
      "sender_id": userID,
      "contentType": "TEXT",
      "type": "USER_MESSAGE",
      "content": text,
      "timestamp": Date()
      ], completion: completion)
    
    PearMatchesAPI.shared.sendNotification(fromID: userID, toID: otherUserID) { (result) in
      switch result {
      case .success(let successful):
        if successful {
          print("Successfully sent notification")
        } else {
          print("Failed to send notification")
        }
      case .failure(let error):
        print("Error sending notification: :\(error)")
      }
    }
  }
  
  func updateLastSeenTime(completion: ((Error?) -> Void)?) {
    guard let userID = DataStore.shared.currentPearUser?.documentID else {
      print("Failed to get user")
      return
    }
    self.lastOpenedDate = Date()
    let updateDateKey = self.firstPersonID == userID ? "firstPersonLastOpened" : "secondPersonLastOpened"
    Firestore.firestore().document(self.documentPath).updateData([
      updateDateKey: self.lastOpenedDate
      ], completion: completion)
  }
  
}
