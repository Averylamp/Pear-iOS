//
//  PearChatAPI.swift
//  Pear
//
//  Created by Avery Lamp on 3/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseFirestore
import CodableFirebase

class PearChatAPI: ChatAPI {
  
  static let shared = PearChatAPI()
  
  private init() {
    
  }
  
  let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
  ]
  
  static let getAllChatsQuery: String = ""
}

// MARK: Routes
extension PearChatAPI {
  
  func getFirebaseChatObject(firebaseDocumentPath: String, completion: @escaping (Result<Chat, ChatAPIError>) -> Void) {
    print("Fetching Firebase chat: \(firebaseDocumentPath)")
    let chat = Firestore.firestore().document(firebaseDocumentPath)
    chat.getDocument { (document, error) in
      if let error = error {
        print("Error fetching test Chat object: \(error)")
        completion(.failure(ChatAPIError.firebaseError(error: error)))
        return
      }
      if let document = document,
        var documentData = document.data() {
        documentData["documentID"] = document.documentID
        documentData["documentPath"] =  firebaseDocumentPath
        do {
          let chatObject = try FirestoreDecoder().decode(Chat.self, from: documentData)
          chatObject.initialMessagesFetch(completion: { (chat) in
            if let chat = chat {
              completion(.success(chat))
            } else {
              completion(.failure(ChatAPIError.failedInitialMessagesFetching))
            }
          })
        } catch {
          print("Error deserializing chat object")
          print(error)
          completion(.failure(ChatAPIError.unknownError(error: error)))
        }
      }
    }
  }
  
}
