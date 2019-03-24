//
//  ChatAPI.swift
//  Pear
//
//  Created by Avery Lamp on 3/23/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

enum ChatAPIError: Error {
  case failedDeserialization
  case unknownError(error: Error)
  case firebaseError(error: Error)
}

protocol ChatAPI {
//  func getAllChatsForUser(user_id: String, completion: @escaping (Result<[Chat], ChatAPIError>) -> Void)
  func getFirebaseChatObject(firebaseDocumentID: String, completion: @escaping (Result<Chat, ChatAPIError>) -> Void)
}
