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
  
  func getAllChatsForUser(user_id: String, completion: @escaping (Result<[Chat], ChatAPIError>) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: "\(NetworkingConfig.graphQLHost)")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 15.0)

    request.httpMethod = "POST"
    
    request.allHTTPHeaderFields = defaultHeaders
    do {
      
      let fullDictionary: [String: Any] = [
        "query": PearChatAPI.getAllChatsQuery,
        "variables": [
//          "phoneNumber": phoneNumber
        ]
      ]
      
      let data: Data = try JSONSerialization.data(withJSONObject: fullDictionary, options: .prettyPrinted)
      
      request.httpBody = data
      
      let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, _, error) in
        if let error = error {
          print(error as Any)
          completion(.failure(ChatAPIError.unknownError(error: error)))
          return
        } else {
          if  let data = data,
            let json = try? JSON(data: data) {
            do {
              if let profiles = json["data"]["findDetachedProfiles"].array {
//
//                var detachedProfiles: [PearDetachedProfile] = []
//                print("\(profiles.count) Detached profiles found matching your phone number")
//                for profile in profiles {
//                  let pearDetachedProfileData = try profile.rawData()
//                  let pearDetachedUser = try JSONDecoder().decode(PearDetachedProfile.self, from: pearDetachedProfileData)
//                  detachedProfiles.append(pearDetachedUser)
//                }
//                completion(.success(detachedProfiles))
              } else {
//                completion(.failure(ChatAPIError.noDetachedProfilesFound))
              }
            } catch {
              print("Error: \(error)")
              completion(.failure(ChatAPIError.unknownError(error: error)))
              return
            }
          } else {
            print("Failed Conversions")
            completion(.failure(ChatAPIError.failedDeserialization))
            return
          }
        }
      }
      dataTask.resume()
    } catch {
      print(error)
      completion(.failure(ChatAPIError.unknownError(error: error)))
    }
    
  }
  
  func getFirebaseChatObject(firebaseDocumentID: String, completion: @escaping (Result<Chat, ChatAPIError>) -> Void) {
    let chat = Firestore.firestore().collection("chats").document(firebaseDocumentID)
    chat.getDocument { (document, error) in
      if let error = error {
        print("Error fetching test Chat object: \(error)")
        completion(.failure(ChatAPIError.firebaseError(error: error)))
        return
      }
      if let document = document,
        var documentData = document.data() {
        documentData["documentID"] = document.documentID
        do {
          let chatObject = try FirestoreDecoder().decode(Chat.self, from: documentData)
          print(chatObject)
          completion(.success(chatObject))
        } catch {
          print("Error deserializing chat object")
          print(error)
          completion(.failure(ChatAPIError.unknownError(error: error)))
        }
      }
    }
  }
  
}
